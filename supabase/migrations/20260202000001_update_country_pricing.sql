-- Update country pricing for therapists
-- Arab therapists: $17 per session
-- Mauritanian therapists: 663 MRU per session

-- Create table if it doesn't exist
CREATE TABLE IF NOT EXISTS country_pricing (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  country_code VARCHAR(10) NOT NULL UNIQUE,
  country_name VARCHAR(100) NOT NULL,
  currency VARCHAR(10) NOT NULL,
  session_price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_country_pricing_code ON country_pricing(country_code);

-- Update Mauritania pricing to 663 MRU (or insert if not exists)
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+222', 'Mauritania', 'MRU', 663.00)
ON CONFLICT (country_code) 
DO UPDATE SET session_price = 663.00;

-- Egypt (already might exist from old migration)
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+20', 'Egypt', 'USD', 17.00)
ON CONFLICT (country_code) DO UPDATE SET session_price = 17.00;

-- Insert/Update all other Arab countries with $17 pricing
INSERT INTO country_pricing (country_code, country_name, currency, session_price) VALUES
  -- Gulf Countries
  ('+966', 'Saudi Arabia', 'USD', 17.00),
  ('+971', 'United Arab Emirates', 'USD', 17.00),
  ('+965', 'Kuwait', 'USD', 17.00),
  ('+974', 'Qatar', 'USD', 17.00),
  ('+973', 'Bahrain', 'USD', 17.00),
  ('+968', 'Oman', 'USD', 17.00),
  
  -- Levant Countries
  ('+962', 'Jordan', 'USD', 17.00),
  ('+964', 'Iraq', 'USD', 17.00),
  ('+963', 'Syria', 'USD', 17.00),
  ('+961', 'Lebanon', 'USD', 17.00),
  
  -- North African Countries
  ('+249', 'Sudan', 'USD', 17.00),
  ('+218', 'Libya', 'USD', 17.00),
  ('+216', 'Tunisia', 'USD', 17.00),
  ('+213', 'Algeria', 'USD', 17.00),
  ('+212', 'Morocco', 'USD', 17.00)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price;

-- Insert/Update default pricing to ensure it's $17
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('default', 'Other Countries', 'USD', 17.00)
ON CONFLICT (country_code) 
DO UPDATE SET session_price = 17.00, currency = 'USD';

-- Add comment to table
COMMENT ON TABLE country_pricing IS 'Pricing per session based on therapist country code (from phone number)';
COMMENT ON COLUMN country_pricing.country_code IS 'International calling code (e.g., +222 for Mauritania, +20 for Egypt)';
COMMENT ON COLUMN country_pricing.session_price IS 'Price per therapy session in the specified currency';
