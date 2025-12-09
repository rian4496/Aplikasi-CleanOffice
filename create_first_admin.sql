-- ============================================
-- CREATE FIRST ADMIN ACCOUNT
-- ============================================
-- Run this AFTER you register an admin account via the app
-- Replace 'YOUR_ADMIN_EMAIL' with the actual email you used to register

-- Step 1: Find the user ID (run this first to get the user_id)
SELECT
  id as user_id,
  email,
  created_at
FROM auth.users
WHERE email = 'admin@kantor.com';  -- ⚠️ CHANGE THIS to your admin email

-- Copy the user_id from result above, then run Step 2:

-- Step 2: Update user to make them admin
UPDATE users
SET
  role = 'admin',
  status = 'active',
  verification_status = 'approved'
WHERE email = 'admin@kantor.com';  -- ⚠️ CHANGE THIS to your admin email

-- Step 3: Verify the change
SELECT
  id,
  email,
  display_name,
  role,
  status,
  verification_status
FROM users
WHERE email = 'admin@kantor.com';  -- ⚠️ CHANGE THIS to your admin email

-- Expected result:
-- role: 'admin'
-- status: 'active'
-- verification_status: 'approved'

-- ============================================
-- ALTERNATIVE: Create admin directly (if you know the Auth user ID)
-- ============================================

-- If you already have the Auth user ID:
/*
UPDATE users
SET
  role = 'admin',
  status = 'active',
  verification_status = 'approved'
WHERE id = 'YOUR_USER_ID_HERE';
*/
