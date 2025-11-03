# 🚀 REQUEST SERVICE REFACTORING ROADMAP
**Complete Implementation Guide - Phase 2 to Completion**

---

## 📋 **PHASE 1 SUMMARY (✅ COMPLETED)**

### Files Created:
1. ✅ `lib/models/request.dart` (400 lines)
2. ✅ `lib/services/request_service.dart` (550 lines)
3. ✅ `lib/providers/riverpod/request_providers.dart` (350 lines)

### Key Features Implemented:
- Request model with RequestStatus enum
- Business logic with validation (3 active limit)
- Riverpod state management
- Cleaner list provider
- Notification integration
- Soft delete support

---

## 🎨 **PHASE 2: UI REFACTORING** (Priority: HIGH)

### 📁 **Files to Modify:**

#### 1. `lib/screens/employee/create_request_screen.dart` (MAJOR REFACTOR)

**Current Issues:**
- Hardcoded for employee only
- No cleaner picker
- No request limit validation
- Direct firestore calls (should use RequestService)

**Changes Needed:**

```dart
// ==================== NEW IMPORTS ====================
import '../../providers/riverpod/request_providers.dart';
import '../../models/request.dart';
import '../../core/error/exceptions.dart';

// ==================== NEW STATE VARIABLES ====================
String? _selectedCleanerId;
String? _selectedCleanerName;
bool _showCleanerPicker = true; // Toggle untuk show/hide cleaner picker

// ==================== NEW WIDGETS TO ADD ====================

/// 1. Active Request Count Display (at top)
Widget _buildRequestLimitBanner() {
  final canCreate = ref.watch(canCreateRequestProvider);
  final activeCount = ref.watch(activeRequestCountProvider);
  
  return canCreate.when(
    data: (can) {
      if (!can) {
        return Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.red[700]),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Anda sudah memiliki 3 permintaan aktif. '
                  'Tunggu hingga salah satu selesai.',
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            ],
          ),
        );
      }
      
      return activeCount.when(
        data: (count) => Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              SizedBox(width: 12),
              Text(
                'Permintaan aktif: $count/3',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        loading: () => SizedBox.shrink(),
        error: (_, __) => SizedBox.shrink(),
      );
    },
    loading: () => SizedBox.shrink(),
    error: (_, __) => SizedBox.shrink(),
  );
}

/// 2. Cleaner Picker Section (NEW)
Widget _buildCleanerPicker() {
  final cleanersAsync = ref.watch(availableCleanersProvider);
  
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with toggle
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.person_outline, color: AppConstants.primaryColor),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Petugas (Opsional)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _selectedCleanerName ?? 'Tidak dipilih - akan di-assign otomatis',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _showCleanerPickerDialog(),
                child: Text(
                  _selectedCleanerId == null ? 'Pilih' : 'Ubah',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        
        // Selected cleaner card (if any)
        if (_selectedCleanerId != null) ...[
          Divider(height: 1),
          _buildSelectedCleanerCard(),
        ],
      ],
    ),
  );
}

/// 3. Selected Cleaner Card
Widget _buildSelectedCleanerCard() {
  return Padding(
    padding: EdgeInsets.all(16),
    child: Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, color: Colors.grey[600]),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedCleanerName ?? 'Unknown',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                'Petugas Kebersihan',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: Colors.grey),
          onPressed: () {
            setState(() {
              _selectedCleanerId = null;
              _selectedCleanerName = null;
            });
          },
        ),
      ],
    ),
  );
}

/// 4. Cleaner Picker Dialog (Modal Bottom Sheet)
Future<void> _showCleanerPickerDialog() async {
  final cleanersAsync = ref.read(availableCleanersProvider);
  
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Pilih Petugas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          
          // Cleaner List
          Expanded(
            child: cleanersAsync.when(
              data: (cleaners) {
                if (cleaners.isEmpty) {
                  return Center(
                    child: Text('Tidak ada petugas tersedia'),
                  );
                }
                
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: cleaners.length,
                  itemBuilder: (context, index) {
                    final cleaner = cleaners[index];
                    return _buildCleanerListItem(cleaner);
                  },
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// 5. Cleaner List Item
Widget _buildCleanerListItem(CleanerProfile cleaner) {
  final isSelected = _selectedCleanerId == cleaner.id;
  
  return Card(
    margin: EdgeInsets.only(bottom: 12),
    elevation: isSelected ? 4 : 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: isSelected 
            ? AppConstants.primaryColor 
            : Colors.grey[300]!,
        width: isSelected ? 2 : 1,
      ),
    ),
    child: InkWell(
      onTap: () {
        setState(() {
          _selectedCleanerId = cleaner.id;
          _selectedCleanerName = cleaner.name;
        });
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[300],
              backgroundImage: cleaner.photoUrl != null
                  ? NetworkImage(cleaner.photoUrl!)
                  : null,
              child: cleaner.photoUrl == null
                  ? Icon(Icons.person, color: Colors.grey[600])
                  : null,
            ),
            SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cleaner.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.task_alt, size: 14, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        'Tugas aktif: ${cleaner.activeTaskCount}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Select indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppConstants.primaryColor,
                size: 28,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey[400],
                size: 28,
              ),
          ],
        ),
      ),
    ),
  );
}

// ==================== REFACTOR _submitRequest() ====================

Future<void> _submitRequest() async {
  // Validate form
  if (!_formKey.currentState!.validate()) {
    _showError('Mohon lengkapi semua field yang wajib diisi');
    return;
  }

  // Check request limit FIRST
  final canCreate = await ref.read(canCreateRequestProvider.future);
  if (!canCreate) {
    _showError(
      'Anda sudah memiliki 3 permintaan aktif. '
      'Tunggu hingga salah satu selesai untuk membuat permintaan baru.',
    );
    return;
  }

  // Show confirmation
  final confirmed = await _showConfirmationDialog();
  if (!confirmed) return;

  setState(() => _isSubmitting = true);

  try {
    // Get image bytes if image selected
    Uint8List? imageBytes;
    if (_webImage != null) {
      imageBytes = _webImage;
    } else if (_selectedImage != null) {
      imageBytes = await _selectedImage!.readAsBytes();
    }

    // Create request using RequestActions
    final actions = ref.read(requestActionsProvider);
    final requestId = await actions.createRequest(
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
      assignedTo: _selectedCleanerId,           // NEW: Optional cleaner
      assignedToName: _selectedCleanerName,     // NEW: Cleaner name
      isUrgent: _isUrgent,
      preferredDateTime: _preferredDateTime,
      imageBytes: imageBytes,
    );

    if (!mounted) return;

    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedCleanerId != null
                    ? 'Permintaan berhasil dibuat dan ditugaskan ke $_selectedCleanerName'
                    : 'Permintaan berhasil dibuat dan menunggu petugas',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );

    // Navigate back
    Navigator.pop(context, true);
  } on ValidationException catch (e) {
    _logger.error('Validation error', e);
    _showError(e.message);
  } on FirestoreException catch (e) {
    _logger.error('Firestore error', e);
    _showError(e.message);
  } catch (e) {
    _logger.error('Unexpected error', e);
    _showError('Terjadi kesalahan. Silakan coba lagi.');
  } finally {
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}
```

**Widget Order in Build Method:**
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(...),
    body: SingleChildScrollView(
      child: Column(
        children: [
          // 1. Request Limit Banner (NEW)
          _buildRequestLimitBanner(),
          
          // 2. Cleaner Picker Section (NEW)
          _buildCleanerPicker(),
          
          // 3. Location Input (EXISTING)
          _buildLocationInput(),
          
          // 4. Description Input (EXISTING)
          _buildDescriptionInput(),
          
          // 5. Date/Time Picker (EXISTING)
          _buildDateTimePicker(),
          
          // 6. Photo Upload (EXISTING)
          _buildPhotoUpload(),
          
          // 7. Urgent Toggle (EXISTING)
          _buildUrgentToggle(),
          
          // 8. Submit Button (REFACTORED)
          _buildSubmitButton(),
        ],
      ),
    ),
  );
}
```

**Estimated Lines:** ~900 lines (from current 613 lines)

---

#### 2. `lib/main.dart` (MINOR UPDATE)

**Current State:**
```dart
'/create_request': (context) => const CreateRequestScreen(),
```

**No Changes Needed** - Route already exists! ✅

---

### 📊 **Phase 2 Checklist:**

- [ ] Backup existing `create_request_screen.dart`
- [ ] Add new imports (request_providers, request model)
- [ ] Add state variables (_selectedCleanerId, _selectedCleanerName)
- [ ] Implement `_buildRequestLimitBanner()`
- [ ] Implement `_buildCleanerPicker()`
- [ ] Implement `_buildSelectedCleanerCard()`
- [ ] Implement `_showCleanerPickerDialog()`
- [ ] Implement `_buildCleanerListItem()`
- [ ] Refactor `_submitRequest()` to use RequestActions
- [ ] Update widget order in build()
- [ ] Test validation (3 active limit)
- [ ] Test cleaner selection flow
- [ ] Test without cleaner selection (pending flow)

**Estimated Time:** 2-3 hours

---

## 🧪 **PHASE 3: INTEGRATION & TESTING** (Priority: HIGH)

### 📁 **Files to Test:**

#### 1. **Request Creation Flow**
```dart
Test Cases:
- [x] Create request WITHOUT cleaner selection
  → Status should be 'pending'
  → Notification sent to admins
  → Request appears in myRequestsProvider

- [x] Create request WITH cleaner selection
  → Status should be 'assigned'
  → Notification sent to cleaner + requester
  → Request appears in myRequestsProvider
  → Request appears in cleaner's myAssignedRequestsProvider

- [x] Create request when limit reached (3 active)
  → Should show error message
  → Should prevent creation
  → canCreateRequestProvider should return false

- [x] Create request with photo
  → Image should upload to Storage
  → imageUrl should be saved in request

- [x] Create request with urgent flag
  → isUrgent should be true
  → Notification should include urgent indicator

- [x] Create request with preferred datetime
  → preferredDateTime should be saved
  → Notification should include time info
```

#### 2. **Cleaner Self-Assign Flow**
```dart
Test Cases:
- [x] Cleaner sees pending requests
  → pendingRequestsProvider returns requests with status 'pending'

- [x] Cleaner self-assigns request
  → Status changes from 'pending' to 'assigned'
  → assignedTo = cleanerId
  → assignedBy = 'self'
  → Notification sent to requester

- [x] Cleaner cannot self-assign already assigned request
  → Should show error message
```

#### 3. **Request Lifecycle**
```dart
Test Cases:
- [x] Cleaner starts request
  → Status changes from 'assigned' to 'in_progress'
  → startedAt timestamp saved

- [x] Cleaner completes request
  → Status changes from 'in_progress' to 'completed'
  → completedAt timestamp saved
  → Notification sent to requester

- [x] Cleaner completes with photo
  → completionImageUrl saved
  → Photo uploaded to Storage

- [x] Employee cancels request
  → Status changes to 'cancelled'
  → Only works if status is pending/assigned
```

#### 4. **Provider Testing**
```dart
Test Cases:
- [x] myRequestsProvider
  → Returns only user's own requests
  → Real-time updates when status changes

- [x] pendingRequestsProvider
  → Returns only pending requests
  → Updates when request assigned

- [x] myAssignedRequestsProvider
  → Returns only cleaner's assigned requests
  → Updates real-time

- [x] canCreateRequestProvider
  → Returns false when 3 active requests
  → Returns true when < 3 active requests

- [x] availableCleanersProvider
  → Returns cleaners sorted by activeTaskCount
  → Shows correct task counts
```

### 📊 **Phase 3 Checklist:**

- [ ] Copy Phase 1 files to project
  - [ ] request.dart → lib/models/
  - [ ] request_service.dart → lib/services/
  - [ ] request_providers.dart → lib/providers/riverpod/
- [ ] Copy refactored create_request_screen.dart
- [ ] Run `flutter pub get`
- [ ] Test: Create request without cleaner
- [ ] Test: Create request with cleaner
- [ ] Test: Request limit validation
- [ ] Test: Cleaner self-assign
- [ ] Test: Start request
- [ ] Test: Complete request
- [ ] Test: Cancel request
- [ ] Test: Soft delete request
- [ ] Test: Provider streams
- [ ] Test: Notification delivery
- [ ] Fix any bugs found

**Estimated Time:** 3-4 hours

---

## 📱 **PHASE 4: ADDITIONAL SCREENS & WIDGETS** (Priority: MEDIUM)

### 📁 **New Files to Create:**

#### 1. `lib/widgets/shared/request_card_widget.dart` (NEW)

**Purpose:** Reusable card widget untuk menampilkan request di list

```dart
class RequestCardWidget extends StatelessWidget {
  final Request request;
  final VoidCallback onTap;
  final bool showAssignee;    // Show cleaner name or not
  final bool compact;         // Compact mode for lists

  // Similar structure to ReportCardWidget tapi untuk Request
  // Show: location, description, status, urgent badge, preferred time
}
```

**Estimated Lines:** ~200 lines

---

#### 2. `lib/screens/shared/request_detail_screen.dart` (NEW)

**Purpose:** Detail screen untuk melihat request lengkap

```dart
class RequestDetailScreen extends ConsumerWidget {
  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch request by ID
    // Show full details:
    // - Location, description, photos
    // - Requester info
    // - Assigned cleaner (if any)
    // - Status history
    // - Preferred datetime
    // - Completion info (if completed)
    
    // Actions (role-based):
    // Employee: Cancel (if pending/assigned)
    // Cleaner: Self-assign (if pending), Start, Complete
    // Admin: Assign, Reassign
  }
}
```

**Estimated Lines:** ~400 lines

---

#### 3. `lib/screens/employee/request_history_screen.dart` (NEW)

**Purpose:** Show all requests history for employee

```dart
class RequestHistoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(myRequestsProvider);
    
    // Features:
    // - List of all requests (sorted by date)
    // - Filter by status (pending, assigned, in_progress, completed)
    // - Search by location/description
    // - Pull to refresh
    // - Empty state
    
    // Tap to open RequestDetailScreen
  }
}
```

**Estimated Lines:** ~300 lines

---

#### 4. `lib/widgets/cleaner/available_requests_widget.dart` (NEW)

**Purpose:** Widget for cleaner to see and self-assign pending requests

```dart
class AvailableRequestsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingRequests = ref.watch(pendingRequestsProvider);
    
    // Features:
    // - List of pending requests
    // - Quick view: location, description, urgent badge
    // - Self-assign button on each card
    // - Filter by urgent/normal
    // - Empty state if no pending requests
  }
}
```

**Estimated Lines:** ~250 lines

---

#### 5. `lib/widgets/admin/request_management_widget.dart` (NEW)

**Purpose:** Admin widget to manage all requests

```dart
class RequestManagementWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allRequests = ref.watch(allRequestsProvider);
    
    // Features:
    // - View all requests
    // - Filter by status
    // - Assign/reassign cleaner
    // - View statistics
    // - Export data (future)
  }
}
```

**Estimated Lines:** ~350 lines

---

### 📊 **Phase 4 Checklist:**

- [ ] Create RequestCardWidget
- [ ] Create RequestDetailScreen
- [ ] Create RequestHistoryScreen
- [ ] Create AvailableRequestsWidget (cleaner)
- [ ] Create RequestManagementWidget (admin)
- [ ] Update employee_home_screen to show recent requests
- [ ] Update cleaner_home_screen to show available requests
- [ ] Update admin_dashboard to show request stats
- [ ] Add navigation routes for new screens
- [ ] Test all new screens
- [ ] Test navigation flow

**Estimated Time:** 4-5 hours

---

## 📚 **PHASE 5: DOCUMENTATION & POLISH** (Priority: LOW)

### 📁 **Files to Create/Update:**

#### 1. `docs/REQUEST_SERVICE_GUIDE.md` (NEW)

**Content:**
```markdown
# Request Service Documentation

## Overview
- What is Request Service
- Difference between Report and Request
- User flows

## Architecture
- Model structure
- Service layer
- Provider layer
- UI components

## API Reference
- RequestService methods
- RequestProvider methods
- RequestActions methods

## Usage Examples
- Create request
- Self-assign request
- Complete request

## Testing Guide
- Unit tests
- Integration tests
- Manual testing checklist
```

**Estimated Lines:** ~300 lines

---

#### 2. `docs/MIGRATION_GUIDE.md` (NEW)

**Content:**
```markdown
# Migration Guide: Adding Request Service

## Prerequisites
- Flutter project with Riverpod
- Firebase setup
- Existing Report system

## Step-by-Step Installation

### 1. Copy Files
- Copy request.dart
- Copy request_service.dart
- Copy request_providers.dart

### 2. Update Dependencies
- Check pubspec.yaml
- Run flutter pub get

### 3. Firestore Setup
- Create 'requests' collection
- Update security rules
- Create indexes

### 4. Update Existing Code
- Update create_request_screen
- Update navigation
- Update home screens

### 5. Testing
- Run test suite
- Manual testing checklist

## Troubleshooting
- Common errors
- Debug tips
```

**Estimated Lines:** ~400 lines

---

#### 3. `CHANGELOG.md` (UPDATE)

```markdown
## [v2.0.0] - 2025-11-XX

### Added
- 🆕 Request Service for personal service requests
- 🆕 Employee can select cleaner when creating request
- 🆕 Cleaner can self-assign from pending requests
- 🆕 Request limit validation (max 3 active per employee)
- 🆕 Cleaner picker UI with availability status
- 🆕 Request detail screen
- 🆕 Request history screen
- 🆕 Separate notification system for requests

### Changed
- ♻️ Refactored create_request_screen with cleaner selection
- ♻️ Updated notification_service to support requests
- ♻️ Improved state management with request_providers

### Fixed
- 🐛 Fixed request creation validation
- 🐛 Fixed notification delivery for requests
```

---

#### 4. Firestore Security Rules (UPDATE)

**File:** `firestore.rules`

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ==================== REQUESTS COLLECTION ====================
    match /requests/{requestId} {
      // Helper functions
      function isOwner() {
        return request.auth.uid == resource.data.requestedBy;
      }
      
      function isAssignedCleaner() {
        return request.auth.uid == resource.data.assignedTo;
      }
      
      function isAdmin() {
        return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      }
      
      function isCleaner() {
        return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'cleaner';
      }
      
      // Read rules
      allow read: if isOwner() || isAssignedCleaner() || isAdmin() || 
                     (isCleaner() && resource.data.status == 'pending');
      
      // Create rules
      allow create: if request.auth != null && 
                       request.resource.data.requestedBy == request.auth.uid;
      
      // Update rules
      allow update: if isOwner() ||           // Owner can cancel
                       isAssignedCleaner() ||  // Cleaner can update status
                       isAdmin() ||            // Admin can do anything
                       (isCleaner() && resource.data.status == 'pending'); // Self-assign
      
      // Delete rules (soft delete only)
      allow delete: if false; // No hard delete
    }
  }
}
```

---

#### 5. Firestore Indexes (NEW)

**File:** `firestore.indexes.json`

```json
{
  "indexes": [
    {
      "collectionGroup": "requests",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "requestedBy", "order": "ASCENDING" },
        { "fieldPath": "deletedAt", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "requests",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "deletedAt", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "requests",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "assignedTo", "order": "ASCENDING" },
        { "fieldPath": "deletedAt", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "requests",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "requestedBy", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "deletedAt", "order": "ASCENDING" }
      ]
    }
  ]
}
```

---

### 📊 **Phase 5 Checklist:**

- [ ] Write REQUEST_SERVICE_GUIDE.md
- [ ] Write MIGRATION_GUIDE.md
- [ ] Update CHANGELOG.md
- [ ] Update Firestore security rules
- [ ] Create Firestore indexes
- [ ] Add inline code comments
- [ ] Update README.md
- [ ] Create API documentation
- [ ] Add usage examples
- [ ] Record demo video (optional)

**Estimated Time:** 2-3 hours

---

## 📊 **COMPLETE TIMELINE SUMMARY**

| Phase | Priority | Time | Status |
|-------|----------|------|--------|
| Phase 1: Core Models & Services | CRITICAL | 2h | ✅ DONE |
| Phase 2: UI Refactoring | HIGH | 3h | ⏳ NEXT |
| Phase 3: Integration & Testing | HIGH | 4h | 📋 TODO |
| Phase 4: Additional Screens | MEDIUM | 5h | 📋 TODO |
| Phase 5: Documentation | LOW | 3h | 📋 TODO |
| **TOTAL** | | **17h** | **~6% Done** |

---

## 🎯 **RECOMMENDED EXECUTION ORDER**

### Week 1 (MVP):
```
Day 1-2: Phase 2 (UI Refactoring)
Day 3-4: Phase 3 (Integration & Testing)
Day 5: Bug fixes & stabilization
```

### Week 2 (Enhancement):
```
Day 1-2: Phase 4 (Additional Screens)
Day 3: Phase 5 (Documentation)
Day 4-5: User testing & feedback
```

---

## 🚨 **CRITICAL PATH ITEMS**

Must complete in order:
1. ✅ Phase 1 files (request.dart, request_service.dart, request_providers.dart)
2. ⏳ Phase 2: Refactor create_request_screen.dart
3. 📋 Phase 3: Test basic flow (create, self-assign, complete)
4. 📋 Fix critical bugs
5. 📋 Phase 4: Add detail screens
6. 📋 Phase 5: Documentation

Can be done in parallel:
- RequestCardWidget (Phase 4)
- Documentation (Phase 5)
- Security rules (Phase 5)

---

## 📝 **NOTES FOR NEXT CHAT SESSION**

If chat limit reached, continue with:

**Option A - Phase 2 (Recommended):**
```
"Lanjutkan Phase 2: Refactor create_request_screen.dart
dengan cleaner picker dan request limit validation"
```

**Option B - Phase 3 (If Phase 2 done):**
```
"Lanjutkan Phase 3: Integration testing
dan bug fixing untuk request service"
```

**Option C - Specific Issue:**
```
"Ada error di [specific part], tolong debug dan fix"
```

---

## 🔗 **QUICK REFERENCE**

### Files Already Created (Phase 1):
- ✅ `/mnt/user-data/outputs/request.dart`
- ✅ `/mnt/user-data/outputs/request_service.dart`
- ✅ `/mnt/user-data/outputs/request_providers.dart`

### Files to Modify (Phase 2):
- ⏳ `lib/screens/employee/create_request_screen.dart` (MAJOR)

### Files to Create (Phase 4):
- 📋 `lib/widgets/shared/request_card_widget.dart`
- 📋 `lib/screens/shared/request_detail_screen.dart`
- 📋 `lib/screens/employee/request_history_screen.dart`
- 📋 `lib/widgets/cleaner/available_requests_widget.dart`
- 📋 `lib/widgets/admin/request_management_widget.dart`

### Files to Create (Phase 5):
- 📋 `docs/REQUEST_SERVICE_GUIDE.md`
- 📋 `docs/MIGRATION_GUIDE.md`
- 📋 `firestore.rules` (update)
- 📋 `firestore.indexes.json` (new)

---

## ✅ **SUCCESS CRITERIA**

MVP is done when:
- [x] Phase 1 complete (models, service, providers)
- [ ] Phase 2 complete (UI refactored)
- [ ] Phase 3 complete (basic flow tested)
- [ ] Employee can create request
- [ ] Employee can select cleaner OR leave pending
- [ ] Request limit validation works
- [ ] Cleaner can self-assign pending requests
- [ ] Cleaner can complete requests
- [ ] Notifications working
- [ ] No critical bugs

Full feature complete when:
- [ ] All 5 phases done
- [ ] All test cases passed
- [ ] Documentation complete
- [ ] Security rules deployed
- [ ] User feedback incorporated

---

**🎉 END OF ROADMAP 🎉**

**Current Progress: Phase 1 Complete (6% of total work)**
**Next Action: Phase 2 - Refactor create_request_screen.dart**

Good luck! 🚀
