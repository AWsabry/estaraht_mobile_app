-- Ensure session_files table exists
CREATE TABLE IF NOT EXISTS session_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id TEXT NOT NULL,
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

-- Enable RLS
ALTER TABLE session_files ENABLE ROW LEVEL SECURITY;

-- Drop policy if exists and recreate
DROP POLICY IF EXISTS "Allow all session_files operations" ON session_files;
CREATE POLICY "Allow all session_files operations" ON session_files
  FOR ALL
  USING (true)
  WITH CHECK (true);
