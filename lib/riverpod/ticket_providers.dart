import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/ticket.dart';
import '../../models/location.dart';
import '../../core/logging/app_logger.dart';
import './auth_providers.dart'; // For currentUserIdProvider

final _logger = AppLogger('TicketProviders');

// ==================== TICKET REPOSITORY ====================

class TicketRepository {
  final SupabaseClient _client;

  TicketRepository(this._client);

  /// Fetch all tickets (optionally filtered by type)
  /// Includes joins for creator, asset, and location names
  Future<List<Ticket>> getTickets({TicketType? type, TicketStatus? status, String? assetId}) async {
    try {
      // Select with left joins for related data
      // Using column-based syntax: table_name(columns)
      var query = _client.from('tickets').select('''
        *,
        creator:users(display_name),
        asset:assets(name),
        location:locations(name),
        inventory_item:inventory_items(name)
      ''');

      if (type != null) {
        query = query.eq('type', type.value);
      }
      if (status != null) {
        query = query.eq('status', status.value);
      }
      if (assetId != null) {
        query = query.eq('asset_id', assetId);
      }

      final response = await query.order('created_at', ascending: false);
      _logger.info('Tickets fetched: ${response.length} items');
      return (response as List).map((e) => Ticket.fromJson(e)).toList();
    } catch (e, s) {
      _logger.error('Error fetching tickets: $e\n$s');
// Fallback logic continues...
      // Still provide fallback for robustness
      try {
        var query = _client.from('tickets').select();
        if (type != null) query = query.eq('type', type.value);
        if (status != null) query = query.eq('status', status.value);
        if (assetId != null) query = query.eq('asset_id', assetId);
        final response = await query.order('created_at', ascending: false);
        return (response as List).map((e) => Ticket.fromJson(e)).toList();
      } catch (e2) {
        rethrow;
      }
    }
  }

  /// Fetch tickets for Teknisi inbox (kerusakan only)
  Future<List<Ticket>> getTeknisiInbox() async {
    return getTickets(type: TicketType.kerusakan);
  }

  /// Fetch tickets for Cleaner inbox (kebersihan only)
  Future<List<Ticket>> getCleanerInbox() async {
    return getTickets(type: TicketType.kebersihan);
  }

  /// Fetch tickets claimed/assigned to current user (in_progress or claimed)
  Future<List<Ticket>> getCleanerTasks(String userId) async {
    try {
      final response = await _client
          .from('tickets')
          .select('*, creator:created_by(display_name), asset:asset_id(name), location:location_id(name), inventory_item:inventory_item_id(name)')
          .eq('assigned_to', userId)
          .eq('type', TicketType.kebersihan.value) // Only kebersihan for cleaner
          .inFilter('status', ['claimed', 'in_progress'])
          .order('created_at', ascending: false);
      _logger.info('Fetched ${response.length} cleaner tasks for $userId');
      return response.map<Ticket>((json) => Ticket.fromJson(json)).toList();
    } catch (e) {
      _logger.error('Error fetching cleaner tasks', e);
      rethrow;
    }
  }

  /// Fetch kerusakan tickets claimed/assigned to teknisi user
  Future<List<Ticket>> getTeknisiTasks(String userId) async {
    try {
      final response = await _client
          .from('tickets')
          .select('*, creator:created_by(display_name), asset:asset_id(name), location:location_id(name), inventory_item:inventory_item_id(name)')
          .eq('assigned_to', userId)
          .eq('type', TicketType.kerusakan.value) // Only kerusakan for teknisi
          .inFilter('status', ['claimed', 'in_progress'])
          .order('created_at', ascending: false);
      _logger.info('Fetched ${response.length} teknisi tasks for $userId');
      return response.map<Ticket>((json) => Ticket.fromJson(json)).toList();
    } catch (e) {
      _logger.error('Error fetching teknisi tasks', e);
      rethrow;
    }
  }

  /// Fetch stock requests for Kasubbag approval (with joins)
  Future<List<Ticket>> getPendingStockRequests() async {
    try {
      final response = await _client
          .from('tickets')
          .select('''
            *,
            creator:users(display_name),
            asset:assets(name),
            location:locations(name),
            inventory_item:inventory_items(name)
          ''')
          .eq('type', TicketType.stockRequest.value)
          .inFilter('status', ['open', 'pending_approval'])
          .order('created_at', ascending: false);
      return (response as List).map((e) => Ticket.fromJson(e)).toList();
    } catch (e) {
      _logger.error('Error fetching pending stock requests', e);
      rethrow;
    }
  }

  /// Get ticket by ID (with joins for display names)
  Future<Ticket?> getTicketById(String id) async {
    try {
      final response = await _client
          .from('tickets')
          .select('''
            *,
            creator:users(display_name),
            asset:assets(name),
            location:locations(name),
            inventory_item:inventory_items(name)
          ''')
          .eq('id', id)
          .maybeSingle();
      return response != null ? Ticket.fromJson(response) : null;
    } catch (e) {
      _logger.error('Error fetching ticket by ID', e);
      rethrow;
    }
  }

  /// Create new ticket
  Future<Ticket> createTicket({
    required TicketType type,
    required String title,
    String? description,
    TicketPriority priority = TicketPriority.normal,
    required String createdBy,
    String? locationId,
    String? assetId,
    String? inventoryItemId,
    int? requestedQuantity,
    String? imageUrl,
  }) async {
    try {
      final data = Ticket.toInsertJson(
        type: type,
        title: title,
        description: description,
        priority: priority,
        createdBy: createdBy,
        locationId: locationId,
        assetId: assetId,
        inventoryItemId: inventoryItemId,
        requestedQuantity: requestedQuantity,
        imageUrl: imageUrl,
      );

      final response = await _client.from('tickets').insert(data).select().single();
      _logger.info('Ticket created: ${response['ticket_number']}');
      return Ticket.fromJson(response);
    } catch (e) {
      _logger.error('Error creating ticket', e);
      rethrow;
    }
  }

  /// Claim ticket (Teknisi/Cleaner takes ownership)
  Future<Ticket> claimTicket(String ticketId, String userId) async {
    try {
      final response = await _client
          .from('tickets')
          .update({
            'assigned_to': userId,
            'status': TicketStatus.claimed.value,
            'claimed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', ticketId)
          .select()
          .single();
      _logger.info('Ticket claimed: $ticketId by $userId');
      return Ticket.fromJson(response);
    } catch (e) {
      _logger.error('Error claiming ticket', e);
      rethrow;
    }
  }

  /// Assign ticket (Admin assigns to staff)
  Future<Ticket> assignTicket(String ticketId, String userId) async {
    try {
      final response = await _client
          .from('tickets')
          .update({
            'assigned_to': userId,
            'status': TicketStatus.claimed.value, // Status becomes 'Claimed' / 'Diambil'
            'claimed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', ticketId)
          .select()
          .single();
      _logger.info('Ticket assigned: $ticketId to $userId');
      return Ticket.fromJson(response);
    } catch (e) {
      _logger.error('Error assigning ticket', e);
      rethrow;
    }
  }

  /// Update ticket status
  Future<Ticket> updateTicketStatus(String ticketId, TicketStatus status, {String? approvedBy}) async {
    try {
      final Map<String, dynamic> updateData = {'status': status.value};

      if (status == TicketStatus.completed) {
        updateData['completed_at'] = DateTime.now().toIso8601String();
      }
      if (status == TicketStatus.approved || status == TicketStatus.rejected) {
        updateData['approved_by'] = approvedBy;
        updateData['approved_at'] = DateTime.now().toIso8601String();
      }

      final response = await _client
          .from('tickets')
          .update(updateData)
          .eq('id', ticketId)
          .select()
          .single();
      _logger.info('Ticket status updated: $ticketId -> ${status.value}');
      return Ticket.fromJson(response);
    } catch (e) {
      _logger.error('Error updating ticket status', e);
      rethrow;
    }
  }

  /// Resolve ticket with proof of work (image & note)
  /// For stock request tickets, this will also reduce inventory
  Future<Ticket> resolveTicket({
    required String ticketId,
    required String userId,
    required String note,
    required Uint8List imageBytes, // Web requires bytes
  }) async {
    try {
      // 0. Get full ticket data first
      final ticketData = await _client
          .from('tickets')
          .select()
          .eq('id', ticketId)
          .single();
      
      final ticket = Ticket.fromJson(ticketData);

      // 1. If it's a Stock Request, reduce inventory first (before marking complete)
      final inventoryItemId = ticket.inventoryItemId;
      final requestedQuantity = ticket.requestedQuantity;
      
      if (ticket.type == TicketType.stockRequest && 
          inventoryItemId != null && 
          requestedQuantity != null &&
          requestedQuantity > 0) {
        
        _logger.info('📦 Stock Request detected. Reducing inventory...');
        
        // Check stock availability
        final currentStockResponse = await _client
            .from('inventory_items')
            .select('current_stock')
            .eq('id', inventoryItemId)
            .single();
        
        final currentStock = currentStockResponse['current_stock'] as int? ?? 0;
        
        if (currentStock < requestedQuantity) {
          throw Exception('Stok tidak mencukupi. Tersedia: $currentStock, Diminta: $requestedQuantity');
        }

        final newStock = currentStock - requestedQuantity;

        // Update inventory stock
        await _client
            .from('inventory_items')
            .update({'current_stock': newStock})
            .eq('id', inventoryItemId);

        // Log stock movement to existing stock_movements table
        await _client.from('stock_movements').insert({
          'item_id': inventoryItemId,
          'type': 'OUT',
          'quantity': requestedQuantity,
          'reference_id': 'ticket:${ticket.ticketNumber}',
          'notes': 'Resolved via ticket: ${ticket.ticketNumber}',
        });

        _logger.info('✅ Inventory reduced: $currentStock → $newStock');
      }

      // 2. Upload Image (only if bytes are provided)
      String? imageUrl;
      if (imageBytes.isNotEmpty) {
        _logger.info('Uploading resolution image for ticket: $ticketId');
        
        final fileName = 'resolution_${ticketId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final path = '$userId/$fileName';
        
        await _client.storage.from('report_images').uploadBinary(
          path,
          imageBytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );

        imageUrl = _client.storage.from('report_images').getPublicUrl(path);
      } else {
        _logger.info('No image provided, skipping upload for ticket: $ticketId');
      }

      // 3. Update Ticket status to completed
      final updateData = <String, dynamic>{
        'status': TicketStatus.completed.value,
        'completed_at': DateTime.now().toIso8601String(),
        'resolution_note': note,
      };
      if (imageUrl != null) {
        updateData['resolution_image'] = imageUrl;
      }
      
      final response = await _client
          .from('tickets')
          .update(updateData)
          .eq('id', ticketId)
          .select()
          .single();
      
      _logger.info('Ticket resolved: $ticketId');
      return Ticket.fromJson(response);
    } catch (e) {
      _logger.error('Error resolving ticket', e);
      rethrow;
    }
  }

  /// Fetch locations for selection
  Future<List<Location>> getLocations() async {
    try {
      final response = await _client.from('locations').select().order('name');
      return (response as List).map((e) => Location.fromSupabase(e)).toList();
    } catch (e) {
      _logger.error('Error fetching locations', e);
      // Return empty list instead of throwing to avoid blocking UI
      return [];
    }
  }

  /// Fetch inventory items for selection
  Future<List<Map<String, dynamic>>> getInventoryItems() async {
    try {
      // Correct column names: 'name' and 'current_stock' per InventoryItem model
      final response = await _client.from('inventory_items').select('id, name, current_stock').order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.error('Error fetching inventory items', e);
      return [];
    }
  }

  /// Delete ticket by ID
  Future<void> deleteTicket(String ticketId) async {
    try {
      await _client.from('tickets').delete().eq('id', ticketId);
      _logger.info('Ticket deleted: $ticketId');
    } catch (e) {
      _logger.error('Error deleting ticket', e);
      rethrow;
    }
  }
}

// ==================== PROVIDERS ====================

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository(Supabase.instance.client);
});

/// All tickets (no filter)
final allTicketsProvider = FutureProvider<List<Ticket>>((ref) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getTickets();
});

/// Teknisi inbox (kerusakan tickets - open status only)
final teknisiInboxProvider = FutureProvider<List<Ticket>>((ref) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getTickets(type: TicketType.kerusakan, status: TicketStatus.open);
});

/// Cleaner inbox (kebersihan tickets)
final cleanerInboxProvider = FutureProvider<List<Ticket>>((ref) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getCleanerInbox();
});

/// My claimed tickets (assigned to current user, status claimed/in_progress)
final cleanerTasksProvider = FutureProvider<List<Ticket>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getCleanerTasks(userId);
});

/// Kasubbag approval queue (pending stock requests)
final kasubbagApprovalQueueProvider = FutureProvider<List<Ticket>>((ref) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getPendingStockRequests();
});

/// Single ticket by ID
final ticketByIdProvider = FutureProvider.family<Ticket?, String>((ref, id) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getTicketById(id);
});

/// List of locations
final locationListProvider = FutureProvider<List<Location>>((ref) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getLocations();
});

/// List of inventory items (simplified)
final inventoryDropdownProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getInventoryItems();
});

/// Tickets by Asset ID
final ticketsByAssetProvider = FutureProvider.family<List<Ticket>, String>((ref, assetId) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getTickets(assetId: assetId);
});

// ==================== TICKET CONTROLLER (for mutations) ====================

class TicketController {
  final Ref _ref;

  TicketController(this._ref);

  Future<void> deleteTicket(String ticketId) async {
    final repo = _ref.read(ticketRepositoryProvider);
    await repo.deleteTicket(ticketId);
    // Refresh the ticket lists
    _ref.invalidate(allTicketsProvider);
    _ref.invalidate(teknisiInboxProvider);
    _ref.invalidate(cleanerInboxProvider);
  }

  Future<void> refresh() async {
    _ref.invalidate(allTicketsProvider);
    _ref.invalidate(teknisiInboxProvider);
    _ref.invalidate(cleanerInboxProvider);
  }
}

final ticketControllerProvider = Provider<TicketController>((ref) {
  return TicketController(ref);
});


// ==================== REALTIME STREAMS ====================

/// Realtime Ticket Stream (No Joins)
/// Used for Dashboard Charts/Stats that need auto-update
final ticketsStreamProvider = StreamProvider<List<Ticket>>((ref) {
  return Supabase.instance.client
      .from('tickets')
      .stream(primaryKey: ['id'])
      .map((data) => data.map((json) => Ticket.fromJson(json)).toList());
});

// ==================== CLEANER TICKET STATS ====================

/// Provider for cleaner statistics based on TICKETS (not reports)
/// Used by cleaner home dashboard
final cleanerTicketStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return _emptyStats();
  }

  final repo = ref.watch(ticketRepositoryProvider);
  final client = Supabase.instance.client;

  try {
    // Fetch all tickets assigned to this user
    final allTickets = await client
        .from('tickets')
        .select()
        .eq('assigned_to', userId)
        .order('created_at', ascending: false);

    final tickets = (allTickets as List).map((e) => Ticket.fromJson(e)).toList();

    // Count by status
    final claimed = tickets.where((t) => t.status == TicketStatus.claimed).length;
    final inProgress = tickets.where((t) => t.status == TicketStatus.inProgress).length;
    final completed = tickets.where((t) => t.status == TicketStatus.completed).length;
    final total = tickets.length;

    // Count completed today
    final today = DateTime.now();
    final completedToday = tickets.where((t) => 
        t.status == TicketStatus.completed &&
        t.completedAt != null &&
        t.completedAt!.year == today.year &&
        t.completedAt!.month == today.month &&
        t.completedAt!.day == today.day).length;

    // Calculate average work time
    int avgWorkTimeMinutes = 0;
    final completedWithTime = tickets.where((t) => 
        t.status == TicketStatus.completed &&
        t.claimedAt != null && 
        t.completedAt != null).toList();
    
    if (completedWithTime.isNotEmpty) {
      final totalMinutes = completedWithTime.fold<int>(0, (sum, t) {
        final duration = t.completedAt!.difference(t.claimedAt!);
        return sum + duration.inMinutes;
      });
      avgWorkTimeMinutes = (totalMinutes / completedWithTime.length).round();
    }

    return {
      'assigned': claimed, // waiting to start
      'inProgress': inProgress,
      'completed': completed,
      'total': total,
      'completedToday': completedToday,
      'avgWorkTimeMinutes': avgWorkTimeMinutes,
    };
  } catch (e) {
    _logger.error('Error fetching cleaner ticket stats: $e');
    return _emptyStats();
  }
});

Map<String, int> _emptyStats() {
  return {
    'assigned': 0,
    'inProgress': 0,
    'completed': 0,
    'total': 0,
    'completedToday': 0,
    'avgWorkTimeMinutes': 0,
  };
}
