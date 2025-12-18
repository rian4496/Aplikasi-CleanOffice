import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transactions/disposal_model.dart';
import '../riverpod/supabase_service_providers.dart';
import '../riverpod/auth_providers.dart';

// Removed mock data

class DisposalController extends AsyncNotifier<List<DisposalRequest>> {
  @override
  Future<List<DisposalRequest>> build() async {
    final service = ref.watch(supabaseDatabaseServiceProvider);
    return await service.getDisposalRequests();
  }

  Future<void> submitProposal(DisposalRequest request) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(supabaseDatabaseServiceProvider);
      await service.createDisposalRequest(request);
      
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> verifyProposal(String id) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(supabaseDatabaseServiceProvider);
      await service.updateDisposalStatus(id, 'verified');
      
      ref.invalidateSelf();
    } catch (e, st) {
      ref.invalidateSelf();
      throw e;
    }
  }
  
  Future<void> approveProposal(String id, String decreeNumber) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(supabaseDatabaseServiceProvider);
      final userId = ref.read(currentUserIdProvider);

      await service.updateDisposalStatus(
        id, 
        'approved', 
        approvedBy: userId ?? 'system', 
        approvalDate: DateTime.now()
      );
      
      ref.invalidateSelf();
    } catch (e, st) {
      ref.invalidateSelf();
      throw e;
    }
  }
}

final disposalListProvider = AsyncNotifierProvider<DisposalController, List<DisposalRequest>>(DisposalController.new);
