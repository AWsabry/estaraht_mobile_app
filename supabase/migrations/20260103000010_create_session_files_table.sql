-- Create session_files table for PDF/file uploads
CREATE TABLE IF NOT EXISTS session_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID NOT NULL,
  uploaded_by TEXT NOT NULL,
  uploader_type TEXT NOT NULL CHECK (uploader_type IN ('doctor', 'patient')),
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  file_size INTEGER,
  mime_type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_session_files_booking_id ON session_files(booking_id);
CREATE INDEX IF NOT EXISTS idx_session_files_uploaded_by ON session_files(uploaded_by);

-- Create storage bucket for session files (run in Supabase dashboard)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('session-files', 'session-files', false);

-- Storage policies (run in Supabase dashboard)
-- Doctors can upload/read files for their bookings
-- Patients can upload/read files for their bookings
