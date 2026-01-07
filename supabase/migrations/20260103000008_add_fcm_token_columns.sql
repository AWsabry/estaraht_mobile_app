-- Add FCM token columns for push notifications
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS fcm_token TEXT;
ALTER TABLE patients ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- Create index for faster lookups when sending notifications
CREATE INDEX IF NOT EXISTS idx_doctors_fcm_token ON doctors(fcm_token) WHERE fcm_token IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_patients_fcm_token ON patients(fcm_token) WHERE fcm_token IS NOT NULL;
