-- Migration: Add wallet column to doctors table
-- Stores the doctor's accumulated earnings from completed sessions

ALTER TABLE doctors ADD COLUMN IF NOT EXISTS wallet DECIMAL(10,2) DEFAULT 0.00;

COMMENT ON COLUMN doctors.wallet IS 'Doctor wallet balance in USD (accumulated from completed sessions)';
