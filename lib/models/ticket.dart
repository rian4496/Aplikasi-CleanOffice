/// Ticket model for universal inbox/ticketing system
class Ticket {
  final String id;
  final String ticketNumber;
  final TicketType type;
  final String title;
  final String? description;
  final TicketStatus status;
  final TicketPriority priority;
  
  // Relationships
  final String createdBy;
  final String? assignedTo;
  final String? approvedBy;
  final String? locationId;
  final String? assetId;
  final String? inventoryItemId;
  final int? requestedQuantity;
  
  // Display names for related entities (populated via joins)
  final String? createdByName;
  final String? assignedToName;
  final String? assetName;
  final String? locationName;
  final String? inventoryItemName;
  
  // Attachments
  final String? imageUrl;
  final String? resolutionImage;
  final String? resolutionNote;

  // Timestamps
  final DateTime? claimedAt;
  final DateTime? approvedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Ticket({
    required this.id,
    required this.ticketNumber,
    required this.type,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    required this.createdBy,
    this.assignedTo,
    this.approvedBy,
    this.locationId,
    this.assetId,
    this.inventoryItemId,
    this.requestedQuantity,
    this.createdByName,
    this.assignedToName,
    this.assetName,
    this.locationName,
    this.inventoryItemName,
    this.imageUrl,
    this.resolutionImage,
    this.resolutionNote,
    this.claimedAt,
    this.approvedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    // Extract nested display names from joined tables
    String? createdByName;
    if (json['creator'] != null && json['creator'] is Map) {
      createdByName = json['creator']['display_name'] as String?;
    }
    
    String? assetName;
    if (json['asset'] != null && json['asset'] is Map) {
      assetName = json['asset']['name'] as String?;
    }
    
    String? locationName;
    if (json['location'] != null && json['location'] is Map) {
      locationName = json['location']['name'] as String?;
    }
    
    String? inventoryItemName;
    if (json['inventory_item'] != null && json['inventory_item'] is Map) {
      inventoryItemName = json['inventory_item']['name'] as String?;
    }

    String? assignedToName;
    if (json['assignee'] != null && json['assignee'] is Map) {
      assignedToName = json['assignee']['display_name'] as String?;
    }

    return Ticket(
      id: json['id'] as String,
      ticketNumber: json['ticket_number'] as String,
      type: TicketType.fromString(json['type'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      status: TicketStatus.fromString(json['status'] as String),
      priority: TicketPriority.fromString(json['priority'] as String),
      createdBy: json['created_by'] as String,
      assignedTo: json['assigned_to'] as String?,
      approvedBy: json['approved_by'] as String?,
      locationId: json['location_id'] as String?,
      assetId: json['asset_id'] as String?,
      inventoryItemId: json['inventory_item_id'] as String?,
      requestedQuantity: json['requested_quantity'] as int?,
      createdByName: createdByName,
      assignedToName: assignedToName,
      assetName: assetName,
      locationName: locationName,
      inventoryItemName: inventoryItemName,
      imageUrl: json['image_url'] as String?,
      resolutionImage: json['resolution_image'] as String?,
      resolutionNote: json['resolution_note'] as String?,
      claimedAt: json['claimed_at'] != null ? DateTime.parse(json['claimed_at'] as String) : null,
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at'] as String) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_number': ticketNumber,
      'type': type.value,
      'title': title,
      'description': description,
      'status': status.value,
      'priority': priority.value,
      'created_by': createdBy,
      'assigned_to': assignedTo,
      'approved_by': approvedBy,
      'location_id': locationId,
      'asset_id': assetId,
      'inventory_item_id': inventoryItemId,
      'requested_quantity': requestedQuantity,
      'image_url': imageUrl,
      'resolution_image': resolutionImage,
      'resolution_note': resolutionNote,
      'claimed_at': claimedAt?.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// For creating new ticket (without auto-generated fields)
  static Map<String, dynamic> toInsertJson({
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
  }) {
    return {
      'type': type.value,
      'title': title,
      'description': description,
      'priority': priority.value,
      'created_by': createdBy,
      'location_id': locationId,
      'asset_id': assetId,
      'inventory_item_id': inventoryItemId,
      'requested_quantity': requestedQuantity,
      'image_url': imageUrl,
    };
  }

  Ticket copyWith({
    String? id,
    String? ticketNumber,
    TicketType? type,
    String? title,
    String? description,
    TicketStatus? status,
    TicketPriority? priority,
    String? createdBy,
    String? assignedTo,
    String? approvedBy,
    String? locationId,
    String? assetId,
    String? inventoryItemId,
    int? requestedQuantity,
    String? imageUrl,
    DateTime? claimedAt,
    DateTime? approvedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Ticket(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      approvedBy: approvedBy ?? this.approvedBy,
      locationId: locationId ?? this.locationId,
      assetId: assetId ?? this.assetId,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      requestedQuantity: requestedQuantity ?? this.requestedQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
      claimedAt: claimedAt ?? this.claimedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ==================== ENUMS ====================

enum TicketType {
  kerusakan,
  kebersihan,
  stockRequest;

  String get value {
    switch (this) {
      case TicketType.kerusakan: return 'kerusakan';
      case TicketType.kebersihan: return 'kebersihan';
      case TicketType.stockRequest: return 'stock_request';
    }
  }

  String get displayName {
    switch (this) {
      case TicketType.kerusakan: return 'Laporan Kerusakan';
      case TicketType.kebersihan: return 'Laporan Kebersihan';
      case TicketType.stockRequest: return 'Permintaan Stok';
    }
  }

  static TicketType fromString(String value) {
    switch (value) {
      case 'kerusakan': return TicketType.kerusakan;
      case 'kebersihan': return TicketType.kebersihan;
      case 'stock_request': return TicketType.stockRequest;
      default: return TicketType.kerusakan;
    }
  }
}

enum TicketStatus {
  open,
  claimed,
  inProgress,
  pendingApproval,
  approved,
  rejected,
  completed,
  cancelled;

  String get value {
    switch (this) {
      case TicketStatus.open: return 'open';
      case TicketStatus.claimed: return 'claimed';
      case TicketStatus.inProgress: return 'in_progress';
      case TicketStatus.pendingApproval: return 'pending_approval';
      case TicketStatus.approved: return 'approved';
      case TicketStatus.rejected: return 'rejected';
      case TicketStatus.completed: return 'completed';
      case TicketStatus.cancelled: return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case TicketStatus.open: return 'Terbuka';
      case TicketStatus.claimed: return 'Diambil';
      case TicketStatus.inProgress: return 'Dalam Proses';
      case TicketStatus.pendingApproval: return 'Menunggu Approval';
      case TicketStatus.approved: return 'Disetujui';
      case TicketStatus.rejected: return 'Ditolak';
      case TicketStatus.completed: return 'Selesai';
      case TicketStatus.cancelled: return 'Dibatalkan';
    }
  }

  static TicketStatus fromString(String value) {
    switch (value) {
      case 'open': return TicketStatus.open;
      case 'claimed': return TicketStatus.claimed;
      case 'in_progress': return TicketStatus.inProgress;
      case 'pending_approval': return TicketStatus.pendingApproval;
      case 'approved': return TicketStatus.approved;
      case 'rejected': return TicketStatus.rejected;
      case 'completed': return TicketStatus.completed;
      case 'cancelled': return TicketStatus.cancelled;
      default: return TicketStatus.open;
    }
  }
}

enum TicketPriority {
  low,
  normal,
  high,
  urgent;

  String get value {
    switch (this) {
      case TicketPriority.low: return 'low';
      case TicketPriority.normal: return 'normal';
      case TicketPriority.high: return 'high';
      case TicketPriority.urgent: return 'urgent';
    }
  }

  String get displayName {
    switch (this) {
      case TicketPriority.low: return 'Rendah';
      case TicketPriority.normal: return 'Normal';
      case TicketPriority.high: return 'Tinggi';
      case TicketPriority.urgent: return 'Urgent';
    }
  }

  static TicketPriority fromString(String value) {
    switch (value) {
      case 'low': return TicketPriority.low;
      case 'normal': return TicketPriority.normal;
      case 'high': return TicketPriority.high;
      case 'urgent': return TicketPriority.urgent;
      default: return TicketPriority.normal;
    }
  }
}
