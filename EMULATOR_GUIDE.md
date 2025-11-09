# 🔥 Firebase Emulator - Panduan Lengkap

## 📋 Cara Menyimpan Data Emulator

Data Firebase Emulator secara default akan **hilang** saat emulator di-restart. Berikut cara menyimpan data secara permanen:

---

## ✅ **REKOMENDASI: Gunakan Script Auto-Save**

### 1️⃣ **Start Emulator dengan Auto-Save**

Gunakan script yang sudah disediakan:

```bash
# Double-click file ini di Windows Explorer:
start-emulator.bat

# Atau jalankan di terminal:
.\start-emulator.bat
```

**Apa yang dilakukan:**
- ✅ Import data yang sudah ada dari folder `emulator-data/`
- ✅ Start emulator
- ✅ Otomatis export data saat Anda stop emulator (Ctrl+C)

### 2️⃣ **Stop Emulator dengan Aman**

Tekan `Ctrl + C` di terminal untuk stop emulator. Data akan otomatis di-save!

---

## 💾 **Backup Manual (Opsional)**

Jika emulator sedang berjalan dan Anda ingin backup data tanpa stop:

```bash
# Double-click file ini:
backup-emulator.bat

# Atau jalankan di terminal:
.\backup-emulator.bat
```

---

## 🔧 **Command Manual (Jika Tidak Pakai Script)**

### Start dengan auto-save:
```bash
firebase emulators:start --import=./emulator-data --export-on-exit
```

### Export data saja (saat emulator running):
```bash
firebase emulators:export ./emulator-data
```

### Start dengan import data lama:
```bash
firebase emulators:start --import=./emulator-data
```

---

## 📁 **Struktur Folder Data**

Setelah backup, folder `emulator-data/` akan berisi:

```
emulator-data/
├── auth_export/
│   └── accounts.json          # User accounts
├── firestore_export/
│   └── firestore_export.overall_export_metadata
│   └── all_namespaces/
│       └── all_kinds/
│           └── all_namespaces_all_kinds.export_metadata
│           └── output-0       # Firestore data
└── storage_export/            # Storage files (images, etc)
```

---

## 🚀 **Best Practices**

### ✅ **DO:**
1. Selalu gunakan `start-emulator.bat` untuk start emulator
2. Stop emulator dengan `Ctrl+C` agar data ter-save
3. Commit folder `emulator-data/` ke git jika ingin share data dengan tim
4. Backup manual sebelum melakukan perubahan besar

### ❌ **DON'T:**
1. Jangan kill process emulator secara paksa (Task Manager)
2. Jangan hapus folder `emulator-data/` jika masih butuh data
3. Jangan commit `emulator-data/` ke public repo jika ada data sensitif

---

## 🔍 **Troubleshooting**

### **Problem: Data tidak tersimpan setelah restart**
**Solusi:** Pastikan Anda:
- ✅ Start emulator dengan `--export-on-exit` flag
- ✅ Stop emulator dengan `Ctrl+C` (bukan close terminal)
- ✅ Tunggu hingga muncul pesan "Export complete"

### **Problem: Error saat import data**
**Solusi:**
```bash
# Hapus folder lama dan buat fresh start
rm -rf emulator-data
firebase emulators:start --export-on-exit
```

### **Problem: Permission error setelah import**
**Solusi:** Firestore rules sudah diupdate di `firestore.rules`. Restart emulator untuk apply rules baru.

---

## 📊 **Emulator Ports**

Service yang berjalan:

| Service   | Port | URL                        |
|-----------|------|----------------------------|
| Firestore | 8080 | http://localhost:8080      |
| Auth      | 9099 | http://localhost:9099      |
| Storage   | 9199 | http://localhost:9199      |
| Functions | 5001 | http://localhost:5001      |
| Database  | 9000 | http://localhost:9000      |
| **UI**    | 4000 | http://localhost:4000      |

**Emulator UI:** Buka http://localhost:4000 untuk melihat data secara visual.

---

## 📝 **Tips**

### Seed Initial Data:

Buat file `seed-data.json`:
```json
{
  "users": {
    "admin1": {
      "email": "admin@test.com",
      "role": "supervisor",
      "name": "Admin Test"
    }
  },
  "inventory": {
    "item1": {
      "name": "Sapu",
      "category": "alat",
      "currentStock": 10,
      "minStock": 5,
      "maxStock": 50
    }
  }
}
```

Import via Emulator UI atau script.

---

## 🎯 **Workflow Pengembangan**

1. **Hari 1:**
   - Start emulator: `.\start-emulator.bat`
   - Input data test via app
   - Stop dengan Ctrl+C (data auto-saved)

2. **Hari 2:**
   - Start emulator: `.\start-emulator.bat` (data kemarin otomatis di-load!)
   - Lanjut development

3. **Share data dengan tim:**
   - Commit folder `emulator-data/` ke git
   - Tim lain pull dan langsung punya data yang sama

---

**Made with ❤️ for CleanOffice App**
