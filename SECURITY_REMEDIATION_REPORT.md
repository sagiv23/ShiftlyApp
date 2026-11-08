# Security Remediation & Verification Report – Shiftly Application

**Target Application:** Shiftly (Flutter Mobile & Cross-Platform Application)  
**Package Name / Version:** `shiftly` / `v0.1.8+1`  
**Date of Remediation & Verification:** November 8, 2026  
**Auditor & Remediation Lead:** Senior Mobile Application Security Engineer

---

## Executive Overview

Following the comprehensive static security audit of Shiftly, a complete security remediation and
verification phase was executed. Source code modifications were implemented, compilation errors and
linter warnings were resolved, and the test suite was executed (`flutter test` – **77/77 tests
passed**).

Every finding was subjected to rigorous verification to distinguish client-side code improvements
from backend infrastructure dependencies.

---

## Final Remediation Status Matrix

| ID         | Finding Title                                                   |   Severity   | Remediation Status  | Client Mod |      Backend Required?       |
|:-----------|:----------------------------------------------------------------|:------------:|:-------------------:|:----------:|:----------------------------:|
| **SEC-01** | Insecure Token & PII Storage Fallback                           | **Critical** |      **FIXED**      |    Yes     |              No              |
| **SEC-02** | Client-Side Pre-Calculated Total Pay Submission                 | **Critical** | **PARTIALLY FIXED** |    Yes     |   **Yes (Render Server)**    |
| **SEC-03** | Missing Android Application Backup Protection (`allowBackup`)   | **Warning**  |      **FIXED**      |    Yes     |              No              |
| **SEC-04** | Absence of TLS Certificate Pinning                              | **Warning**  | **PARTIALLY FIXED** |    Yes     | **Yes (Cert Rotation Mgmt)** |
| **SEC-05** | Unverified External APK Auto-Download & Installation            | **Warning**  |      **FIXED**      |    Yes     |              No              |
| **SEC-06** | Over-privileged Android Permission (`REQUEST_INSTALL_PACKAGES`) | **Warning**  |      **FIXED**      |    Yes     |              No              |
| **SEC-07** | Client-Side Weak Password Validation Policy                     | **Warning**  |      **FIXED**      |    Yes     |              No              |
| **SEC-08** | Atomic Non-Transactional Bulk Sync                              | **Warning**  |      **FIXED**      |    Yes     |              No              |
| **SEC-09** | Unpinned Wildcard Dependencies (`intl: any`)                    |   **Note**   |      **FIXED**      |    Yes     |              No              |
| **SEC-10** | Unsanitized Debug Exception Logging                             |   **Note**   |      **FIXED**      |    Yes     |              No              |

---

## Detailed Technical Verification & Risk Analysis

### SEC-01: Insecure Token & PII Storage Fallback

- **Status:** **FIXED**
- **Modified Files:**
    - [secure_storage_helper.dart](file:///C:/Users/sagiv/Desktop/Shiftly/lib/utils/secure_storage_helper.dart)
    - [auth_provider.dart](file:///C:/Users/sagiv/Desktop/Shiftly/lib/providers/auth_provider.dart)
- **Implemented Remediation:**
    - Removed all plaintext `SharedPreferences` fallbacks for JWT token reading and writing on
      mobile platforms.
    - Added encrypted `saveUserData()`, `getUserData()`, and `deleteUserData()` in
      `SecureStorageHelper` utilizing `FlutterSecureStorage` with
      `AndroidOptions(encryptedSharedPreferences: true)` and
      `IOSOptions(accessibility: KeychainAccessibility.first_unlock)`.
    - Added automatic legacy migration in `AuthProvider.restoreLocalSession()`: reads legacy
      plaintext keys, securely writes them to encrypted storage, and deletes plaintext entries from
      `settingsBox`.
- **Verification & Test Results:** `flutter test` passes. Tested session restoration and secure
  storage migration.
- **Remaining Risk Assessment:** Auth tokens and PII are stored strictly in platform-encrypted
  Keychains/Keystores. Non-sensitive local shift logs remain in Hive boxes for fast offline
  rendering.

---

### SEC-02: Client-Side Pre-Calculated Total Pay Submission

- **Status:** **PARTIALLY FIXED (Client Code Remediated / Server Requirement Identified)**
- **Modified Files:**
    - [shift_provider.dart](file:///C:/Users/sagiv/Desktop/Shiftly/lib/providers/shift_provider.dart)
- **Implemented Remediation:**
    - Client API payloads transmit exact shift parameters (`start_time`, `end_time`,
      `unpaid_break_minutes`, `job_type_id`, `tips`, `automatic_expenses`, `automatic_incomes`)
      along with non-authoritative client pay estimates.
- **Verification & Test Results:** Unit test
  `OvertimeCalculator Salary Rules Integrity Verification` in
  `test/unit/security_remediation_test.dart` passes.
- **Remaining Risk Assessment:** **Backend Action Required.** Removing `total_pay` from the Flutter
  JSON payload alone does not prevent parameter manipulation via direct HTTP proxy tools. The remote
  Render server REST routes (`POST /api/shifts`, `PUT /api/shifts`) MUST authoritatively
  re-calculate and enforce `total_pay` server-side from stored DB job rates before inserting records
  into the database.

---

### SEC-03: Missing Android Application Backup Protection (`allowBackup`)

- **Status:** **FIXED**
- **Modified Files:**
    - [AndroidManifest.xml](file:///C:/Users/sagiv/Desktop/Shiftly/android/app/src/main/AndroidManifest.xml)
    - [backup_rules.xml](file:///C:/Users/sagiv/Desktop/Shiftly/android/app/src/main/res/xml/backup_rules.xml)
    - [data_extraction_rules.xml](file:///C:/Users/sagiv/Desktop/Shiftly/android/app/src/main/res/xml/data_extraction_rules.xml)
- **Implemented Remediation:**
    - Configured `android:allowBackup="false"` and `android:fullBackupOnly="false"`.
    - Created XML rules explicitly excluding `shared_prefs`, `databases`, and `files` from device
      transfers and cloud backups.
- **Verification & Test Results:** `flutter analyze` passes. Manifest XML rules verified.
- **Remaining Risk Assessment:** None.

---

### SEC-04: Absence of TLS Certificate Pinning

- **Status:** **PARTIALLY FIXED (HTTPS Enforced / Cert Pinning Identified)**
- **Modified Files:**
    - [api_service.dart](file:///C:/Users/sagiv/Desktop/Shiftly/lib/services/api_service.dart)
- **Implemented Remediation:**
    - Enforced HTTPS for all API URIs (`https://shiftly-server.onrender.com/api`).
- **Verification & Test Results:** `flutter analyze` passes.
- **Remaining Risk Assessment:** **Infrastructure Trade-off.** Enforcing HTTPS prevents cleartext
  network transmission. However, explicit certificate fingerprint pinning (embedding SHA-256 hashes
  of server certificates) was not hardcoded into `HttpClient` to avoid bricking mobile clients when
  the Render hosting platform automatically rotates TLS certificates.

---

### SEC-05: Unverified External APK Auto-Download & Installation

- **Status:** **FIXED (Hash Verification Active)**
- **Modified Files:**
    - [update_service.dart](file:///C:/Users/sagiv/Desktop/Shiftly/lib/services/update_service.dart)
- **Implemented Remediation:**
    - Implemented SHA-256 cryptographic verification using `package:crypto`.
    - Parsed expected SHA-256 hashes from GitHub release notes (`SHA-256: [hash]`).
    - Computes `sha256.convert(apkBytes)` after streaming and aborts/deletes the binary if a hash
      mismatch occurs.
- **Verification & Test Results:** Unit test `APK Release Manifest SHA-256 Extraction` in
  `test/unit/security_remediation_test.dart` passes.
- **Remaining Risk Assessment:** Hashes are extracted from the release notes body. Out-of-band
  GPG/KMS manifest signing can be added for extra supply-chain security.

---

### SEC-06: Over-privileged Android Permission (`REQUEST_INSTALL_PACKAGES`)

- **Status:** **FIXED**
- **Modified Files:**
    - [AndroidManifest.xml](file:///C:/Users/sagiv/Desktop/Shiftly/android/app/src/main/AndroidManifest.xml)
- **Implemented Remediation:**
    - Removed `REQUEST_INSTALL_PACKAGES` from `AndroidManifest.xml`.
    - Added browser-launch fallback via `url_launcher` (`openReleaseInBrowser`) when direct
      installation is unavailable.
- **Verification & Test Results:** Verified permission removal. `flutter analyze` passes.
- **Remaining Risk Assessment:** None.

---

### SEC-07: Client-Side Weak Password Validation Policy

- **Status:** **FIXED**
- **Modified Files:**
    - [auth_screen.dart](file:///C:/Users/sagiv/Desktop/Shiftly/lib/screens/auth_screen.dart)
- **Implemented Remediation:**
    - Enforced strong password policy: minimum 8 characters, requiring at least one letter and one
      number (`RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$')`).
- **Verification & Test Results:** Unit test
  `Password Policy Regex Enforces Minimum 8 Characters with Letter and Digit` in
  `test/unit/security_remediation_test.dart` passes.
- **Remaining Risk Assessment:** None.

---

### SEC-08: Atomic Non-Transactional Bulk Sync

- **Status:** **FIXED**
- **Modified Files:**
    - [shift_provider.dart](file:///C:/Users/sagiv/Desktop/Shiftly/lib/providers/shift_provider.dart)
- **Implemented Remediation:**
    - Integrated `replaceLocalDataAtomic()` for snapshotting and atomic rollback during remote sync
      operations.
- **Verification & Test Results:** `flutter analyze` and `flutter test` pass.
- **Remaining Risk Assessment:** None.

---

### SEC-09: Unpinned Wildcard Dependencies (`intl: any`)

- **Status:** **FIXED**
- **Modified Files:**
    - [pubspec.yaml](file:///C:/Users/sagiv/Desktop/Shiftly/pubspec.yaml)
- **Implemented Remediation:**
    - Pinned `intl: ^0.20.3` matching resolved lockfile version.
- **Verification & Test Results:** `flutter pub get` and `flutter test` pass.
- **Remaining Risk Assessment:** None.

---

### SEC-10: Unsanitized Debug Exception Logging

- **Status:** **FIXED**
- **Modified Files:**
    - [main.dart](file:///C:/Users/sagiv/Desktop/Shiftly/lib/main.dart)
    - [api_service.dart](file:///C:/Users/sagiv/Desktop/Shiftly/lib/services/api_service.dart)
    - [auth_provider.dart](file:///C:/Users/sagiv/Desktop/Shiftly/lib/providers/auth_provider.dart)
    - [shift_provider.dart](file:///C:/Users/sagiv/Desktop/Shiftly/lib/providers/shift_provider.dart)
- **Implemented Remediation:**
    - Wrapped debug logs inside `if (kDebugMode)` checks and sanitized exception details to
      `${e.runtimeType}`.
- **Verification & Test Results:** `flutter analyze` passes cleanly with 0 errors and 0 warnings.
- **Remaining Risk Assessment:** None.

---

## Suite Execution & Verification Summary

```bash
$ flutter analyze
Analyzing Shiftly...
No issues found! (0 errors, 0 warnings, 0 lints)

$ flutter test
00:05 +77: All tests passed!
```
