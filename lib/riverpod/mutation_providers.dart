// lib/riverpod/mutation_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transactions/asset_mutation.dart';
import '../services/features/mutation_service.dart';

// Service Provider
final mutationServiceProvider = Provider<MutationService>((ref) {
  return MutationService();
});

// List Provider
final mutationListProvider = FutureProvider.autoDispose.family<List<AssetMutation>, String?>((ref, status) async {
  final service = ref.watch(mutationServiceProvider);
  return service.getMutations(status: status);
});

// Detail Provider
final mutationDetailProvider = FutureProvider.autoDispose.family<AssetMutation?, String>((ref, id) async {
  final service = ref.watch(mutationServiceProvider);
  return service.getMutationById(id);
});

// Helper for UI Actions
final mutationActionsProvider = Provider((ref) => MutationActions(ref));

class MutationActions {
  final Ref _ref;
  
  MutationActions(this._ref);

  Future<void> createMutation(AssetMutation mutation) async {
    final service = _ref.read(mutationServiceProvider);
    await service.createMutation(mutation);
    _ref.invalidate(mutationListProvider);
  }

  Future<void> approveMutation(String id, String approverId) async {
    final service = _ref.read(mutationServiceProvider);
    await service.approveMutation(id, approverId);
    _ref.invalidate(mutationListProvider);
    _ref.invalidate(mutationDetailProvider(id));
  }

  Future<void> rejectMutation(String id, String approverId, String reason) async {
    final service = _ref.read(mutationServiceProvider);
    await service.rejectMutation(id, approverId, reason);
    _ref.invalidate(mutationListProvider);
    _ref.invalidate(mutationDetailProvider(id));
  }
}

// Controller State for UI Loading (Optional, or handle in UI)
// We will let UI handle loading state via local State or FutureBuilder
