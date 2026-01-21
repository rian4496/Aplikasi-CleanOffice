// lib/models/transactions/custodian_history_model.dart
// SIM-ASET: Custodian History Model

class CustodianHistory {
  final String id;
  final String assetId;
  final String? oldCustodianId;
  final String? oldCustodianName;
  final String? newCustodianId;
  final String? newCustodianName;
  final String? changedBy;
  final String? changeReason;
  final DateTime changedAt;

  const CustodianHistory({
    required this.id,
    required this.assetId,
    this.oldCustodianId,
    this.oldCustodianName,
    this.newCustodianId,
    this.newCustodianName,
    this.changedBy,
    this.changeReason,
    required this.changedAt,
  });

  factory CustodianHistory.fromJson(Map<String, dynamic> json) {
    return CustodianHistory(
      id: json['id']?.toString() ?? '',
      assetId: json['asset_id'] ?? '',
      oldCustodianId: json['old_custodian_id'],
      oldCustodianName: json['old_custodian']?['full_name'],
      newCustodianId: json['new_custodian_id'],
      newCustodianName: json['new_custodian']?['full_name'],
      changedBy: json['changed_by'],
      changeReason: json['change_reason'],
      changedAt: json['changed_at'] != null 
          ? DateTime.parse(json['changed_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset_id': assetId,
      'old_custodian_id': oldCustodianId,
      'new_custodian_id': newCustodianId,
      'changed_by': changedBy,
      'change_reason': changeReason,
    };
  }
}
