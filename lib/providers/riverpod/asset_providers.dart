// lib/providers/riverpod/asset_providers.dart
// SIM-ASET: Asset Providers

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/asset.dart';
import '../../models/location.dart';

// ==================== SUPABASE CLIENT ====================
final _supabase = Supabase.instance.client;

// ==================== LOCATIONS PROVIDER ====================
final locationsProvider = FutureProvider<List<Location>>((ref) async {
  final response = await _supabase
      .from('locations')
      .select()
      .order('name');

  return (response as List)
      .map((json) => Location.fromSupabase(json))
      .toList();
});

// ==================== ALL ASSETS PROVIDER ====================
final allAssetsProvider = FutureProvider<List<Asset>>((ref) async {
  final response = await _supabase
      .from('assets')
      .select('''
        *,
        locations(name)
      ''')
      .order('name');

  return (response as List)
      .map((json) => Asset.fromSupabase(json))
      .toList();
});

// ==================== ASSETS BY STATUS PROVIDER ====================
final assetsByStatusProvider = FutureProvider.family<List<Asset>, AssetStatus>((ref, status) async {
  final response = await _supabase
      .from('assets')
      .select('''
        *,
        locations(name)
      ''')
      .eq('status', status.toDatabase())
      .order('name');

  return (response as List)
      .map((json) => Asset.fromSupabase(json))
      .toList();
});

// ==================== ASSETS BY CONDITION PROVIDER ====================
final assetsByConditionProvider = FutureProvider.family<List<Asset>, AssetCondition>((ref, condition) async {
  final response = await _supabase
      .from('assets')
      .select('''
        *,
        locations(name)
      ''')
      .eq('condition', condition.toDatabase())
      .order('name');

  return (response as List)
      .map((json) => Asset.fromSupabase(json))
      .toList();
});

// ==================== SINGLE ASSET PROVIDER ====================
final assetByIdProvider = FutureProvider.family<Asset?, String>((ref, assetId) async {
  final response = await _supabase
      .from('assets')
      .select('''
        *,
        locations(name)
      ''')
      .eq('id', assetId)
      .maybeSingle();

  if (response == null) return null;
  return Asset.fromSupabase(response);
});

// ==================== ASSET BY QR CODE PROVIDER ====================
final assetByQrCodeProvider = FutureProvider.family<Asset?, String>((ref, qrCode) async {
  final response = await _supabase
      .from('assets')
      .select('''
        *,
        locations(name)
      ''')
      .eq('qr_code', qrCode)
      .maybeSingle();

  if (response == null) return null;
  return Asset.fromSupabase(response);
});

// ==================== ASSET STATS PROVIDER ====================
final assetStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final assets = await ref.watch(allAssetsProvider.future);

  return {
    'total': assets.length,
    'active': assets.where((a) => a.status == AssetStatus.active).length,
    'inactive': assets.where((a) => a.status == AssetStatus.inactive).length,
    'disposed': assets.where((a) => a.status == AssetStatus.disposed).length,
    'good': assets.where((a) => a.condition == AssetCondition.good).length,
    'fair': assets.where((a) => a.condition == AssetCondition.fair).length,
    'poor': assets.where((a) => a.condition == AssetCondition.poor).length,
    'broken': assets.where((a) => a.condition == AssetCondition.broken).length,
  };
});

// ==================== SEARCH ASSETS PROVIDER ====================
final searchAssetsProvider = FutureProvider.family<List<Asset>, String>((ref, query) async {
  if (query.isEmpty) {
    return ref.watch(allAssetsProvider.future);
  }

  final response = await _supabase
      .from('assets')
      .select('''
        *,
        locations(name)
      ''')
      .or('name.ilike.%$query%,qr_code.ilike.%$query%,category.ilike.%$query%')
      .order('name');

  return (response as List)
      .map((json) => Asset.fromSupabase(json))
      .toList();
});

// ==================== ASSETS BY CATEGORY PROVIDER ====================
final assetsByCategoryProvider = FutureProvider.family<List<Asset>, String>((ref, category) async {
  final response = await _supabase
      .from('assets')
      .select('''
        *,
        locations(name)
      ''')
      .eq('category', category)
      .order('name');

  return (response as List)
      .map((json) => Asset.fromSupabase(json))
      .toList();
});

