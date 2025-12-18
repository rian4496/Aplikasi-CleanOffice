// lib/models/stock_request.dart

class StockRequest {
  final String id;
  final String itemId;
  final String? itemName; // Joined or cached
  final String requesterId;
  final String? requesterName; // Cached
  final int requestedQuantity;
  final String status; // pending, approved, rejected, fulfilled, cancelled
  final String? notes;
  
  // Approval
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? approvedByName;
  
  // Fulfillment
  final DateTime? fulfilledAt;
  final String? fulfilledBy;
  final String? fulfilledByName;
  
  // Rejection
  final String? rejectionReason;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  StockRequest({
    required this.id,
    required this.itemId,
    this.itemName,
    required this.requesterId,
    this.requesterName,
    required this.requestedQuantity,
    required this.status,
    this.notes,
    this.approvedAt,
    this.approvedBy,
    this.approvedByName,
    this.fulfilledAt,
    this.fulfilledBy,
    this.fulfilledByName,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
  });

  factory StockRequest.fromSupabase(Map<String, dynamic> data) {
    return StockRequest(
      id: data['id'],
      itemId: data['item_id'],
      itemName: data['item_name'] ?? (data['inventory_items'] != null ? data['inventory_items']['name'] : null),
      requesterId: data['requester_id'],
      requesterName: data['requester_name'],
      requestedQuantity: data['requested_quantity'],
      status: data['status'],
      notes: data['notes'],
      approvedAt: data['approved_at'] != null ? DateTime.parse(data['approved_at']) : null,
      approvedBy: data['approved_by'],
      approvedByName: data['approved_by_name'],
      fulfilledAt: data['fulfilled_at'] != null ? DateTime.parse(data['fulfilled_at']) : null,
      fulfilledBy: data['fulfilled_by'],
      fulfilledByName: data['fulfilled_by_name'],
      rejectionReason: data['rejection_reason'],
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at']) : null,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'requester_id': requesterId,
      'requester_name': requesterName,
      'requested_quantity': requestedQuantity,
      'status': status,
      'notes': notes,
      'approved_at': approvedAt?.toIso8601String(),
      'approved_by': approvedBy,
      'approved_by_name': approvedByName,
      'fulfilled_at': fulfilledAt?.toIso8601String(),
      'fulfilled_by': fulfilledBy,
      'fulfilled_by_name': fulfilledByName,
      'rejection_reason': rejectionReason,
      // 'created_at' and 'updated_at' usually handled by DB
    };
  }
}
