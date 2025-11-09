# ⚡ QUICK INTEGRATION CHECKLIST

Copy-paste commands dan code snippets untuk integrate Phase 4 files.

---

## 📁 STEP 1: COPY FILES

```bash
# Dari outputs folder ke project structure
cp request_card_widget_shared.dart lib/widgets/shared/request_card_widget.dart
cp request_detail_screen.dart lib/screens/shared/
cp request_history_screen.dart lib/screens/employee/
cp available_requests_widget.dart lib/widgets/cleaner/
cp request_management_widget.dart lib/widgets/admin/
```

---

## 🔌 STEP 2: ADD MISSING PROVIDER

**File:** `lib/providers/riverpod/request_providers.dart`

Tambahkan di akhir file (sebelum closing bracket):

```dart
/// Provider untuk get single request by ID (stream)
final requestByIdProvider = StreamProvider.family<Request?, String>((ref, requestId) {
  return ref.watch(requestServiceProvider).getRequestById(requestId);
});
```

---

## 🛠️ STEP 3: ADD SERVICE METHOD

**File:** `lib/services/request_service.dart`

Tambahkan method baru:

```dart
/// Get request by ID (stream for real-time updates)
Stream<Request?> getRequestById(String requestId) {
  return _firestore
      .collection('requests')
      .doc(requestId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return Request.fromFirestore(doc, null);
  });
}
```

---

## 👤 STEP 4: UPDATE EMPLOYEE HOME SCREEN

**File:** `lib/screens/employee/employee_home_screen.dart`

**A. Add import:**
```dart
import '../employee/request_history_screen.dart';
```

**B. Add navigation button (pilih salah satu):**

**Option 1 - Di AppBar actions:**
```dart
AppBar(
  title: const Text('Beranda'),
  actions: [
    IconButton(
      icon: const Icon(Icons.history),
      tooltip: 'Riwayat Request',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RequestHistoryScreen(),
          ),
        );
      },
    ),
  ],
)
```

**Option 2 - Di body sebagai button:**
```dart
// Di dalam Column atau ListView body
ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RequestHistoryScreen(),
      ),
    );
  },
  icon: const Icon(Icons.history),
  label: const Text('Lihat Riwayat Request'),
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16),
  ),
)
```

**Option 3 - Di Drawer (jika pakai DrawerMenuWidget):**
```dart
DrawerMenuItem(
  icon: Icons.history,
  title: 'Riwayat Request',
  onTap: () {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RequestHistoryScreen(),
      ),
    );
  },
),
```

---

## 🧹 STEP 5: UPDATE CLEANER HOME SCREEN

**File:** `lib/screens/cleaner/cleaner_home_screen.dart`

**A. Add import:**
```dart
import '../../widgets/cleaner/available_requests_widget.dart';
```

**B. Add widget di body (setelah stats cards):**
```dart
// Di dalam Column atau ListView.builder
Padding(
  padding: const EdgeInsets.all(16),
  child: AvailableRequestsWidget(
    onRequestAssigned: () {
      // Refresh stats atau provider lain jika perlu
      ref.invalidate(myAssignedRequestsProvider);
      
      // Optional: Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tugas berhasil diambil!'),
          duration: Duration(seconds: 2),
        ),
      );
    },
  ),
)
```

---

## 👨‍💼 STEP 6: UPDATE ADMIN HOME SCREEN

**File:** `lib/screens/admin/admin_home_screen.dart`

**A. Add import:**
```dart
import '../../widgets/admin/request_management_widget.dart';
```

**B. Add widget di body:**
```dart
// Di dalam Column atau ListView
Padding(
  padding: const EdgeInsets.all(16),
  child: RequestManagementWidget(
    onRequestUpdated: () {
      // Refresh all requests provider
      ref.invalidate(allRequestsProvider);
      
      // Optional: Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request berhasil diupdate'),
          duration: Duration(seconds: 2),
        ),
      );
    },
  ),
)
```

---

## ✅ STEP 7: VERIFY IMPORTS

Pastikan semua imports sudah ada di masing-masing file:

**request_detail_screen.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/request.dart';
import '../../providers/riverpod/request_providers.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
```

**request_history_screen.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/request.dart';
import '../../providers/riverpod/request_providers.dart';
import '../../widgets/shared/request_card_widget.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../shared/request_detail_screen.dart';
import '../../core/theme/app_theme.dart';
```

---

## 🧪 STEP 8: TEST FLOW

### **Employee Test:**
1. [ ] Open employee home screen
2. [ ] Create new request
3. [ ] Tap history button
4. [ ] See request in "All" tab
5. [ ] Try search
6. [ ] Try filter tabs
7. [ ] Tap card → see detail
8. [ ] Cancel pending request

### **Cleaner Test:**
1. [ ] Open cleaner home screen
2. [ ] See available requests widget
3. [ ] Try urgent filter
4. [ ] Tap "Ambil Tugas"
5. [ ] Confirm dialog
6. [ ] See success message
7. [ ] Request removed from available
8. [ ] Navigate to detail
9. [ ] Start → Complete with photo

### **Admin Test:**
1. [ ] Open admin home screen
2. [ ] See statistics
3. [ ] Try status filter
4. [ ] Try search
5. [ ] Tap assign button
6. [ ] Select cleaner
7. [ ] See success message
8. [ ] Try force cancel

---

## 🚨 TROUBLESHOOTING

### Error: "Provider requestByIdProvider not found"
**Fix:** Jalankan `Step 2` untuk add provider

### Error: "The method 'getRequestById' isn't defined"
**Fix:** Jalankan `Step 3` untuk add service method

### Error: Navigator operation failed
**Fix:** Pastikan sudah import screen dengan benar

### Empty state terus muncul
**Fix:** Check Firestore rules & data ada atau tidak

### Image upload gagal
**Fix:** Check Firebase Storage rules

---

## 📝 OPTIONAL: ADD NAMED ROUTES

**File:** `lib/main.dart`

Di `MaterialApp`, tambahkan routes:

```dart
MaterialApp(
  // ... existing code
  routes: {
    '/request_history': (context) => const RequestHistoryScreen(),
    '/request_detail': (context) {
      final requestId = ModalRoute.of(context)!.settings.arguments as String;
      return RequestDetailScreen(requestId: requestId);
    },
  },
)
```

Then navigate dengan:
```dart
// To history
Navigator.pushNamed(context, '/request_history');

// To detail
Navigator.pushNamed(
  context,
  '/request_detail',
  arguments: requestId,
);
```

---

## 🎉 DONE!

After completing all steps, your app should have:
- ✅ Request history screen untuk employee
- ✅ Request detail screen dengan role-based actions
- ✅ Available requests widget untuk cleaner
- ✅ Request management widget untuk admin
- ✅ Reusable request card widget

**Run the app:**
```bash
flutter pub get  # If needed
flutter run
```

**Happy coding! 🚀**
