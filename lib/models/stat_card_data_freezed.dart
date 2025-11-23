// lib/models/stat_card_data_freezed.dart
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stat_card_data_freezed.freezed.dart';

@freezed
class StatCardData with _$StatCardData {
  const StatCardData._(); // Private constructor for custom methods

  const factory StatCardData({
    required String label,
    required String sublabel,
    required int value,
    required double percentage,
    required Color accentColor,
    required IconData icon,
    int? comparisonValue, // For showing trend (+12, -5, etc.)
    @Default(true) bool isPositiveTrend, // true = green up arrow, false = red down arrow
  }) = _StatCardData;

  String get formattedValue => value.toString();

  String? get trendText {
    if (comparisonValue == null) return null;
    final sign = comparisonValue! >= 0 ? '+' : '';
    return '$sign$comparisonValue%';
  }

  IconData? get trendIcon {
    if (comparisonValue == null) return null;
    if (comparisonValue! > 0) {
      return isPositiveTrend ? Icons.trending_up : Icons.trending_down;
    } else if (comparisonValue! < 0) {
      return isPositiveTrend ? Icons.trending_down : Icons.trending_up;
    }
    return Icons.trending_flat;
  }

  Color? get trendColor {
    if (comparisonValue == null) return null;
    if (comparisonValue! > 0) {
      return isPositiveTrend ? Colors.green : Colors.red;
    } else if (comparisonValue! < 0) {
      return isPositiveTrend ? Colors.red : Colors.green;
    }
    return Colors.grey;
  }
}
