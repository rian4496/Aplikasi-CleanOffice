import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum OpnameStatus {
  OPEN,
  COMPLETED,
  CANCELLED,
}

class StockOpname extends Equatable {
  final String id;
  final String opnameNumber;
  final OpnameStatus status;
  final String? notes;
  final String performedBy;
  final String? performedByName;
  final DateTime startedAt;
  final DateTime? completedAt;

  const StockOpname({
    required this.id,
    required this.opnameNumber,
    required this.status,
    this.notes,
    required this.performedBy,
    this.performedByName,
    required this.startedAt,
    this.completedAt,
  });

  factory StockOpname.fromSupabase(Map<String, dynamic> map) {
    return StockOpname(
      id: map['id'] as String,
      opnameNumber: map['opname_number'] as String,
      status: OpnameStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OpnameStatus.OPEN,
      ),
      notes: map['notes'] as String?,
      performedBy: map['performed_by'] as String,
      performedByName: map['performed_by_name'] as String?,
      startedAt: DateTime.parse(map['started_at'] as String),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
    );
  }

  Color get statusColor {
    switch (status) {
      case OpnameStatus.OPEN:
        return Colors.blue;
      case OpnameStatus.COMPLETED:
        return Colors.green;
      case OpnameStatus.CANCELLED:
        return Colors.red;
    }
  }

  @override
  List<Object?> get props => [
        id,
        opnameNumber,
        status,
        notes,
        performedBy,
        performedByName,
        startedAt,
        completedAt,
      ];
}

class StockOpnameItem extends Equatable {
  final String id;
  final String opnameId;
  final String itemId;
  final String? itemName; // For easier display (joined)
  final int systemStock;
  final int? actualStock;
  final String? notes;

  const StockOpnameItem({
    required this.id,
    required this.opnameId,
    required this.itemId,
    this.itemName,
    required this.systemStock,
    this.actualStock,
    this.notes,
  });

  factory StockOpnameItem.fromSupabase(Map<String, dynamic> map) {
    return StockOpnameItem(
      id: map['id'] as String,
      opnameId: map['opname_id'] as String,
      itemId: map['item_id'] as String,
      itemName: map['inventory_items'] != null ? map['inventory_items']['name'] : null,
      systemStock: map['system_stock'] as int,
      actualStock: map['actual_stock'] as int?,
      notes: map['notes'] as String?,
    );
  }

  int get discrepancy => (actualStock ?? systemStock) - systemStock;

  @override
  List<Object?> get props => [id, opnameId, itemId, systemStock, actualStock, notes];
}
