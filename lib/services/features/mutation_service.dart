// lib/services/features/mutation_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/transactions/asset_mutation.dart';

class MutationService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get mutations with optional filters
  Future<List<AssetMutation>> getMutations({
    String? status,
    String? assetId,
    int limit = 50,
  }) async {
    try {
      var query = _client.from('asset_mutations').select('''
        *,
        assets:assets!asset_id (name, asset_code),
        origin_location:locations!origin_location_id (name),
        destination_location:locations!destination_location_id (name),
        requester:users!requester_id (display_name),
        approver:users!approver_id (display_name)
      ''');

      if (status != null) {
        query = query.eq('status', status);
      }
      if (assetId != null) {
        query = query.eq('asset_id', assetId);
      }

      final response = await query.order('created_at', ascending: false).limit(limit);
      
      return (response as List).map((e) => AssetMutation.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal memuat data mutasi: $e');
    }
  }
  
  /// Get mutations for report (filtered by date range)
  Future<List<AssetMutation>> getMutationsForReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Format dates to ISO string for Supabase comparison
      // start: 00:00:00, end: 23:59:59
      final startIso = DateTime(startDate.year, startDate.month, startDate.day).toIso8601String();
      final endIso = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59).toIso8601String();

      var query = _client.from('asset_mutations').select('''
        *,
        assets:assets!asset_id (name, asset_code),
        origin_location:locations!origin_location_id (name),
        destination_location:locations!destination_location_id (name),
        requester:users!requester_id (display_name),
        approver:users!approver_id (display_name)
      ''')
      .gte('created_at', startIso)
      .lte('created_at', endIso)
      .order('created_at', ascending: true); // Chronological order for report

      final response = await query;
      
      return (response as List).map((e) => AssetMutation.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal memuat data laporan mutasi: $e');
    }
  }

  /// Get single mutation by ID
  Future<AssetMutation?> getMutationById(String id) async {
    try {
      final response = await _client.from('asset_mutations').select('''
        *,
        assets:assets!asset_id (name, asset_code),
        origin_location:locations!origin_location_id (name),
        destination_location:locations!destination_location_id (name),
        requester:users!requester_id (display_name),
        approver:users!approver_id (display_name)
      ''').eq('id', id).single();
      
      return AssetMutation.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Create new mutation request
  Future<void> createMutation(AssetMutation mutation) async {
    try {
      await _client.from('asset_mutations').insert(mutation.toSupabase());
    } catch (e) {
      throw Exception('Gagal membuat mutasi: $e');
    }
  }

  /// Approve mutation
  /// This performs a TRANSACTION: 
  /// 1. Updates mutation status to 'approved'
  /// 2. Updates asset's location_id to destination_location_id
  Future<void> approveMutation(String mutationId, String approverId) async {
    try {
      // Supabase RPC is preferred for transactions, but for now we do client-side sequence
      // Note: In production, wrap this in a postgres function or use RPC for atomicity.
      
      // 1. Get mutation details to know asset and destination
      final mutation = await getMutationById(mutationId);
      if (mutation == null) throw Exception('Mutasi tidak ditemukan');
      if (mutation.status != MutationStatus.pending) throw Exception('Mutasi sudah diproses');

      // 2. Update Mutation Status
      await _client.from('asset_mutations').update({
        'status': 'approved',
        'approver_id': approverId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', mutationId);

      // 3. Update Asset Location
      if (mutation.destinationLocationId != null) {
        await _client.from('assets').update({
          'location_id': mutation.destinationLocationId,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', mutation.assetId);
      }
    } catch (e) {
      throw Exception('Gagal menyetujui mutasi: $e');
    }
  }

  /// Reject mutation
  Future<void> rejectMutation(String mutationId, String approverId, String reason) async {
    try {
      await _client.from('asset_mutations').update({
        'status': 'rejected',
        'approver_id': approverId,
        'rejection_reason': reason, // Make sure column exists, or use 'notes'
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', mutationId);
    } catch (e) {
      throw Exception('Gagal menolak mutasi: $e');
    }
  }
}
