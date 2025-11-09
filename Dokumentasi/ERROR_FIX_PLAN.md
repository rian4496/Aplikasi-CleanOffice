# 🔧 ERROR FIX PLAN - Dari Screenshot

## 🚨 **ERRORS DETECTED:**

Dari screenshot VS Code, ada beberapa error:

### **1. Operator '+' not defined for type 'AsyncValue<int>'**
**Files affected:**
- admin_dashboard_screen.dart (Line 151, 135, 123)
- cleaner_home_screen.dart (Line 123, 135, 151, etc)

**Problem:**
```dart
// ❌ WRONG:
dart:undefined_operator
```

**Cause:** Mencoba menggunakan operator pada AsyncValue tanpa extract data

---

### **2. Method 'QuickAccessCard' not defined**
**Files affected:**
- cleaner_home_screen.dart (Line 361, 375, 389)
- admin_dashboard_screen.dart

**Problem:**
```dart
dart:undefined_method
```

**Cause:** Widget QuickAccessCard mungkin tidak di-import atau nama salah

---

### **3. Declaration '_boundQuickAccess' not referenced**
**Files affected:**
- Multiple locations (Line 318, 227, 440, 584, etc)

**Problem:** Unused variables/declarations

---

## 🎯 **ROOT CAUSES:**

1. **AsyncValue not handled properly**
   - Using AsyncValue without .when() or .value
   - Treating streams as regular values

2. **Missing imports**
   - QuickAccessCard widget not imported
   - Some widgets might be in wrong path

3. **Unused code**
   - Dead code that should be removed

---

## ✅ **SOLUTIONS:**

### **Solution 1: Fix AsyncValue Usage**

Find all instances of AsyncValue operations and fix:

```dart
// ❌ WRONG:
final count = ref.watch(someCountProvider);
final total = count + 10;  // Error!

// ✅ CORRECT:
final countAsync = ref.watch(someCountProvider);
final total = countAsync.when(
  data: (count) => count + 10,
  loading: () => 10,
  error: (_, __) => 10,
);
```

### **Solution 2: Fix QuickAccessCard**

Verify import and usage:

```dart
// Check import:
import '../../widgets/shared/quick_access_card_widget.dart';

// Usage should be:
QuickAccessCardWidget(  // Note: might be QuickAccessCardWidget, not QuickAccessCard
  icon: Icons.inventory,
  title: 'Inventaris',
  onTap: () {},
)
```

### **Solution 3: Remove Unused Code**

Clean up declarations that are not used.

---

## 🔧 **AUTOMATED FIX NEEDED:**

We need to:
1. Run build_runner first
2. Fix AsyncValue issues
3. Verify widget imports
4. Remove dead code

---

