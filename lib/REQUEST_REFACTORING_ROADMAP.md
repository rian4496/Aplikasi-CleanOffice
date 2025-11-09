# 🚀 REQUEST SERVICE REFACTORING - COMPLETE ROADMAP

**Project:** Clean Office Request Service Implementation  
**Created:** 2025-11-01  
**Status:** Phase 1 ✅ Complete | Phase 2-6 📋 Pending

---

## 📦 PHASE 1: CORE MODELS & SERVICES ✅ COMPLETE

### Files Created:
1. ✅ `lib/models/request.dart` (400 lines)
2. ✅ `lib/services/request_service.dart` (550 lines)
3. ✅ `lib/providers/riverpod/request_providers.dart` (350 lines)

### Status: **PRODUCTION READY**

---

## 🎨 PHASE 2: UI REFACTORING - CREATE REQUEST SCREEN

### Objective:
Refactor `create_request_screen.dart` untuk support:
- Multi-role (employee/admin)
- Cleaner picker (optional selection)
- Request limit validation (3 active max)
- Private request visibility

---

### 📋 TASK 2.1: Update Import Statements

**File:** `lib/screens/employee/create_request_screen.dart`

**Changes:**
```dart
// ADD THESE IMPORTS:
import '../../models/request.dart';
import '../../services/request_service.dart';
import '../../providers/riverpod/request_providers.dart';

// REMOVE (if exists):
// Old request-related imports
```

---

### 📋 TASK 2.2: Add Cleaner Picker UI Component

**Location:** Inside `_CreateRequestScreenState`

**Add State Variables:**
```dart
// Add to existing state variables
String? _selectedCleanerId;
String? _selectedCleanerName;
```

**Add Cleaner Picker Method:**
```dart
Future<void> _showCleanerPicker() async {
  final cleanersAsync = ref.read(availableCleanersProvider);
  
  await cleanersAsync.when(
    data: (cleaners) async {
      if (cleaners.isEmpty) {
        _showError('Tidak ada petugas tersedia saat ini');
        return;
      }

      final selected = await showModalBottomSheet<CleanerProfile>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Pilih Petugas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ],
                ),
              ),
              
              // Cleaner List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cleaners.length,
                  itemBuilder: (context, index) {
                    final cleaner = cleaners[index];
                    return _buildCleanerItem(cleaner);
                  },
                ),
              ),
            ],
          ),
        ),
      );

      if (selected != null) {
        setState(() {
          _selectedCleanerId = selected.id;
          _selectedCleanerName = selected.name;
        });
      }
    },
    loading: () => _showError('Memuat daftar petugas...'),
    error: (error, stack) => _showError('Gagal memuat petugas: $error'),
  );
}

Widget _buildCleanerItem(CleanerProfile cleaner) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey[300],
        backgroundImage: cleaner.photoUrl != null 
            ? NetworkImage(cleaner.photoUrl!)
            : null,
        child: cleaner.photoUrl == null 
            ? const Icon(Icons.person, color: Colors.white)
            : null,
      ),
      title: Text(
        cleaner.name,
        style: const TextStyle(fontWeight: FontWeight.w600