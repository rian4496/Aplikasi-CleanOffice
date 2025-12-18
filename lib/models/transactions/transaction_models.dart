// Transaction Models - Plain Dart (non-Freezed for compatibility)

// =====================================================
// 1. PROCUREMENT (PENGADAAN)
// =====================================================

class ProcurementRequest {
  final String id;
  final String code;
  final DateTime requestDate;
  final String? requesterId;
  final String status;
  final String? description;
  final double totalEstimatedBudget;
  final String? poNumber;
  final String? vendorId;
  final DateTime? createdAt;
  final String? requesterName;
  final List<ProcurementItem> items;

  const ProcurementRequest({
    required this.id,
    required this.code,
    required this.requestDate,
    this.requesterId,
    this.status = 'pending',
    this.description,
    this.totalEstimatedBudget = 0,
    this.poNumber,
    this.vendorId,
    this.createdAt,
    this.requesterName,
    this.items = const [],
  });

  factory ProcurementRequest.fromJson(Map<String, dynamic> json) {
    return ProcurementRequest(
      id: json['id']?.toString() ?? '',
      code: json['code'] ?? '',
      requestDate: json['request_date'] != null
          ? DateTime.parse(json['request_date'])
          : DateTime.now(),
      requesterId: json['requester_id'] ?? json['requesterId'],
      status: json['status'] ?? 'pending',
      description: json['description'],
      totalEstimatedBudget: (json['total_estimated_budget'] ?? json['totalEstimatedBudget'] ?? 0).toDouble(),
      poNumber: json['po_number'] ?? json['poNumber'],
      vendorId: json['vendor_id'] ?? json['vendorId'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      requesterName: json['requester_name'] ?? json['requesterName'],
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => ProcurementItem.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'request_date': requestDate.toIso8601String(),
    'requester_id': requesterId,
    'status': status,
    'description': description,
    'total_estimated_budget': totalEstimatedBudget,
    'po_number': poNumber,
    'vendor_id': vendorId,
    'created_at': createdAt?.toIso8601String(),
    'requester_name': requesterName,
    'items': items.map((e) => e.toJson()).toList(),
  };

  ProcurementRequest copyWith({
    String? id,
    String? code,
    DateTime? requestDate,
    String? requesterId,
    String? status,
    String? description,
    double? totalEstimatedBudget,
    String? poNumber,
    String? vendorId,
    DateTime? createdAt,
    String? requesterName,
    List<ProcurementItem>? items,
  }) {
    return ProcurementRequest(
      id: id ?? this.id,
      code: code ?? this.code,
      requestDate: requestDate ?? this.requestDate,
      requesterId: requesterId ?? this.requesterId,
      status: status ?? this.status,
      description: description ?? this.description,
      totalEstimatedBudget: totalEstimatedBudget ?? this.totalEstimatedBudget,
      poNumber: poNumber ?? this.poNumber,
      vendorId: vendorId ?? this.vendorId,
      createdAt: createdAt ?? this.createdAt,
      requesterName: requesterName ?? this.requesterName,
      items: items ?? this.items,
    );
  }
}

class ProcurementItem {
  final String id;
  final String procurementId;
  final String itemName;
  final int quantity;
  final double unitPriceEstimate;
  final double totalPriceEstimate;
  final String? budgetId;

  const ProcurementItem({
    required this.id,
    required this.procurementId,
    required this.itemName,
    this.quantity = 1,
    this.unitPriceEstimate = 0,
    this.totalPriceEstimate = 0,
    this.budgetId,
  });

  factory ProcurementItem.fromJson(Map<String, dynamic> json) {
    return ProcurementItem(
      id: json['id']?.toString() ?? '',
      procurementId: json['procurement_id'] ?? json['procurementId'] ?? '',
      itemName: json['item_name'] ?? json['itemName'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPriceEstimate: (json['unit_price_estimate'] ?? json['unitPriceEstimate'] ?? 0).toDouble(),
      totalPriceEstimate: (json['total_price_estimate'] ?? json['totalPriceEstimate'] ?? 0).toDouble(),
      budgetId: json['budget_id'] ?? json['budgetId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'procurement_id': procurementId,
    'item_name': itemName,
    'quantity': quantity,
    'unit_price_estimate': unitPriceEstimate,
    'total_price_estimate': totalPriceEstimate,
    'budget_id': budgetId,
  };

  ProcurementItem copyWith({
    String? id,
    String? procurementId,
    String? itemName,
    int? quantity,
    double? unitPriceEstimate,
    double? totalPriceEstimate,
    String? budgetId,
  }) {
    return ProcurementItem(
      id: id ?? this.id,
      procurementId: procurementId ?? this.procurementId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unitPriceEstimate: unitPriceEstimate ?? this.unitPriceEstimate,
      totalPriceEstimate: totalPriceEstimate ?? this.totalPriceEstimate,
      budgetId: budgetId ?? this.budgetId,
    );
  }
}

// =====================================================
// 2. MAINTENANCE (PERBAIKAN)
// =====================================================

class MaintenanceRequest {
  final String id;
  final String? code;
  final String assetId;
  final String? reporterId;
  final String issueTitle;
  final String? issueDescription;
  final String priority;
  final String? assignedTechnicianId;
  final String? externalVendorId;
  final String status;
  final DateTime? scheduledDate;
  final DateTime? completionDate;
  final String? notesTechnician;
  final double totalCost;
  final String? proofPhotoBefore;
  final String? proofPhotoAfter;
  final DateTime? createdAt;
  final String? assetName;

  const MaintenanceRequest({
    required this.id,
    this.code,
    required this.assetId,
    this.reporterId,
    required this.issueTitle,
    this.issueDescription,
    this.priority = 'normal',
    this.assignedTechnicianId,
    this.externalVendorId,
    this.status = 'reported',
    this.scheduledDate,
    this.completionDate,
    this.notesTechnician,
    this.totalCost = 0,
    this.proofPhotoBefore,
    this.proofPhotoAfter,
    this.createdAt,
    this.assetName,
  });

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id']?.toString() ?? '',
      code: json['code'],
      assetId: json['asset_id'] ?? json['assetId'] ?? '',
      reporterId: json['reporter_id'] ?? json['reporterId'],
      issueTitle: json['issue_title'] ?? json['issueTitle'] ?? '',
      issueDescription: json['issue_description'] ?? json['issueDescription'],
      priority: json['priority'] ?? 'normal',
      assignedTechnicianId: json['assigned_technician_id'] ?? json['assignedTechnicianId'],
      externalVendorId: json['external_vendor_id'] ?? json['externalVendorId'],
      status: json['status'] ?? 'reported',
      scheduledDate: json['scheduled_date'] != null ? DateTime.parse(json['scheduled_date']) : null,
      completionDate: json['completion_date'] != null ? DateTime.parse(json['completion_date']) : null,
      notesTechnician: json['notes_technician'] ?? json['notesTechnician'],
      totalCost: (json['total_cost'] ?? json['totalCost'] ?? 0).toDouble(),
      proofPhotoBefore: json['proof_photo_before'] ?? json['proofPhotoBefore'],
      proofPhotoAfter: json['proof_photo_after'] ?? json['proofPhotoAfter'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      assetName: json['asset_name'] ?? json['assetName'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'asset_id': assetId,
    'reporter_id': reporterId,
    'issue_title': issueTitle,
    'issue_description': issueDescription,
    'priority': priority,
    'assigned_technician_id': assignedTechnicianId,
    'external_vendor_id': externalVendorId,
    'status': status,
    'scheduled_date': scheduledDate?.toIso8601String(),
    'completion_date': completionDate?.toIso8601String(),
    'notes_technician': notesTechnician,
    'total_cost': totalCost,
    'proof_photo_before': proofPhotoBefore,
    'proof_photo_after': proofPhotoAfter,
    'created_at': createdAt?.toIso8601String(),
    'asset_name': assetName,
  };

  MaintenanceRequest copyWith({
    String? id,
    String? code,
    String? assetId,
    String? reporterId,
    String? issueTitle,
    String? issueDescription,
    String? priority,
    String? assignedTechnicianId,
    String? externalVendorId,
    String? status,
    DateTime? scheduledDate,
    DateTime? completionDate,
    String? notesTechnician,
    double? totalCost,
    String? proofPhotoBefore,
    String? proofPhotoAfter,
    DateTime? createdAt,
    String? assetName,
  }) {
    return MaintenanceRequest(
      id: id ?? this.id,
      code: code ?? this.code,
      assetId: assetId ?? this.assetId,
      reporterId: reporterId ?? this.reporterId,
      issueTitle: issueTitle ?? this.issueTitle,
      issueDescription: issueDescription ?? this.issueDescription,
      priority: priority ?? this.priority,
      assignedTechnicianId: assignedTechnicianId ?? this.assignedTechnicianId,
      externalVendorId: externalVendorId ?? this.externalVendorId,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completionDate: completionDate ?? this.completionDate,
      notesTechnician: notesTechnician ?? this.notesTechnician,
      totalCost: totalCost ?? this.totalCost,
      proofPhotoBefore: proofPhotoBefore ?? this.proofPhotoBefore,
      proofPhotoAfter: proofPhotoAfter ?? this.proofPhotoAfter,
      createdAt: createdAt ?? this.createdAt,
      assetName: assetName ?? this.assetName,
    );
  }
}
