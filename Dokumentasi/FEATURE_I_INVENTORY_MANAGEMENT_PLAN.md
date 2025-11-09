# 📦 FEATURE I: INVENTORY MANAGEMENT - COMPLETE PLAN

## 🎯 **OVERVIEW**

**NEW FEATURE APPROVED!** Sistem manajemen inventaris alat kebersihan untuk Cleaner & Admin.

**Business Value:** ⭐⭐⭐⭐⭐ (VERY HIGH)
- Prevent kehabisan stok
- Efisiensi operasional
- Request items workflow
- Real-time monitoring

**Estimated Time:** 12-15 hours
**Complexity:** Medium-High
**Priority:** High (approved by user)

---

## 📊 **FEATURE REQUIREMENTS**

### **Core Features:**

1. ✅ **Dashboard Overview**
   - Total items summary
   - Low stock warnings
   - Out of stock alerts
   - Recent activities
   - Stock level chart

2. ✅ **Search & Filter**
   - Search by item name
   - Filter by category
   - Filter by stock status
   - Sort options

3. ✅ **Stock Cards**
   - Item details
   - Current stock / max stock
   - Color-coded status indicators
   - Last updated info
   - Quick actions

4. ✅ **Stock Update** (Admin)
   - Add new items
   - Update stock quantity
   - Edit item details
   - Delete items
   - Batch operations

5. ✅ **Request Items** (Cleaner)
   - Request when low/out
   - Specify quantity
   - Add notes/reason
   - Track request status
   - Admin approval workflow

6. ✅ **Smart Features**
   - Low stock alerts (< 20%)
   - Out of stock alerts (0)
   - Auto-refresh (real-time)
   - Color-coded status
   - Notification badges

---

## 🏗️ **TECHNICAL ARCHITECTURE**

### **1. Data Models**

**`lib/models/inventory_item.dart`**
```dart
class InventoryItem {
  final String id;
  final String name;
  final String category; // 'alat', 'consumable', 'ppe'
  final int currentStock;
  final int maxStock;
  final int minStock; // threshold for low stock alert
  final String unit; // 'pcs', 'botol', 'pasang', etc.
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;
  
  // Computed
  double get stockPercentage => (currentStock / maxStock) * 100;
  StockStatus get status {
    if (currentStock == 0) return StockStatus.outOfStock;
    if (currentStock <= minStock) return StockStatus.lowStock;
    if (stockPercentage >= 50) return StockStatus.inStock;
    return StockStatus.mediumStock;
  }
}

enum StockStatus {
  inStock,      // > 50% - Green
  mediumStock,  // 20-50% - Yellow
  lowStock,     // < 20% - Red
  outOfStock,   // 0 - Gray
}

enum ItemCategory {
  alat('Alat Kebersihan'),
  consumable('Bahan Habis Pakai'),
  ppe('Alat Pelindung Diri');
}
```

**`lib/models/stock_request.dart`**
```dart
class StockRequest {
  final String id;
  final String itemId;
  final String itemName;
  final String requesterId; // cleaner userId
  final String requesterName;
  final int requestedQuantity;
  final String? notes;
  final RequestStatus status;
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? approvedByName;
  final String? rejectionReason;
}

enum RequestStatus {
  pending,
  approved,
  rejected,
  fulfilled,
}
```

**`lib/models/stock_history.dart`**
```dart
class StockHistory {
  final String id;
  final String itemId;
  final String itemName;
  final int previousStock;
  final int newStock;
  final int change; // +5 or -3
  final String type; // 'restock', 'usage', 'adjustment'
  final String? notes;
  final String updatedBy;
  final String updatedByName;
  final DateTime updatedAt;
}
```

---

### **2. Firestore Collections**

```
inventory/
  {itemId}/
    - id
    - name
    - category
    - currentStock
    - maxStock
    - minStock
    - unit
    - description
    - imageUrl
    - createdAt
    - updatedAt

stockRequests/
  {requestId}/
    - id
    - itemId
    - itemName
    - requesterId
    - requesterName
    - requestedQuantity
    - notes
    - status
    - requestedAt
    - approvedAt
    - approvedBy
    - approvedByName
    - rejectionReason

stockHistory/
  {historyId}/
    - id
    - itemId
    - itemName
    - previousStock
    - newStock
    - change
    - type
    - notes
    - updatedBy
    - updatedByName
    - updatedAt
```

---

### **3. Services**

**`lib/services/inventory_service.dart`**
```dart
class InventoryService {
  // CRUD Operations
  Future<void> addItem(InventoryItem item);
  Future<void> updateItem(String itemId, Map<String, dynamic> updates);
  Future<void> deleteItem(String itemId);
  
  // Stock Management
  Future<void> updateStock(String itemId, int newStock, String updatedBy);
  Future<void> addStock(String itemId, int quantity, String updatedBy);
  Future<void> reduceStock(String itemId, int quantity, String updatedBy);
  
  // Requests
  Future<void> createRequest(StockRequest request);
  Future<void> approveRequest(String requestId, String approvedBy);
  Future<void> rejectRequest(String requestId, String reason);
  Future<void> fulfillRequest(String requestId);
  
  // Queries
  Stream<List<InventoryItem>> streamAllItems();
  Stream<List<InventoryItem>> streamLowStockItems();
  Stream<List<StockRequest>> streamPendingRequests();
  Stream<List<StockHistory>> streamHistory(String itemId);
  
  // Analytics
  Future<Map<String, int>> getStockSummary();
  Future<List<InventoryItem>> getMostUsedItems(int limit);
}
```

---

### **4. Providers (Riverpod)**

**`lib/providers/riverpod/inventory_providers.dart`**
```dart
// Inventory Items
@riverpod
Stream<List<InventoryItem>> allInventoryItems(Ref ref);

@riverpod
Stream<List<InventoryItem>> lowStockItems(Ref ref);

@riverpod
Stream<List<InventoryItem>> outOfStockItems(Ref ref);

// Stock Requests
@riverpod
Stream<List<StockRequest>> pendingStockRequests(Ref ref);

@riverpod
Stream<List<StockRequest>> myStockRequests(Ref ref);

// Search & Filter
@riverpod
class InventoryFilterNotifier extends _$InventoryFilterNotifier {
  @override
  InventoryFilter build() => InventoryFilter();
  
  void updateSearchQuery(String query);
  void setCategory(ItemCategory? category);
  void setStatus(StockStatus? status);
}

@riverpod
List<InventoryItem> filteredInventoryItems(Ref ref);

// Summary Stats
@riverpod
Future<InventorySummary> inventorySummary(Ref ref);
```

---

### **5. UI Components**

#### **Screens:**

**`lib/screens/inventory/inventory_dashboard_screen.dart`**
- Overview stats
- Low stock alerts
- Recent activities
- Quick actions
- Chart: Stock levels

**`lib/screens/inventory/inventory_list_screen.dart`**
- Search bar
- Category filter chips
- Status filter chips
- Sort options
- Item cards grid

**`lib/screens/inventory/item_detail_screen.dart`**
- Full item details
- Stock level chart
- History timeline
- Update stock (admin)
- Request item (cleaner)

**`lib/screens/inventory/stock_requests_screen.dart`**
- Pending requests list
- Approve/reject actions
- Request history
- Filter by status

**`lib/screens/inventory/add_edit_item_screen.dart`** (Admin)
- Item form
- Category selection
- Stock input
- Image upload
- Save/update

#### **Widgets:**

**`lib/widgets/inventory/inventory_card.dart`**
- Item name + category
- Stock level bar
- Color-coded indicator
- Quick actions

**`lib/widgets/inventory/stock_level_indicator.dart`**
- Progress bar
- Color-coded by status
- Percentage text

**`lib/widgets/inventory/request_item_dialog.dart`**
- Quantity input
- Notes field
- Submit button

**`lib/widgets/inventory/update_stock_dialog.dart`** (Admin)
- Current stock display
- New stock input
- Add/reduce buttons
- Notes field

**`lib/widgets/inventory/stock_request_card.dart`**
- Requester info
- Item + quantity
- Status badge
- Approve/reject buttons (admin)

**`lib/widgets/inventory/inventory_stats_widget.dart`**
- Total items
- In stock count
- Low stock count
- Out of stock count

---

## 📝 **SAMPLE DATA**

### **Initial Inventory Items:**

```dart
final sampleInventory = [
  // ALAT KEBERSIHAN
  InventoryItem(
    name: 'Sapu',
    category: 'alat',
    currentStock: 15,
    maxStock: 20,
    minStock: 5,
    unit: 'pcs',
  ),
  InventoryItem(
    name: 'Pel',
    category: 'alat',
    currentStock: 8,
    maxStock: 10,
    minStock: 3,
    unit: 'pcs',
  ),
  InventoryItem(
    name: 'Kain Lap',
    category: 'alat',
    currentStock: 25,
    maxStock: 30,
    minStock: 10,
    unit: 'pcs',
  ),
  InventoryItem(
    name: 'Ember',
    category: 'alat',
    currentStock: 6,
    maxStock: 10,
    minStock: 3,
    unit: 'pcs',
  ),
  InventoryItem(
    name: 'Sikat Toilet',
    category: 'alat',
    currentStock: 4,
    maxStock: 10,
    minStock: 3,
    unit: 'pcs',
  ),
  
  // BAHAN HABIS PAKAI
  InventoryItem(
    name: 'Sabun Cuci',
    category: 'consumable',
    currentStock: 2,
    maxStock: 20,
    minStock: 5,
    unit: 'botol',
  ),
  InventoryItem(
    name: 'Disinfektan',
    category: 'consumable',
    currentStock: 0,
    maxStock: 15,
    minStock: 3,
    unit: 'botol',
  ),
  InventoryItem(
    name: 'Pembersih Lantai',
    category: 'consumable',
    currentStock: 8,
    maxStock: 15,
    minStock: 4,
    unit: 'botol',
  ),
  InventoryItem(
    name: 'Pewangi Ruangan',
    category: 'consumable',
    currentStock: 12,
    maxStock: 20,
    minStock: 5,
    unit: 'botol',
  ),
  InventoryItem(
    name: 'Tisu',
    category: 'consumable',
    currentStock: 18,
    maxStock: 30,
    minStock: 10,
    unit: 'box',
  ),
  
  // ALAT PELINDUNG DIRI
  InventoryItem(
    name: 'Sarung Tangan',
    category: 'ppe',
    currentStock: 15,
    maxStock: 25,
    minStock: 8,
    unit: 'pasang',
  ),
  InventoryItem(
    name: 'Masker',
    category: 'ppe',
    currentStock: 35,
    maxStock: 50,
    minStock: 15,
    unit: 'pcs',
  ),
  InventoryItem(
    name: 'Apron',
    category: 'ppe',
    currentStock: 7,
    maxStock: 10,
    minStock: 3,
    unit: 'pcs',
  ),
  InventoryItem(
    name: 'Sepatu Boots',
    category: 'ppe',
    currentStock: 5,
    maxStock: 8,
    minStock: 2,
    unit: 'pasang',
  ),
];
```

---

## 🎨 **COLOR CODING SYSTEM**

```dart
class StockStatusColors {
  static const inStock = Colors.green;        // > 50%
  static const mediumStock = Colors.amber;    // 20-50%
  static const lowStock = Colors.orange;      // < 20%
  static const outOfStock = Colors.red;       // 0
}
```

---

## ⏱️ **IMPLEMENTATION TIMELINE**

### **Day 1 (4 hours):**
- ✅ Create data models
- ✅ Setup Firestore collections
- ✅ Create inventory service
- ✅ Create providers
- ✅ Add sample data

### **Day 2 (4 hours):**
- ✅ Build inventory dashboard screen
- ✅ Build inventory list screen
- ✅ Create inventory card widget
- ✅ Create stock level indicator
- ✅ Search & filter functionality

### **Day 3 (3 hours):**
- ✅ Build item detail screen
- ✅ Create request item dialog
- ✅ Create update stock dialog
- ✅ Build stock requests screen
- ✅ Request approval workflow

### **Day 4 (2 hours):**
- ✅ Add/edit item screen (admin)
- ✅ Low stock alerts
- ✅ Real-time notifications
- ✅ Integration with main dashboard

### **Day 5 (2 hours):**
- ✅ Testing all features
- ✅ Bug fixes
- ✅ Polish UI
- ✅ Documentation

**Total:** 15 hours over 5 days

---

## 🔐 **ROLE-BASED PERMISSIONS**

### **Admin:**
- ✅ View all inventory
- ✅ Add new items
- ✅ Update stock
- ✅ Delete items
- ✅ View requests
- ✅ Approve/reject requests
- ✅ View history

### **Cleaner:**
- ✅ View all inventory
- ✅ Request items
- ✅ View own requests
- ❌ Update stock
- ❌ Add/delete items
- ❌ Approve requests

### **Employee:**
- ✅ View inventory (read-only)
- ❌ Request items (not their job)
- ❌ Any modifications

---

## 📱 **RESPONSIVE DESIGN**

### **Mobile:**
- Single column cards
- Bottom sheet for actions
- Swipe to refresh
- Floating action button

### **Tablet:**
- 2 column grid
- Side panel for filters
- Split view (list + detail)

### **Desktop:**
- 3-4 column grid
- Sidebar navigation
- Modal dialogs
- Data table option

---

## 🚀 **SMART FEATURES**

### **1. Low Stock Alerts**
```dart
// Auto-check every hour
if (item.currentStock <= item.minStock) {
  showNotification(
    'Low Stock Alert!',
    '${item.name} stock is low (${item.currentStock}/${item.maxStock})',
  );
}
```

### **2. Out of Stock Alerts**
```dart
if (item.currentStock == 0) {
  showCriticalNotification(
    'Out of Stock!',
    '${item.name} is out of stock. Request immediately!',
  );
}
```

### **3. Auto-refresh**
```dart
// Real-time updates from Firestore
Stream<List<InventoryItem>> streamAllItems() {
  return FirebaseFirestore.instance
    .collection('inventory')
    .snapshots()
    .map((snapshot) => snapshot.docs.map(...).toList());
}
```

### **4. Request Workflow**
```
Cleaner sees low stock
  ↓
Click "Request Item"
  ↓
Fill quantity + notes
  ↓
Submit request
  ↓
Admin gets notification
  ↓
Admin approves/rejects
  ↓
Cleaner gets notification
  ↓
If approved → Admin restocks
  ↓
Request marked as fulfilled
```

---

## 📊 **INTEGRATION WITH EXISTING FEATURES**

### **With Feature A (Real-time):**
- Auto-refresh inventory every 30s
- Live stock updates

### **With Feature B (Filtering):**
- Reuse filter chips pattern
- Search functionality

### **With Feature D (Charts):**
- Stock level charts
- Usage trends
- Category distribution

### **With Feature F (Notifications):**
- Low stock alerts
- Request approval notifications
- Out of stock warnings

### **With Feature G (Role Views):**
- Admin: Full inventory management
- Cleaner: View + request
- Employee: Read-only

---

## ✅ **SUCCESS CRITERIA**

- [ ] All CRUD operations working
- [ ] Search & filter functional
- [ ] Stock update reflected real-time
- [ ] Request workflow complete
- [ ] Low stock alerts working
- [ ] Color-coded status correct
- [ ] Responsive on all devices
- [ ] Sample data loaded
- [ ] 0 compilation errors
- [ ] Integration with main app

---

## 🎯 **FINAL IMPLEMENTATION ORDER**

**Updated Full Plan:**

1. ✅ Feature D: Data Visualization (DONE)
2. ⏳ Feature E: Export & Reports
3. ⏳ Feature F: Push Notifications
4. ⏳ Feature G: Role-based Views
5. ⏳ Feature H: Mobile Optimization
6. ⏳ **Feature I: Inventory Management** ← NEW!
7. ⏳ Testing & Documentation

**Total Timeline:** 8-9 working days (~47-60 hours)

---

## 💡 **FUTURE ENHANCEMENTS (Phase 2)**

- 📷 Barcode/QR code scanning
- 📈 Usage forecasting
- 🤖 Auto-reorder suggestions
- 📧 Email notifications to suppliers
- 📊 Advanced analytics dashboard
- 🔄 Supplier management
- 💰 Cost tracking
- 📝 Maintenance schedules

---

## 🎊 **READY TO START?**

**This is a COMPLETE, PRODUCTION-READY inventory management system!**

**Say "start Feature I" to begin implementation NOW!**

**OR say "continue E-H first" to do inventory later!**

Your choice! 🚀

