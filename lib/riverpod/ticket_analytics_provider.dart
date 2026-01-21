// lib/riverpod/ticket_analytics_provider.dart
// 📊 Ticket Analytics Provider
// Provides extended analytics data for ticket statistics screen

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ticket_providers.dart';
import '../../models/ticket.dart';

// ==================== TIME PERIOD ENUM ====================
enum AnalyticsPeriod {
  thisWeek,
  thisMonth,
  threeMonths,
  oneYear,
}

// ==================== STATE CLASS ====================
class TicketAnalyticsState {
  final AnalyticsPeriod period;
  final bool isLoading;
  
  // Stats
  final int totalTickets;
  final int completedTickets;
  final int pendingTickets;
  final double avgResponseTimeHours;
  
  // Trend changes (vs previous period)
  final double totalChange;
  final double responseTimeChange;
  
  // Chart Data
  final List<double> volumeTrend; // For line chart
  final List<String> volumeLabels; // X-axis labels
  final Map<String, int> statusDistribution; // For pie chart
  final List<double> trendKerusakan;
  final List<double> trendKebersihan;
  final List<double> trendStok;
  final List<String> categoryLabels;
  
  // Top Locations
  final List<LocationStat> topLocations;
  
  const TicketAnalyticsState({
    this.period = AnalyticsPeriod.thisWeek,
    this.isLoading = true,
    this.totalTickets = 0,
    this.completedTickets = 0,
    this.pendingTickets = 0,
    this.avgResponseTimeHours = 0,
    this.totalChange = 0,
    this.responseTimeChange = 0,
    this.volumeTrend = const [],
    this.volumeLabels = const [],
    this.statusDistribution = const {},
    this.trendKerusakan = const [],
    this.trendKebersihan = const [],
    this.trendStok = const [],
    this.categoryLabels = const [],
    this.topLocations = const [],
  });
  
  TicketAnalyticsState copyWith({
    AnalyticsPeriod? period,
    bool? isLoading,
    int? totalTickets,
    int? completedTickets,
    int? pendingTickets,
    double? avgResponseTimeHours,
    double? totalChange,
    double? responseTimeChange,
    List<double>? volumeTrend,
    List<String>? volumeLabels,
    Map<String, int>? statusDistribution,
    List<double>? trendKerusakan,
    List<double>? trendKebersihan,
    List<double>? trendStok,
    List<String>? categoryLabels,
    List<LocationStat>? topLocations,
  }) {
    return TicketAnalyticsState(
      period: period ?? this.period,
      isLoading: isLoading ?? this.isLoading,
      totalTickets: totalTickets ?? this.totalTickets,
      completedTickets: completedTickets ?? this.completedTickets,
      pendingTickets: pendingTickets ?? this.pendingTickets,
      avgResponseTimeHours: avgResponseTimeHours ?? this.avgResponseTimeHours,
      totalChange: totalChange ?? this.totalChange,
      responseTimeChange: responseTimeChange ?? this.responseTimeChange,
      volumeTrend: volumeTrend ?? this.volumeTrend,
      volumeLabels: volumeLabels ?? this.volumeLabels,
      statusDistribution: statusDistribution ?? this.statusDistribution,
      trendKerusakan: trendKerusakan ?? this.trendKerusakan,
      trendKebersihan: trendKebersihan ?? this.trendKebersihan,
      trendStok: trendStok ?? this.trendStok,
      categoryLabels: categoryLabels ?? this.categoryLabels,
      topLocations: topLocations ?? this.topLocations,
    );
  }
}

class LocationStat {
  final String name;
  final int count;
  
  const LocationStat(this.name, this.count);
}

// ==================== NOTIFIER (Modern Riverpod 2.0+) ====================
class TicketAnalyticsNotifier extends Notifier<TicketAnalyticsState> {
  bool _initialLoadDone = false;
  
  @override
  TicketAnalyticsState build() {
    // Listen to ticket stream for realtime updates AFTER initial load
    ref.listen(ticketsStreamProvider, (previous, next) {
      if (_initialLoadDone && next.hasValue) {
        // Only reload on stream updates after initial load is done
        _processTickets(next.value ?? []);
      }
    });
    
    // Initial load using FutureProvider (faster than stream)
    _loadInitialData();
    return const TicketAnalyticsState();
  }
  
  void setPeriod(AnalyticsPeriod period) {
    state = state.copyWith(period: period, isLoading: true);
    _loadInitialData();
  }
  
  /// Fast initial load using FutureProvider
  void _loadInitialData() async {
    try {
      // Use allTicketsProvider which is a FutureProvider (faster)
      final tickets = await ref.read(allTicketsProvider.future);
      _initialLoadDone = true;
      _processTickets(tickets);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
  
  /// Process tickets and update state
  void _processTickets(List<Ticket> tickets) {
    if (tickets.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }
    
    final now = DateTime.now();
    final periodStart = _getPeriodStart(state.period, now);
    final previousPeriodStart = _getPreviousPeriodStart(state.period, periodStart);
    
    // Filter tickets for current period
    final periodTickets = tickets.where((t) => t.createdAt.isAfter(periodStart)).toList();
    final previousTickets = tickets.where((t) => 
      t.createdAt.isAfter(previousPeriodStart) && t.createdAt.isBefore(periodStart)
    ).toList();
    
    // Calculate stats - use enum comparison directly
    final completed = periodTickets.where((t) => 
      t.status == TicketStatus.completed
    ).length;
    
    final pending = periodTickets.where((t) => 
      t.status == TicketStatus.open || 
      t.status == TicketStatus.inProgress ||
      t.status == TicketStatus.claimed ||
      t.status == TicketStatus.pendingApproval
    ).length;
    
    // Calculate change %
    final prevTotal = previousTickets.length;
    final totalChange = prevTotal > 0 ? ((periodTickets.length - prevTotal) / prevTotal) * 100 : 0.0;
    
    // Status distribution - use enum comparison directly
    final statusDist = <String, int>{
      'Open': periodTickets.where((t) => t.status == TicketStatus.open || t.status == TicketStatus.pendingApproval).length,
      'In Progress': periodTickets.where((t) => t.status == TicketStatus.inProgress || t.status == TicketStatus.claimed).length,
      'Completed': completed,
      'Rejected': periodTickets.where((t) => t.status == TicketStatus.rejected).length,
    };
    
    // Volume trend and category breakdown
    final (volumeTrend, volumeLabels, trendK, trendB, trendS, catLabels) = _calculateTrends(periodTickets, state.period, periodStart, now);
    
    // Top locations
    final locationCounts = <String, int>{};
    for (final t in periodTickets) {
      final loc = t.locationName ?? 'Unknown';
      locationCounts[loc] = (locationCounts[loc] ?? 0) + 1;
    }
    final sortedLocations = locationCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topLocs = sortedLocations.take(5).map((e) => LocationStat(e.key, e.value)).toList();
    
    state = state.copyWith(
      isLoading: false,
      totalTickets: periodTickets.length,
      completedTickets: completed,
      pendingTickets: pending,
      avgResponseTimeHours: 2.5, // Placeholder - needs actual calculation
      totalChange: totalChange,
      responseTimeChange: -15.0, // Placeholder
      statusDistribution: statusDist,
      volumeTrend: volumeTrend,
      volumeLabels: volumeLabels,
      trendKerusakan: trendK,
      trendKebersihan: trendB,
      trendStok: trendS,
      categoryLabels: catLabels,
      topLocations: topLocs,
    );
  }
  
  DateTime _getPeriodStart(AnalyticsPeriod period, DateTime now) {
    switch (period) {
      case AnalyticsPeriod.thisWeek:
        return now.subtract(Duration(days: now.weekday - 1));
      case AnalyticsPeriod.thisMonth:
        return DateTime(now.year, now.month, 1);
      case AnalyticsPeriod.threeMonths:
        return DateTime(now.year, now.month - 2, 1);
      case AnalyticsPeriod.oneYear:
        return DateTime(now.year - 1, now.month, now.day);
    }
  }
  
  DateTime _getPreviousPeriodStart(AnalyticsPeriod period, DateTime currentStart) {
    switch (period) {
      case AnalyticsPeriod.thisWeek:
        return currentStart.subtract(const Duration(days: 7));
      case AnalyticsPeriod.thisMonth:
        return DateTime(currentStart.year, currentStart.month - 1, 1);
      case AnalyticsPeriod.threeMonths:
        return DateTime(currentStart.year, currentStart.month - 3, 1);
      case AnalyticsPeriod.oneYear:
        return DateTime(currentStart.year - 1, currentStart.month, currentStart.day);
    }
  }
  
  (List<double>, List<String>, List<double>, List<double>, List<double>, List<String>) _calculateTrends(
    List<Ticket> tickets, AnalyticsPeriod period, DateTime start, DateTime end
  ) {
    final volumeTrend = <double>[];
    final volumeLabels = <String>[];
    final trendK = <double>[];
    final trendB = <double>[];
    final trendS = <double>[];
    final catLabels = <String>[];
    
    int intervals;
    Duration step;
    
    switch (period) {
      case AnalyticsPeriod.thisWeek:
        intervals = 7;
        step = const Duration(days: 1);
        break;
      case AnalyticsPeriod.thisMonth:
        intervals = 4;
        step = const Duration(days: 7);
        break;
      case AnalyticsPeriod.threeMonths:
        intervals = 12;
        step = const Duration(days: 7);
        break;
      case AnalyticsPeriod.oneYear:
        intervals = 12;
        step = const Duration(days: 30);
        break;
    }
    
    final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    
    for (int i = 0; i < intervals; i++) {
      final intervalStart = start.add(step * i);
      final intervalEnd = intervalStart.add(step);
      
      final intervalTickets = tickets.where((t) => 
        t.createdAt.isAfter(intervalStart) && t.createdAt.isBefore(intervalEnd)
      ).toList();
      
      volumeTrend.add(intervalTickets.length.toDouble());
      
      // Labels
      if (period == AnalyticsPeriod.thisWeek) {
        volumeLabels.add(dayNames[intervalStart.weekday - 1]);
        catLabels.add(dayNames[intervalStart.weekday - 1]);
      } else if (period == AnalyticsPeriod.oneYear) {
        volumeLabels.add(monthNames[intervalStart.month - 1]);
        catLabels.add(monthNames[intervalStart.month - 1]);
      } else {
        volumeLabels.add('${intervalStart.day}/${intervalStart.month}');
        catLabels.add('${intervalStart.day}/${intervalStart.month}');
      }
      
      // Category breakdown - use enum value directly
      trendK.add(intervalTickets.where((t) => t.type == TicketType.kerusakan).length.toDouble());
      trendB.add(intervalTickets.where((t) => t.type == TicketType.kebersihan).length.toDouble());
      trendS.add(intervalTickets.where((t) => t.type == TicketType.stockRequest).length.toDouble());
    }
    
    return (volumeTrend, volumeLabels, trendK, trendB, trendS, catLabels);
  }
}

// ==================== PROVIDER (Modern Riverpod 2.0+) ====================
final ticketAnalyticsProvider = NotifierProvider<TicketAnalyticsNotifier, TicketAnalyticsState>(() {
  return TicketAnalyticsNotifier();
});
