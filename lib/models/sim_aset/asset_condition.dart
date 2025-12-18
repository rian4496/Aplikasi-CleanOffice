// lib/models/sim_aset/asset_condition.dart
// SIM-ASET: Asset Condition Model

import 'package:flutter/material.dart';

class AssetCondition {
  final String id;
  final String code;
  final String name;
  final String? colorHex;
  final int sortOrder;
  final DateTime createdAt;

  AssetCondition({
    required this.id,
    required this.code,
    required this.name,
    this.colorHex,
    this.sortOrder = 0,
    required this.createdAt,
  });

  factory AssetCondition.fromSupabase(Map<String, dynamic> json) {
    return AssetCondition(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      colorHex: json['color'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'code': code,
      'name': name,
      'color': colorHex,
      'sort_order': sortOrder,
    };
  }

  /// Get Flutter Color from hex string
  Color get color {
    if (colorHex == null) return Colors.grey;
    final hex = colorHex!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  /// Condition icons based on code
  IconData get icon {
    switch (code) {
      case 'baik':
        return Icons.check_circle;
      case 'cukup':
        return Icons.thumb_up;
      case 'kurang':
        return Icons.warning;
      case 'rusak_ringan':
        return Icons.build;
      case 'rusak_berat':
        return Icons.dangerous;
      default:
        return Icons.help_outline;
    }
  }
}

