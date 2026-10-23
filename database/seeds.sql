-- Monetix Financial Tracker - Test Seed Data

-- 1. Insert Test User
INSERT INTO users (first_name, last_name, email, password_hash) 
VALUES ('Nurlan', 'Rasulzade', 'nurlan@example.com', 'scrypt:32768:8:1$hash_placeholder');

-- 2. Insert Accounts for User (user_id = 1)
INSERT INTO accounts (user_id, account_name, account_type, balance, currency) 
VALUES 
(1, 'Kapital Bank Cashback', 'Debit', 1250.50, 'AZN'),
(1, 'Nağd Pul (Cib)', 'Cash', 180.00, 'AZN'),
(1, 'Qənaət Hesabı', 'Savings', 500.00, 'AZN');

-- 3. Insert Default Categories
INSERT INTO categories (user_id, category_name, type) 
VALUES 
(1, 'Maaş və Gəlir', 'Income'),
(1, 'Qida və Market', 'Expense'),
(1, 'Nəqliyyat', 'Expense'),
(1, 'Kommunal və Xidmətlər', 'Expense'),
(1, 'Əyləncə', 'Expense');

-- 4. Insert Initial Transactions
INSERT INTO transactions (account_id, category_id, amount, transaction_type, description) 
VALUES 
(1, 1, 1500.00, 'Income', 'Aylıq məvacib daxilolması'),
(1, 2, 45.20, 'Expense', 'Bravo Supermarket alış-verişi'),
(2, 3, 12.00, 'Expense', 'Taksi və metro xərci'),
(1, 4, 65.00, 'Expense', 'İnternet və kommunal ödəniş');

-- 5. Insert Budget Limits
INSERT INTO budgets (user_id, category_id, limit_amount, start_date, end_date) 
VALUES 
(1, 2, 400.00, '2026-10-01', '2026-10-31'),
(1, 3, 100.00, '2026-10-01', '2026-10-31');