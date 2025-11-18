// lib/models/stock_history_freezed.dart
// Stock history entry model for audit trail - Freezed Version

import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/firestore_converters.dart';

part 'stock_history_freezed.freezed.dart';
part 'stock_history_freezed.g.dart';

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

// ==================== STOCK HISTORY ====================

@freezed
class StockHistory with _$StockHistory {
  const StockHistory._(); // Private constructor for custom methods

  const factory StockHistory({
    required String id,
    required String itemId,
    required String itemName,
    required StockAction action,
    required int quantity,
    required int previousStock,
    required int newStock,
    required String performedBy,
    required String performedByName,
    String? notes,
    @ISODateTimeConverter() required DateTime timestamp,
    String? referenceId, // Optional: link to request ID or other reference
  }) = _StockHistory;

  /// Convert dari JSON ke StockHistory object
  factory StockHistory.fromJson(Map<String, dynamic> json) => _$StockHistoryFromJson(json);

  /// Convert dari Map ke StockHistory object (backward compatibility)
  factory StockHistory.fromMap(String id, Map<String, dynamic> map) {
    return StockHistory.fromJson({
      'id': id,
      'itemId': map['itemId'],
      'itemName': map['itemName'],
      'action': map['action'], // json_serializable handles enum
      'quantity': map['quantity'],
      'previousStock': map['previousStock'],
      'newStock': map['newStock'],
      'performedBy': map['performedBy'],
      'performedByName': map['performedByName'],
      'notes': map['notes'],
      'timestamp': map['timestamp'],
      'referenceId': map['referenceId'],
    });
  }

  /// Convert StockHistory object ke Map (backward compatibility)
  Map<String, dynamic> toMap() {
    final json = toJson();
    // Remove 'id' from map for Firestore
    json.remove('id');
    // Convert enum to string for backward compatibility
    json['action'] = action.name;
    return json;
  }
}
