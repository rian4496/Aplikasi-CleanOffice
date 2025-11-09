# 👥 FEATURE G: ROLE-BASED VIEWS - IMPLEMENTATION PLAN

## 🎯 **OVERVIEW**

Create fixed, role-specific dashboard layouts optimized for each user type (Admin, Cleaner, Employee).

**Estimated Time:** 5-6 hours  
**Complexity:** Medium  
**Approach:** Fixed layouts (not customizable)  

---

## 📋 **REQUIREMENTS**

### **3 User Roles:**

1. **Admin** - Management & oversight
   - Full dashboard access
   - All features visible
   - Analytics & charts
   - Management tools

2. **Cleaner** - Task execution focused
   - Task list priority
   - Performance metrics
   - Quick actions
   - Simplified interface

3. **Employee** - Report creation focused
   - Quick report button
   - My reports status
   - Simple interface
   - Limited access

---

## 🎨 **DESIGN APPROACH**

### **Admin Dashboard Layout:**
```
┌─────────────────────────────────────┐
│ [Stats Grid - 4 cards]              │
├─────────────────────────────────────┤
│ [Charts - 4 interactive]            │
├─────────────────────────────────────┤
│ [Recent Activities]  [Alerts]       │
├─────────────────────────────────────┤
│ [Quick Actions]                     │
└─────────────────────────────────────┘
```

### **Cleaner Dashboard Layout:**
```
┌─────────────────────────────────────┐
│ [Today's Tasks - Large Card]        │
├─────────────────────────────────────┤
│ [My Performance]                    │
├─────────────────────────────────────┤
│ [Available Tasks]                   │
├─────────────────────────────────────┤
│ [Recent Completed]                  │
└─────────────────────────────────────┘
```

### **Employee Dashboard Layout:**
```
┌─────────────────────────────────────┐
│ [Quick Report Button - Large]       │
├─────────────────────────────────────┤
│ [My Pending Reports]                │
├─────────────────────────────────────┤
│ [Recently Completed]                │
└─────────────────────────────────────┘
```

---

## 🏗️ **IMPLEMENTATION PLAN**

### **Phase 1: Admin Role Widgets (2 hours)**

**Already have most widgets! Just need to organize:**

**1. Update admin_dashboard_screen.dart**
- Already has stats, charts, activities
- Just need better organization
- Add quick actions panel

**2. Files to check/update:**
- ✅ admin_overview_widget.dart (stats)
- ✅ admin_analytics_widget.dart (charts)
- ✅ recent_activities_widget.dart
- ⏳ admin_quick_actions.dart (NEW)

---

### **Phase 2: Cleaner Role Widgets (1.5 hours)**

**Files to create:**

**1. `lib/widgets/cleaner/cleaner_dashboard_widget.dart`**
- Main dashboard layout for cleaner

**2. `lib/widgets/cleaner/today_tasks_card.dart`**
- Today's assigned tasks
- Urgent count
- Quick start button

**3. `lib/widgets/cleaner/my_performance_card.dart`**
- Tasks completed today/week
- Performance score
- Average time

**4. Update `lib/screens/cleaner/cleaner_home_screen.dart`**
- Use new dashboard widget
- Task-focused layout

---

### **Phase 3: Employee Role Widgets (1 hour)**

**Files to create:**

**1. `lib/widgets/employee/employee_dashboard_widget.dart`**
- Main dashboard layout

**2. `lib/widgets/employee/quick_report_card.dart`**
- Large "Create Report" button
- Quick location selector
- Common issues

**3. `lib/widgets/employee/my_reports_card.dart`**
- Pending reports list
- Status indicators

**4. Update `lib/screens/employee/employee_home_screen.dart`**
- Use new dashboard widget

---

### **Phase 4: Role Detection & Routing (30 min)**

**Update main navigation:**

**`lib/core/router/app_router.dart` or similar**
- Check user role
- Route to appropriate dashboard
- Already partially implemented

---

### **Phase 5: Testing (1 hour)**

- Test admin view
- Test cleaner view
- Test employee view
- Test role switching
- Verify permissions

---

## 📊 **SIMPLIFIED APPROACH**

**Since we already have:**
- ✅ Admin dashboard (fully functional)
- ✅ Basic cleaner screen
- ✅ Basic employee screen

**We just need to:**
1. ✅ Organize admin dashboard (already good)
2. **Enhance cleaner dashboard** (1.5h)
3. **Enhance employee dashboard** (1h)
4. Test (30min)

**Total: ~3 hours instead of 5-6!** ⚡

---

## 🎯 **WHAT'S ALREADY DONE:**

### **Admin Dashboard:** ✅ 90% Complete
- Stats cards ✅
- Charts ✅
- Recent activities ✅
- Filters ✅
- Export ✅
- Batch operations ✅

**Just need:** Quick actions panel (optional)

### **Cleaner Screen:** ⏳ 50% Complete
- Basic task list ✅
- Task cards ✅

**Need:** Dashboard organization, performance card

### **Employee Screen:** ⏳ 40% Complete
- Report creation ✅
- Basic reports list ✅

**Need:** Dashboard organization, quick actions

---

## 💡 **DECISION:**

### **Option A: Full Enhancement (5-6h)**
- Create all new widgets
- Complete redesign
- All features

### **Option B: Quick Enhancement (3h)** ⭐ RECOMMENDED
- Use existing widgets
- Better organization
- Focus on UX improvements

**I recommend Option B since we already have good foundations!**

---

## 🚀 **QUICK IMPLEMENTATION PLAN:**

### **1. Cleaner Dashboard Enhancement (1.5h)**
Create:
- `cleaner_dashboard_widget.dart` - Main layout
- `today_tasks_card.dart` - Today's tasks
- `cleaner_performance_card.dart` - Performance metrics

### **2. Employee Dashboard Enhancement (1h)**
Create:
- `employee_dashboard_widget.dart` - Main layout
- `quick_report_card.dart` - Large create button
- `my_reports_summary.dart` - Report status

### **3. Integration (30m)**
- Update cleaner_home_screen.dart
- Update employee_home_screen.dart
- Test all roles

**Total: 3 hours** ⚡

---

## ✅ **READY TO START?**

**I'll create:**
1. Cleaner dashboard widgets (1.5h)
2. Employee dashboard widgets (1h)
3. Integrate everything (30m)

**This will complete Feature G in ~3 hours!**

**Say "go" to start!** 🚀

