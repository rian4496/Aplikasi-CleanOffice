import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transactions/transaction_models.dart';
import '../models/transactions/disposal_model.dart';

// =====================================================
// 1. PROCUREMENT REPOSITORY
// =====================================================
class ProcurementRepository {
  final SupabaseClient _client;

  ProcurementRepository(this._client);

  /// Fetch all requests, joining relevant tables
  Future<List<ProcurementRequest>> fetchRequests() async {
    try {
      final response = await _client
          .from('transactions_procurement')
          .select('''
            *,
            requester:master_pegawai(nama_lengkap),
            items:transaction_procurement_items(*)
          ''')
          .order('request_date', ascending: false);

      return (response as List).map((e) {
        // Flatten Join for simplified Model
        final requester = e['requester'] != null ? e['requester']['nama_lengkap'] : null;
        
        // Items are nested
        final itemsList = (e['items'] as List?) ?? [];
        
        // Create map with requester_name for model compatibility
        final map = Map<String, dynamic>.from(e);
        if (requester != null) map['requester_name'] = requester;
        map['items'] = itemsList;

        return ProcurementRequest.fromJson(map);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load procurement requests: $e');
    }
  }

  /// Create a new Request with Items
  Future<void> createRequest(ProcurementRequest request, List<ProcurementItem> items) async {
    // 1. Insert Header
    final headerData = {
      'code': request.code,
      'request_date': request.requestDate.toIso8601String(),
      'description': request.description,
      'status': 'pending', // Always pending initially
      'total_estimated_budget': request.totalEstimatedBudget,
      // 'requester_id': request.requesterId, // TODO: Get from Auth Context
    };

    final headerRes = await _client
        .from('transactions_procurement')
        .insert(headerData)
        .select()
        .single();
    
    final newId = headerRes['id'];

    // 2. Insert Items
    if (items.isNotEmpty) {
      final itemsData = items.map((i) => {
        'procurement_id': newId,
        'item_name': i.itemName,
        'quantity': i.quantity,
        'unit_price_estimate': i.unitPriceEstimate,
        'budget_id': i.budgetId, // Fix: Save Budget ID
      }).toList();

      await _client.from('transaction_procurement_items').insert(itemsData);
    }
  }

  /// Update Status with ERP Logic (Budget & Asset Integration)
  Future<void> updateStatus(String id, String newStatus) async {
    // 1. Update Status
    await _client
        .from('transactions_procurement')
        .update({'status': newStatus})
        .eq('id', id);

    // 2. ERP Logic Triggers
    if (newStatus == 'approved_admin') {
      await _processBudgetDeduction(id);
    } else if (newStatus == 'completed') {
      await _processAssetRegistration(id);
    }
  }

  /// Private: Auto-deduct budget when approved
  Future<void> _processBudgetDeduction(String procurementId) async {
    try {
      // Fetch items
      final response = await _client
          .from('transaction_procurement_items')
          .select('budget_id, quantity, unit_price_estimate')
          .eq('procurement_id', procurementId);
      
      final items = List<Map<String, dynamic>>.from(response);
      
      // Group by Budget ID
      final Map<String, double> budgetDeductions = {};
      for (var item in items) {
        final budgetId = item['budget_id'] as String?;
        if (budgetId != null) {
          final cost = (item['quantity'] as int) * (item['unit_price_estimate'] as num).toDouble();
          budgetDeductions[budgetId] = (budgetDeductions[budgetId] ?? 0) + cost;
        }
      }

      // Execute Deductions
      for (var entry in budgetDeductions.entries) {
        // Fetch current remaining
        final budgetRes = await _client
            .from('master_anggaran')
            .select('remaining_amount')
            .eq('id', entry.key)
            .single();
        
        final currentRemaining = (budgetRes['remaining_amount'] as num).toDouble();
        
        // Update
        await _client
            .from('master_anggaran')
            .update({'remaining_amount': currentRemaining - entry.value})
            .eq('id', entry.key);
      }
    } catch (e) {
      print('ERP Error (Budget Deduction): $e');
      // Non-blocking error logging
    }
  }

  /// Private: Auto-register assets when completed
  Future<void> _processAssetRegistration(String procurementId) async {
    try {
      // Fetch procurement header + items
      final procRes = await _client
          .from('transactions_procurement')
          .select('code, request_date, items:transaction_procurement_items(*)')
          .eq('id', procurementId)
          .single();
      
      final code = procRes['code'];
      final date = DateTime.parse(procRes['request_date']);
      final items = List<Map<String, dynamic>>.from(procRes['items']);

      for (var item in items) {
        final qty = item['quantity'] as int;
        final name = item['item_name'] as String;
        final price = (item['unit_price_estimate'] as num).toDouble();

        // Register each unit individually for tracking (Standard Asset Mgmt Practice)
        for (var i = 0; i < qty; i++) {
            await _client.from('master_assets').insert({
            'name': name,
            'status': 'active',
            'condition': 'good',
            'category': 'Pengadaan', // Default category, user can refine later
            'qr_code': 'AST-${date.year}-${DateTime.now().millisecondsSinceEpoch}-$i', // Auto-gen QR
            'purchase_date': date.toIso8601String(),
            'purchase_price': price,
            'source': 'Procurement $code',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      print('ERP Error (Asset Registration): $e');
    }
  }
}

// =====================================================
// 2. MAINTENANCE REPOSITORY
// =====================================================
class MaintenanceRepository {
  final SupabaseClient _client;

  MaintenanceRepository(this._client);

  Future<List<MaintenanceRequest>> fetchRequests() async {
    try {
      final response = await _client
          .from('transactions_maintenance')
          .select('''
            *,
            asset:master_assets(name)
          ''')
          .order('created_at', ascending: false);

      return (response as List).map((e) {
        final assetName = e['asset'] != null ? e['asset']['name'] : 'Unknown Asset';
        
        final map = Map<String, dynamic>.from(e);
        map['asset_name'] = assetName;

        return MaintenanceRequest.fromJson(map);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load maintenance requests: $e');
    }
  }

  Future<void> createReport(MaintenanceRequest request) async {
    await _client.from('transactions_maintenance').insert({
      'code': request.code,
      'asset_id': request.assetId,
      'issue_title': request.issueTitle,
      'issue_description': request.issueDescription,
      'priority': request.priority,
      'status': 'reported',
      'created_at': DateTime.now().toIso8601String(),
    });
  }
  
  /// Alias for createReport for backward compatibility
  Future<void> createRequest(MaintenanceRequest request) => createReport(request);


  Future<void> updateStatus(String id, String newStatus) async {
    await _client
        .from('transactions_maintenance')
        .update({'status': newStatus})
        .eq('id', id);
  }
}

// =====================================================
// 3. DISPOSAL REPOSITORY
// =====================================================
class DisposalRepository {
  final SupabaseClient _client;

  DisposalRepository(this._client);

  Future<List<DisposalRequest>> fetchRequests() async {
    try {
      final response = await _client
          .from('transactions_disposal')
          .select('*, asset:master_assets(name, asset_code)')
          .order('created_at', ascending: false);

      return (response as List).map((json) {
         final asset = json['asset'] as Map<String, dynamic>?;
         if (asset != null) {
           json['asset_name'] = asset['name'];
           json['asset_code'] = asset['asset_code'];
         }
         return DisposalRequest.fromJson(json);
      }).toList();
    } catch(e) {
      throw Exception(e.toString());
    }
  }

  Future<void> createRequest(DisposalRequest req) async {
    await _client.from('transactions_disposal').insert({
      'code': req.code,
      'asset_id': req.assetId,
      'reason': req.reason,
      'description': req.description,
      'estimated_value': req.estimatedValue,
      'status': 'draft',
      'proposer_id': _client.auth.currentUser?.id,
    });
  }

  Future<void> updateStatus(String id, String status, {String? disposalType, double? finalValue}) async {
    final Map<String, dynamic> updates = {'status': status};
    
    if (status == 'approved') {
      updates['approval_date'] = DateTime.now().toIso8601String();
      updates['approved_by'] = _client.auth.currentUser?.id;
    }
    
    // Additional logic for completion handled by caller or triggers usually, but here simple:
    if (finalValue != null) updates['final_value'] = finalValue;
    if (disposalType != null) updates['final_disposal_type'] = disposalType;

    await _client.from('transactions_disposal').update(updates).eq('id', id);
  }
}
