// lib/services/realtime_service.dart
// Real-time auto-refresh service for Admin Dashboard

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/riverpod/admin_providers.dart';
import '../providers/riverpod/request_providers.dart';

class RealtimeService {
  Timer? _timer;
  final Ref ref;
  
  RealtimeService(this.ref);
  
  /// Start auto-refresh with configurable interval
  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    // Cancel existing timer if any
    _timer?.cancel();
    
    // Start new timer
    _timer = Timer.periodic(interval, (timer) {
      _refreshAllData();
    });
  }
  
  /// Stop auto-refresh
  void stopAutoRefresh() {
    _timer?.cancel();
    _timer = null;
  }
  
  /// Refresh all admin data by invalidating providers
  void _refreshAllData() {
    // Invalidate all providers to trigger Firestore re-fetch
    ref.invalidate(needsVerificationReportsProvider);
    ref.invalidate(allRequestsProvider);
    ref.invalidate(availableCleanersProvider);
    ref.invalidate(needsVerificationCountProvider);
    ref.invalidate(pendingReportsCountProvider);
  }
  
  /// Force refresh (for pull-to-refresh)
  void forceRefresh() {
    _refreshAllData();
  }
  
  /// Check for new urgent items
  /// Compares old vs new reports to detect newly added urgent items
  List<String> checkNewUrgentItems(
    List oldReports,
    List newReports,
  ) {
    final newUrgentIds = <String>[];
    
    for (var newReport in newReports) {
      // Check if report is urgent
      if (newReport.isUrgent == true) {
        // Check if this report existed in old list
        final existed = oldReports.any((old) => old.id == newReport.id);
        
        if (!existed) {
          // This is a NEW urgent report!
          newUrgentIds.add(newReport.id);
        }
      }
    }
    
    return newUrgentIds;
  }
  
  /// Clean up resources
  void dispose() {
    stopAutoRefresh();
  }
}

// Provider for RealtimeService
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final service = RealtimeService(ref);
  
  // Auto-dispose when no longer needed
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

// Provider for tracking last refresh time (simplified)
final lastRefreshTimeProvider = Provider<DateTime?>((ref) {
  return null;
});

// Provider for new urgent items detection (simplified)
final newUrgentItemsProvider = Provider<List<String>>((ref) {
  return [];
});
