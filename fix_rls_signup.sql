-- Fix RLS Policy for User Signup
-- Problem: New users can't insert their own profile during registration
-- Solution: Allow authenticated users to insert their own profile

-- 1. Drop existing restrictive policy (if exists)
DROP POLICY IF EXISTS "Service role can insert users" ON public.users;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;

-- 2. Create new policy: Allow users to insert ONLY their own profile
CREATE POLICY "Users can insert own profile"
  ON public.users
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- 3. Verify trigger exists and is active
SELECT
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- Expected result:
-- trigger_name: on_auth_user_created
-- event_manipulation: INSERT
-- event_object_table: users (in auth schema)
-- action_statement: EXECUTE FUNCTION public.handle_new_user()

-- 4. If trigger doesn't exist, recreate it:
-- DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
--
-- CREATE TRIGGER on_auth_user_created
--   AFTER INSERT ON auth.users
--   FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 5. Test the policy by trying to insert (run this as authenticated user in SQL editor):
-- INSERT INTO users (id, email, display_name, role, status, verification_status)
-- VALUES (
--   auth.uid(),
--   'test@example.com',
--   'Test User',
--   'employee',
--   'inactive',
--   'pending'
-- );

-- 6. Verify all RLS policies for users table
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'users'
ORDER BY policyname;
