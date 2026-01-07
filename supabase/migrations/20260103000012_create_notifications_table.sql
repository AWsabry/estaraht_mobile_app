-- Add columns to existing notifications table for in-app notifications
-- This works as an alternative to FCM when service account keys are not available

-- Add new columns if they don't exist
DO $$ 
BEGIN
  -- Add recipient_id if not exists
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'notifications' AND column_name = 'recipient_id') THEN
    ALTER TABLE notifications ADD COLUMN recipient_id TEXT;
  END IF;
  
  -- Add recipient_type if not exists
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'notifications' AND column_name = 'recipient_type') THEN
    ALTER TABLE notifications ADD COLUMN recipient_type TEXT DEFAULT 'patient';
  END IF;
  
  -- Add title if not exists
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'notifications' AND column_name = 'title') THEN
    ALTER TABLE notifications ADD COLUMN title TEXT;
  END IF;
  
  -- Add body if not exists
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'notifications' AND column_name = 'body') THEN
    ALTER TABLE notifications ADD COLUMN body TEXT;
  END IF;
  
  -- Add notification_type if not exists
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'notifications' AND column_name = 'notification_type') THEN
    ALTER TABLE notifications ADD COLUMN notification_type TEXT DEFAULT 'general';
  END IF;
  
  -- Add data if not exists
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'notifications' AND column_name = 'data') THEN
    ALTER TABLE notifications ADD COLUMN data JSONB DEFAULT '{}';
  END IF;
  
  -- Add is_read if not exists
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'notifications' AND column_name = 'is_read') THEN
    ALTER TABLE notifications ADD COLUMN is_read BOOLEAN DEFAULT FALSE;
  END IF;
END $$;

-- Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_notifications_recipient ON notifications(recipient_id, recipient_type);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(recipient_id, recipient_type, is_read);

-- Enable realtime for this table (ignore if already added)
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist and recreate
DROP POLICY IF EXISTS "Users can read own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;
DROP POLICY IF EXISTS "Service role can insert notifications" ON notifications;

-- Users can only read their own notifications
CREATE POLICY "Users can read own notifications" ON notifications
  FOR SELECT USING (
    recipient_id = auth.uid()::text
  );

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications" ON notifications
  FOR UPDATE USING (
    recipient_id = auth.uid()::text
  );

-- Anyone authenticated can insert notifications (for sending)
CREATE POLICY "Authenticated users can insert notifications" ON notifications
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');
