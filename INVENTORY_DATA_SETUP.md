# 📦 Inventory Data Setup Guide

## 🎯 Cara Generate Sample Data Inventory

Ada 3 cara untuk mengisi data inventory:

---

## ✅ **REKOMENDASI: Gunakan Dev Menu (Real-Time!)**

### **Langkah-langkah:**

1. **Login ke app** sebagai admin:
   - Email: `admin@kantor.com`
   - Password: [password Anda]

2. **Buka Dev Menu**:
   - Dari Home Screen → Buka Drawer → Cari "Dev Menu"
   - Atau navigasi langsung ke `DevMenuScreen`

3. **Pilih "Generate Inventory Data"**:
   - Scroll ke section "🌱 Sample Data Generator"
   - Tap "Generate Inventory Data"

4. **Dalam screen tersebut**:
   - **Current Count**: Lihat jumlah item saat ini
   - **Generate Data**: Tap untuk buat 8 sample items
   - **Clear All**: Tap untuk hapus semua data (reset)

5. **Sample Data yang Dibuat**:
   - ✅ 8 inventory items
   - ✅ Berbagai kategori (Alat, Consumable, PPE)
   - ✅ Berbagai status stok (High, Medium, Low, Out)
   - ✅ Perfect untuk testing semua fitur!

### **Keuntungan Dev Menu:**
- ✅ Real-time, langsung dari app
- ✅ Tidak perlu restart emulator
- ✅ Bisa generate ulang kapan saja
- ✅ Bisa clear all untuk reset
- ✅ Lihat count langsung

---

## 📁 **Option 2: Import JSON File**

### **Langkah-langkah:**

1. **Pastikan emulator sudah running:**
   ```bash
   cd D:\Flutter\Aplikasi-CleanOffice
   .\start-emulator.bat
   ```

2. **Import seed data:**
   ```bash
   .\import-seed-data.bat
   ```

3. **Restart app** untuk melihat data baru

### **File yang Digunakan:**
- `seed-data.json` - Contains 8 sample inventory items
- `import-seed-data.bat` - Script untuk import via curl

---

## 🖱️ **Option 3: Manual via Emulator UI**

### **Langkah-langkah:**

1. **Buka Emulator UI:**
   ```
   http://localhost:4000
   ```

2. **Klik tab "Firestore"**

3. **Start collection** dengan ID: `inventory`

4. **Add document** dengan format ini:

```json
{
  "id": "item_001",
  "name": "Sapu Ijuk",
  "category": "alat",
  "description": "Sapu untuk membersihkan lantai",
  "unit": "pcs",
  "currentStock": 25,
  "minStock": 5,
  "maxStock": 100,
  "location": "Gudang A - Rak 1",
  "imageUrl": "",
  "createdAt": "2025-11-08T10:00:00.000Z",
  "updatedAt": "2025-11-08T10:00:00.000Z",
  "createdBy": "hIq4FbvgETuco69SgglL",
  "createdByName": "ADMIN"
}
```

5. **Ulangi** untuk items lainnya (lihat `seed-data.json` untuk full list)

---

## 📊 **Sample Data yang Dihasilkan**

Setelah generate, Anda akan punya 8 items:

| No | Nama | Kategori | Stok | Status | Keterangan |
|----|------|----------|------|--------|------------|
| 1 | Sapu Ijuk | alat | 25/100 | ✅ Normal | Stok cukup |
| 2 | Kain Pel | alat | 15/50 | ✅ Normal | Stok cukup |
| 3 | Sabun Cuci | consumable | 3/100 | ⚠️ Low | **Testing alert!** |
| 4 | Pewangi | consumable | 0/50 | ❌ Out | **Testing alert!** |
| 5 | Masker N95 | ppe | 8/100 | 🔵 Medium | Mendekati min |
| 6 | Sarung Tangan | ppe | 45/200 | ✅ Normal | Stok bagus |
| 7 | Pembersih Lantai | consumable | 12/100 | 🔵 Medium | Mendekati min |
| 8 | Tissue Gulung | consumable | 120/500 | ✅ Normal | Stok tinggi |

---

## 🎨 **Categories & Icons**

| Category Value | Display Label | Icon | Contoh |
|----------------|---------------|------|--------|
| `alat` | Alat Kebersihan | cleaning_services | Sapu, Pel |
| `consumable` | Bahan Habis Pakai | inventory | Sabun, Tissue |
| `ppe` | Alat Pelindung Diri | health_and_safety | Masker, Sarung Tangan |

---

## 🔍 **Stock Status Logic**

Status ditentukan otomatis berdasarkan persentase:

```dart
// Status calculation in InventoryItem model
if (currentStock == 0) return StockStatus.outOfStock;  // ❌ 0%
if (percentage < 25) return StockStatus.lowStock;     // ⚠️ < 25%
if (percentage < 50) return StockStatus.mediumStock;  // 🔵 < 50%
return StockStatus.inStock;                           // ✅ >= 50%
```

---

## 🧪 **Testing Different Features**

### **1. Test Low Stock Alert:**
- Items: Sabun Cuci (3/100), Pewangi (0/50)
- Expected: Orange/Red badges muncul
- Expected: Admin dapat notifikasi (jika notification service aktif)

### **2. Test Analytics Charts:**
- Buka "Analitik Inventaris"
- Expected: Pie chart menunjukkan distribusi status
- Expected: Bar chart menunjukkan 10 item stok terendah

### **3. Test Export:**
- Pilih items → Batch export
- Expected: Excel/CSV berisi semua data
- Expected: Color-coded status cells di Excel

### **4. Test Stock History:**
- Tambah/kurangi stok item apapun
- Expected: Tercatat di Stock History
- Expected: Tampil di detail item

---

## 🔄 **Reset Data**

### **Via Dev Menu:**
```
Dev Menu → Generate Inventory Data → Clear All
```

### **Via Emulator UI:**
```
http://localhost:4000 → Firestore → inventory → Clear all data button
```

### **Via Manual:**
```bash
# Stop emulator
Ctrl + C

# Delete emulator data folder
rmdir /s /q emulator-data

# Start fresh
.\start-emulator.bat
```

---

## 🚀 **Quick Start Workflow**

```bash
# 1. Start emulator dengan persistence
.\start-emulator.bat

# 2. Jalankan app
flutter run

# 3. Login sebagai admin
# Email: admin@kantor.com

# 4. Buka Dev Menu → Generate Inventory Data

# 5. Tap "Generate Data"

# 6. Buka Dashboard Inventaris

# 7. ✅ Data siap digunakan!
```

---

## 📝 **Notes**

- ✅ Sample data menggunakan timestamp unik (tidak akan konflik)
- ✅ Data persist saat restart emulator (jika pakai start-emulator.bat)
- ✅ Bisa generate ulang tanpa konflik (ID unik dengan timestamp)
- ✅ createdBy menggunakan current logged-in user ID
- ⚠️ Jangan commit `emulator-data/` ke git jika ada data sensitif

---

**Happy Testing! 🎉**
