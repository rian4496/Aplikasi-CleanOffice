# 🧪 Testing Checklist - Supabase Migration

## ✅ Test Case 1: New User Registration

### Steps:
1. Launch the app
2. Click "Sign Up" / "Daftar"
3. Fill in the form:
   ```
   Name: Test Supabase User
   Email: testsupabase@example.com
   Password: password123
   Confirm Password: password123
   ```
4. Click "Daftar" button

### Expected Results:
- ✅ Success snackbar appears: "Akun berhasil didaftar! Tunggu verifikasi dari admin."
- ✅ App redirects to Login screen
- ✅ No errors in console

### Verification in Supabase Dashboard:

**1. Check Auth User Created:**
- Go to: https://supabase.com/dashboard/project/nrbijfhtkigszvibminy/auth/users
- Look for: testsupabase@example.com
- Should see user with ID (UUID format)

**2. Check Profile Created in Database:**
- Go to: https://supabase.com/dashboard/project/nrbijfhtkigszvibminy/editor
- Table: `users`
- Find row where `email = 'testsupabase@example.com'`
- Verify fields:
  ```
  id: [UUID matching Auth user]
  email: testsupabase@example.com
  display_name: Test Supabase User
  role: employee
  status: inactive
  verification_status: pending
  created_at: [timestamp]
  ```

**3. Run SQL Query:**
```sql
SELECT
  id,
  email,
  display_name,
  role,
  status,
  verification_status,
  created_at
FROM users
WHERE email = 'testsupabase@example.com';
```

---

## ✅ Test Case 2: Duplicate Email Registration

### Steps:
1. Try to register again with same email: `testsupabase@example.com`
2. Click "Daftar"

### Expected Results:
- ❌ Error snackbar appears
- Message contains: "Email sudah terdaftar" or similar
- User stays on Sign Up screen
- No new user created in Supabase

---

## ✅ Test Case 3: Weak Password

### Steps:
1. Fill form with:
   ```
   Name: Weak Pass User
   Email: weakpass@example.com
   Password: 123
   Confirm Password: 123
   ```
2. Click "Daftar"

### Expected Results:
- ❌ Form validation error OR
- ❌ Error snackbar: "Password terlalu lemah (minimal 6 karakter)"
- No user created

---

## ✅ Test Case 4: Password Mismatch

### Steps:
1. Fill form with:
   ```
   Name: Mismatch User
   Email: mismatch@example.com
   Password: password123
   Confirm Password: password456
   ```
2. Click "Daftar"

### Expected Results:
- ❌ Error snackbar: "Password tidak cocok"
- No user created

---

## ✅ Test Case 5: Invalid Email Format

### Steps:
1. Fill form with:
   ```
   Name: Invalid Email
   Email: notanemail
   Password: password123
   Confirm Password: password123
   ```
2. Click "Daftar"

### Expected Results:
- ❌ Form validation error: "Email tidak valid"
- No user created

---

## ✅ Test Case 6: Empty Fields

### Steps:
1. Leave all fields empty
2. Click "Daftar"

### Expected Results:
- ❌ Form validation errors for each required field
- No user created

---

## 🔍 Debug Checklist

If registration fails, check:

### 1. Console Output:
Look for these log messages:
```
✅ Supabase initialized successfully
🔐 Starting registration for: [email]
✅ Auth user created: [user_id]
✅ User profile created manually: [user_id]
✅ Registration complete for: [email]
```

Or error messages:
```
❌ Auth API error during signup
❌ Database error during signup
❌ Unexpected error during signup
```

### 2. Supabase Logs:
- Go to: Dashboard → Logs → Auth Logs
- Check for signup events
- Look for errors

### 3. Database Trigger:
Run SQL to verify trigger exists:
```sql
SELECT
  trigger_name,
  event_manipulation,
  event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';
```

Should return:
```
trigger_name: on_auth_user_created
event_manipulation: INSERT
event_object_table: users
```

### 4. RLS Policies:
Check if RLS is blocking:
```sql
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'users';
```

Should show policies for SELECT, INSERT, UPDATE.

---

## 🎯 Success Criteria

Registration is working correctly if:

1. ✅ User can fill signup form
2. ✅ Form validation catches errors
3. ✅ Success message appears after valid submission
4. ✅ User created in Auth (Supabase Dashboard)
5. ✅ Profile created in users table
6. ✅ Profile has correct default values:
   - `status = 'inactive'`
   - `verification_status = 'pending'`
   - `role = 'employee'`
7. ✅ App redirects to login screen
8. ✅ Duplicate email is rejected
9. ✅ Weak password is rejected

---

## 🐛 Known Issues & Workarounds

### Issue: Profile not auto-created

**Symptom:** User exists in Auth but not in `users` table.

**Workaround:**
```sql
-- Manually create profile
INSERT INTO users (id, email, display_name, role, status, verification_status)
SELECT
  id,
  email,
  COALESCE(raw_user_meta_data->>'display_name', email),
  'employee',
  'inactive',
  'pending'
FROM auth.users
WHERE id = '[USER_ID_HERE]';
```

### Issue: RLS blocking insert

**Symptom:** Error "new row violates row-level security policy"

**Fix:**
Check policy `Service role can insert users`:
```sql
CREATE POLICY "Service role can insert users"
  ON public.users FOR INSERT
  TO authenticated
  WITH CHECK (true);
```

---

## 📊 Test Results Log

| Test Case | Date | Result | Notes |
|-----------|------|--------|-------|
| New User Registration | 2025-12-03 | ⏳ Pending | First test |
| Duplicate Email | - | ⏳ Pending | - |
| Weak Password | - | ⏳ Pending | - |
| Password Mismatch | - | ⏳ Pending | - |
| Invalid Email | - | ⏳ Pending | - |
| Empty Fields | - | ⏳ Pending | - |

**Legend:**
- ✅ Passed
- ❌ Failed
- ⏳ Pending
- 🔄 In Progress

---

## 🚀 Next Testing Phase

After Registration tests pass:

1. **Login Flow** - Test with newly created user
2. **Admin Verification** - Approve user and test login again
3. **Profile Update** - Test changing display name, phone, etc.
4. **Password Reset** - Test forgot password flow

---

**Last Updated:** 2025-12-03
**Tester:** [Your Name]
**App Version:** 1.0.0+1
