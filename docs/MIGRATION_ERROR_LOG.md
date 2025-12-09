# Dokumentasi Perbaikan Error - Migrasi Supabase

## Overview
Migrasi dari Appwrite ke Supabase pada aplikasi CleanOffice Flutter.

---

## Progres Error Count
```
624 → 208 → 98 → 135 → 130 → 128 → 126 → (ongoing)
```

---

## 1. SERVICE FILE ERRORS

### 1.1 `storage_service.dart`
**Error:** `uri_does_not_exist` - Import `appwrite_storage_service.dart` tidak ditemukan  
**Root Cause:** File Appwrite service sudah dihapus  
**Fix:** Rewrite service untuk menggunakan `SupabaseStorageService`

### 1.2 `inventory_service.dart`
**Error:** `undefined_class` - `AppwriteDatabaseService` tidak ditemukan  
**Root Cause:** File Appwrite service sudah dihapus  
**Fix:** Rewrite service untuk menggunakan Supabase langsung dengan `Supabase.instance.client`

### 1.3 `seed_data_service.dart`
**Error:** `uri_does_not_exist` - Import Appwrite services  
**Root Cause:** Legacy file yang tidak terpakai  
**Fix:** Delete file (unused)

---

## 2. MODEL ERRORS

### 2.1 `report_freezed.dart` & `request_freezed.dart`
**Error:** `undefined_class` - `DocumentSnapshot` tidak ditemukan  
**Root Cause:** Method `fromFirestore` masih menggunakan Firestore type  
**Fix:** Hapus `fromFirestore` factory methods, gunakan `fromSupabase` saja

### 2.2 `inventory_item.dart`
**Error:** `undefined_method` - `StockRequest.fromSupabase` tidak ada  
**Root Cause:** Hanya ada `fromMap`, belum ada `fromSupabase`  
**Fix:** Tambah factory method `StockRequest.fromSupabase` dengan snake_case mapping

---

## 3. PROVIDER ERRORS

### 3.1 `profile_providers.dart`
**Error:** `uri_does_not_exist` - Import Appwrite services  
**Root Cause:** Masih import dari file Appwrite yang dihapus  
**Fix:** Update imports ke `supabase_service_providers.dart`

**Additional Error:** `argument_type_not_assignable` - `updateUserProfile(UserProfile)`  
**Root Cause:** `SupabaseDatabaseService.updateUserProfile` expect named parameters, bukan UserProfile object  
**Fix:** Ubah pemanggilan ke:
```dart
await _database.updateUserProfile(
  userId: updatedProfile.uid,
  displayName: updatedProfile.displayName,
  ...
);
```

### 3.2 `chat_providers.dart`
**Error:** `undefined_method` - `isUserOnline`, `getUsersOnlineStatus`  
**Root Cause:** ChatService baru belum punya method ini  
**Fix:** Tambah stub methods di `chat_service.dart`

---

## 4. SCREEN ERRORS

### 4.1 `create_cleaning_report_screen.dart` & `create_report_screen.dart`
**Error:** `undefined_named_parameter` - `folder` tidak dikenali  
**Root Cause:** `SupabaseStorageService.uploadImage` menggunakan `bucket`, bukan `folder`  
**Fix:** Ganti parameter:
```dart
// Before
folder: 'cleaning_reports',
// After
bucket: SupabaseConfig.reportImagesBucket,
```

### 4.2 `chat_room_screen.dart`
**Error:** Multiple `undefined_method` errors  
**Methods yang tidak ada:**
- `markMessagesAsRead`
- `setTypingIndicator`
- `sendImageMessage`
- `sendFileMessage`
- `deleteMessage` (dengan named params)
- `editMessage`

**Fix:** Tambah semua stub methods di `chat_service.dart`

---

## 5. GRADLE ERROR

### 5.1 Gradle Version
**Error:** `Minimum supported Gradle version is 8.11.1. Current version is 8.9`  
**Root Cause:** Flutter/Android plugin memerlukan Gradle baru  
**Fix:** Update `gradle-wrapper.properties`:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.11.1-all.zip
```

---

## 6. LOGGER ERRORS

### 6.1 `realtime_service.dart`
**Error:** `undefined_method` - `_logger.debug()` tidak ada  
**Root Cause:** `AppLogger` class tidak punya method `debug`  
**Fix:** Ganti `_logger.debug()` ke `_logger.info()`

---

## 7. REMAINING ISSUES (To Fix)

### 7.1 `profile_providers.dart` line 87
- Error di method `uploadProfilePicture`
- Need to check method signature

### 7.2 Chat Feature
- Many methods are stubs (not fully implemented)
- Realtime presence not implemented
- Typing indicators not implemented

### 7.3 Other Screens
- ~100+ remaining analysis errors
- Most are UI-related type mismatches
- Pre-existing issues not related to migration

---

## Summary of Changes Made

| File | Action |
|------|--------|
| `storage_service.dart` | Rewritten for Supabase |
| `inventory_service.dart` | Rewritten for Supabase |
| `seed_data_service.dart` | Deleted |
| `chat_service.dart` | Rewritten + Stub methods |
| `realtime_service.dart` | Fixed logger calls |
| `profile_providers.dart` | Updated imports + method calls |
| `report_freezed.dart` | Removed fromFirestore |
| `request_freezed.dart` | Removed fromFirestore |
| `inventory_item.dart` | Added fromSupabase |
| `create_report_screen.dart` | Fixed bucket param |
| `create_cleaning_report_screen.dart` | Fixed bucket param |
| `chat_room_screen.dart` | Fixed deleteMessage call |
| `gradle-wrapper.properties` | Updated Gradle version |

---

## Lessons Learned

1. **Service API Mismatch**: Supabase dan Appwrite punya API yang berbeda - perlu mapping parameter
2. **Model Conversion**: snake_case (Supabase) vs camelCase (Dart) perlu factory methods
3. **Missing Methods**: ChatService memerlukan banyak method yang belum diimplementasi
4. **Logger API**: Custom logger class harus dicek method yang tersedia
5. **Build System**: Gradle version harus compatible dengan Flutter plugin
