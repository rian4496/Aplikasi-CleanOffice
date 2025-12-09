# 🔍 Analisa: Inbox Pending Tidak Muncul

## 📊 Status Saat Ini

**Masalah**: Setelah hot restart, inbox pending di screen "Verifikasi Akun" masih kosong, padahal user `fitri@bridakalsel.com` sudah berhasil didaftarkan.

---

## ✅ Analisa Kode & Data Flow

### 1. Provider Chain (Data Flow)

```
User Registration
  ↓
Supabase Auth + Database Trigger
  ↓
User profile tersimpan di tabel `users` dengan `verification_status = 'pending'`
  ↓
[PROVIDER] pendingVerificationUsersProvider
  ↓
[SERVICE] SupabaseDatabaseService.getAllUserProfiles()
  ↓
[DATABASE] Query: SELECT * FROM users ORDER BY created_at DESC
  ↓
[SCREEN] AccountVerificationScreen filters by verificationStatus == 'pending'
  ↓
[UI] Tab "Menunggu" shows pending users
```

### 2. Kode Provider (admin_providers.dart:268-279)

```dart
final pendingVerificationUsersProvider = FutureProvider<List<UserProfile>>((ref) async {
  final service = ref.read(supabaseDatabaseServiceProvider);
  try {
    // ✅ Ambil semua user profiles dari Supabase
    final users = await service.getAllUserProfiles();
    _logger.info('✅ Loaded ${users.length} users for verification from Supabase');
    return users;
  } catch (e) {
    _logger.error('❌ Error loading users for verification', e);
    rethrow;
  }
});
```

**Analisa**:
- ✅ Provider sudah menggunakan `supabaseDatabaseServiceProvider`
- ✅ Memanggil `getAllUserProfiles()` yang query ke Supabase
- ✅ Ada logging untuk debugging

### 3. Kode Service (supabase_database_service.dart:18-49)

```dart
Future<List<UserProfile>> getAllUserProfiles() async {
  try {
    _logger.info('📋 Fetching all user profiles');

    final response = await _client
        .from(SupabaseConfig.usersTable)  // ← Query ke tabel 'users'
        .select()
        .order('created_at', ascending: false);

    final users = (response as List)
        .map((data) => UserProfile.fromSupabase(data))
        .toList();

    _logger.info('✅ Loaded ${users.length} user profiles');
    return users;
  } catch (e, stackTrace) {
    _logger.error('❌ Unexpected error fetching user profiles', e, stackTrace);
    throw DatabaseException(...);
  }
}
```

**Analisa**:
- ✅ Query ke tabel `users` di Supabase
- ✅ Menggunakan `UserProfile.fromSupabase()` untuk mapping data
- ✅ Ada logging `📋 Fetching all user profiles` dan `✅ Loaded X user profiles`

### 4. Kode Screen (account_verification_screen.dart:151-211)

```dart
Widget _buildUserList(String statusFilter) {
  final usersAsync = ref.watch(pendingVerificationUsersProvider);  // ← Watch provider

  return usersAsync.when(
    data: (users) {
      // Filter berdasarkan verificationStatus
      List<UserProfile> filteredUsers;
      if (statusFilter == 'pending') {
        filteredUsers = users.where((u) => u.verificationStatus == 'pending').toList();
      } else if (statusFilter == 'approved') {
        filteredUsers = users.where((u) => u.verificationStatus == 'approved').toList();
      } else {
        filteredUsers = users.where((u) => u.verificationStatus == 'rejected').toList();
      }

      if (filteredUsers.isEmpty) {
        return _buildEmptyState(statusFilter);  // ← "Tidak ada akun yang menunggu verifikasi"
      }

      return RefreshIndicator(...);  // ← Show list
    },
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (error, _) => Center(...),  // ← Show error message
  );
}
```

**Analisa**:
- ✅ Screen menggunakan `ref.watch(pendingVerificationUsersProvider)`
- ✅ Filter berdasarkan `verificationStatus == 'pending'`
- ✅ Jika empty, tampilkan "Tidak ada akun yang menunggu verifikasi"

### 5. Screen Initialization (account_verification_screen.dart:30-38)

```dart
@override
void initState() {
  super.initState();
  _tabController = TabController(length: 3, vsync: this);

  // ✅ Auto-refresh data saat screen dibuka
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.invalidate(pendingVerificationUsersProvider);
  });
}
```

**Analisa**:
- ✅ Ada `ref.invalidate()` untuk force refresh data saat screen dibuka
- ✅ Ini memastikan data selalu fresh

---

## 🔍 Kemungkinan Masalah

### Kemungkinan 1: Screen Belum Pernah Dibuka ⚠️

**Gejala**: Tidak ada log dari provider di terminal

**Bukti dari log**:
```
✅ Login complete for: admin@kantor.com (role: admin)
AuthProviders: SEVERE: Error loading user profile AppwriteException...
AppwriteDatabaseService: SEVERE: Error fetching reports...
```

**Tidak ada log**:
```
📋 Fetching all user profiles        ← TIDAK ADA
✅ Loaded X users for verification    ← TIDAK ADA
```

**Kesimpulan**: Provider `pendingVerificationUsersProvider` **belum pernah dipanggil** karena screen Verifikasi Akun belum dibuka.

**Solusi**: Buka screen Verifikasi Akun dari dashboard admin:
1. Login sebagai admin
2. Klik tombol "More" (di bottom navigation bar)
3. Pilih "Verifikasi Akun"

---

### Kemungkinan 2: Data Tidak Tersimpan di Supabase ❌

**Cara Verifikasi**:

1. Buka **Supabase Dashboard**: https://supabase.com/dashboard/project/nrbijfhtkigszvibminy
2. Go to **Table Editor** → Pilih tabel `users`
3. Cari row dengan `email = 'fitri@bridakalsel.com'`

**Expected**:
```
id: [UUID]
email: fitri@bridakalsel.com
display_name: Fitri
role: employee
status: inactive
verification_status: pending  ← HARUS 'pending'
created_at: [timestamp]
```

**Jika tidak ada data**, jalankan SQL query:
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
WHERE email = 'fitri@bridakalsel.com';
```

---

### Kemungkinan 3: RLS Policy Blocking Read ❌

**Gejala**: Error di log saat fetch users

**Cara Verifikasi**:

Run SQL di Supabase Dashboard:
```sql
SELECT
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'users' AND cmd = 'SELECT';
```

**Expected Result**:
```
policyname: "Users can view all profiles"  (atau similar)
cmd: SELECT
qual: true  (atau policy yang allow read)
```

**Jika tidak ada SELECT policy**, jalankan:
```sql
-- Allow authenticated users to read all user profiles
CREATE POLICY "Users can view all profiles"
  ON public.users
  FOR SELECT
  TO authenticated
  USING (true);
```

---

### Kemungkinan 4: UserProfile.fromSupabase() Mapping Error ❌

**Gejala**: Data ada di database tapi error saat mapping

**Field mapping yang digunakan**:
```dart
factory UserProfile.fromSupabase(Map<String, dynamic> data) {
  return UserProfile(
    uid: data['id'] as String? ?? '',               // ← Supabase uses 'id'
    displayName: data['display_name'] as String? ?? '',
    email: data['email'] as String? ?? '',
    verificationStatus: data['verification_status'] as String? ?? 'pending',  // ← CRITICAL
    // ... other fields
  );
}
```

**Pastikan field di Supabase Database**:
- ✅ `id` (UUID)
- ✅ `display_name` (TEXT)
- ✅ `email` (TEXT)
- ✅ `verification_status` (TEXT) dengan value 'pending', 'approved', atau 'rejected'

---

## 🧪 Langkah Testing

### Step 1: Verifikasi Data di Database

1. Buka Supabase Dashboard → Table Editor → `users`
2. Cari `fitri@bridakalsel.com`
3. **Pastikan**:
   - Row exists
   - `verification_status = 'pending'`
   - `status = 'inactive'`

### Step 2: Buka Screen Verifikasi Akun

1. **Login sebagai admin** (`admin@kantor.com`)
2. **Klik bottom navigation bar** → Tombol "More" (icon 3 titik atau grid)
3. **Pilih "Verifikasi Akun"** dari menu
4. **Perhatikan log di terminal**:

**Expected logs**:
```
📋 Fetching all user profiles
✅ Loaded 2 user profiles  (admin + fitri)
```

### Step 3: Cek Tab "Menunggu"

1. **Tab "Menunggu"** harus menampilkan `fitri@bridakalsel.com`
2. **Jika tidak ada**, cek error di log terminal

### Step 4: Test Filter

**Debug tambahan** - cek di log apakah filtering bekerja:

Tambahkan logging di screen (temporary):
```dart
if (statusFilter == 'pending') {
  filteredUsers = users.where((u) => u.verificationStatus == 'pending').toList();
  debugPrint('🔍 Filtered pending users: ${filteredUsers.length} out of ${users.length}');
  for (var u in filteredUsers) {
    debugPrint('   - ${u.email} (status: ${u.verificationStatus})');
  }
}
```

---

## 📋 Checklist Debugging

- [ ] **Data exists in Supabase** - Run SQL query untuk verifikasi
- [ ] **Screen dibuka** - Buka screen "Verifikasi Akun" dari admin dashboard
- [ ] **Provider dipanggil** - Cek log `📋 Fetching all user profiles`
- [ ] **Data fetched** - Cek log `✅ Loaded X user profiles`
- [ ] **Filtering works** - Tab "Menunggu" shows pending users
- [ ] **RLS policies correct** - SELECT policy allows authenticated users

---

## 🎯 Kesimpulan Sementara

Berdasarkan analisa kode:

1. ✅ **Provider sudah benar** - Menggunakan Supabase service
2. ✅ **Service sudah benar** - Query ke Supabase table `users`
3. ✅ **Screen sudah benar** - Filter berdasarkan `verificationStatus`
4. ⚠️ **Screen belum dibuka** - Tidak ada log provider di terminal

**Kemungkinan terbesar**: Screen "Verifikasi Akun" **belum pernah dibuka** setelah hot restart.

**Solusi**: Buka screen Verifikasi Akun manually, lalu perhatikan log di terminal.

---

**Next Action**:
1. Jalankan aplikasi
2. Login sebagai admin
3. Buka screen "Verifikasi Akun"
4. Lihat log di terminal
5. Screenshot hasil di tab "Menunggu"
