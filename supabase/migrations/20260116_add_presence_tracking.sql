-- Migration: Add presence tracking columns
-- Run this in Supabase SQL Editor

-- Add last_seen column to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_users_last_seen ON users(last_seen);

-- Update existing users to have a default last_seen value
UPDATE users SET last_seen = NOW() WHERE last_seen IS NULL;
