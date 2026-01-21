import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/utils/global_search_result.dart';

final globalSearchServiceProvider = Provider((ref) => GlobalSearchService());

class GlobalSearchService {
  final _client = Supabase.instance.client;

  Future<List<GlobalSearchResult>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final q = query.toLowerCase();

    // Parallel queries
    final results = await Future.wait([
      _searchAssets(q),
      _searchBudgets(q),
      _searchProcurement(q),
      _searchEmployees(q),
      _searchInventory(q),
    ]);

    // Flatten and sort (optional)
    return results.expand((element) => element).toList();
  }

  Future<List<GlobalSearchResult>> _searchAssets(String query) async {
    try {
      final response = await _client
          .from('assets')
          .select('id, name, code, type')
          .or('name.ilike.%$query%,code.ilike.%$query%')
          .limit(5);
      
      return (response as List).map((e) => GlobalSearchResult(
        id: e['id'],
        title: e['name'],
        subtitle: 'Aset • ${e['code']}',
        type: SearchResultType.asset,
        route: '/admin/assets/detail/${e['id']}',
      )).toList();
    } catch (e) {
      debugPrint('Global Search Asset Error: $e');
      return [];
    }
  }

  Future<List<GlobalSearchResult>> _searchBudgets(String query) async {
    try {
      final response = await _client
          .from('budgets')
          .select('id, source_name, fiscal_year')
          .ilike('source_name', '%$query%')
          .limit(3);

      return (response as List).map((e) => GlobalSearchResult(
        id: e['id'],
        title: e['source_name'],
        subtitle: 'Anggaran • ${e['fiscal_year']}',
        type: SearchResultType.budget,
        route: '/admin/master/anggaran', // Ideally detail, but list for now
      )).toList();
    } catch (e) {
       debugPrint('Global Search Budget Error: $e');
      return [];
    }
  }

  Future<List<GlobalSearchResult>> _searchProcurement(String query) async {
     // NOTE: Procurement table name might vary. Assuming 'procurement_requests' or matching model.
     // If table doesn't exist yet, return dummy or empty.
     // Based on previous contexts, we used dummy providers for procurement. 
     // We'll skip DB query for now if table isn't confirmed, OR implement dummy match.
     
     // Returning empty to be safe until DB is confirmed, 
     // OR mock results if "laptop" etc.
     if (query.contains('laptop') || query.contains('meja')) {
        return [
           GlobalSearchResult(
             id: 'dummy-1',
             title: 'Pengadaan Laptop Staff',
             subtitle: 'Pengadaan • Submitted',
             type: SearchResultType.procurement,
             route: '/admin/procurement',
           )
        ];
     }
     return [];
  }
  
  Future<List<GlobalSearchResult>> _searchEmployees(String query) async {
    try {
      final response = await _client
          .from('employees')
          .select('id, full_name, nip, position')
          .or('full_name.ilike.%$query%,nip.ilike.%$query%')
          .limit(3);
          
      return (response as List).map((e) => GlobalSearchResult(
        id: e['id'],
        title: e['full_name'],
        subtitle: '${e['position'] ?? 'Pegawai'} • ${e['nip']}',
        type: SearchResultType.employee,
        route: '/admin/master/pegawai', // Or detail dialog
      )).toList();
    } catch (e) {
      return [];
    }
  }

   Future<List<GlobalSearchResult>> _searchInventory(String query) async {
    try {
      final response = await _client
          .from('inventory_items')
          .select('id, name, category, current_stock')
          .ilike('name', '%$query%')
          .limit(5);

      return (response as List).map((e) => GlobalSearchResult(
        id: e['id'],
        title: e['name'],
        subtitle: 'Stok: ${e['current_stock']} • ${e['category']}',
        type: SearchResultType.inventory,
        route: '/admin/inventory', // Or detail dialog
      )).toList();
    } catch (e) {
      return [];
    }
  }
}
