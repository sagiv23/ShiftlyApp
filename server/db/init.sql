-- Create Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Job Types table (linked to users, primary key includes user_id)
CREATE TABLE IF NOT EXISTS job_types (
    id VARCHAR(50) NOT NULL,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    hourly_rate DECIMAL(10, 2),
    wage_history JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id, user_id)
);

-- Create Shifts table (linked to users)
CREATE TABLE IF NOT EXISTS shifts (
    id UUID PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    job_type_id VARCHAR(50),
    date DATE NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    tips DECIMAL(10, 2) DEFAULT 0,
    break_type VARCHAR(20),
    unpaid_break_minutes DECIMAL(10, 2),
    hourly_rate DECIMAL(10, 2),
    automatic_expenses JSONB,
    description TEXT,
    total_pay DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Financial Transactions table (unified for Expenses and Special Incomes)
CREATE TABLE IF NOT EXISTS financial_transactions (
    id UUID PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    description TEXT,
    amount DECIMAL(10, 2) NOT NULL,
    is_income BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Performance & Storage Optimization Indexes (Eliminate Full Table Scans)
CREATE INDEX IF NOT EXISTS idx_shifts_user_id ON shifts(user_id);
CREATE INDEX IF NOT EXISTS idx_shifts_user_date ON shifts(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_job_types_user_id ON job_types(user_id);
CREATE INDEX IF NOT EXISTS idx_financial_transactions_user_id ON financial_transactions(user_id);
