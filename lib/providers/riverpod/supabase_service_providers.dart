// lib/providers/riverpod/supabase_service_providers.dart
// Unified Supabase Service Providers
// These providers serve as the single source of truth for all Supabase services

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/supabase_auth_service.dart';
import '../../services/supabase_database_service.dart';
import '../../services/supabase_storage_service.dart';

part 'supabase_service_providers.g.dart';

// ==================== AUTH SERVICE ====================

/// Provider untuk SupabaseAuthService singleton
@Riverpod(keepAlive: true)
SupabaseAuthService supabaseAuthService(Ref ref) {
  return SupabaseAuthService();
}

// ==================== DATABASE SERVICE ====================

/// Provider untuk SupabaseDatabaseService singleton
@Riverpod(keepAlive: true)
SupabaseDatabaseService supabaseDatabaseService(Ref ref) {
  return SupabaseDatabaseService();
}

// ==================== STORAGE SERVICE ====================

/// Provider untuk SupabaseStorageService singleton
@Riverpod(keepAlive: true)
SupabaseStorageService supabaseStorageService(Ref ref) {
  return SupabaseStorageService();
}

