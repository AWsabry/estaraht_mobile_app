-- Migration: Add approval status columns to doctors table
-- Created: 2026-01-24
-- Purpose: Implement doctor registration approval workflow

-- Add new columns to doctors table
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS approval_status TEXT DEFAULT 'approved';
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMP;
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS reviewed_by TEXT;
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

-- Update existing doctors to approved status to prevent blocking current users
UPDATE doctors SET approval_status = 'approved' WHERE approval_status IS NULL OR approval_status = '';

-- Set default to 'pending' for new registrations going forward
ALTER TABLE doctors ALTER COLUMN approval_status SET DEFAULT 'pending';

-- Add constraint to ensure only valid status values
ALTER TABLE doctors DROP CONSTRAINT IF EXISTS chk_approval_status;
ALTER TABLE doctors ADD CONSTRAINT chk_approval_status
  CHECK (approval_status IN ('pending', 'approved', 'rejected'));

-- Add index for faster queries on approval status
CREATE INDEX IF NOT EXISTS idx_doctors_approval_status ON doctors(approval_status);

-- Add comments for documentation
COMMENT ON COLUMN doctors.approval_status IS 'Doctor account approval status: pending, approved, or rejected';
COMMENT ON COLUMN doctors.reviewed_at IS 'Timestamp when the doctor account was reviewed by admin';
COMMENT ON COLUMN doctors.reviewed_by IS 'Admin user ID who reviewed the doctor account';
COMMENT ON COLUMN doctors.rejection_reason IS 'Reason for rejection if status is rejected';
