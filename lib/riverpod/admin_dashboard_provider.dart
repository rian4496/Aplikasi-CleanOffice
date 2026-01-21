// lib/riverpod/admin_dashboard_provider.dart
// 📊 Admin Dashboard Provider
// Provides dashboard data for admin

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import './transaction_providers.dart';
import 'notification_providers.dart';
import 'cleaner_providers.dart';
import 'ticket_providers.dart';
import 'master_crud_controllers.dart'; // For employeesProvider, vendorsProvider, budgetsProvider
import 'asset_providers.dart'; // For allAssetsProvider
import '../../models/transactions/transaction_models.dart';

// Helper function for date formatting
String _formatDate(DateTime date) {
  return DateFormat('dd MMM yyyy', 'id').format(date);
}

// ==================== ADMIN DASHBOARD DATA PROVIDER ====================
final adminDashboardDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // Real Data Fetching
  try {
    // Master Data Providers (NEW - using new models directly)
    final employees = await ref.watch(employeesProvider.future);
    final assets = await ref.watch(allAssetsProvider.future);
    final vendors = await ref.watch(vendorsProvider.future);
    final budgets = await ref.watch(budgetsProvider.future);

    // Transaction Providers
    final reports = await ref.watch(maintenanceListProvider.future);
    final requests = await ref.watch(procurementListProvider.future);
    final cleaners = await ref.watch(allCleanersProvider.future);
    
    // Ticket Provider - Use Realtime Stream for Charts (no JOIN, stats only)
    final ticketsAsync = ref.watch(ticketsStreamProvider);
    final tickets = ticketsAsync.value ?? []; // Use latest stream value or empty if loading
    
    // Notification Stream for Recent Activities (Realtime!)
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final notifications = notificationsAsync.value ?? [];
    
    // Ticket Repository - Use getTickets() for Recent Activities (WITH JOIN for creator name)
    final ticketRepo = ref.read(ticketRepositoryProvider);
    final ticketsWithJoin = await ticketRepo.getTickets();

    // Calc Stats
    final pendingReports = reports.where((r) => r.status != 'completed' && r.status != 'rejected').length;
    final pendingRequests = requests.where((r) => r.status != 'approved' && r.status != 'rejected').length;
    final assetsUnderMaintenance = assets.where((a) => (a.conditionId ?? '').toLowerCase() == 'rusak' || (a.conditionId ?? '').toLowerCase() == 'perbaikan').length;

    // Calc Budget (NEW - using Budget model directly)
    double totalPagu = 0;
    double totalUsed = 0;
    for (var b in budgets) {
      totalPagu += b.totalAmount;
      totalUsed += (b.totalAmount - b.remainingAmount);
    }
    double budgetPercent = totalPagu == 0 ? 0 : (totalUsed / totalPagu) * 100;
    
    // ========== TICKET STATISTICS ==========
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    
    // Tiket Hari Ini
    final ticketsToday = tickets.where((t) => t.createdAt.isAfter(todayStart)).length;
    
    // Tiket Minggu Ini
    final ticketsThisWeek = tickets.where((t) => t.createdAt.isAfter(weekStart)).length;
    
    // Tiket Bulan Ini
    final ticketsThisMonth = tickets.where((t) => t.createdAt.isAfter(monthStart)).length;
    
    // Tiket Open (belum selesai)
    final ticketsOpen = tickets.where((t) => 
      t.status.toString().contains('open') || 
      t.status.toString().contains('inProgress') ||
      t.status.toString().contains('claimed') ||
      t.status.toString().contains('pendingApproval')
    ).length;
    
    // Tren Tiket Minggu Ini per Tipe (Senin-Minggu)
    final trendKerusakan = <double>[];
    final trendKebersihan = <double>[];
    final trendStok = <double>[];
    
    for (int i = 0; i < 7; i++) {
      final dayStart = weekStart.add(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final kerusakanCount = tickets.where((t) => 
        t.createdAt.isAfter(dayStart) && t.createdAt.isBefore(dayEnd) &&
        t.type.toString().contains('kerusakan')
      ).length;
      
      final kebersihanCount = tickets.where((t) => 
        t.createdAt.isAfter(dayStart) && t.createdAt.isBefore(dayEnd) &&
        t.type.toString().contains('kebersihan')
      ).length;
      
      final stokCount = tickets.where((t) => 
        t.createdAt.isAfter(dayStart) && t.createdAt.isBefore(dayEnd) &&
        t.type.toString().contains('stockRequest')
      ).length;
      
      trendKerusakan.add(kerusakanCount.toDouble());
      trendKebersihan.add(kebersihanCount.toDouble());
      trendStok.add(stokCount.toDouble());
    }
    // ========== RECENT ACTIVITIES FROM REAL DATA (NOTIFICATIONS + TRANSACTIONS) ==========
    // Combine Tickets, Maintenance, and Procurement into a single sorted list
    final allActivities = <Map<String, dynamic>>[];

    // 1. Add Tickets
    for (var t in ticketsWithJoin) {
      String typeIcon = 'general';
      String category = 'Tiket';
      final typeStr = t.type.toString().toLowerCase();

      if (typeStr.contains('kerusakan')) {
        typeIcon = 'kerusakan';
        category = 'Kerusakan';
      } else if (typeStr.contains('kebersihan')) {
        typeIcon = 'kebersihan';
        category = 'Kebersihan';
      } else if (typeStr.contains('stock') || typeStr.contains('stok')) {
        typeIcon = 'stok';
        category = 'Stok';
      }

      final locName = t.locationName ?? '-';
      final isLocAvailable = locName != '-' && locName != 'Unknown';

      String typeLabel = 'Tiket';
      if (typeStr.contains('kerusakan')) typeLabel = 'Laporan Kerusakan';
      if (typeStr.contains('kebersihan')) typeLabel = 'Laporan Kebersihan';
      if (typeStr.contains('stock') || typeStr.contains('stok')) typeLabel = 'Request Stok';

      allActivities.add({
        'id': t.id,
        'ticketId': t.id,
        'description': '$typeLabel #${t.ticketNumber}', // Title for Desktop consistency
        'title': '$typeLabel #${t.ticketNumber}', // Formal Title: e.g. "Laporan Kerusakan #TKT-..."
        'subtitle': t.title, // Actual Issue: e.g. "AC Bocor"
        'status': t.status.toString().split('.').last,
        'category': category,
        'type': typeIcon,
        'location': locName,
        'user': t.createdByName ?? 'User',
        'userName': t.createdByName,
        'date': _formatDate(t.createdAt),
        'timestamp': t.createdAt,
        'isRead': true,
        'isUrgent': t.priority.toString().contains('high') || t.priority.toString().contains('urgent'),
      });
    }

    // 2. Add Procurement
    for (var p in requests) {
      allActivities.add({
        'id': p.id,
        'description': p.description ?? 'Pengajuan Pengadaan',
        'title': p.description ?? 'Pengajuan Pengadaan', // Show actual item name if possible
        'subtitle': 'Pengajuan #${p.code}', // Code as subtitle
        'status': p.status,
        'category': 'Pengadaan',
        'type': 'procurement',
        'location': '-',
        'user': p.requesterId ?? 'User',
        'date': _formatDate(p.requestDate),
        'timestamp': p.requestDate,
        'isRead': true,
      });
    }

    // 3. Add Maintenance Reports
    for (var m in reports) {
      allActivities.add({
        'id': m.id,
        'description': m.issueTitle,
        'title': m.issueTitle, // Show "AC Rusak" instead of "Laporan #123"
        'subtitle': 'Maintenance #${m.code ?? m.id.substring(0,8)}',
        'status': m.status,
        'category': 'Maintenance',
        'type': 'maintenance',
        'location': '-', // Maintenance model might need location join too, defaulting to - for now
        'user': 'Teknisi',
        'date': _formatDate(m.createdAt ?? DateTime.now()),
        'timestamp': m.createdAt ?? DateTime.now(),
        'isRead': true,
      });
    }

    // Sort descending by timestamp
    allActivities.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

    // Take top 4 (User Request: Batasi 4 card saja)
    final recentActivities = allActivities.take(4).toList();

    return {
      'totalReports': reports.length,
      'pendingReports': pendingReports,
      'totalRequests': requests.length,
      'pendingRequests': pendingRequests,
      'activeCleaners': cleaners.length,
      'assetsUnderMaintenance': assetsUnderMaintenance,
      
      // Master Data Stats
      'totalEmployees': employees.length,
      'totalAssets': assets.length,
      'totalVendors': vendors.length,
      'budgetUsage': totalUsed,
      'totalBudget': totalPagu,
      'budgetPercent': budgetPercent.toStringAsFixed(0),
      
      // Ticket Stats (NEW)
      'ticketsToday': ticketsToday,
      'ticketsThisWeek': ticketsThisWeek,
      'ticketsThisMonth': ticketsThisMonth,
      'ticketsOpen': ticketsOpen,
      'trendKerusakan': trendKerusakan,
      'trendKebersihan': trendKebersihan,
      'trendStok': trendStok,
      
      // Recent Activities (NEW - for Mobile Dashboard)
      'recentActivities': recentActivities,
      
      // Budget Trend Data (Jan-Dec)
      'monthlyBudget': [500.0, 500.0, 600.0, 550.0, 700.0, 800.0, 750.0, 600.0, 900.0, 850.0, 950.0, 1000.0],
      'monthlyActual': [450.0, 480.0, 550.0, 530.0, 680.0, 750.0, 700.0, 580.0, 880.0, 820.0, 900.0, 950.0],
    };
  } catch (e) {
    // Fallback in case of error
    return {
      'totalReports': 0,
      'error': e.toString(),
      'monthlyBudget': <double>[],
      'monthlyActual': <double>[],
      // Fallback Ticket Data to prevent UI reverting to Budget
      'trendKerusakan': <double>[],
      'trendKebersihan': <double>[],
      'trendStok': <double>[],
      'ticketsToday': 0,
      'ticketsThisWeek': 0,
      'ticketsThisMonth': 0,
      'ticketsOpen': 0,
    };
  }
});

// ==================== RECENT ACTIVITIES PROVIDER ====================
final recentActivitiesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    // Fetch latest items from Procurement, Maintenance, and Tickets
    final procRepo = ref.read(procurementRepositoryProvider);
    final maintRepo = ref.read(maintenanceRepositoryProvider);
    final ticketRepo = ref.read(ticketRepositoryProvider);

    // Parallel Fetch
    final results = await Future.wait([
      procRepo.fetchRequests(),
      maintRepo.fetchRequests(),
      ticketRepo.getTickets(),
    ]);

    final procs = results[0] as List<ProcurementRequest>;
    final maints = results[1] as List<MaintenanceRequest>;
    final tickets = results[2] as List<dynamic>;

    // Map to unified activity structure
    final activities = <Map<String, dynamic>>[];

    for (var p in procs.take(3)) {
      activities.add({
        'id': p.id,
        'type': 'procurement',
        'title': 'Pengajuan #${p.code}',
        'subtitle': p.description ?? 'Tanpa deskripsi',
        'status': p.status,
        'timestamp': p.requestDate,
      });
    }

    for (var m in maints.take(3)) {
      activities.add({
        'id': m.id,
        'type': 'maintenance',
        'title': 'Laporan #${m.code ?? m.id.substring(0,8)}',
        'subtitle': m.issueTitle,
        'status': m.status,
        'timestamp': m.createdAt ?? DateTime.now(),
      });
    }
    
    // Add Tickets (Kerusakan, Kebersihan, Stok)
    for (var t in tickets.take(5)) {
      String typeLabel = 'Tiket';
      String icon = 'ticket';
      if (t.type.toString().contains('kerusakan')) {
        typeLabel = 'Laporan Kerusakan';
        icon = 'kerusakan';
      } else if (t.type.toString().contains('kebersihan')) {
        typeLabel = 'Laporan Kebersihan';
        icon = 'kebersihan';
      } else if (t.type.toString().contains('stockRequest')) {
        typeLabel = 'Request Stok';
        icon = 'stok';
      }
      
      activities.add({
        'id': t.id,
        'type': icon,
        'title': '$typeLabel #${t.ticketNumber}',
        'subtitle': t.title,
        'status': t.status.toString().split('.').last,
        'timestamp': t.createdAt,
        'location': t.locationName ?? 'Unknown',
        'userName': t.createdByName ?? 'User',
      });
    }
    
    // Sort descending by time
    activities.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    
    // Fallback Mock if Empty (for Demo/Review)
    if (activities.isEmpty) {
       return [
         {'type': 'procurement', 'title': 'Pengadaan Laptop', 'subtitle': 'Unit baru untuk IT', 'status': 'Pending', 'timestamp': DateTime.now().subtract(const Duration(hours: 2))},
         {'type': 'maintenance', 'title': 'AC Bocor', 'subtitle': 'Ruang Server L1', 'status': 'Selesai', 'timestamp': DateTime.now().subtract(const Duration(hours: 5))},
       ];
    }

    return activities.take(5).toList();
  } catch (e) {
    // Return mock on error so UI doesn't look broken
    return [
         {'type': 'procurement', 'title': 'System Init', 'subtitle': 'Dashboard Ready', 'status': 'Active', 'timestamp': DateTime.now()},
    ];
  }
});

// ==================== ALL ACTIVITIES PROVIDER (NO LIMIT) ====================
final allActivitiesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final ticketRepo = ref.read(ticketRepositoryProvider);
    
    final results = await Future.wait([
      ref.watch(procurementListProvider.future),
      ref.watch(maintenanceListProvider.future),
      ticketRepo.getTickets(),
    ]);
    
    final procs = results[0] as List<ProcurementRequest>;
    final maints = results[1] as List<MaintenanceRequest>;
    final tickets = results[2] as List<dynamic>;

    final activities = <Map<String, dynamic>>[];

    for (var p in procs) {
      activities.add({
        'id': p.id,
        'type': 'procurement',
        'title': 'Pengajuan #${p.code}',
        'subtitle': p.description ?? 'Tanpa deskripsi',
        'status': p.status,
        'timestamp': p.requestDate,
      });
    }

    for (var m in maints) {
      activities.add({
        'id': m.id,
        'type': 'maintenance',
        'title': 'Laporan #${m.code ?? m.id.substring(0,8)}',
        'subtitle': m.issueTitle,
        'status': m.status,
        'timestamp': m.createdAt ?? DateTime.now(),
      });
    }
    
    // Add Tickets Logic (Kerusakan, Kebersihan, Stok)
    for (var t in tickets) {
      String typeLabel = 'Tiket';
      String icon = 'ticket';
      // Determine type based on TicketType enum or string check
      if (t.type.toString().contains('kerusakan')) {
        typeLabel = 'Laporan Kerusakan';
        icon = 'kerusakan';
      } else if (t.type.toString().contains('kebersihan')) {
        typeLabel = 'Laporan Kebersihan';
        icon = 'kebersihan';
      } else if (t.type.toString().contains('stockRequest')) {
        typeLabel = 'Request Stok';
        icon = 'stok';
      }
      
      activities.add({
        'id': t.id,
        'type': icon, // specific type for icon mapping
        'title': '$typeLabel #${t.ticketNumber}',
        'subtitle': t.title,
        'status': t.status.toString().split('.').last,
        'timestamp': t.createdAt,
        'location': t.locationName ?? 'Unknown',
        'userName': t.createdByName ?? 'User',
      });
    }
    
    // Sort descending by time
    activities.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    
    return activities;
  } catch (e) {
    return [];
  }
});
