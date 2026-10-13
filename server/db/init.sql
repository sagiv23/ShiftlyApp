-- 1. Users Table (Authentication & User Profile Settings)
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    birth_date DATE,
    automatic_expense_enabled BOOLEAN DEFAULT FALSE,
    automatic_income_enabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Job Types Table (User Work Roles & Wage Rate History)
CREATE TABLE IF NOT EXISTS job_types (
    id VARCHAR(50) NOT NULL,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    hourly_rate DECIMAL(10, 2) DEFAULT 0,
    wage_history JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id, user_id)
);

-- 3. Default Automatic Items Table (User Fixed Expenses & Incomes Rules)
CREATE TABLE IF NOT EXISTS default_automatic_items (
    id VARCHAR(100) NOT NULL,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    is_income BOOLEAN DEFAULT FALSE,
    is_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id, user_id)
);

-- 4. Shifts Table (Work Shifts Record & Shift-Specific Financial Snapshots)
CREATE TABLE IF NOT EXISTS shifts (
    id UUID PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    job_type_id VARCHAR(50),
    date DATE NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    tips DECIMAL(10, 2) DEFAULT 0,
    break_type VARCHAR(20) DEFAULT 'none',
    unpaid_break_minutes DECIMAL(10, 2) DEFAULT 0,
    hourly_rate DECIMAL(10, 2),
    automatic_expenses JSONB,
    automatic_incomes JSONB,
    description TEXT,
    total_pay DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Financial Transactions Table (One-off Expenses & Special Incomes)
CREATE TABLE IF NOT EXISTS financial_transactions (
    id UUID PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    description TEXT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    is_income BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Optimized Performance Indexes for Fast Querying
CREATE INDEX IF NOT EXISTS idx_shifts_user_date ON shifts(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_job_types_user ON job_types(user_id);
CREATE INDEX IF NOT EXISTS idx_financial_trans_user_date ON financial_transactions(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_default_auto_items_user ON default_automatic_items(user_id);
