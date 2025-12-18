// lib/widgets/shared/custom_speed_dial.dart
// Reusable SpeedDial Widget dengan Gojek-style UI
// Bisa dipakai di Employee, Cleaner, dan Admin screens

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

/// Model untuk SpeedDial Action
class SpeedDialAction {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  const SpeedDialAction({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });
}

/// Custom SpeedDial Widget dengan Gojek-style UI
class CustomSpeedDial extends StatelessWidget {
  /// List of actions to display
  final List<SpeedDialAction> actions;
  
  /// Main FAB background color
  final Color? mainButtonColor;
  
  /// Main FAB icon
  final IconData? mainIcon;
  
  /// Whether to show overlay when open
  final bool showOverlay;
  
  /// Overlay opacity (0.0 - 1.0)
  final double overlayOpacity;

  const CustomSpeedDial({
    super.key,
    required this.actions,
    this.mainButtonColor,
    this.mainIcon,
    this.showOverlay = true,
    this.overlayOpacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    // Get theme primary color as default
    final primaryColor = mainButtonColor ?? Theme.of(context).primaryColor;

    return SpeedDial(
      // ==================== MAIN BUTTON ====================
      icon: mainIcon ?? Icons.add,
      activeIcon: Icons.close,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      activeBackgroundColor: Colors.red[400],
      activeForegroundColor: Colors.white,
      
      // ==================== ANIMATION & BEHAVIOR ====================
      visible: true,
      closeManually: false,
      curve: Curves.easeInOutCubic,
      overlayColor: showOverlay ? Colors.black : Colors.transparent,
      overlayOpacity: showOverlay ? overlayOpacity : 0.0,
      
      // ==================== STYLING ====================
      elevation: 8.0,
      shape: const CircleBorder(),
      buttonSize: const Size(60, 60),
      childrenButtonSize: const Size(56, 56),
      spacing: 12,
      spaceBetweenChildren: 12,
      
      // ==================== ACTIONS ====================
      children: actions.map((action) {
        return SpeedDialChild(
          child: Icon(action.icon, color: Colors.white),
          backgroundColor: action.backgroundColor,
          foregroundColor: Colors.white,
          label: action.label,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          labelBackgroundColor: action.backgroundColor,
          elevation: 6.0,
          onTap: action.onTap,
        );
      }).toList(),
    );
  }
}

// ==================== PREDEFINED COLOR PALETTE ====================
/// Gojek-style color palette untuk consistency
class SpeedDialColors {
  /// Primary Blue - untuk action utama
  static const Color blue = Color(0xFF4A90E2);
  
  /// Gojek Green - untuk layanan
  static const Color green = Color(0xFF00AA13);
  
  /// Orange - untuk pending/warning
  static const Color orange = Color(0xFFFF8C00);
  
  /// Purple - untuk filter/view
  static const Color purple = Color(0xFF7B68EE);
  
  /// Red - untuk urgent/delete
  static const Color red = Color(0xFFE74C3C);
  
  /// Teal - untuk completed/success
  static const Color teal = Color(0xFF00CED1);
  
  /// Indigo - untuk admin actions
  static const Color indigo = Color(0xFF3F51B5);
  
  /// Amber - untuk analytics/reports
  static const Color amber = Color(0xFFFFA726);
}
