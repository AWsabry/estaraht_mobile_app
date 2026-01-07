-- Create country_pricing table for dynamic session pricing
CREATE TABLE IF NOT EXISTS country_pricing (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  country_code VARCHAR(10) NOT NULL UNIQUE,
  country_name VARCHAR(100) NOT NULL,
  currency VARCHAR(10) NOT NULL,
  session_price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert initial pricing data
INSERT INTO country_pricing (country_code, country_name, currency, session_price) VALUES
  ('+222', 'Mauritania', 'MRU', 600.00),
  ('+20', 'Egypt', 'USD', 17.00),
  ('default', 'Other', 'USD', 17.00)
ON CONFLICT (country_code) DO NOTHING;

-- Add country_code column to doctors table
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS country_code VARCHAR(10);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_country_pricing_code ON country_pricing(country_code);
CREATE INDEX IF NOT EXISTS idx_doctors_country_code ON doctors(country_code);
