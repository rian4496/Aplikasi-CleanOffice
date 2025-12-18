import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum TransactionType {
  IN, // Masuk (Pembelian/Restock)
  OUT, // Keluar (Pemakaian/Request)
  ADJUST, // Penyesuaian (Opname/Koreksi)
}

extension TransactionTypeExtension on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.IN:
        return 'Masuk';
      case TransactionType.OUT:
        return 'Keluar';
      case TransactionType.ADJUST:
        return 'Penyesuaian';
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.IN:
        return Colors.green;
      case TransactionType.OUT:
        return Colors.red;
      case TransactionType.ADJUST:
        return Colors.orange;
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.IN:
        return Icons.arrow_downward;
      case TransactionType.OUT:
        return Icons.arrow_upward;
      case TransactionType.ADJUST:
        return Icons.tune;
    }
  }
}

class StockMovement extends Equatable {
  final String id;
  final String itemId;
  final TransactionType type;
  final int quantity; // Can be positive or negative depending on DB implementation, but here absolute
  final String? referenceId; // Request ID or PO Number
  final String? notes;
  final String? performedBy;
  final String? performedByName;
  final DateTime createdAt;

  const StockMovement({
    required this.id,
    required this.itemId,
    required this.type,
    required this.quantity,
    this.referenceId,
    this.notes,
    this.performedBy,
    this.performedByName,
    required this.createdAt,
  });

  /// From Supabase (snake_case)
  factory StockMovement.fromSupabase(Map<String, dynamic> map) {
    return StockMovement(
      id: map['id'] as String,
      itemId: map['item_id'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.ADJUST,
      ),
      quantity: map['quantity'] as int,
      referenceId: map['reference_id'] as String?,
      notes: map['notes'] as String?,
      performedBy: map['performed_by'] as String?,
      performedByName: map['performed_by_name'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// To Supabase
  Map<String, dynamic> toSupabase() {
    return {
      'item_id': itemId,
      'type': type.name,
      'quantity': quantity,
      'reference_id': referenceId,
      'notes': notes,
      'performed_by': performedBy,
      'performed_by_name': performedByName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        itemId,
        type,
        quantity,
        referenceId,
        notes,
        performedBy,
        performedByName,
        createdAt,
      ];
}

// ==================== STOCK ACTION (Legacy) ====================
enum StockAction {
  add,
  reduce,
  adjustment,
  fulfillRequest,
  initialStock,
  manual,
  systemCorrection,
}

extension StockActionExtension on StockAction {
  String get label {
    switch (this) {
      case StockAction.add:
        return 'Penambahan';
      case StockAction.reduce:
        return 'Pengurangan';
      case StockAction.adjustment:
        return 'Penyesuaian';
      case StockAction.fulfillRequest:
        return 'Pemenuhan Permintaan';
      case StockAction.initialStock:
        return 'Stok Awal';
      case StockAction.manual:
        return 'Manual';
      case StockAction.systemCorrection:
        return 'Koreksi Sistem';
    }
  }
}

// ==================== STOCK HISTORY (Legacy) ====================
class StockHistory extends Equatable {
  final String id;
  final String itemId;
  final StockAction action;
  final int quantity;
  final int previousStock;
  final int newStock;
  final String? notes;
  final String performedByName;
  final DateTime timestamp;

  const StockHistory({
    required this.id,
    required this.itemId,
    required this.action,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    this.notes,
    required this.performedByName,
    required this.timestamp,
  });

  factory StockHistory.fromMap(String id, Map<String, dynamic> map) {
    return StockHistory(
      id: id,
      itemId: map['itemId'] as String,
      action: StockAction.values.firstWhere(
        (e) => e.name == map['action'],
        orElse: () => StockAction.adjustment,
      ),
      quantity: map['quantity'] as int,
      previousStock: map['previousStock'] as int,
      newStock: map['newStock'] as int,
      notes: map['notes'] as String?,
      performedByName: map['performedByName'] as String? ?? 'System',
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        itemId,
        action,
        quantity,
        previousStock,
        newStock,
        notes,
        performedByName,
        timestamp,
      ];
}
