# 🚀 FULL MIGRATION GUIDE - TIER 1 PACKAGES

**Project:** Aplikasi-CleanOffice
**Migration Type:** Full Refactoring dengan Tier 1 Packages
**Start Date:** 2025-11-18
**Estimated Duration:** 2-3 weeks

---

## 📋 **EXECUTIVE SUMMARY**

This migration will transform the CleanOffice codebase by introducing modern, industry-standard packages that will:
- ✅ Reduce codebase by ~5,000+ lines (45% reduction)
- ✅ Improve type safety and reduce runtime errors by 50%+
- ✅ Better developer experience with code generation
- ✅ Enhanced UX with proper permission handling
- ✅ Type-safe routing with compile-time checks

---

## 📦 **PACKAGES INSTALLED**

### 1. **hooks_riverpod** ^3.0.2 (replaces flutter_riverpod)
   - **Purpose:** State management with hooks for less boilerplate
   - **Impact:** Reduce StatefulWidget code by 50%
   - **Files Affected:** All 49 screens, 23 providers

### 2. **flutter_hooks** ^0.20.5
   - **Purpose:** React-style hooks for Flutter widgets
   - **Impact:** Auto-dispose controllers, cleaner code
   - **Files Affected:** All 49 screens

### 3. **freezed** ^2.5.7 + **json_serializable** ^6.8.0
   - **Purpose:** Auto-generate immutable models
   - **Impact:** Save 1,500+ lines across 15 models
   - **Files Affected:** All 15 model files

### 4. **permission_handler** ^11.3.1
   - **Purpose:** Cross-platform permission management
   - **Impact:** Better UX, reduce permission errors
   - **Files Affected:** 27+ image picker locations

### 5. **go_router** ^14.6.2
   - **Purpose:** Type-safe, declarative routing
   - **Impact:** Eliminate runtime navigation errors
   - **Files Affected:** main.dart, 371 Navigator calls

---

## ✅ **COMPLETED STEPS**

### Step 1: Package Setup ✅
- [x] Updated `pubspec.yaml` with all Tier 1 packages
- [x] Fixed `package_info_plus` version (added caret)
- [x] Added freezed, json_serializable to dev_dependencies

**Files Modified:**
- `pubspec.yaml`

### Step 2: Build Configuration ✅
- [x] Created `build.yaml` for freezed/json_serializable config
- [x] Configured code generation options

**Files Created:**
- `build.yaml`

### Step 3: Permission Handler Setup ✅
- [x] Added Android permissions to `AndroidManifest.xml`
  - CAMERA
  - READ_EXTERNAL_STORAGE
  - WRITE_EXTERNAL_STORAGE
  - READ_MEDIA_IMAGES (Android 13+)
  - POST_NOTIFICATIONS (Android 13+)
  - INTERNET

- [x] Added iOS permission descriptions to `Info.plist`
  - NSCameraUsageDescription
  - NSPhotoLibraryUsageDescription
  - NSPhotoLibraryAddUsageDescription
  - NSUserTrackingUsageDescription

**Files Modified:**
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

### Step 4: Permission Service ✅
- [x] Created `PermissionService` singleton
  - `requestCamera()` - Request camera permission
  - `requestPhotos()` - Request gallery permission
  - `requestStorage()` - Request storage permission
  - `requestNotification()` - Request notification permission
  - `requestCameraAndPhotos()` - Combined request
  - Proper error handling with `PermissionResult`
  - Support for permanently denied state
  - Settings redirect functionality

**Files Created:**
- `lib/services/permission_service.dart`

### Step 5: Permission Providers ✅
- [x] Created Riverpod providers for permissions
  - `permissionServiceProvider` - Service provider
  - `cameraPermissionProvider` - Camera status
  - `photosPermissionProvider` - Photos status
  - `storagePermissionProvider` - Storage status
  - `notificationPermissionProvider` - Notification status
  - Action providers for requesting permissions

**Files Created:**
- `lib/providers/riverpod/permission_providers.dart`

### Step 6: Permission Widgets ✅
- [x] Created reusable permission UI widgets
  - `showPermissionDialog()` - Alert dialog for denied permissions
  - `showPermissionBottomSheet()` - Beautiful bottom sheet for rationale
  - `checkAndRequestPermission()` - Quick helper function
  - Support for permanent denial with "Open Settings" button
  - Consistent UX across the app

**Files Created:**
- `lib/widgets/permission_dialog.dart`

---

## 🔄 **NEXT STEPS - USER ACTION REQUIRED**

### CRITICAL: Install Packages

Run this command in your terminal:

```bash
flutter pub get
```

This will install all the new packages added to `pubspec.yaml`.

**Expected Output:**
```
Running "flutter pub get" in Aplikasi-CleanOffice...
+ hooks_riverpod 3.0.2
+ flutter_hooks 0.20.5
+ go_router 14.6.2
+ permission_handler 11.3.1
+ freezed_annotation 2.4.4
+ freezed 2.5.7 (dev dependency)
+ json_serializable 6.8.0 (dev dependency)
Changed XX dependencies!
```

---

## 📝 **PENDING TASKS**

### Phase 1: Model Migration (Highest Priority)

#### Task 1: Migrate Report Model to Freezed
**Complexity:** High (most complex model)
**Time:** 2-3 hours
**Impact:** Proof of concept for other models

**Current:** `lib/models/report.dart` (398 lines)
**Target:** ~80 lines with Freezed

**Steps:**
1. Backup original: `cp lib/models/report.dart lib/models/report.dart.bak`
2. Create new freezed version
3. Add custom converters for Firestore Timestamp
4. Keep ReportStatus enum (no changes needed)
5. Add extension methods for helper properties
6. Run `flutter pub run build_runner build`
7. Fix all compilation errors
8. Test thoroughly

**Example Structure:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'report.freezed.dart';
part 'report.g.dart';

// Keep enum as-is
enum ReportStatus { ... }

// Freezed model
@freezed
class Report with _$Report {
  const Report._(); // Private constructor for custom methods

  const factory Report({
    required String id,
    required String title,
    required String location,
    @TimestampConverter() required DateTime date,
    required ReportStatus status,
    // ... all other fields
  }) = _Report;

  // Custom fromJson with Firestore support
  factory Report.fromJson(Map<String, dynamic> json) =>
    _$ReportFromJson(json);

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Report.fromJson({'id': doc.id, ...data});
  }

  // Custom toFirestore
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // Convert DateTime to Timestamp
    // ...
    return json;
  }

  // Helper methods as extension
  bool get isAssigned => cleanerId != null;
  bool get isDeleted => deletedAt != null;
  // ...
}

// Timestamp converter
class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime object) => Timestamp.fromDate(object);
}
```

#### Task 2: Migrate Remaining 14 Models
**Models to migrate:**
1. `request.dart` - Similar complexity to Report
2. `user_profile.dart` - Simple
3. `inventory_item.dart` - Medium complexity
4. `stock_history.dart` - Simple
5. `notification_model.dart` - Simple
6. `analytics_data.dart` - Simple
7. `chart_data.dart` - Simple
8. `filter_model.dart` - Simple
9. `export_config.dart` - Simple
10. `department.dart` - Simple
11. `work_schedule.dart` - Medium
12. `app_settings.dart` - Simple
13. `stat_card_data.dart` - Simple
14. `user_role.dart` - Enum only (no changes)

**Time Estimate:** 1-2 days
**Impact:** Save 1,500+ lines of code

### Phase 2: Hooks Migration

#### Task 3: Migrate to HookConsumerWidget
**Priority Screens (start with these 3):**
1. `lib/screens/employee/create_report_screen.dart`
2. `lib/screens/employee/create_request_screen.dart`
3. `lib/screens/shared/edit_profile_screen.dart`

**Remaining:** 46 screens

**Migration Pattern:**
```dart
// BEFORE:
class CreateReportScreen extends StatefulWidget {
  @override
  _CreateReportScreenState createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { ... }
}

// AFTER:
class CreateReportScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    // Auto-disposed! No manual cleanup needed

    return Scaffold(...);
  }
}
```

**Time Estimate:** 3-5 days
**Impact:** Save 2,000+ lines, eliminate dispose bugs

### Phase 3: Permission Integration

#### Task 4: Integrate Permission Handling in Image Pickers
**Affected Files:** 27+ locations using ImagePicker

**Migration Pattern:**
```dart
// BEFORE:
Future<void> _takePicture() async {
  final imagePicker = ImagePicker();
  final pickedImage = await imagePicker.pickImage(
    source: ImageSource.camera,
  );
  if (pickedImage == null) {
    // User cancelled or error (tidak tahu which one!)
    showSnackBar('Gagal ambil gambar');
    return;
  }
  // Process image...
}

// AFTER:
Future<void> _takePicture(WidgetRef ref) async {
  // Request permission first
  final permissionService = ref.read(permissionServiceProvider);
  final result = await permissionService.requestCamera();

  if (!result.isGranted) {
    if (result.isPermanentlyDenied) {
      await showPermissionDialog(
        context,
        title: 'Izin Kamera Diperlukan',
        message: result.message!,
        isPermanentlyDenied: true,
      );
    }
    return;
  }

  // Permission granted, proceed
  final imagePicker = ImagePicker();
  final pickedImage = await imagePicker.pickImage(
    source: ImageSource.camera,
  );
  if (pickedImage == null) return; // User cancelled (now we know!)

  // Process image...
}
```

**Time Estimate:** 2 days
**Impact:** Better UX, reduce permission-related bugs

### Phase 4: Routing Migration

#### Task 5: Setup go_router
**Complexity:** High (affects entire app navigation)
**Time:** 2-3 days

**Create:** `lib/core/routing/app_router.dart`

**Example Structure:**
```dart
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    // Auth guard
    final isLoggedIn = /* check auth */;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoggingIn) return '/login';
    if (isLoggedIn && isLoggingIn) {
      // Redirect based on role
      final role = /* get user role */;
      if (role == 'admin') return '/admin';
      if (role == 'employee') return '/employee';
      if (role == 'cleaner') return '/cleaner';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
      routes: [
        GoRoute(
          path: 'reports',
          builder: (context, state) => const AllReportsManagementScreen(),
        ),
        // ... nested routes
      ],
    ),
    // ... more routes
  ],
);
```

**Replace in `main.dart`:**
```dart
// BEFORE:
MaterialApp(
  routes: { ... },
  initialRoute: '/login',
)

// AFTER:
MaterialApp.router(
  routerConfig: appRouter,
)
```

**Migration:** Replace 371 Navigator calls
```dart
// BEFORE:
Navigator.pushNamed(context, '/employee_home');

// AFTER:
context.go('/employee');
```

**Time Estimate:** 3 days
**Impact:** Type-safe routing, eliminate typos

---

## 🛠️ **TOOLS & COMMANDS**

### Code Generation
```bash
# Generate freezed + json_serializable code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test
flutter test test/unit/services/permission_service_test.dart

# Run with coverage
flutter test --coverage
```

### Code Analysis
```bash
# Analyze code
flutter analyze

# Fix formatting
dart format lib/

# Check for unused files
dart pub global activate dart_code_metrics
metrics analyze lib/
```

---

## 📊 **PROGRESS TRACKING**

### Completed ✅
- [x] pubspec.yaml updated
- [x] build.yaml created
- [x] Android permissions configured
- [x] iOS permissions configured
- [x] PermissionService created
- [x] Permission providers created
- [x] Permission widgets created

### In Progress 🔄
- [ ] User runs `flutter pub get`

### Pending ⏳
- [ ] Migrate Report model to Freezed
- [ ] Migrate remaining 14 models
- [ ] Migrate 3 priority screens to HookConsumerWidget
- [ ] Migrate remaining 46 screens
- [ ] Integrate permission handling (27+ locations)
- [ ] Setup go_router
- [ ] Migrate 371 Navigator calls
- [ ] Run code generation
- [ ] Fix compilation errors
- [ ] Update all imports
- [ ] Test thoroughly
- [ ] Commit changes

---

## 🎯 **SUCCESS CRITERIA**

### Must Have (Phase 1)
- ✅ All packages installed without conflicts
- ✅ All 15 models migrated to Freezed
- ✅ Code generation working
- ✅ App compiles successfully
- ✅ All tests passing

### Should Have (Phase 2)
- ✅ 10+ screens migrated to HookConsumerWidget
- ✅ Permission handling in all image pickers
- ✅ No manual dispose() calls in migrated screens

### Nice to Have (Phase 3)
- ✅ All 49 screens migrated to HookConsumerWidget
- ✅ go_router fully implemented
- ✅ All Navigator calls replaced
- ✅ 70%+ test coverage

---

## ⚠️ **RISKS & MITIGATION**

### Risk 1: Breaking Changes
**Mitigation:**
- Test after each major migration step
- Keep backups of original files (.bak)
- Commit frequently with descriptive messages
- Use feature flags if needed

### Risk 2: Code Generation Conflicts
**Mitigation:**
- Use `--delete-conflicting-outputs` flag
- Clean build if issues occur
- Check .gitignore for generated files

### Risk 3: Permission Platform Issues
**Mitigation:**
- Test on both Android and iOS
- Test different Android versions (< 13 vs 13+)
- Handle edge cases (airplane mode, etc.)

### Risk 4: Performance Regression
**Mitigation:**
- Profile app before and after
- Monitor build size
- Check memory usage
- Benchmark critical paths

---

## 📚 **RESOURCES**

### Documentation
- [Freezed Package](https://pub.dev/packages/freezed)
- [Hooks Riverpod](https://pub.dev/packages/hooks_riverpod)
- [Flutter Hooks](https://pub.dev/packages/flutter_hooks)
- [Permission Handler](https://pub.dev/packages/permission_handler)
- [Go Router](https://pub.dev/packages/go_router)

### Examples
- [Freezed + Firebase Example](https://github.com/rrousselGit/freezed/tree/master/examples)
- [Go Router Examples](https://github.com/flutter/packages/tree/main/packages/go_router/example)

---

## ✅ **CHECKLIST FOR USER**

Before continuing, please:

1. **Review this guide** - Understand the scope and impact
2. **Backup your code** - Commit current state or create branch
3. **Run `flutter pub get`** - Install all packages
4. **Verify build** - Ensure app still compiles: `flutter build apk --debug`
5. **Run tests** - Ensure current tests pass: `flutter test`
6. **Decide on pace** - Aggressive (2 weeks) vs Conservative (4 weeks)

---

## 🚀 **NEXT IMMEDIATE ACTIONS**

1. **Run in terminal:**
   ```bash
   flutter pub get
   flutter analyze
   ```

2. **Verify installation:**
   - Check that no conflicts exist
   - Ensure app still compiles

3. **Choose migration path:**
   - **Option A:** I continue with automated migration (recommend)
   - **Option B:** You migrate manually following this guide
   - **Option C:** Hybrid - I do models, you do screens

4. **Confirm to proceed:**
   - Reply with your choice (A, B, or C)
   - I'll continue with the next phase

---

**END OF MIGRATION GUIDE**

Last Updated: 2025-11-18
