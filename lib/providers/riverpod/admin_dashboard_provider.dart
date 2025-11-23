// lib/providers/riverpod/admin_dashboard_provider.dart
// 📊 Admin Dashboard Provider
// Provides dashboard data for admin

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../services/appwrite_database_service.dart';

part 'admin_dashboard_provider.g.dart';

@riverpod
Future<Map<String, dynamic>> adminDashboardData(
  AdminDashboardDataRef ref,
) async {
  // TODO: Implement real data fetching from Appwrite
  // For now, return mock data

  await Future.delayed(const Duration(milliseconds: 500));

  return {
    'totalReports': 42,
    'pendingReports': 8,
    'totalRequests': 15,
    'activeCleaners': 12,
    'completedToday': 18,
    'avgResponseTime': '2.5h',
  };
}

@riverpod
Future<List<Map<String, dynamic>>> recentActivities(
  RecentActivitiesRef ref,
) async {
  // TODO: Implement real data fetching
  await Future.delayed(const Duration(milliseconds: 300));

  return [
    {
      'type': 'verification',
      'reportId': '123',
      'title': 'Report #123 - Diverifikasi',
      'subtitle': 'Ruang Meeting A-1',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 2)),
    },
    {
      'type': 'assignment',
      'requestId': '45',
      'title': 'Request #45 - Ditugaskan',
      'subtitle': 'Assigned to John Doe',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'type': 'completion',
      'reportId': '122',
      'title': 'Report #122 - Selesai',
      'subtitle': 'Toilet Lantai 2',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
    },
  ];
}
