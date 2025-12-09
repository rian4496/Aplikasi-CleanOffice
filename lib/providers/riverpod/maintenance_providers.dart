// lib/providers/riverpod/maintenance_providers.dart
// SIM-ASET: Maintenance Providers

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/maintenance_log.dart';
import 'auth_providers.dart';

// ==================== SUPABASE CLIENT ====================
final _supabase = Supabase.instance.client;

// ==================== ALL MAINTENANCE LOGS PROVIDER ====================
final allMaintenanceLogsProvider = FutureProvider<List<MaintenanceLog>>((ref) async {
  final response = await _supabase
      .from('maintenance_logs')
      .select('''
        *,
        assets(name)
      ''')
      .order('created_at', ascending: false);

  return (response as List)
      .map((json) => MaintenanceLog.fromSupabase(json))
      .toList();
});

// ==================== MAINTENANCE BY STATUS PROVIDER ====================
final maintenanceByStatusProvider = FutureProvider.family<List<MaintenanceLog>, MaintenanceStatus>((ref, status) async {
  final response = await _supabase
      .from('maintenance_logs')
      .select('''
        *,
        assets(name)
      ''')
      .eq('status', status.toDatabase())
      .order('scheduled_at');

  return (response as List)
      .map((json) => MaintenanceLog.fromSupabase(json))
      .toList();
});

// ==================== PENDING MAINTENANCE PROVIDER ====================
final pendingMaintenanceProvider = FutureProvider<List<MaintenanceLog>>((ref) async {
  return ref.watch(maintenanceByStatusProvider(MaintenanceStatus.pending).future);
});

// ==================== MY ASSIGNED MAINTENANCE PROVIDER ====================
final myMaintenanceTasksProvider = FutureProvider<List<MaintenanceLog>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final response = await _supabase
      .from('maintenance_logs')
      .select('''
        *,
        assets(name)
      ''')
      .eq('technician_id', user.id)
      .inFilter('status', ['pending', 'in_progress'])
      .order('scheduled_at');

  return (response as List)
      .map((json) => MaintenanceLog.fromSupabase(json))
      .toList();
});

// ==================== MAINTENANCE FOR ASSET PROVIDER ====================
final maintenanceForAssetProvider = FutureProvider.family<List<MaintenanceLog>, String>((ref, assetId) async {
  final response = await _supabase
      .from('maintenance_logs')
      .select()
      .eq('asset_id', assetId)
      .order('created_at', ascending: false);

  return (response as List)
      .map((json) => MaintenanceLog.fromSupabase(json))
      .toList();
});

// ==================== UPCOMING MAINTENANCE PROVIDER ====================
final upcomingMaintenanceProvider = FutureProvider<List<MaintenanceLog>>((ref) async {
  final now = DateTime.now();
  final nextWeek = now.add(const Duration(days: 7));

  final response = await _supabase
      .from('maintenance_logs')
      .select('''
        *,
        assets(name)
      ''')
      .eq('status', 'pending')
      .gte('scheduled_at', now.toIso8601String())
      .lte('scheduled_at', nextWeek.toIso8601String())
      .order('scheduled_at');

  return (response as List)
      .map((json) => MaintenanceLog.fromSupabase(json))
      .toList();
});

// ==================== MAINTENANCE STATS PROVIDER ====================
final maintenanceStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final logs = await ref.watch(allMaintenanceLogsProvider.future);

  return {
    'total': logs.length,
    'pending': logs.where((l) => l.status == MaintenanceStatus.pending).length,
    'inProgress': logs.where((l) => l.status == MaintenanceStatus.inProgress).length,
    'completed': logs.where((l) => l.status == MaintenanceStatus.completed).length,
    'cancelled': logs.where((l) => l.status == MaintenanceStatus.cancelled).length,
  };
});
