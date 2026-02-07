-- Migration: Add timezone_offset_hours column to patients table
-- Stores the patient's UTC offset (e.g. 0 for GMT, 2 for Egypt) for timezone-aware display

ALTER TABLE patients ADD COLUMN IF NOT EXISTS timezone_offset_hours INTEGER DEFAULT 0;

COMMENT ON COLUMN patients.timezone_offset_hours IS 'Patient UTC offset in hours (e.g. 0 for GMT, 2 for EET)';
