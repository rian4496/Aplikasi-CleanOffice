import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/transaction_repositories.dart';
import '../models/transactions/transaction_models.dart';
import '../models/transactions/disposal_model.dart';

// ==================== REPOSITORY PROVIDERS ====================

final procurementRepositoryProvider = Provider<ProcurementRepository>((ref) {
  final client = Supabase.instance.client;
  return ProcurementRepository(client);
});

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  final client = Supabase.instance.client;
  return MaintenanceRepository(client);
});

final disposalRepositoryProvider = Provider<DisposalRepository>((ref) {
  final client = Supabase.instance.client;
  return DisposalRepository(client);
});

// ==================== DATA PROVIDERS (ASYNC) ====================

// 1. Procurement List
final procurementListProvider = FutureProvider<List<ProcurementRequest>>((ref) async {
  final repo = ref.watch(procurementRepositoryProvider);
  return repo.fetchRequests();
  return repo.fetchRequests();
});

final procurementArchiveListProvider = FutureProvider<List<ProcurementRequest>>((ref) async {
  final repo = ref.watch(procurementRepositoryProvider);
  return repo.fetchArchivedRequests();
});

// 2. Maintenance List
final maintenanceListProvider = FutureProvider<List<MaintenanceRequest>>((ref) async {
  final repo = ref.watch(maintenanceRepositoryProvider);
  return repo.fetchRequests();
});

// 3. Disposal List
final disposalListProvider = FutureProvider<List<DisposalRequest>>((ref) async {
  final repo = ref.watch(disposalRepositoryProvider);
  return repo.fetchRequests();
});
