// lib/providers/riverpod/master_data_providers.dart
// SIM-ASET: Master Data Providers for dropdowns

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/sim_aset/asset_type.dart';
import '../../models/sim_aset/asset_category.dart';
import '../../models/sim_aset/department.dart';
import '../../models/sim_aset/asset_condition.dart';
import '../../models/location.dart';

// ==================== SUPABASE CLIENT ====================
final _supabase = Supabase.instance.client;

// ==================== ASSET TYPES ====================
final assetTypesProvider = FutureProvider<List<AssetType>>((ref) async {
  final response = await _supabase
      .from('asset_types')
      .select()
      .order('code');

  return (response as List)
      .map((json) => AssetType.fromSupabase(json))
      .toList();
});

// ==================== ASSET CATEGORIES ====================
final assetCategoriesProvider = FutureProvider<List<AssetCategory>>((ref) async {
  final response = await _supabase
      .from('asset_categories')
      .select()
      .eq('is_active', true)
      .order('sort_order');

  return (response as List)
      .map((json) => AssetCategory.fromSupabase(json))
      .toList();
});

/// Categories filtered by type (movable/immovable)
final categoriesByTypeProvider = FutureProvider.family<List<AssetCategory>, String>((ref, typeId) async {
  final response = await _supabase
      .from('asset_categories')
      .select()
      .eq('type_id', typeId)
      .eq('is_active', true)
      .order('sort_order');

  return (response as List)
      .map((json) => AssetCategory.fromSupabase(json))
      .toList();
});

// ==================== DEPARTMENTS ====================
final departmentsProvider = FutureProvider<List<Department>>((ref) async {
  final response = await _supabase
      .from('departments')
      .select()
      .eq('is_active', true)
      .order('name');

  return (response as List)
      .map((json) => Department.fromSupabase(json))
      .toList();
});

// ==================== ASSET CONDITIONS ====================
final assetConditionsProvider = FutureProvider<List<AssetCondition>>((ref) async {
  final response = await _supabase
      .from('asset_conditions')
      .select()
      .order('sort_order');

  return (response as List)
      .map((json) => AssetCondition.fromSupabase(json))
      .toList();
});

// ==================== LOCATIONS ====================
final locationsProvider = FutureProvider<List<Location>>((ref) async {
  final response = await _supabase
      .from('locations')
      .select()
      .order('name');

  return (response as List)
      .map((json) => Location.fromSupabase(json))
      .toList();
});

/// Locations grouped by building
final locationsByBuildingProvider = FutureProvider<Map<String, List<Location>>>((ref) async {
  final locations = await ref.watch(locationsProvider.future);
  
  final Map<String, List<Location>> grouped = {};
  for (final loc in locations) {
    final building = loc.building ?? 'Other';
    grouped.putIfAbsent(building, () => []);
    grouped[building]!.add(loc);
  }
  
  return grouped;
});

