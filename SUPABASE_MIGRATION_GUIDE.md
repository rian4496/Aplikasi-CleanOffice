# 🚀 Supabase Migration Guide - CleanOffice App

## ✅ Migration Status: **Phase 1 Complete**

Aplikasi CleanOffice telah berhasil dimigrasikan dari Appwrite ke Supabase untuk **Authentication & User Management**.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [What's Been Migrated](#whats-been-migrated)
3. [Project Setup](#project-setup)
4. [Database Schema](#database-schema)
5. [Testing Registration](#testing-registration)
6. [Next Steps](#next-steps)
7. [Troubleshooting](#troubleshooting)

---

## Overview

**Why Supabase?**
- PostgreSQL database (more powerful than NoSQL)
- Built-in Row Level Security (RLS)
- Realtime subscriptions out of the box
- Better developer experience
- No more unique index collision issues (bye Appwrite 409 errors!)

**Migration Approach:**
- Gradual migration (Supabase + Appwrite coexist temporarily)
- Start with Auth & User Management
- Then migrate Reports, Requests, Inventory, etc.

---

## What's Been Migrated

### ✅ Completed

1. **Supabase Configuration**
   - File: `lib/core/config/supabase_config.dart`
   - Project URL: `https://nrbijfhtkigszvibminy.supabase.co`
   - Anon Key configured

2. **Database Schema**
   - File: `supabase_schema.sql` (already executed in Supabase)
   - Tables: users, reports, requests, inventory, chats, messages, notifications, departments
   - RLS policies configured
   - Auto-create user profile trigger installed

3. **Storage Buckets**
   - `report-images` (public)
   - `profile-images` (public)
   - `inventory-images` (public)

4. **Flutter Code**
   - ✅ `supabase_auth_service.dart` - Complete auth service
   - ✅ `user_profile.dart` - Added `fromSupabase()` and `toSupabase()` methods
   - ✅ `sign_up_screen.dart` - Now uses SupabaseAuthService
   - ✅ `main.dart` - Supabase initialized on app start

### ⏳ Pending Migration

- Login Screen (still uses Appwrite)
- Admin Dashboard (user verification)
- Reports Management
- Requests Management
- Inventory Management
- Chat System
- Notifications

---

## Project Setup

### Supabase Project Details

```
Project Name: cleanoffice-app
Organization: fian4496's Org
Region: Asia-Pacific (Singapore)
Project URL: https://nrbijfhtkigszvibminy.supabase.co
```

### Environment Variables

Already configured in `lib/core/config/supabase_config.dart`:

```dart
static const String supabaseUrl = 'https://nrbijfhtkigszvibminy.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

---

## Database Schema

### Users Table

**Important Fields:**
- `id` (UUID, Primary Key) - Same as Auth user ID
- `email` (TEXT, Required, Unique)
- `display_name` (TEXT, Required)
- `role` (ENUM: admin, employee, cleaner)
- `status` (ENUM: active, inactive, deleted) - Default: `inactive`
- `verification_status` (ENUM: pending, approved, rejected) - Default: `pending`
- `phone_number`, `photo_url`, `location` (Optional)
- `department_id`, `employee_id` (Optional, Foreign Keys)
- `created_at`, `updated_at` (Timestamps)

**Key Differences from Appwrite:**
| Feature | Appwrite | Supabase |
|---------|----------|----------|
| Field naming | camelCase | snake_case |
| Document ID | Separate from Auth ID | Same as Auth ID |
| User creation | Manual create document | Auto via trigger |
| Verification | Manual check | Built into RLS |

### Auto User Profile Creation

When a new user signs up via Supabase Auth:

```sql
-- Trigger automatically creates profile in public.users table
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

**Data Flow:**
1. User fills signup form
2. `SupabaseAuthService.signUpWithEmailAndPassword()` called
3. Supabase Auth creates user in `auth.users`
4. Database trigger fires → creates profile in `public.users`
5. App fetches profile and returns to user

---

## Testing Registration

### Test Case 1: New User Registration

1. **Run the app:**
   ```bash
   flutter run -d windows
   ```

2. **Navigate to Sign Up screen**

3. **Fill in the form:**
   - Name: "Test User Supabase"
   - Email: "testsupabase@example.com"
   - Password: "password123"
   - Confirm Password: "password123"

4. **Click "Daftar" button**

5. **Expected Results:**
   - ✅ Success message: "Akun berhasil didaftar! Tunggu verifikasi dari admin."
   - ✅ Redirected to Login screen
   - ✅ Check Supabase Dashboard → Auth → Users: New user appears
   - ✅ Check Supabase Dashboard → Table Editor → users: Profile exists with:
     - `status = 'inactive'`
     - `verification_status = 'pending'`
     - `role = 'employee'`

6. **Verify in App (as Admin):**
   - Login as admin (using old Appwrite account)
   - Open "Verifikasi Akun" screen
   - Tab "Menunggu" → Should show "testsupabase@example.com"
   - **NOTE**: This won't work yet until we migrate admin dashboard to Supabase

### Test Case 2: Duplicate Email

1. Try registering with same email again
2. **Expected**: Error message "Email sudah terdaftar"

### Test Case 3: Weak Password

1. Try password less than 6 characters
2. **Expected**: Error message "Password terlalu lemah (minimal 6 karakter)"

---

## Next Steps

### Immediate (Today):

1. **Test Registration** ✅
   - Register new user
   - Verify in Supabase Dashboard
   - Check error handling

2. **Migrate Login Screen**
   - Update `login_screen.dart` to use `SupabaseAuthService`
   - Test login with newly registered user
   - Verify verification status check works

3. **Migrate Admin User Verification**
   - Update `account_verification_screen.dart`
   - Fetch users from Supabase
   - Test approve/reject functionality

### Short Term (This Week):

4. **Migrate Reports Management**
   - Create `supabase_database_service.dart`
   - Update report providers
   - Test CRUD operations

5. **Migrate Requests Management**
   - Similar to reports
   - Test cleaner assignment

6. **Migrate Inventory**
   - Straightforward CRUD
   - Test low stock alerts

### Long Term (Next Week):

7. **Migrate Chat System**
   - Implement Realtime subscriptions
   - Test message delivery

8. **Migrate Storage**
   - Move images from Appwrite to Supabase Storage
   - Update upload/download logic

9. **Complete Migration**
   - Remove all Appwrite code
   - Update dependencies (remove `appwrite` package)
   - Final testing

---

## Troubleshooting

### Issue: "Supabase initialization failed"

**Symptoms:**
```
❌ Supabase initialization failed: ...
```

**Solutions:**
1. Check internet connection
2. Verify Supabase URL and Anon Key in `supabase_config.dart`
3. Check Supabase Dashboard → Project is not paused

### Issue: "Profile not auto-created"

**Symptoms:**
User created in Auth but profile not in `users` table.

**Solutions:**
1. Check Supabase Dashboard → Database → Functions → `handle_new_user` exists
2. Check trigger: `on_auth_user_created` is enabled
3. Fallback: Service will create profile manually after 500ms

### Issue: "User cannot login after registration"

**Symptoms:**
Registration succeeds but login shows "Akun belum diverifikasi"

**Expected Behavior:**
- This is CORRECT! New users must be approved by admin first.
- Admin must change `verification_status` from `pending` to `approved`
- Only then user can login

**To Test Login:**
1. Go to Supabase Dashboard
2. Table Editor → users → Find the user
3. Edit row:
   - `verification_status` = `approved`
   - `status` = `active`
4. Save
5. Try login again → Should work

### Issue: RLS Policy Blocking Access

**Symptoms:**
```
new row violates row-level security policy
```

**Solutions:**
1. Check RLS policies in Supabase Dashboard → Authentication → Policies
2. Verify user is authenticated (`auth.uid()` is not null)
3. For admin operations, verify user role is 'admin'

### Issue: Field Name Mismatch

**Symptoms:**
```
column "displayName" does not exist
```

**Solution:**
- Supabase uses `snake_case` (e.g., `display_name`)
- Appwrite uses `camelCase` (e.g., `displayName`)
- Always use `UserProfile.fromSupabase()` and `toSupabase()` methods

---

## SQL Queries for Manual Testing

### Check User Profile

```sql
SELECT * FROM users WHERE email = 'testsupabase@example.com';
```

### Manually Approve User

```sql
UPDATE users
SET verification_status = 'approved',
    status = 'active'
WHERE email = 'testsupabase@example.com';
```

### Check All Pending Users

```sql
SELECT email, display_name, role, verification_status, status, created_at
FROM users
WHERE verification_status = 'pending'
ORDER BY created_at DESC;
```

### Check Auth Users vs Database Users

```sql
-- Count Auth users
SELECT COUNT(*) FROM auth.users;

-- Count Database profiles
SELECT COUNT(*) FROM public.users;

-- Find orphan Auth users (no profile)
SELECT a.email, a.created_at
FROM auth.users a
LEFT JOIN public.users p ON a.id = p.id
WHERE p.id IS NULL;
```

---

## Key Takeaways

### ✅ Benefits of Migration

1. **No More 409 Errors**: Supabase handles document ID properly
2. **Automatic Profile Creation**: Trigger eliminates manual steps
3. **Better Error Messages**: Clear, user-friendly feedback
4. **RLS Security**: Database-level access control
5. **Realtime Ready**: Built-in subscriptions for chat, notifications

### ⚠️ Important Notes

1. **Backward Compatibility**: Appwrite code still exists (will be removed later)
2. **Testing Required**: Test each feature after migration
3. **Data Migration**: Old Appwrite data needs manual migration
4. **Admin Access**: Use Supabase Dashboard for direct database access

---

## Support & Contact

**Supabase Dashboard:**
https://supabase.com/dashboard/project/nrbijfhtkigszvibminy

**SQL Editor:**
Dashboard → SQL Editor (for running queries)

**Table Editor:**
Dashboard → Table Editor (for viewing/editing data)

**Auth Users:**
Dashboard → Authentication → Users

**Logs:**
Dashboard → Logs (for debugging)

---

**Last Updated:** 2025-12-03
**Migration Phase:** 1 of 5 (Auth & Users) ✅
**Status:** Ready for Testing 🚀
