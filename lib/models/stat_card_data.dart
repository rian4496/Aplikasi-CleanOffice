// lib/models/stat_card_data.dart

import 'package:flutter/material.dart';

class StatCardData {
  final String label;
  final String sublabel;
  final int value;
  final double percentage;
  final Color accentColor;
  final IconData icon;
  final int? comparisonValue; // For showing trend (+12, -5, etc.)
  final bool isPositiveTrend; // true = green up arrow, false = red down arrow

  const StatCardData({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.percentage,
    required this.accentColor,
    required this.icon,
    this.comparisonValue,
    this.isPositiveTrend = true,
  });

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
