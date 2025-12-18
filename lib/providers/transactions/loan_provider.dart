import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transactions/loan_model.dart';
import '../riverpod/supabase_service_providers.dart';

// Async Notifier for CRUD
class LoanController extends AsyncNotifier<List<LoanRequest>> {
  @override
  Future<List<LoanRequest>> build() async {
    final service = ref.watch(supabaseDatabaseServiceProvider);
    return await service.getLoanRequests();
  }

  Future<void> createLoan(LoanRequest loan) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(supabaseDatabaseServiceProvider);
      await service.createLoanRequest(loan);
      
      // Refresh list
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> updateStatus(String id, String newStatus, {String? rejectionReason}) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(supabaseDatabaseServiceProvider);
      await service.updateLoanStatus(id, newStatus, rejectionReason: rejectionReason);
      
      // Refresh list
      ref.invalidateSelf();
    } catch (e, st) {
      // Restore old state if possible or just show error
      // Actually invalidating self is safer to get fresh data
      ref.invalidateSelf();
      throw e; // Rethrow to let UI handle it
    }
  }
}

final loanListProvider = AsyncNotifierProvider<LoanController, List<LoanRequest>>(LoanController.new);
