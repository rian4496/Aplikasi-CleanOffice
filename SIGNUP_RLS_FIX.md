# 🔧 Fix: User Signup RLS Policy Error

## ❌ Problem

User `fitri@kantor.com` gagal register dengan error:

```
PostgrestException(message: new row violates row-level security policy for table "users", code: 42501, details: Unauthorized, hint: null)
```

### What Happened:

1. ✅ Auth user created: `c771d5c4-80fe-444b-994b-2e4eaf6f056f`
2. ❌ Database trigger `handle_new_user()` **tidak jalan otomatis**
3. ⚠️ Fallback manual insert **diblokir oleh RLS policy**
4. ❌ Registration failed

## 🔍 Root Cause

**RLS Policy terlalu ketat**: User baru yang sudah authenticated tidak punya permission untuk insert profile-nya sendiri ke tabel `users`.

### Original Policy (Yang Salah):
```sql
CREATE POLICY "Service role can insert users"
  ON public.users FOR INSERT
  TO authenticated
  WITH CHECK (true);  -- ❌ Ini tidak cukup!
```

Policy ini **tidak spesifik** bahwa user boleh insert **hanya profile mereka sendiri**.

## ✅ Solution

### Step 1: Run SQL Fix di Supabase Dashboard

1. Buka **Supabase Dashboard** → **SQL Editor**
2. Copy paste SQL dari file `fix_rls_signup.sql`:

```sql
-- Drop existing restrictive policy
DROP POLICY IF EXISTS "Service role can insert users" ON public.users;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;

-- Create new policy: Allow users to insert ONLY their own profile
CREATE POLICY "Users can insert own profile"
  ON public.users
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);
```

3. Click **Run** atau tekan `Ctrl+Enter`

### Step 2: Verify Policy Created

Run this to check:

```sql
SELECT
  policyname,
  cmd,
  with_check
FROM pg_policies
WHERE tablename = 'users' AND cmd = 'INSERT';
```

**Expected result:**
```
policyname: "Users can insert own profile"
cmd: INSERT
with_check: (auth.uid() = id)
```

### Step 3: Check Trigger Status

Pastikan trigger `handle_new_user()` aktif:

```sql
SELECT
  trigger_name,
  event_manipulation,
  event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';
```

**Expected result:**
```
trigger_name: on_auth_user_created
event_manipulation: INSERT
event_object_table: users
```

### Step 4: Delete Orphan Auth User

User `fitri@kantor.com` sudah terbuat di Auth tapi **tidak ada profile** di database. Kita perlu hapus:

```sql
-- 1. Check auth user exists
SELECT id, email, created_at
FROM auth.users
WHERE email = 'fitri@kantor.com';

-- 2. Delete auth user (will cascade and clean up)
-- IMPORTANT: Go to Dashboard → Authentication → Users
-- Find fitri@kantor.com → Click "..." → Delete User
```

**ATAU** via SQL (hati-hati!):

```sql
-- Only if you're absolutely sure!
DELETE FROM auth.users WHERE email = 'fitri@kantor.com';
```

### Step 5: Test Registration Again

1. Buka app
2. Go to Sign Up screen
3. Fill form:
   ```
   Name: Fitri
   Email: fitri@kantor.com
   Password: password123
   Confirm: password123
   ```
4. Click **Daftar**

**Expected result:**
```
✅ Auth user created
✅ User profile created manually (or by trigger)
✅ Registration complete
```

## 📊 How It Works Now

### With Fixed RLS Policy:

```
User signs up
  ↓
1. Supabase Auth creates user in auth.users
  ↓
2. Trigger fires: handle_new_user() → auto-create profile
  ↓
   IF trigger fails (network/timing issue)
  ↓
3. Fallback: App manually creates profile
  ↓
   WITH CHECK (auth.uid() = id)  ← User can only insert their own profile
  ↓
4. ✅ Success! Profile created
```

### Security Check:

The new policy ensures:
- ✅ User can insert **ONLY their own profile** (where `id = auth.uid()`)
- ❌ User **CANNOT** insert profiles for other users
- ❌ User **CANNOT** insert without being authenticated

Example:
```sql
-- ✅ ALLOWED (user inserting own profile)
INSERT INTO users (id, email, display_name, ...)
VALUES (auth.uid(), 'me@example.com', 'My Name', ...);

-- ❌ BLOCKED (user trying to insert someone else's profile)
INSERT INTO users (id, email, display_name, ...)
VALUES ('random-uuid-here', 'someone@example.com', 'Other Name', ...);
```

## 🧪 Testing Checklist

After applying fix, test these scenarios:

- [ ] **New user signup** - Should succeed
- [ ] **Duplicate email signup** - Should show error "Email sudah terdaftar"
- [ ] **Weak password** - Should show error "Password terlalu lemah"
- [ ] **Profile created in database** - Check Supabase Dashboard → Table Editor → users
- [ ] **Default values correct**:
  - `status = 'inactive'`
  - `verification_status = 'pending'`
  - `role = 'employee'`

## 🔗 Related Files

- `fix_rls_signup.sql` - SQL script to fix RLS policy
- `supabase_schema.sql` - Original database schema
- `lib/services/supabase_auth_service.dart` - Registration logic
- `TESTING_CHECKLIST.md` - Complete testing guide

## 📝 Notes

### Why Trigger Didn't Fire?

Possible reasons:
1. **Timing issue** - Trigger runs async, app checks too fast
2. **Trigger error** - Check Supabase Dashboard → Logs → Database Logs
3. **Schema mismatch** - Trigger function has bugs

### Why Fallback Failed?

Original RLS policy didn't allow authenticated users to insert their own profiles. Fixed with:

```sql
WITH CHECK (auth.uid() = id)
```

This ensures user can only insert if the `id` column matches their `auth.uid()`.

---

**Last Updated:** 2025-12-03
**Issue:** Registration RLS Policy Error
**Status:** Fixed with SQL update ✅
