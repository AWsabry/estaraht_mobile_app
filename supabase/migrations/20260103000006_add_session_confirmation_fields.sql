-- Add session confirmation fields to bookings table
-- These fields track when doctor and patient confirm session completion

ALTER TABLE bookings
ADD COLUMN IF NOT EXISTS doctor_confirmed BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS patient_confirmed BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;

-- Add comments
COMMENT ON COLUMN bookings.doctor_confirmed IS 'Whether doctor has confirmed session completion';
COMMENT ON COLUMN bookings.patient_confirmed IS 'Whether patient has confirmed session completion';
COMMENT ON COLUMN bookings.completed_at IS 'Timestamp when session was marked as completed';

-- Create index for querying confirmed sessions
CREATE INDEX IF NOT EXISTS idx_bookings_confirmation
ON bookings(doctor_confirmed, patient_confirmed, status);
