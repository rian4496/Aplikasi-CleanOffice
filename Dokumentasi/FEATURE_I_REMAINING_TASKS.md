# 📋 FEATURE I: REMAINING TASKS CHECKLIST

## ✅ **COMPLETED (30%):**

### **Phase 1: Models** ✅ DONE
- ✅ `lib/models/inventory_item.dart` (InventoryItem, StockRequest, enums)

### **Phase 2: Service** ✅ DONE
- ✅ `lib/services/inventory_service.dart` (CRUD, requests)

### **Phase 3: Widgets** ⏳ PARTIAL (1/5)
- ✅ `lib/widgets/inventory/inventory_card.dart`
- ⏳ NEED: stock_level_indicator.dart
- ⏳ NEED: request_item_dialog.dart
- ⏳ NEED: update_stock_dialog.dart
- ⏳ NEED: stock_request_card.dart

---

## ⏳ **REMAINING (70%):**

### **Phase 4: Providers** ❌ NOT STARTED
**File:** `lib/providers/riverpod/inventory_providers.dart`

**Need to create:**
```dart
@riverpod
Stream<List<InventoryItem>> allInventoryItems(Ref ref);

@riverpod
Stream<List<InventoryItem>> lowStockItems(Ref ref);

@riverpod
Stream<List<StockRequest>> pendingStockRequests(Ref ref);

@riverpod
Stream<List<StockRequest>> myStockRequests(Ref ref);
```

**Then run:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### **Phase 5: UI Screens** ❌ NOT STARTED

**Need to create 5 screens:**

**1. `lib/screens/inventory/inventory_dashboard_screen.dart`**
- Overview stats (total, low stock, out of stock)
- Quick actions
- Recent activity
- Navigate to list

**2. `lib/screens/inventory/inventory_list_screen.dart`**
- Search bar
- Category filter chips
- List of inventory cards
- FAB to add item (admin only)

**3. `lib/screens/inventory/item_detail_screen.dart`**
- Full item details
- Stock level visualization
- Update stock button (admin)
- Request item button (cleaner)
- History (optional)

**4. `lib/screens/inventory/stock_requests_screen.dart`**
- List of pending requests
- Approve/reject actions (admin)
- My requests view (cleaner)

**5. `lib/screens/inventory/add_edit_item_screen.dart`** (Admin only)
- Form to add/edit item
- Name, category, stock levels, unit
- Save button

---

### **Phase 6: Remaining Widgets** ❌ NOT STARTED

**Need 4 more widgets:**

**1. `lib/widgets/inventory/stock_level_indicator.dart`**
```dart
// Progress bar with color coding
// Show current/max stock
// Visual indicator
```

**2. `lib/widgets/inventory/request_item_dialog.dart`**
```dart
// Dialog for cleaner to request items
// Quantity input
// Notes field
// Submit button
```

**3. `lib/widgets/inventory/update_stock_dialog.dart`** (Admin)
```dart
// Dialog to update stock
// Current stock display
// New stock input
// Quick add/subtract buttons
// Save button
```

**4. `lib/widgets/inventory/stock_request_card.dart`**
```dart
// Display request info
// Requester name, item, quantity
// Status badge
// Approve/reject buttons (admin)
```

---

### **Phase 7: Sample Data** ❌ NOT STARTED

**Create:** `lib/data/sample_inventory.dart`

**14 Items to add:**

**Alat Kebersihan:**
1. Sapu (15/20 pcs)
2. Pel (8/10 pcs)
3. Kain Lap (25/30 pcs)
4. Ember (6/10 pcs)
5. Sikat Toilet (4/10 pcs)

**Bahan Habis Pakai:**
6. Sabun Cuci (2/20 botol) - LOW
7. Disinfektan (0/15 botol) - OUT
8. Pembersih Lantai (8/15 botol)
9. Pewangi Ruangan (12/20 botol)
10. Tisu (18/30 box)

**Alat Pelindung Diri:**
11. Sarung Tangan (15/25 pasang)
12. Masker (35/50 pcs)
13. Apron (7/10 pcs)
14. Sepatu Boots (5/8 pasang)

**Function to populate:**
```dart
Future<void> populateSampleInventory() async {
  final service = InventoryService();
  for (var item in sampleItems) {
    await service.addItem(item);
  }
}
```

---

### **Phase 8: Navigation Integration** ❌ NOT STARTED

**Update files:**

**1. `lib/screens/admin/admin_dashboard_screen.dart`**
- Add inventory card/button to dashboard
- Navigate to inventory list

**2. `lib/screens/cleaner/cleaner_home_screen.dart`**
- Add inventory access button
- Navigate to inventory list

**3. `lib/widgets/admin/admin_sidebar.dart`** (if exists)
- Add "Inventaris" menu item
- Icon: Icons.inventory

**4. Navigation routes** (wherever routes are defined)
```dart
'/inventory': (context) => InventoryDashboardScreen(),
'/inventory/list': (context) => InventoryListScreen(),
'/inventory/detail': (context) => ItemDetailScreen(),
'/inventory/requests': (context) => StockRequestsScreen(),
'/inventory/add': (context) => AddEditItemScreen(),
```

---

### **Phase 9: Notifications Integration** ❌ NOT STARTED

**Update:** `lib/services/inventory_service.dart`

**Add notification triggers:**
```dart
// When stock becomes low
if (item.status == StockStatus.lowStock) {
  await NotificationFirestoreService().sendNotification(
    userId: adminUserId,
    type: NotificationType.general,
    title: 'Stok Menipis!',
    message: '${item.name} stok tersisa ${item.currentStock}',
  );
}

// When request is approved
await NotificationFirestoreService().sendNotification(
  userId: request.requesterId,
  type: NotificationType.general,
  title: 'Request Disetujui',
  message: 'Request ${request.itemName} telah disetujui',
);
```

---

### **Phase 10: Testing** ❌ NOT STARTED

**Test checklist:**
- [ ] Add new item (admin)
- [ ] Update stock (admin)
- [ ] View inventory (all roles)
- [ ] Search items
- [ ] Filter by category
- [ ] Request item (cleaner)
- [ ] Approve request (admin)
- [ ] Reject request (admin)
- [ ] Low stock alert appears
- [ ] Out of stock alert appears
- [ ] Navigation works
- [ ] All data persists to Firestore

---

## 📊 **PROGRESS SUMMARY:**

| Phase | Status | Progress |
|-------|--------|----------|
| 1. Models | ✅ | 100% |
| 2. Service | ✅ | 100% |
| 3. Widgets | ⏳ | 20% (1/5) |
| 4. Providers | ❌ | 0% |
| 5. Screens | ❌ | 0% |
| 6. More Widgets | ❌ | 0% |
| 7. Sample Data | ❌ | 0% |
| 8. Navigation | ❌ | 0% |
| 9. Notifications | ❌ | 0% |
| 10. Testing | ❌ | 0% |
| **OVERALL** | **⏳** | **30%** |

---

## ⏱️ **TIME ESTIMATE:**

**Completed:** ~2.5 hours  
**Remaining:** ~9-10 hours

**Breakdown:**
- Providers: 1h
- Screens: 4-5h
- Widgets: 1.5h
- Sample data: 30min
- Navigation: 1h
- Notifications: 30min
- Testing: 1h

---

## 🎯 **PRIORITY ORDER:**

**CRITICAL (Must have for MVP):**
1. ✅ Models
2. ✅ Service
3. ⏳ Providers
4. ⏳ Inventory list screen
5. ⏳ Basic inventory card (done)
6. ⏳ Sample data
7. ⏳ Navigation integration

**IMPORTANT (Full functionality):**
8. Request item dialog
9. Update stock dialog
10. Stock requests screen
11. Notifications

**NICE TO HAVE (Polish):**
12. Dashboard screen
13. Item detail screen
14. Add/edit item screen

---

## 🚀 **NEXT SESSION STEPS:**

**START WITH:**
1. Create providers (1h)
2. Run build_runner
3. Create inventory_list_screen (1.5h)
4. Add sample data (30min)
5. Test basic flow

**THEN:**
6. Create dialogs (1h)
7. Create requests screen (1.5h)
8. Add navigation (1h)
9. Integration testing

---

## 📝 **FILES CREATED SO FAR:**

1. ✅ lib/models/inventory_item.dart
2. ✅ lib/services/inventory_service.dart
3. ✅ lib/widgets/inventory/inventory_card.dart

**Files to create: ~15 more**

---

## 🎊 **YOU'RE 30% THROUGH THE FINAL FEATURE!**

**Keep going! The finish line is in sight! 💪**

