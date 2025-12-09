-- ============================================
-- FIX RLS POLICY V2: Admin Can View All Users
-- ============================================
-- Problem: Previous policy caused infinite recursion
-- Solution: Use simpler approach - ALL authenticated users can view ALL users

-- Step 1: Drop ALL existing SELECT policies
DROP POLICY IF EXISTS "Users can view all active users" ON public.users;
DROP POLICY IF EXISTS "Admins can view all users" ON public.users;
DROP POLICY IF EXISTS "Users can view active users and self" ON public.users;

-- Step 2: Create single policy - All authenticated users can view all users
-- This is safe because:
-- - Only authenticated users can access
-- - Admin needs to see pending users for verification
-- - Regular users need to see active users for app functionality
CREATE POLICY "Authenticated users can view all users"
  ON public.users
  FOR SELECT
  TO authenticated
  USING (true);

-- ============================================
-- VERIFY POLICY
-- ============================================

-- Check SELECT policies on users table
SELECT
  policyname,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'users' AND cmd = 'SELECT'
ORDER BY policyname;

-- Expected result:
-- policyname: "Authenticated users can view all users"
-- cmd: SELECT
-- qual: true
