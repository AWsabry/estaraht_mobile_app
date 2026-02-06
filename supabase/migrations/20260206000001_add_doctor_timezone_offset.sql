-- Migration: Add timezone_offset_hours column to doctors table
-- Stores the doctor's UTC offset (e.g. 0 for GMT, 2 for Egypt) for timezone-aware scheduling

ALTER TABLE doctors ADD COLUMN IF NOT EXISTS timezone_offset_hours INTEGER DEFAULT 0;

COMMENT ON COLUMN doctors.timezone_offset_hours IS 'Doctor UTC offset in hours (e.g. 0 for GMT, 2 for EET)';
