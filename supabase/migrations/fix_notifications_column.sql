-- ============================================
-- FIX: ADD MISSING 'message' COLUMN TO NOTIFICATIONS
-- Run this in Supabase SQL Editor to fix the PostgrestException
-- ============================================

-- 1. Add 'message' column if it doesn't exist
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS message TEXT;

-- 2. Add 'body' column if it exists (for backward compatibility, optional)
-- If 'body' existed and had data, we might want to migrate it, but keeping it simple for now.

-- 3. Verify 'data' column exists too (from previous SQL)
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS data JSONB;

-- 4. Re-enable the triggers (just to be safe, though not strictly needed if only column was missing)
-- (Triggers depend on the function, function depends on the table columns. If column is added, function works)

-- 5. Add a test notification to ensure it works
INSERT INTO notifications (user_id, type, title, message, data)
SELECT 
  auth.uid(), 
  'general', 
  'System Fix', 
  'Fitur notifikasi telah diperbaiki.', 
  '{"fixed": true}'::jsonb
FROM auth.users
WHERE id = auth.uid();
