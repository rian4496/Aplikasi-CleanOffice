import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_providers.dart';
import 'request_providers.dart';

class AdminStats {
  final int needsVerificationCount;
  final int pendingReportsCount;
  final int totalRequestsCount;
  final int activeCleanersCount;

  const AdminStats({
    required this.needsVerificationCount,
    required this.pendingReportsCount,
    required this.totalRequestsCount,
    required this.activeCleanersCount,
  });
}

final adminStatsProvider = Provider<AsyncValue<AdminStats>>((ref) {
  final departmentId = ref.watch(currentUserDepartmentProvider);
  
  final needsVerificationAsync = ref.watch(needsVerificationReportsProvider);
  final pendingReportsAsync = ref.watch(pendingReportsProvider);
  final allRequestsAsync = ref.watch(allRequestsProvider);
  final cleanersAsync = ref.watch(availableCleanersProvider);

  if (needsVerificationAsync.isLoading || 
      pendingReportsAsync.isLoading || 
      allRequestsAsync.isLoading || 
      cleanersAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (needsVerificationAsync.hasError || 
      pendingReportsAsync.hasError || 
      allRequestsAsync.hasError || 
      cleanersAsync.hasError) {
    return const AsyncValue.error('Failed to load stats', StackTrace.empty);
  }

  return AsyncValue.data(AdminStats(
    needsVerificationCount: needsVerificationAsync.value?.length ?? 0,
    pendingReportsCount: pendingReportsAsync.value?.length ?? 0,
    totalRequestsCount: allRequestsAsync.value?.length ?? 0,
    activeCleanersCount: cleanersAsync.value?.length ?? 0,
  ));
});
