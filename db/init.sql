-- Personal Finance Bot Database Schema
-- PostgreSQL initialization script

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Expenses Table
CREATE TABLE IF NOT EXISTS expenses (
    id SERIAL PRIMARY KEY,
    telegram_message_id BIGINT,
    date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
    currency VARCHAR(10) DEFAULT 'TRY',
    category VARCHAR(100),
    subcategory VARCHAR(100),
    bank VARCHAR(100),
    payment_method VARCHAR(50),
    description TEXT,
    fingerprint VARCHAR(64) UNIQUE,
    confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
    source VARCHAR(20) CHECK (source IN ('text', 'photo', 'manual')),
    raw_input TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for expenses
CREATE INDEX idx_expenses_date ON expenses(date);
CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_expenses_fingerprint ON expenses(fingerprint);
CREATE INDEX idx_expenses_telegram_id ON expenses(telegram_message_id);

-- Incomes Table
CREATE TABLE IF NOT EXISTS incomes (
    id SERIAL PRIMARY KEY,
    telegram_message_id BIGINT,
    date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
    currency VARCHAR(10) DEFAULT 'TRY',
    category VARCHAR(100),
    source_name VARCHAR(100),
    bank VARCHAR(100),
    description TEXT,
    fingerprint VARCHAR(64) UNIQUE,
    confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
    source VARCHAR(20) CHECK (source IN ('text', 'photo', 'manual')),
    raw_input TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for incomes
CREATE INDEX idx_incomes_date ON incomes(date);
CREATE INDEX idx_incomes_category ON incomes(category);
CREATE INDEX idx_incomes_fingerprint ON incomes(fingerprint);
CREATE INDEX idx_incomes_telegram_id ON incomes(telegram_message_id);

-- Investments Table
CREATE TABLE IF NOT EXISTS investments (
    id SERIAL PRIMARY KEY,
    telegram_message_id BIGINT,
    date DATE NOT NULL,
    transaction_type VARCHAR(10) NOT NULL CHECK (transaction_type IN ('buy', 'sell', 'dividend')),
    asset_type VARCHAR(50) CHECK (asset_type IN ('stock', 'crypto', 'gold', 'forex', 'bond', 'fund', 'other')),
    asset_name VARCHAR(100),
    amount DECIMAL(12,2) NOT NULL,
    quantity DECIMAL(18,8),
    unit_price DECIMAL(18,8),
    currency VARCHAR(10) DEFAULT 'TRY',
    bank VARCHAR(100),
    description TEXT,
    fingerprint VARCHAR(64) UNIQUE,
    confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
    source VARCHAR(20) CHECK (source IN ('text', 'photo', 'manual')),
    raw_input TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for investments
CREATE INDEX idx_investments_date ON investments(date);
CREATE INDEX idx_investments_asset_type ON investments(asset_type);
CREATE INDEX idx_investments_asset_name ON investments(asset_name);
CREATE INDEX idx_investments_fingerprint ON investments(fingerprint);
CREATE INDEX idx_investments_telegram_id ON investments(telegram_message_id);

-- Recurring Payments Table
CREATE TABLE IF NOT EXISTS recurring_payments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    type VARCHAR(50) CHECK (type IN ('subscription', 'bill', 'rent', 'insurance', 'loan', 'other')),
    amount DECIMAL(12,2) CHECK (amount >= 0),
    currency VARCHAR(10) DEFAULT 'TRY',
    due_day INT NOT NULL CHECK (due_day >= 1 AND due_day <= 31),
    category VARCHAR(100),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    last_reminded_at DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for recurring_payments
CREATE INDEX idx_recurring_payments_due_day ON recurring_payments(due_day);
CREATE INDEX idx_recurring_payments_is_active ON recurring_payments(is_active);
CREATE INDEX idx_recurring_payments_last_reminded ON recurring_payments(last_reminded_at);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expenses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_incomes_updated_at BEFORE UPDATE ON incomes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_investments_updated_at BEFORE UPDATE ON investments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_recurring_payments_updated_at BEFORE UPDATE ON recurring_payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert some sample recurring payments (optional)
INSERT INTO recurring_payments (name, type, amount, currency, due_day, category, description) VALUES
('Netflix Aboneliği', 'subscription', 149.99, 'TRY', 1, 'Eğlence', 'Aylık Netflix abonelik ücreti'),
('İnternet Faturası', 'bill', 420.00, 'TRY', 5, 'Fatura', 'Aylık ev internet faturası'),
('Elektrik Faturası', 'bill', 350.00, 'TRY', 10, 'Fatura', 'Aylık elektrik faturası'),
('Doğalgaz Faturası', 'bill', 280.00, 'TRY', 12, 'Fatura', 'Aylık doğalgaz faturası'),
('Spotify Aboneliği', 'subscription', 29.99, 'TRY', 15, 'Eğlence', 'Aylık Spotify Premium aboneliği')
ON CONFLICT DO NOTHING;

-- Grant necessary permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO finance_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO finance_user;
