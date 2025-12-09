# 📋 Phase 2: Screen Migration Plan - Reports & Requests

**Date**: 2025-12-05
**Status**: 🟡 PENDING

---

## 🎯 Overview

Setelah backend migration selesai (services, models, providers), sekarang perlu migrate **UI screens** untuk menggunakan Supabase providers.

**Total Screens**: 20 files
- **Report Screens**: 7 files
- **Request Screens**: 13 files

---

## 📊 Screens Inventory

### 🔵 Report Screens (7 files)

| # | File | Type | Priority | Complexity |
|---|------|------|----------|------------|
| 1 | `admin/all_reports_management_screen.dart` | Admin | HIGH | Medium |
| 2 | `admin/all_reports_management_screen_hooks.dart` | Admin (Hooks) | HIGH | Medium |
| 3 | `admin/modern_dashboard_screen.dart` | Dashboard | HIGH | Low (partial) |
| 4 | `admin/reports/reports_list_screen.dart` | Admin List | MEDIUM | Medium |
| 5 | `admin/reports_list_screen.dart` | Admin List (Old) | LOW | Medium |
| 6 | `admin/reports_list_screen_hooks.dart` | Admin List (Hooks) | LOW | Medium |
| 7 | `admin/verification/verification_screen.dart` | Admin Verify | HIGH | High |

### 🟢 Request Screens (13 files)

| # | File | Type | Priority | Complexity |
|---|------|------|----------|------------|
| 1 | `admin/admin_dashboard_screen.dart` | Dashboard | HIGH | Low (partial) |
| 2 | `admin/all_requests_management_screen.dart` | Admin | HIGH | Medium |
| 3 | `admin/cleaner_management_screen.dart` | Admin | MEDIUM | Low (partial) |
| 4 | `admin/cleaner_management_screen_hooks.dart` | Admin (Hooks) | MEDIUM | Low (partial) |
| 5 | `admin/modern_dashboard_screen.dart` | Dashboard | HIGH | Low (partial) |
| 6 | `cleaner/create_cleaning_report_screen.dart` | Cleaner | MEDIUM | Low (storage only) |
| 7 | `employee/create_report_screen.dart` | Employee | HIGH | High |
| 8 | `employee/create_request_screen.dart` | Employee | HIGH | High |
| 9 | `employee/create_request_screen_hooks.dart` | Employee (Hooks) | HIGH | High |
| 10 | `employee/request_history_screen.dart` | Employee | HIGH | Medium |
| 11 | `employee/request_history_screen_hooks.dart` | Employee (Hooks) | HIGH | Medium |
| 12 | `shared/request_detail/request_detail_screen.dart` | Shared | HIGH | High |
| 13 | `shared/request_detail/request_detail_screen_hooks.dart` | Shared (Hooks) | HIGH | High |

---

## 🔍 Migration Analysis

### Pattern 1: StreamProvider → FutureProvider

**Old (Appwrite):**
```dart
import '../../providers/riverpod/report_providers.dart';

final reportsStream = ref.watch(allReportsProvider(null));

reportsStream.when(
  data: (reports) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
);
```

**New (Supabase):**
```dart
import '../../providers/riverpod/supabase_report_providers.dart';

final reportsAsync = ref.watch(allReportsProvider);

reportsAsync.when(
  data: (reports) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
);
```

**Key Differences:**
- No `.family(null)` parameter (departmentFilter removed for now)
- Same `.when()` API
- Auto-dispose behavior (no manual cleanup needed)

---

### Pattern 2: Service Direct Call → Mutation Provider

**Old (Direct Service Call):**
```dart
final service = ref.read(appwriteDatabaseServiceProvider);

try {
  await service.createReport(newReport);
  ref.invalidate(allReportsProvider); // Manual invalidation
} catch (e) {
  // Handle error
}
```

**New (Mutation Provider):**
```dart
final createReport = ref.read(createReportProvider);

try {
  await createReport(newReport);
  // Auto-invalidation! No manual refresh needed
} catch (e) {
  // Handle error
}
```

**Benefits:**
- Auto-invalidation of related providers
- Consistent error handling
- Better testability

---

### Pattern 3: Storage Service

**Old (Appwrite Storage):**
```dart
import '../../services/appwrite_storage_service.dart';

final storageService = AppwriteStorageService();
final imageUrl = await storageService.uploadReportImage(file, userId);
```

**New (Supabase Storage):**
```dart
import '../../services/supabase_storage_service.dart';

final storageService = SupabaseStorageService();
final imageUrl = await storageService.uploadReportImage(file, userId);
```

**Note:** API almost identical! Minimal changes.

---

## 🛠️ Migration Steps (Per Screen)

### Step-by-Step Template

For each screen file:

#### 1. Update Imports
```dart
// REMOVE:
import '../../providers/riverpod/report_providers.dart';
import '../../services/appwrite_storage_service.dart';

// ADD:
import '../../providers/riverpod/supabase_report_providers.dart';
import '../../services/supabase_storage_service.dart';
```

#### 2. Update Provider Calls
- Remove `.family(departmentId)` if present → use filter provider instead
- Change `StreamProvider` → `FutureProvider`
- No other API changes needed (same `.when()`)

#### 3. Update Mutations
- Replace direct service calls with mutation providers
- Remove manual `ref.invalidate()` (auto-handled)

#### 4. Update Storage Calls
- Change `AppwriteStorageService()` → `SupabaseStorageService()`
- API identical, no other changes

#### 5. Test Screen
- Verify data loads correctly
- Test create/update/delete operations
- Check error handling
- Verify UI refreshes after mutations

---

## 📝 Detailed Migration Plan

### Phase 2A: Dashboard Screens (Priority: HIGH)

**Goal:** Get dashboards working first (most visible)

#### Task 1: Admin Dashboard
**File:** `admin/admin_dashboard_screen.dart`

**Changes:**
1. Import `supabase_report_providers.dart` and `supabase_request_providers.dart`
2. Update summary providers (if used)
3. Test statistics display

**Estimated Time:** 15 minutes

---

#### Task 2: Modern Dashboard
**File:** `admin/modern_dashboard_screen.dart`

**Changes:**
1. Import Supabase providers
2. Update both report and request providers
3. Test real-time stats

**Estimated Time:** 20 minutes

---

### Phase 2B: Employee Screens (Priority: HIGH)

**Goal:** Employees can create reports/requests

#### Task 3: Create Report Screen
**File:** `employee/create_report_screen.dart`

**Changes:**
1. Import `supabase_report_providers.dart`
2. Import `SupabaseStorageService`
3. Update `createReport` mutation
4. Update image upload logic
5. Test full create flow

**Estimated Time:** 30 minutes

---

#### Task 4: Create Request Screen
**File:** `employee/create_request_screen.dart`

**Changes:**
1. Import `supabase_request_providers.dart`
2. Update `createRequest` mutation
3. Test full create flow

**Estimated Time:** 20 minutes

---

#### Task 5: Create Request Screen (Hooks Version)
**File:** `employee/create_request_screen_hooks.dart`

**Changes:** Same as Task 4

**Estimated Time:** 20 minutes

---

#### Task 6: Request History Screen
**File:** `employee/request_history_screen.dart`

**Changes:**
1. Import `supabase_request_providers.dart`
2. Update `userRequestsProvider(userId)`
3. Test list display

**Estimated Time:** 15 minutes

---

#### Task 7: Request History Screen (Hooks Version)
**File:** `employee/request_history_screen_hooks.dart`

**Changes:** Same as Task 6

**Estimated Time:** 15 minutes

---

### Phase 2C: Shared Screens (Priority: HIGH)

#### Task 8: Request Detail Screen
**File:** `shared/request_detail/request_detail_screen.dart`

**Changes:**
1. Import `supabase_request_providers.dart`
2. Update `requestByIdProvider(requestId)`
3. Update mutation providers (update status, cancel, etc.)
4. Test all actions

**Estimated Time:** 30 minutes

---

#### Task 9: Request Detail Screen (Hooks Version)
**File:** `shared/request_detail/request_detail_screen_hooks.dart`

**Changes:** Same as Task 8

**Estimated Time:** 30 minutes

---

### Phase 2D: Admin Management Screens (Priority: HIGH)

#### Task 10: All Reports Management
**File:** `admin/all_reports_management_screen.dart`

**Changes:**
1. Import `supabase_report_providers.dart`
2. Update `allReportsProvider`
3. Update `filteredReportsProvider` (if using filters)
4. Update mutation providers (assign, verify, delete)
5. Test full CRUD

**Estimated Time:** 40 minutes

---

#### Task 11: All Reports Management (Hooks Version)
**File:** `admin/all_reports_management_screen_hooks.dart`

**Changes:** Same as Task 10

**Estimated Time:** 40 minutes

---

#### Task 12: All Requests Management
**File:** `admin/all_requests_management_screen.dart`

**Changes:**
1. Import `supabase_request_providers.dart`
2. Update `allRequestsProvider`
3. Update mutation providers
4. Test full CRUD

**Estimated Time:** 40 minutes

---

#### Task 13: Verification Screen
**File:** `admin/verification/verification_screen.dart`

**Changes:**
1. Import `supabase_report_providers.dart`
2. Update `reportsByStatusProvider('completed')`
3. Update `verifyReportProvider`
4. Test approve/reject flow

**Estimated Time:** 30 minutes

---

### Phase 2E: Admin List Screens (Priority: MEDIUM)

#### Task 14-16: Reports List Screens
**Files:**
- `admin/reports/reports_list_screen.dart`
- `admin/reports_list_screen.dart`
- `admin/reports_list_screen_hooks.dart`

**Changes:** Similar to Task 10

**Estimated Time:** 30 minutes each

---

### Phase 2F: Cleaner Screens (Priority: MEDIUM)

#### Task 17: Cleaner Management Screen
**File:** `admin/cleaner_management_screen.dart`

**Changes:**
1. Only uses `request_providers` for storage
2. Minimal changes (storage service only)

**Estimated Time:** 10 minutes

---

#### Task 18: Cleaner Management Screen (Hooks)
**File:** `admin/cleaner_management_screen_hooks.dart`

**Changes:** Same as Task 17

**Estimated Time:** 10 minutes

---

#### Task 19: Create Cleaning Report Screen
**File:** `cleaner/create_cleaning_report_screen.dart`

**Changes:**
1. Only imports `appwriteStorageServiceProvider` (can skip for now)
2. Update when migrating storage

**Estimated Time:** 5 minutes (or skip)

---

#### Task 20: Create Report Screen (Employee)
**File:** `employee/create_report_screen.dart`

**Changes:**
1. Import storage service only
2. Update storage calls

**Estimated Time:** 10 minutes

---

## 📊 Migration Priority Matrix

### Phase 2A: Critical Path (Day 1)
**Screens:** 5 screens
**Estimated Time:** 2 hours

1. ✅ Admin Dashboard (`admin_dashboard_screen.dart`)
2. ✅ Modern Dashboard (`modern_dashboard_screen.dart`)
3. ✅ Create Report (`employee/create_report_screen.dart`)
4. ✅ Create Request (`employee/create_request_screen.dart`)
5. ✅ Request History (`employee/request_history_screen.dart`)

**Why First:**
- Most used by employees (daily operations)
- Visible impact
- Basic CRUD functionality

---

### Phase 2B: Admin Essentials (Day 2)
**Screens:** 4 screens
**Estimated Time:** 2.5 hours

6. ✅ All Reports Management (`admin/all_reports_management_screen.dart`)
7. ✅ All Requests Management (`admin/all_requests_management_screen.dart`)
8. ✅ Request Detail (`shared/request_detail/request_detail_screen.dart`)
9. ✅ Verification Screen (`admin/verification/verification_screen.dart`)

**Why Second:**
- Admin operations (assign, verify)
- Management features
- Detail views

---

### Phase 2C: Hooks Versions (Day 3)
**Screens:** 6 screens
**Estimated Time:** 2.5 hours

10. ✅ All Reports Management (Hooks)
11. ✅ Create Request (Hooks)
12. ✅ Request History (Hooks)
13. ✅ Request Detail (Hooks)
14. ✅ Cleaner Management (Hooks)
15. ✅ Reports List (Hooks)

**Why Third:**
- Duplicate functionality (Hooks version)
- Lower priority
- Same logic as non-Hooks

---

### Phase 2D: Secondary Screens (Day 4)
**Screens:** 5 screens
**Estimated Time:** 1.5 hours

16. ✅ Reports List Screen (various versions)
17. ✅ Cleaner Management Screen
18. ✅ Create Cleaning Report Screen
19. ✅ Create Report Screen (Employee - storage)
20. ✅ Any remaining screens

**Why Last:**
- Less frequently used
- Partial migration (storage only)
- Redundant screens

---

## 🧪 Testing Strategy

### Per-Screen Testing Checklist

For each migrated screen:

- [ ] **Data Loading**
  - [ ] Screen loads without errors
  - [ ] Data displays correctly
  - [ ] Loading states work
  - [ ] Error states work

- [ ] **CRUD Operations**
  - [ ] Create works (if applicable)
  - [ ] Read/View works
  - [ ] Update works (if applicable)
  - [ ] Delete works (if applicable)

- [ ] **UI Updates**
  - [ ] UI refreshes after mutations
  - [ ] No manual refresh needed
  - [ ] Optimistic updates work (if implemented)

- [ ] **Error Handling**
  - [ ] Network errors handled
  - [ ] Validation errors displayed
  - [ ] User-friendly error messages

- [ ] **Edge Cases**
  - [ ] Empty states
  - [ ] Long lists
  - [ ] Concurrent operations
  - [ ] Offline behavior

---

### Integration Testing

After all screens migrated:

- [ ] **End-to-End Flows**
  - [ ] Employee creates report → Admin assigns → Cleaner completes → Admin verifies
  - [ ] Employee creates request → Admin assigns → Cleaner completes
  - [ ] Employee views history
  - [ ] Admin views all reports/requests
  - [ ] Admin filters/sorts data

- [ ] **Performance**
  - [ ] Lists load quickly (<2s)
  - [ ] No memory leaks
  - [ ] Smooth scrolling
  - [ ] Image uploads work

- [ ] **Data Integrity**
  - [ ] All fields saved correctly
  - [ ] Timestamps correct
  - [ ] Soft delete works
  - [ ] RLS policies enforced

---

## 📝 Code Review Checklist

Before marking screen as complete:

- [ ] All imports updated
- [ ] No Appwrite references remaining
- [ ] Error handling implemented
- [ ] Loading states implemented
- [ ] Comments updated (if any)
- [ ] No console errors
- [ ] No analyzer warnings
- [ ] Tested on both mobile and desktop
- [ ] Tested as different user roles (admin, employee, cleaner)

---

## ⚠️ Potential Issues & Solutions

### Issue 1: Department Filter Missing

**Problem:** Old providers had `departmentId` parameter, new ones don't.

**Solution:**
- Use `filteredReportsProvider` with `departmentFilter` set
- Or add department filter to `allReportsProvider` (extend service)

**Decision:** Use filter provider for now, extend later if needed.

---

### Issue 2: Realtime Updates

**Problem:** FutureProviders don't auto-refresh on database changes.

**Solution (Short-term):**
- Mutation providers auto-invalidate
- Manual refresh with pull-to-refresh

**Solution (Long-term - Phase 5):**
- Implement Supabase Realtime subscriptions
- Use `StreamProvider` with Realtime channel

---

### Issue 3: Provider Name Conflicts

**Problem:** Both files export same provider names.

**Solution:**
```dart
// Option 1: Qualified imports
import '../../providers/riverpod/supabase_report_providers.dart' as supabase;
final reports = ref.watch(supabase.allReportsProvider);

// Option 2: Hide old provider
import '../../providers/riverpod/supabase_report_providers.dart';
import '../../providers/riverpod/report_providers.dart' hide allReportsProvider;

// Option 3: Remove old import entirely (preferred)
import '../../providers/riverpod/supabase_report_providers.dart';
```

**Decision:** Option 3 (clean migration, no backward compat)

---

### Issue 4: Storage Service API Differences

**Problem:** Minor API differences between Appwrite and Supabase storage.

**Solution:**
- API is almost identical (both return `Future<String>` URL)
- Error types different (handle `StorageException` vs `AppwriteException`)
- Test thoroughly

---

## 📊 Progress Tracking

### Overall Progress

- **Total Screens**: 20
- **Completed**: 0
- **In Progress**: 0
- **Remaining**: 20
- **Progress**: 0%

---

### By Priority

| Priority | Total | Completed | Remaining | Progress |
|----------|-------|-----------|-----------|----------|
| HIGH | 13 | 0 | 13 | 0% |
| MEDIUM | 5 | 0 | 5 | 0% |
| LOW | 2 | 0 | 2 | 0% |

---

### By Type

| Type | Total | Completed | Remaining | Progress |
|------|-------|-----------|-----------|----------|
| Admin | 10 | 0 | 10 | 0% |
| Employee | 5 | 0 | 5 | 0% |
| Cleaner | 2 | 0 | 2 | 0% |
| Shared | 2 | 0 | 2 | 0% |
| Dashboard | 2 | 0 | 2 | 0% |

---

## 🎯 Success Criteria

Migration considered complete when:

- [x] All 20 screens updated
- [x] All imports changed to Supabase providers
- [x] All CRUD operations work
- [x] All tests pass
- [x] No Appwrite code references in screens
- [x] Performance acceptable (<2s load times)
- [x] Error handling working
- [x] Documentation updated

---

## 📚 Resources

### Documentation
- [Phase 2 Complete Guide](PHASE_2_REPORTS_REQUESTS_MIGRATION_COMPLETE.md)
- [Supabase Report Providers](lib/providers/riverpod/supabase_report_providers.dart)
- [Supabase Request Providers](lib/providers/riverpod/supabase_request_providers.dart)

### Example Code
See Phase 2 Complete Guide for code examples:
- Create report with image upload
- Filter and display reports
- Assign report to cleaner
- Verify report (admin)

---

**Status**: 🟡 READY TO START
**Estimated Total Time**: 8-10 hours
**Recommended Timeline**: 4 days (2-3 hours per day)

---

**Last Updated**: 2025-12-05
