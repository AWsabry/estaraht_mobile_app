-- Add avg_session_time column to doctors table
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS avg_session_time INTEGER DEFAULT 30;

-- Add comment
COMMENT ON COLUMN doctors.avg_session_time IS 'Average session time in minutes, set during registration';
