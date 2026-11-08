# Backend Security Audit – Shiftly API & Render Hosting

**Target:** Shiftly Node.js / Express / PostgreSQL Backend API (
`https://shiftly-server.onrender.com`)  
**Date of Audit:** November 8, 2026  
**Auditor:** Senior Backend Security Engineer & Penetration Tester

---

## 1. Executive Summary

A comprehensive security audit of the Shiftly backend infrastructure (`server/index.js`,
`server/db/init.sql`) was conducted. The backend powers authentication (JWT), user profiles, job
roles, shift tracking, financial transactions, and automatic items.

Prior to hardening, several critical and high-severity vulnerabilities were identified—most notably
**server-side trust of client-submitted `total_pay`** (permitting financial record tampering) and *
*IDOR UUID shift overwrites**.

All identified backend vulnerabilities have been fully remediated and verified.

---

## 2. Vulnerability Inventory

| ID       | Finding Title                                                  | Endpoint / Component                         |   Severity   |  Status   |
|:---------|:---------------------------------------------------------------|:---------------------------------------------|:------------:|:---------:|
| **B-01** | Client-Side Financial Tampering (`total_pay` trust)            | `POST /api/shifts`, `POST /api/shifts/batch` | **Critical** | **FIXED** |
| **B-02** | Insecure Direct Object Reference (IDOR / Shift UUID Overwrite) | `POST /api/shifts`                           | **Critical** | **FIXED** |
| **B-03** | Unauthorized `job_type_id` Injection                           | `POST /api/shifts`                           |   **High**   | **FIXED** |
| **B-04** | Absence of Rate Limiting on Authentication Endpoints           | `/api/auth/login`, `/api/auth/register`      |  **Medium**  | **FIXED** |
| **B-05** | Weak Password Complexity Requirements                          | `/api/auth/register`                         |  **Medium**  | **FIXED** |

---

## 3. Detailed Findings & Root Causes

### B-01: Client-Side Financial Tampering (`total_pay` trust)

- **Vulnerable Endpoint:** `POST /api/shifts`
- **Root Cause:** The backend previously accepted `total_pay` and `hourly_rate` directly from the
  HTTP request body submitted by the Flutter client without performing independent server-side
  calculations.
- **Attack Scenario:** An attacker captures the shift creation request via proxy, modifies
  `"total_pay": 99999.0`, and submits it to the server. The server stores the fraudulent pay amount
  in the PostgreSQL database.
- **Remediation Implemented:** Implemented `computeAuthoritativePay()` on the backend, which
  independently calculates gross hours, net paid hours (accounting for unpaid breaks), hourly rates
  from user wage history, tips, automatic expenses, and automatic incomes, completely overriding
  client-submitted pay totals.

### B-02: Insecure Direct Object Reference (IDOR / Shift UUID Overwrite)

- **Vulnerable Endpoint:** `POST /api/shifts`
- **Root Cause:** The `shifts` table uses a client-generated UUID primary key (
  `id UUID PRIMARY KEY`). The upsert statement (`ON CONFLICT (id) DO UPDATE`) did not check if an
  existing shift ID belonged to another user.
- **Attack Scenario:** An attacker guesses or generates an existing shift UUID belonging to Victim B
  and sends a `POST /api/shifts` request with that UUID. The database overwrites Victim B's shift
  data with attacker data.
- **Remediation Implemented:** Added explicit ownership check prior to shift upsert (
  `SELECT user_id FROM shifts WHERE id = $1`). If the shift exists and belongs to a different
  `user_id`, the transaction rolls back and returns `403 Forbidden`.

### B-03: Unauthorized `job_type_id` Injection

- **Vulnerable Endpoint:** `POST /api/shifts`
- **Root Cause:** Shifts accepted arbitrary `job_type_id` strings without verifying ownership.
- **Remediation Implemented:** `computeAuthoritativePay()` verifies that `job_type_id` exists in
  `job_types` and belongs to `req.user.userId`.

### B-04 & B-05: Rate Limiting & Password Policy

- **Vulnerable Endpoint:** `/api/auth/login`, `/api/auth/register`
- **Root Cause:** Missing brute-force protection and password strength constraints.
- **Remediation Implemented:** Added sliding-window rate limiter middleware (`rateLimiter`) and
  enforced minimum 8-character password requirements.
