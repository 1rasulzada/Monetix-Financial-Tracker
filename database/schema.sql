-- Monetix Financial Tracker - Database Schema (PostgreSQL)

-- 1. USERS Table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. ACCOUNTS Table
CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    account_name VARCHAR(50) NOT NULL,
    account_type VARCHAR(20) CHECK (account_type IN ('Debit', 'Credit', 'Cash', 'Savings')),
    balance DECIMAL(12, 2) DEFAULT 0.00,
    currency VARCHAR(5) DEFAULT 'AZN',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_account_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 3. CATEGORIES Table
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    user_id INT, -- NULL if global default category
    category_name VARCHAR(50) NOT NULL,
    type VARCHAR(10) CHECK (type IN ('Income', 'Expense')),
    CONSTRAINT fk_category_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 4. TRANSACTIONS Table
CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    account_id INT NOT NULL,
    category_id INT NOT NULL,
    amount DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    transaction_type VARCHAR(10) CHECK (transaction_type IN ('Income', 'Expense', 'Transfer')),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    CONSTRAINT fk_transaction_account FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    CONSTRAINT fk_transaction_category FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT
);

-- 5. BUDGETS Table
CREATE TABLE budgets (
    budget_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    category_id INT NOT NULL,
    limit_amount DECIMAL(12, 2) NOT NULL CHECK (limit_amount > 0),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    CONSTRAINT fk_budget_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_budget_category FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
);

-- 6. AUDIT_LOGS Table
CREATE TABLE audit_logs (
    log_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);