// lib/models/stock_history.dart
// Stock history entry model for audit trail

import 'package:equatable/equatable.dart';

class StockHistory extends Equatable {
  final String id;
  final String itemId;
  final String itemName;
  final StockAction action;
  final int quantity;
  final int previousStock;
  final int newStock;
  final String performedBy;
  final String performedByName;
  final String? notes;
  final DateTime timestamp;
  final String? referenceId; // Optional: link to request ID or other reference

  const StockHistory({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.action,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    required this.performedBy,
    required this.performedByName,
    this.notes,
    required this.timestamp,
    this.referenceId,
  });

  // From Firestore
  factory StockHistory.fromMap(String id, Map<String, dynamic> map) {
    return StockHistory(
      id: id,
      itemId: map['itemId'] as String,
      itemName: map['itemName'] as String,
      action: StockAction.values.firstWhere(
        (e) => e.name == map['action'],
        orElse: () => StockAction.manual,
      ),
      quantity: map['quantity'] as int,
      previousStock: map['previousStock'] as int,
      newStock: map['newStock'] as int,
      performedBy: map['performedBy'] as String,
      performedByName: map['performedByName'] as String,
      notes: map['notes'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      referenceId: map['referenceId'] as String?,
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'action': action.name,
      'quantity': quantity,
      'previousStock': previousStock,
      'newStock': newStock,
      'performedBy': performedBy,
      'performedByName': performedByName,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
      'referenceId': referenceId,
    };
  }

  @override
  List<Object?> get props => [
        id,
        itemId,
        itemName,
        action,
        quantity,
        previousStock,
        newStock,
        performedBy,
        performedByName,
        notes,
        timestamp,
        referenceId,
      ];
}

// ==================== STOCK ACTION ENUM ====================

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
        return 'Tambah Stok';
      case StockAction.reduce:
        return 'Kurangi Stok';
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

  String get icon {
    switch (this) {
      case StockAction.add:
        return '➕';
      case StockAction.reduce:
        return '➖';
      case StockAction.adjustment:
        return '🔧';
      case StockAction.fulfillRequest:
        return '✅';
      case StockAction.initialStock:
        return '🆕';
      case StockAction.manual:
        return '✏️';
      case StockAction.systemCorrection:
        return '⚙️';
    }
  }
}
