// Disposal Model - Plain Dart (non-Freezed for compatibility)

class DisposalRequest {
  final String id;
  final String code;
  final String assetId;
  final String? proposerId;
  final String reason;
  final String? description;
  final double estimatedValue;
  final String status;
  final DateTime? approvalDate;
  final String? approvedBy;
  final String? finalDisposalType;
  final double? finalValue;
  final DateTime? executionDate;
  final DateTime? createdAt;
  final String? assetName;
  final String? assetCode;

  const DisposalRequest({
    required this.id,
    required this.code,
    required this.assetId,
    this.proposerId,
    required this.reason,
    this.description,
    this.estimatedValue = 0,
    this.status = 'draft',
    this.approvalDate,
    this.approvedBy,
    this.finalDisposalType,
    this.finalValue,
    this.executionDate,
    this.createdAt,
    this.assetName,
    this.assetCode,
  });

  factory DisposalRequest.fromJson(Map<String, dynamic> json) {
    return DisposalRequest(
      id: json['id']?.toString() ?? '',
      code: json['code'] ?? '',
      assetId: json['asset_id'] ?? json['assetId'] ?? '',
      proposerId: json['proposer_id'] ?? json['proposerId'],
      reason: json['reason'] ?? '',
      description: json['description'],
      estimatedValue: (json['estimated_value'] ?? json['estimatedValue'] ?? 0).toDouble(),
      status: json['status'] ?? 'draft',
      approvalDate: json['approval_date'] != null ? DateTime.parse(json['approval_date']) : null,
      approvedBy: json['approved_by'] ?? json['approvedBy'],
      finalDisposalType: json['final_disposal_type'] ?? json['finalDisposalType'],
      finalValue: json['final_value'] != null ? (json['final_value']).toDouble() : null,
      executionDate: json['execution_date'] != null ? DateTime.parse(json['execution_date']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      assetName: json['asset_name'] ?? json['assetName'],
      assetCode: json['asset_code'] ?? json['assetCode'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'asset_id': assetId,
    'proposer_id': proposerId,
    'reason': reason,
    'description': description,
    'estimated_value': estimatedValue,
    'status': status,
    'approval_date': approvalDate?.toIso8601String(),
    'approved_by': approvedBy,
    'final_disposal_type': finalDisposalType,
    'final_value': finalValue,
    'execution_date': executionDate?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
    'asset_name': assetName,
    'asset_code': assetCode,
  };

  DisposalRequest copyWith({
    String? id,
    String? code,
    String? assetId,
    String? proposerId,
    String? reason,
    String? description,
    double? estimatedValue,
    String? status,
    DateTime? approvalDate,
    String? approvedBy,
    String? finalDisposalType,
    double? finalValue,
    DateTime? executionDate,
    DateTime? createdAt,
    String? assetName,
    String? assetCode,
  }) {
    return DisposalRequest(
      id: id ?? this.id,
      code: code ?? this.code,
      assetId: assetId ?? this.assetId,
      proposerId: proposerId ?? this.proposerId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      status: status ?? this.status,
      approvalDate: approvalDate ?? this.approvalDate,
      approvedBy: approvedBy ?? this.approvedBy,
      finalDisposalType: finalDisposalType ?? this.finalDisposalType,
      finalValue: finalValue ?? this.finalValue,
      executionDate: executionDate ?? this.executionDate,
      createdAt: createdAt ?? this.createdAt,
      assetName: assetName ?? this.assetName,
      assetCode: assetCode ?? this.assetCode,
    );
  }
}
