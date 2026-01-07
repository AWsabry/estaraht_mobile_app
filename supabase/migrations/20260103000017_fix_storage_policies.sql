-- Drop existing restrictive policies
DROP POLICY IF EXISTS "Doctors can upload session files" ON storage.objects;
DROP POLICY IF EXISTS "Patients can upload session files" ON storage.objects;
DROP POLICY IF EXISTS "Doctors can read session files" ON storage.objects;
DROP POLICY IF EXISTS "Patients can read session files" ON storage.objects;
DROP POLICY IF EXISTS "Doctors can delete their session files" ON storage.objects;
DROP POLICY IF EXISTS "Patients can delete their session files" ON storage.objects;
DROP POLICY IF EXISTS "Allow uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow reads" ON storage.objects;
DROP POLICY IF EXISTS "Allow deletes" ON storage.objects;

-- Create simple policies for session-files bucket
-- Allow all authenticated users to upload
CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'session-files');

-- Allow all authenticated users to read
CREATE POLICY "Allow authenticated reads"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'session-files');

-- Allow all authenticated users to update
CREATE POLICY "Allow authenticated updates"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'session-files');

-- Allow all authenticated users to delete
CREATE POLICY "Allow authenticated deletes"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'session-files');
