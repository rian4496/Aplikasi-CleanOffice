# 🔧 Fix: Admin Tidak Bisa Lihat User Pending

## ❌ Masalah

**Gejala**:
- Log menunjukkan: `✅ Loaded 1 user profiles` (harusnya 2: admin + fitri)
- Tab "Menunggu" di screen Verifikasi Akun kosong
- User `fitri@bridakalsel.com` sudah terdaftar di database dengan `verification_status = 'pending'`

**Log dari aplikasi**:
```
📋 Fetching all user profiles
✅ Loaded 1 user profiles  ← HANYA 1 (harusnya 2)
✅ Loaded 1 users for verification from Supabase
```

---

## 🔍 Root Cause

**RLS Policy terlalu ketat** - Admin tidak bisa melihat user dengan `status = 'inactive'`.

### Policy yang Bermasalah (supabase_schema.sql:255-258):

```sql
CREATE POLICY "Users can view all active users"
  ON public.users FOR SELECT
  TO authenticated
  USING (status = 'active' OR id = auth.uid());
```

**Masalahnya**:
- Policy ini **HANYA** mengizinkan melihat user dengan `status = 'active'`
- User baru yang mendaftar punya `status = 'inactive'` dan `verification_status = 'pending'`
- Akibatnya, **admin tidak bisa melihat user pending** untuk diverifikasi

**Kenapa admin hanya melihat 1 user**:
- Admin melihat dirinya sendiri (`id = auth.uid()`) ✅
- Admin **TIDAK** melihat Fitri karena `status = 'inactive'` ❌

---

## ✅ Solusi

### Step 1: Run SQL Fix di Supabase Dashboard

1. Buka **Supabase Dashboard** → **SQL Editor**
2. Copy paste SQL dari file `fix_rls_select_all_users.sql`:

```sql
-- Drop the restrictive policy
DROP POLICY IF EXISTS "Users can view all active users" ON public.users;

-- Admin can see ALL users (including inactive/pending)
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

-- Regular users can view active users + themselves
CREATE POLICY "Users can view active users and self"
  ON public.users
  FOR SELECT
  TO authenticated
  USING (
    status = 'active' OR id = auth.uid()
  );
```

3. Click **Run** atau tekan `Ctrl+Enter`

### Step 2: Verify Policy Created

Run SQL di Supabase Dashboard:

```sql
SELECT
  policyname,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'users' AND cmd = 'SELECT'
ORDER BY policyname;
```

**Expected Result**:
```
policyname: "Admins can view all users"
cmd: SELECT
qual: EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')

policyname: "Users can view active users and self"
cmd: SELECT
qual: (status = 'active' OR id = auth.uid())
```

### Step 3: Test di Aplikasi

1. **Hot restart aplikasi** (tekan `R` di terminal)
2. **Login sebagai admin**
3. **Buka screen "Verifikasi Akun"**
4. **Lihat log**:

**Expected log**:
```
📋 Fetching all user profiles
✅ Loaded 2 user profiles  ← Sekarang ada 2!
✅ Loaded 2 users for verification from Supabase
```

5. **Tab "Menunggu"** harus menampilkan `fitri@bridakalsel.com`

---

## 📊 Cara Kerja Policy Baru

### Policy 1: Admin Can View ALL Users

```sql
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
```

**Cara Kerja**:
- Cek apakah user yang login (`auth.uid()`) adalah admin
- Jika **role = 'admin'**, policy returns `true` → Admin bisa lihat **SEMUA** user
- Tidak ada filter `status = 'active'` → Admin bisa lihat user inactive/pending

**Contoh**:
- Admin login → `auth.uid() = d507410f-...`
- Query users table → Policy cek: Is `d507410f-...` an admin? ✅ YES
- Result: Admin melihat **SEMUA** rows di tabel users (admin + fitri)

### Policy 2: Regular Users Can View Active + Self

```sql
CREATE POLICY "Users can view active users and self"
  ON public.users
  FOR SELECT
  TO authenticated
  USING (
    status = 'active' OR id = auth.uid()
  );
```

**Cara Kerja**:
- User regular hanya bisa melihat:
  - User dengan `status = 'active'` (terverifikasi)
  - Diri sendiri (`id = auth.uid()`)

**Contoh**:
- Employee login → `auth.uid() = abc123-...`
- Query users table → Policy filter:
  - `status = 'active'` ✅ → Terlihat
  - `id = 'abc123-...'` ✅ → Terlihat (diri sendiri)
  - User pending/inactive lainnya ❌ → Tidak terlihat

---

## 🔐 Security Check

### ✅ Admin Privileges:
- ✅ Can view **ALL** users (active, inactive, pending, rejected)
- ✅ Needed for account verification screen
- ✅ Needed for user management

### ✅ Regular User Restrictions:
- ✅ Can view **ONLY** active users
- ✅ Can view themselves (even if inactive)
- ❌ **CANNOT** view other inactive/pending users
- ❌ **CANNOT** see rejected users

### ✅ Security Examples:

**Scenario 1**: Admin opens verification screen
```
User: admin@kantor.com (role: admin)
Query: SELECT * FROM users

Policy Check:
  - Is user admin? ✅ YES
  - Return: ALL rows (admin + fitri + any others)
```

**Scenario 2**: Employee opens user list
```
User: employee@kantor.com (role: employee)
Query: SELECT * FROM users

Policy Check:
  - Is user admin? ❌ NO
  - Use second policy:
    - Fitri (status: inactive) ❌ BLOCKED
    - Admin (status: active) ✅ ALLOWED
    - Self (id = auth.uid()) ✅ ALLOWED
```

---

## 🧪 Testing Checklist

After applying fix:

- [ ] **Run SQL** di Supabase Dashboard
- [ ] **Verify policies** dengan query `pg_policies`
- [ ] **Hot restart** aplikasi
- [ ] **Login as admin**
- [ ] **Open Verifikasi Akun screen**
- [ ] **Check log**: `✅ Loaded 2 user profiles`
- [ ] **Tab "Menunggu"** shows `fitri@bridakalsel.com`
- [ ] **Test approve** - User dapat login setelah approved
- [ ] **Test reject** - User tidak dapat login setelah rejected

---

## 📝 Verification Query

Untuk memastikan data ada di database:

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
ORDER BY created_at DESC;
```

**Expected Result**:
```
id: d507410f-... | email: admin@kantor.com | role: admin | status: active | verification_status: approved
id: [uuid]      | email: fitri@bridakalsel.com | role: employee | status: inactive | verification_status: pending
```

---

## 🎯 Summary

**Problem**: RLS policy hanya mengizinkan melihat user dengan `status = 'active'`

**Solution**: Dua policy terpisah:
1. **Admin** → Bisa lihat **SEMUA** user
2. **Regular users** → Hanya lihat user active + diri sendiri

**Result**: Admin sekarang bisa melihat user pending untuk verifikasi akun.

---

**File Terkait**:
- `fix_rls_select_all_users.sql` - SQL script untuk fix policy
- `supabase_schema.sql` - Original schema (akan di-update)
- `ANALISA_INBOX_PENDING.md` - Analisa masalah

**Status**: ✅ Ready to apply - Jalankan SQL di Supabase Dashboard
