-- Migration to add session management and subscription fields to patients table
-- Run this in your Supabase SQL editor

-- Add new columns to patients table
ALTER TABLE patients
ADD COLUMN IF NOT EXISTS sessions_available INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS sessions_pending INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS subscribed BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS subscribed_before BOOLEAN DEFAULT FALSE;

-- Update existing patients to have default values
UPDATE patients
SET
  sessions_available = 0,
  sessions_pending = 0,
  subscribed = FALSE,
  subscribed_before = FALSE
WHERE
  sessions_available IS NULL
  OR sessions_pending IS NULL
  OR subscribed IS NULL
  OR subscribed_before IS NULL;

-- Add comments to document the fields
COMMENT ON COLUMN patients.sessions_available IS 'Number of sessions available for the patient to book';
COMMENT ON COLUMN patients.sessions_pending IS 'Number of sessions currently booked but not yet completed or canceled';
COMMENT ON COLUMN patients.subscribed IS 'Whether the patient is currently subscribed to a plan';
COMMENT ON COLUMN patients.subscribed_before IS 'Whether the patient has ever subscribed before (determines if 40$ plan is shown)';
