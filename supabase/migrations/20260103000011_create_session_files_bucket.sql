-- Create storage bucket for session files
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'session-files',
  'session-files',
  false,
  10485760, -- 10 MB limit
  ARRAY['application/pdf', 'image/jpeg', 'image/png', 'image/gif', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for session-files bucket

-- Allow doctors to upload files to their bookings
CREATE POLICY "Doctors can upload session files"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'session-files'
  AND EXISTS (
    SELECT 1 FROM bookings b
    WHERE b.id::text = (storage.foldername(name))[1]
    AND b.doctor_id = auth.uid()::text
  )
);

-- Allow patients to upload files to their bookings
CREATE POLICY "Patients can upload session files"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'session-files'
  AND EXISTS (
    SELECT 1 FROM bookings b
    WHERE b.id::text = (storage.foldername(name))[1]
    AND b.patient_id = auth.uid()::text
  )
);

-- Allow doctors to read files from their bookings
CREATE POLICY "Doctors can read session files"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'session-files'
  AND EXISTS (
    SELECT 1 FROM bookings b
    WHERE b.id::text = (storage.foldername(name))[1]
    AND b.doctor_id = auth.uid()::text
  )
);

-- Allow patients to read files from their bookings
CREATE POLICY "Patients can read session files"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'session-files'
  AND EXISTS (
    SELECT 1 FROM bookings b
    WHERE b.id::text = (storage.foldername(name))[1]
    AND b.patient_id = auth.uid()::text
  )
);

-- Allow doctors to delete their own uploaded files
CREATE POLICY "Doctors can delete their session files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'session-files'
  AND EXISTS (
    SELECT 1 FROM session_files sf
    WHERE sf.file_path = name
    AND sf.uploaded_by = auth.uid()::text
    AND sf.uploader_type = 'doctor'
  )
);

-- Allow patients to delete their own uploaded files
CREATE POLICY "Patients can delete their session files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'session-files'
  AND EXISTS (
    SELECT 1 FROM session_files sf
    WHERE sf.file_path = name
    AND sf.uploaded_by = auth.uid()::text
    AND sf.uploader_type = 'patient'
  )
);
