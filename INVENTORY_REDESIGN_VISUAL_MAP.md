# 📦 Inventory Module - Visual Design Map

> **Status**: ✅ Phase 1 Complete
> **Updated**: 28 November 2024
> **Design System**: Modern Card-based UI with Pastel Palette

---

## 🎨 Visual Layout

### 1. **Inventory List Screen**

```
┌─────────────────────────────────────────────────────┐
│  [≡] Semua Inventaris                    [⋮]       │ ← AppBar (Gradient)
│      Kelola dan pantau semua item                  │
├─────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────┐ │
│  │  🔍 Cari item...                              │ │ ← Search Bar
│  └───────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────┤
│  ┌────┐  ┌──────┐  ┌──────┐  ┌────┐             │ │
│  │📱 │  │🧹    │  │💧    │  │🛡️  │             │ │ ← Category Chips
│  │All │  │Alat  │  │Cons. │  │PPE │  (Scrollable)│ │   (Horizontal Scroll)
│  └────┘  └──────┘  └──────┘  └────┘             │ │
├─────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────┐ │
│  │ ✓ Semua Status                         ▼     │ │ ← Status Dropdown
│  └───────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────┤
│  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ │
│  ┃ [PINK PASTEL CARD]                          ┃ │ ← Card #1 (Pink BG)
│  ┃ ┌──┐  Sapu Lantai      [✓ Stok Cukup]       ┃ │
│  ┃ │🧹│  Alat Kebersihan                        ┃ │
│  ┃ └──┘                                         ┃ │
│  ┃ Stok: 45/50 pcs                      90%    ┃ │
│  ┃ [████████████████░░] ← Progress Bar         ┃ │
│  ┃ [+ Tambah]  [✏ Edit]  [⋮]                   ┃ │
│  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ │
│                                                     │
│  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ │
│  ┃ [BLUE PASTEL CARD]                          ┃ │ ← Card #2 (Blue BG)
│  ┃ ┌──┐  Sabun Cuci      [⚠ Stok Rendah]       ┃ │
│  ┃ │💧│  Bahan Habis Pakai                      ┃ │
│  ┃ └──┘                                         ┃ │
│  ┃ Stok: 8/50 botol                     16%    ┃ │
│  ┃ [███░░░░░░░░░░░░░░░░] ← Progress Bar         ┃ │
│  ┃ [+ Tambah]  [✏ Edit]  [⋮]                   ┃ │
│  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ │
│                                                     │
│  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ │
│  ┃ [GREEN PASTEL CARD]                         ┃ │ ← Card #3 (Green BG)
│  ┃ ┌──┐  Sarung Tangan   [⚠ Stok Sedang]       ┃ │
│  ┃ │🛡️│ Alat Pelindung Diri                    ┃ │
│  ┃ └──┘                                         ┃ │
│  ┃ Stok: 22/50 pasang                   44%    ┃ │
│  ┃ [████████░░░░░░░░░░░] ← Progress Bar         ┃ │
│  ┃ [+ Tambah]  [✏ Edit]  [⋮]                   ┃ │
│  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 🎨 Color Palette Specification

### **Pastel Card Backgrounds** (Rotating)
```
Card #1 (index % 5 = 0): Pink   #FFF1F2 → Text: #BE123C
Card #2 (index % 5 = 1): Blue   #EFF6FF → Text: #1E40AF
Card #3 (index % 5 = 2): Green  #F0FDF4 → Text: #15803D
Card #4 (index % 5 = 3): Yellow #FEFCE8 → Text: #A16207
Card #5 (index % 5 = 4): Purple #FAF5FF → Text: #6B21A8
```

### **Category Colors**
```
🧹 Alat Kebersihan:
   Primary: #3B82F6 (Blue 500)
   Background: #EFF6FF (Blue 50)
   Icon: cleaning_services

💧 Bahan Habis Pakai (Consumable):
   Primary: #10B981 (Green 500)
   Background: #F0FDF4 (Green 50)
   Icon: water_drop

🛡️ Alat Pelindung Diri (PPE):
   Primary: #F59E0B (Amber 500)
   Background: #FFFBEB (Amber 50)
   Icon: security
```

### **Stock Status Colors**
```
✓ Stok Cukup (≥50%):
   Color: #10B981 (Green 500)
   Background: #D1FAE5 (Green 100)
   Icon: check_circle

⚠ Stok Sedang (30-49%):
   Color: #F59E0B (Amber 500)
   Background: #FDE68A (Amber 200)
   Icon: info

⚠ Stok Rendah (1-29% or ≤minStock):
   Color: #F97316 (Orange 500)
   Background: #FFEDD5 (Orange 100)
   Icon: warning

✕ Habis (0%):
   Color: #EF4444 (Red 500)
   Background: #FEE2E2 (Red 100)
   Icon: cancel
```

---

## 📐 Component Specifications

### **1. Inventory Card**

```
┌─────────────────────────────────────────────────┐
│ Margin: 16px (horizontal), 12px (vertical)      │
│ Border Radius: 12px                             │
│ Padding: 16px                                   │
│ Shadow: Subtle (0, 2px) blur 4px                │
│                                                 │
│ ┌────────────────────────────────────────────┐ │
│ │ HEADER ROW                                 │ │
│ │ ┌────┐  Item Name           [Status Badge]│ │
│ │ │Icon│  Category Label                    │ │
│ │ │56px│                                    │ │
│ │ └────┘                                    │ │
│ │   ↑                                       │ │
│ │ Icon Container:                           │ │
│ │ - Size: 56x56px                           │ │
│ │ - Radius: 12px                            │ │
│ │ - BG: White 30% opacity                   │ │
│ │ - Icon: 32px, category color              │ │
│ └────────────────────────────────────────────┘ │
│                                                 │
│ ┌────────────────────────────────────────────┐ │
│ │ STOCK INFO ROW                             │ │
│ │ Stok: 45/50 pcs              90%          │ │
│ │   ↑                           ↑           │ │
│ │ Body1 Bold              Body2 Bold (Color)│ │
│ └────────────────────────────────────────────┘ │
│                                                 │
│ ┌────────────────────────────────────────────┐ │
│ │ PROGRESS BAR                               │ │
│ │ [████████████████░░░░░░░░]                 │ │
│ │   ↑                                        │ │
│ │ Height: 6px, Radius: 3px                   │ │
│ │ BG: #E5E7EB, Fill: Status Color            │ │
│ └────────────────────────────────────────────┘ │
│                                                 │
│ ┌────────────────────────────────────────────┐ │
│ │ ACTION BUTTONS (Not in selection mode)     │ │
│ │ [+ Tambah]  [✏ Edit]  [⋮]                  │ │
│ │   ↑           ↑        ↑                   │ │
│ │ Outlined   Outlined  IconOnly              │ │
│ │ Min Height: 32px                           │ │
│ └────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

### **2. Status Badge**

```
┌──────────────────┐
│ [✓] Stok Cukup   │ ← Pill Shape (radius: 999px)
└──────────────────┘
   ↑        ↑
  Icon    Text
  14px   11px Bold

Padding: 8px (H), 4px (V)
Background: Status Background Color
Icon + Text: Status Color
```

### **3. Category Filter Chips**

```
Horizontal Scrollable Row:
┌────┐  ┌──────┐  ┌──────┐  ┌────┐
│📱 │  │🧹    │  │💧    │  │🛡️  │
│All │  │Alat  │  │Cons. │  │PPE │
└────┘  └──────┘  └──────┘  └────┘
  ↑        ↑
Active  Inactive

Active Chip:
- Background: #6366F1 (Primary)
- Text: White
- Shadow: Elevated
- Height: 40px
- Radius: 20px

Inactive Chip:
- Background: White
- Text: #6B7280 (Gray)
- Border: #E5E7EB (Gray)
- No shadow
```

---

## 📏 Typography Scale

```
Item Name:         16px, Bold (AdminTypography.cardTitle)
Category Label:    12px, Regular, Gray (#6B7280)
Stock Number:      14px, Semi-Bold
Stock Percentage:  14px, Bold, Status Color
Badge Text:        11px, Semi-Bold
Button Text:       14px, Medium
```

---

## 🔄 State Variations

### **1. Normal State**
- Pastel background (rotating)
- Subtle shadow
- No border

### **2. Selected State**
- Border: 2px, Card foreground color
- Shadow: Elevated (blur 8px)
- Checkbox visible

### **3. Selection Mode**
- Checkbox appears on left
- Action buttons hidden
- Long-press to toggle

---

## 📱 Responsive Behavior

```
Mobile (< 600px):
- Single column list
- Full width cards (margin 16px)
- Chips scroll horizontally

Tablet (600-1024px):
- Grid: 2 columns
- Card min-width: 280px

Desktop (> 1024px):
- Grid: 4 columns
- Larger spacing
```

---

## ✨ Interaction States

### **1. Card Tap**
- Normal: Navigate to detail
- Selection Mode: Toggle selection

### **2. Long Press**
- Enable selection mode
- Select current item

### **3. Buttons**
```
[+ Tambah] → Add stock dialog
[✏ Edit]   → Edit item screen
[⋮]        → More options menu
```

---

## 🎯 Design Principles

1. **Visual Hierarchy**: Clear distinction between card sections
2. **Scannability**: Easy to identify status at a glance
3. **Touch Targets**: Minimum 32px height for interactive elements
4. **Color Psychology**:
   - Green = Safe/Good
   - Amber/Orange = Warning
   - Red = Critical
5. **Consistency**: Uses AdminColors design system
6. **Accessibility**: Sufficient contrast ratios (WCAG AA)

---

## 📊 Stock Status Logic

```dart
if (currentStock == 0) → outOfStock (Red)
else if (currentStock <= minStock || percentage < 30) → lowStock (Orange)
else if (percentage < 50) → mediumStock (Amber)
else → inStock (Green)
```

---

## 🔗 Files Reference

| Component | File Path |
|-----------|-----------|
| Design Tokens | `lib/core/design/inventory_design_tokens.dart` |
| Card Widget | `lib/widgets/inventory/inventory_card.dart` |
| Filter Chips | `lib/widgets/inventory/category_filter_chips.dart` |
| List Screen | `lib/screens/inventory/inventory_list_screen.dart` |
| List Screen (Hooks) | `lib/screens/inventory/inventory_list_screen_hooks.dart` |

---

## ✅ Implementation Checklist

- [x] Design tokens file
- [x] Modern card widget with pastel backgrounds
- [x] Category filter chips (horizontal scroll)
- [x] Stock status badges with icons
- [x] Progress bars
- [x] Action buttons (Tambah, Edit, More)
- [x] Selection mode support
- [x] Gesture handling (tap, long-press)
- [x] Integration with existing providers
- [x] No breaking changes

---

## 🚀 Future Enhancements (Phase 2-4)

- [ ] Stats Summary Card
- [ ] Low Stock Alert Banner
- [ ] Enhanced Search & Filter
- [ ] Empty State Widget
- [ ] Grid View Toggle
- [ ] Smooth Animations
- [ ] Advanced Sorting
- [ ] Bulk Actions UI

---

**Generated**: 28 November 2024
**Design System**: AdminColors + Pastel Palette
**Status**: ✅ Production Ready
