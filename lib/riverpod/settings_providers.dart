
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../repositories/settings_repositories.dart';

// ==================== DEPENDENCIES ====================
final supabaseClientProvider = Provider((ref) => Supabase.instance.client);

// ==================== REPOSITORIES ====================
final agencyRepositoryProvider = Provider((ref) {
  return AgencyRepository(ref.watch(supabaseClientProvider));
});

final userRepositoryProvider = Provider((ref) {
  return UserRepository(ref.watch(supabaseClientProvider));
});
