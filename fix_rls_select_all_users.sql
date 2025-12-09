-- ============================================
-- FIX RLS POLICY: Admin Can View All Users
-- ============================================
-- Problem: Current policy only allows viewing 'active' users
-- Solution: Admin can view ALL users (including inactive/pending)
--           Regular users can only view active users + themselves

-- Step 1: Drop the restrictive policy
DROP POLICY IF EXISTS "Users can view all active users" ON public.users;

-- Step 2: Create new policy - Admin can see ALL users
CREATE POLICY "Admins can view all users"
  ON public.users
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Step 3: Create policy - Regular users can view active users + themselves
CREATE POLICY "Users can view active users and self"
  ON public.users
  FOR SELECT
  TO authenticated
  USING (
    status = 'active' OR id = auth.uid()
  );

-- ============================================
-- VERIFY POLICIES
-- ============================================

-- Check all SELECT policies on users table
SELECT
  policyname,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'users' AND cmd = 'SELECT'
ORDER BY policyname;

-- Expected result:
-- 1. "Admins can view all users" - EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
-- 2. "Users can view active users and self" - (status = 'active' OR id = auth.uid())
