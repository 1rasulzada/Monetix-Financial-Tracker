-- Monetix Financial Tracker - Triggers & Views

-- 1. TRIGGER: Tranzaksiya əlavə olunduqda hesabın balansını avtomatik yeniləyən funksiya
CREATE OR REPLACE FUNCTION update_account_balance()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.transaction_type = 'Income' THEN
        UPDATE accounts 
        SET balance = balance + NEW.amount 
        WHERE account_id = NEW.account_id;
    ELSIF NEW.transaction_type = 'Expense' THEN
        UPDATE accounts 
        SET balance = balance - NEW.amount 
        WHERE account_id = NEW.account_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_balance
AFTER INSERT ON transactions
FOR EACH ROW
EXECUTE FUNCTION update_account_balance();


-- 2. TRIGGER: Büdcə limiti aşıldıqda avtomatik AUDIT_LOGS-a xəbərdarlıq yazan funksiya
CREATE OR REPLACE FUNCTION check_budget_limit()
RETURNS TRIGGER AS $$
DECLARE
    total_spent DECIMAL(12, 2);
    current_limit DECIMAL(12, 2);
    user_id_var INT;
BEGIN
    -- Tranzaksiyanın aid olduğu istifadəçini tapırıq
    SELECT user_id INTO user_id_var FROM accounts WHERE account_id = NEW.account_id;

    -- Xərc tranzaksiyasıdırsa, həmin kateqoriya üzrə ümumi xərci hesablayırıq
    IF NEW.transaction_type = 'Expense' THEN
        SELECT COALESCE(SUM(amount), 0) INTO total_spent
        FROM transactions t
        JOIN accounts a ON t.account_id = a.account_id
        WHERE a.user_id = user_id_var AND t.category_id = NEW.category_id;

        -- Mövcud büdcə limitini yoxlayırıq
        SELECT limit_amount INTO current_limit
        FROM budgets
        WHERE user_id = user_id_var AND category_id = NEW.category_id;

        -- Əgər xərc limiti keçibsə, audit jurnala xəbərdarlıq düşür
        IF current_limit IS NOT NULL AND total_spent > current_limit THEN
            INSERT INTO audit_logs (user_id, event_type, message)
            VALUES (user_id_var, 'BUDGET_EXCEEDED', 'Xəbərdarlıq: Seçilmiş kateqoriya üzrə aylıq büdcə limiti aşıldı!');
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_budget
AFTER INSERT ON transactions
FOR EACH ROW
EXECUTE FUNCTION check_budget_limit();


-- 3. VIEW: Saytın interfeysi üçün istifadəçinin xərc xülasəsi analitikası
CREATE OR REPLACE VIEW view_user_expense_summary AS
SELECT 
    a.user_id,
    c.category_name,
    SUM(t.amount) AS total_amount,
    COUNT(t.transaction_id) AS transaction_count
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN categories c ON t.category_id = c.category_id
WHERE t.transaction_type = 'Expense'
GROUP BY a.user_id, c.category_name;