-- Setup country pricing for therapists
-- Arab therapists: $17 per session
-- Mauritanian therapists: 663 MRU per session

-- Delete existing pricing data (optional, for clean setup)
-- DELETE FROM country_pricing;

-- Mauritania (+222) - 663 MRU
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+222', 'Mauritania', 'MRU', 663)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price,
  updated_at = NOW();

-- Egypt (+20) - $17
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+20', 'Egypt', 'USD', 17)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price,
  updated_at = NOW();

-- Saudi Arabia (+966) - $17
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+966', 'Saudi Arabia', 'USD', 17)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price,
  updated_at = NOW();

-- UAE (+971) - $17
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+971', 'United Arab Emirates', 'USD', 17)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price,
  updated_at = NOW();

-- Kuwait (+965) - $17
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+965', 'Kuwait', 'USD', 17)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price,
  updated_at = NOW();

-- Qatar (+974) - $17
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+974', 'Qatar', 'USD', 17)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price,
  updated_at = NOW();

-- Bahrain (+973) - $17
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+973', 'Bahrain', 'USD', 17)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price,
  updated_at = NOW();

-- Oman (+968) - $17
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+968', 'Oman', 'USD', 17)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price,
  updated_at = NOW();

-- Jordan (+962) - $17
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+962', 'Jordan', 'USD', 17)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price,
  updated_at = NOW();

-- Iraq (+964) - $17
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+964', 'Iraq', 'USD', 17)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price,
  updated_at = NOW();

-- Syria (+963) - $17
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+963', 'Syria', 'USD', 17)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price,
  updated_at = NOW();

-- Lebanon (+961) - $17
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+961', 'Lebanon', 'USD', 17)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price,
  updated_at = NOW();

-- Sudan (+249) - $17
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+249', 'Sudan', 'USD', 17)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price,
  updated_at = NOW();

-- Libya (+218) - $17
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+218', 'Libya', 'USD', 17)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price,
  updated_at = NOW();

-- Tunisia (+216) - $17
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+216', 'Tunisia', 'USD', 17)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price,
  updated_at = NOW();

-- Algeria (+213) - $17
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+213', 'Algeria', 'USD', 17)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price,
  updated_at = NOW();

-- Morocco (+212) - $17
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+212', 'Morocco', 'USD', 17)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price,
  updated_at = NOW();

-- Default pricing for other countries - $17
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('default', 'Other Countries', 'USD', 17)
ON CONFLICT (country_code) 
DO UPDATE SET 
  currency = EXCLUDED.currency,
  session_price = EXCLUDED.session_price,
  updated_at = NOW();

-- Verify the data
SELECT country_code, country_name, currency, session_price 
FROM country_pricing 
ORDER BY 
  CASE 
    WHEN country_code = '+222' THEN 0  -- Mauritania first
    WHEN country_code = 'default' THEN 999  -- Default last
    ELSE 1 
  END,
  country_name;
