/// Model untuk tracking pergerakan stok (keluar/masuk)
/// Maps to existing `stock_movements` table in Supabase
class StockMovement {
  final String id;
  final String itemId; // Maps to item_id
  final String type; // 'IN' or 'OUT'
  final int quantity;
  final String? referenceId; // Text reference
  final String? notes;
  final DateTime? performedAt;

  // Display names (populated via joins)
  final String? itemName;

  StockMovement({
    required this.id,
    required this.itemId,
    required this.type,
    required this.quantity,
    this.referenceId,
    this.notes,
    this.performedAt,
    this.itemName,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    // Extract nested display name for item
    String? itemName;
    if (json['inventory_item'] != null && json['inventory_item'] is Map) {
      itemName = json['inventory_item']['name'] as String?;
    }

    return StockMovement(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      type: json['type'] as String,
      quantity: json['quantity'] as int? ?? 0,
      referenceId: json['reference_id'] as String?,
      notes: json['notes'] as String?,
      performedAt: json['performed_at'] != null 
          ? DateTime.parse(json['performed_at'] as String)
          : null,
      itemName: itemName,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'item_id': itemId,
      'type': type,
      'quantity': quantity,
      'reference_id': referenceId,
      'notes': notes,
    };
  }

  bool get isStockIn => type == 'IN';
  bool get isStockOut => type == 'OUT';

  String get displayType => isStockIn ? 'Masuk' : 'Keluar';
}

// Keep MovementType enum for backward compatibility with report screen
enum MovementType {
  stockIn,
  stockOut,
  adjustment;

  String get value {
    switch (this) {
      case MovementType.stockIn: return 'IN';
      case MovementType.stockOut: return 'OUT';
      case MovementType.adjustment: return 'adjustment';
    }
  }

  String get displayName {
    switch (this) {
      case MovementType.stockIn: return 'Masuk';
      case MovementType.stockOut: return 'Keluar';
      case MovementType.adjustment: return 'Penyesuaian';
    }
  }

  static MovementType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'IN': return MovementType.stockIn;
      case 'OUT': return MovementType.stockOut;
      case 'ADJUSTMENT': return MovementType.adjustment;
      default: return MovementType.adjustment;
    }
  }
}
