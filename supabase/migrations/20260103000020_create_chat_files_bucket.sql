-- Create storage bucket for chat files
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'chat-files',
  'chat-files',
  false,
  10485760, -- 10 MB limit
  ARRAY['application/pdf', 'image/jpeg', 'image/png', 'image/gif', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for chat-files bucket

-- Allow authenticated users to upload files to chat channels they are part of
CREATE POLICY "Users can upload chat files"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'chat-files'
);

-- Allow authenticated users to read chat files
CREATE POLICY "Users can read chat files"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'chat-files'
);

-- Allow authenticated users to delete their own chat files
CREATE POLICY "Users can delete chat files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'chat-files'
);
