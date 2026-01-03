-- Add doctor_fee_per_session field to doctors table
-- This field stores the fixed amount (30 USD) that doctors earn per completed session

ALTER TABLE doctors
ADD COLUMN IF NOT EXISTS doctor_fee_per_session DECIMAL(10,2) DEFAULT 30.00;

-- Update existing doctors to have the default fee
UPDATE doctors
SET doctor_fee_per_session = 30.00
WHERE doctor_fee_per_session IS NULL;

-- Add comment to explain the field
COMMENT ON COLUMN doctors.doctor_fee_per_session IS 'Fixed fee in USD that doctor receives per completed session';
