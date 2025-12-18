import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/ticket.dart';
import '../../models/location.dart';
import '../../core/logging/app_logger.dart';

final _logger = AppLogger('TicketProviders');

// ==================== TICKET REPOSITORY ====================

class TicketRepository {
  final SupabaseClient _client;

  TicketRepository(this._client);

  /// Fetch all tickets (optionally filtered by type)
  Future<List<Ticket>> getTickets({TicketType? type, TicketStatus? status, String? assetId}) async {
    try {
      var query = _client.from('tickets').select();

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
      return (response as List).map((e) => Ticket.fromJson(e)).toList();
    } catch (e) {
      _logger.error('Error fetching tickets', e);
      rethrow;
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

  /// Fetch stock requests for Kasubbag approval
  Future<List<Ticket>> getPendingStockRequests() async {
    try {
      final response = await _client
          .from('tickets')
          .select()
          .eq('type', TicketType.stockRequest.value)
          .inFilter('status', ['open', 'pending_approval'])
          .order('created_at', ascending: false);
      return (response as List).map((e) => Ticket.fromJson(e)).toList();
    } catch (e) {
      _logger.error('Error fetching pending stock requests', e);
      rethrow;
    }
  }

  /// Get ticket by ID
  Future<Ticket?> getTicketById(String id) async {
    try {
      final response = await _client
          .from('tickets')
          .select()
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
      // Assuming 'inventory_items' table exists or similar
      // Returning simpler map for dropdown due to complex models
      final response = await _client.from('inventory_items').select('id, item_name, stock_quantity').order('item_name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.error('Error fetching inventory items', e);
      return [];
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

/// Teknisi inbox (kerusakan tickets)
final teknisiInboxProvider = FutureProvider<List<Ticket>>((ref) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getTeknisiInbox();
});

/// Cleaner inbox (kebersihan tickets)
final cleanerInboxProvider = FutureProvider<List<Ticket>>((ref) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getCleanerInbox();
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
