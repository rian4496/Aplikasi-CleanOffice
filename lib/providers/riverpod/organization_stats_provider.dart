// lib/providers/riverpod/organization_stats_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/master/organization.dart';
import '../../models/master/organization_stats.dart';
import './master_providers.dart';
import './asset_providers.dart';
import './admin_providers.dart'; // For user profiles

// Map of Organization ID -> Stats
final organizationStatsProvider = FutureProvider<Map<String, OrganizationStats>>((ref) async {
  // 1. Fetch Data in Parallel
  final results = await Future.wait([
    ref.watch(organizationsProvider.future), // All Orgs
    ref.watch(allAssetsProvider.future),    // All Assets
    ref.watch(pendingVerificationUsersProvider.future), // All Users (using this existing provider)
  ]);

  final organizations = results[0] as List<Organization>;
  final assets = results[1] as dynamic; // Cast properly locally
  final users = results[2] as dynamic;

  final statsMap = <String, OrganizationStats>{};

  // 2. Initialize Map
  for (var org in organizations) {
    statsMap[org.id] = const OrganizationStats();
  }

  // 3. Aggregate Employee Counts
  final employeeCounts = <String, int>{};
  for (var user in (users as List)) {
    // Check if user has departmentId
    // We access it dynamically or cast to UserProfile if needed, but 'dynamic' for now to be safe with List type
    // In real code, we know it is List<UserProfile>
    final deptId = (user as dynamic).departmentId; 
    if (deptId != null && statsMap.containsKey(deptId)) {
      employeeCounts[deptId] = (employeeCounts[deptId] ?? 0) + 1;
    }
  }

  // 4. Aggregate Asset Counts
  final assetCounts = <String, int>{};
  for (var asset in (assets as List)) {
    final deptId = (asset as dynamic).departmentId;
    if (deptId != null && statsMap.containsKey(deptId)) {
      assetCounts[deptId] = (assetCounts[deptId] ?? 0) + 1;
    }
  }

  // 5. Populate Stats Map
  for (var org in organizations) {
    statsMap[org.id] = OrganizationStats(
      employeeCount: employeeCounts[org.id] ?? 0,
      assetCount: assetCounts[org.id] ?? 0,
    );
  }

  return statsMap;
});

// Helper to get stats for a specific org
final statsForOrganizationProvider = Provider.family<AsyncValue<OrganizationStats>, String>((ref, orgId) {
  final statsAsync = ref.watch(organizationStatsProvider);
  return statsAsync.whenData((map) => map[orgId] ?? const OrganizationStats());
});
