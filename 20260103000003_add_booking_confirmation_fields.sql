-- Migration to add confirmation fields to bookings table
-- Run this in your Supabase SQL editor

-- Add confirmation columns to bookings table
ALTER TABLE bookings
ADD COLUMN IF NOT EXISTS doctor_confirmed BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS patient_confirmed BOOLEAN DEFAULT FALSE;

-- Add comments to document the fields
COMMENT ON COLUMN bookings.doctor_confirmed IS 'Whether the doctor has confirmed the session is complete';
COMMENT ON COLUMN bookings.patient_confirmed IS 'Whether the patient has confirmed the session is complete';

-- Update existing bookings
-- Set both to TRUE for already completed sessions
UPDATE bookings
SET
  doctor_confirmed = TRUE,
  patient_confirmed = TRUE
WHERE
  status = 'completed'
  AND (doctor_confirmed IS NULL OR patient_confirmed IS NULL);

-- Create index for faster queries on confirmation status
CREATE INDEX IF NOT EXISTS idx_bookings_confirmations
ON bookings(doctor_confirmed, patient_confirmed)
WHERE status != 'cancelled';
