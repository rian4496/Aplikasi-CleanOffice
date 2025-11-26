import 'package:flutter/material.dart';

/// Motion and Animation Constants for Employee \u0026 Cleaner Modules
/// Defines durations, curves, and animation behaviors
class MotionConstants {
  MotionConstants._();

  // ==================== DURATION CONSTANTS ====================
  /// Quick animations (button taps, icon changes)
  static const Duration quick = Duration(milliseconds: 150);

  /// Medium animations (page transitions, modals)
  static const Duration medium = Duration(milliseconds: 300);

  /// Slow animations (complex transitions, progress)
  static const Duration slow = Duration(milliseconds: 500);

  /// Extra slow (progress bars, data loading)
  static const Duration xSlow = Duration(milliseconds: 800);

  /// Stagger delay between list items
  static const Duration staggerInterval = Duration(milliseconds: 50);

  // ==================== ANIMATION CURVES ====================
  /// Standard easing for most animations
  static const Curve standard = Curves.easeInOutCubic;

  /// Quick out (button taps, micro-interactions)
  static const Curve quickOut = Curves.easeOutCubic;

  /// Quick in (dismissals, exits)
  static const Curve quickIn = Curves.easeInCubic;

  /// Spring/bounce effect (playful interactions)
  static const Curve spring = Curves.easeOutBack;

  /// Elastic bounce (emphasized interactions)
  static const Curve bounce = Curves.elasticOut;

  /// Smooth (fluid transitions)
  static const Curve smooth = Curves.easeInOutCirc;

  // ==================== SCALE FACTORS ====================
  /// Tap scale (buttons, cards)
  static const double tapScaleDown = 0.95;

  /// Hover scale (desktop hover states)
  static const double hoverScaleUp = 1.05;

  /// Active icon scale (bottom nav)
  static const double iconActiveScale = 1.2;

  // ==================== OPACITY VALUES ====================
  /// Disabled state opacity
  static const double opacityDisabled = 0.38;

  /// Inactive state opacity
  static const double opacityInactive = 0.6;

  /// Hover overlay opacity
  static const double opacityHover = 0.08;

  /// Pressed overlay opacity
  static const double opacityPressed = 0.12;

  // ==================== SLIDE OFFSETS ====================
  /// Slide from bottom (bottom sheets)
  static const Offset slideFromBottom = Offset(0, 1);

  /// Slide from right (drawers)
  static const Offset slideFromRight = Offset(1, 0);

  /// Slide from top (notifications)
  static const Offset slideFromTop = Offset(0, -1);

  /// Small slide (stagger animations)
  static const Offset slideSmall = Offset(0, 0.3);

  // ==================== ANIMATION BUILDERS ====================
  /// Build fade transition
  static Widget fadeTransition(
    Animation<double> animation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Build slide transition
  static Widget slideTransition(
    Animation<double> animation,
    Widget child, {
    Offset begin = slideFromBottom,
    Offset end = Offset.zero,
  }) {
    return SlideTransition(
      position: Tween<Offset>(begin: begin, end: end).animate(
        CurvedAnimation(parent: animation, curve: standard),
      ),
      child: child,
    );
  }

  /// Build scale transition
  static Widget scaleTransition(
    Animation<double> animation,
    Widget child, {
    double begin = 0.8,
    double end = 1.0,
  }) {
    return ScaleTransition(
      scale: Tween<double>(begin: begin, end: end).animate(
        CurvedAnimation(parent: animation, curve: quickOut),
      ),
      child: child,
    );
  }

  /// Build stagger animation with delay
  static CurvedAnimation staggerAnimation(
    Animation<double> parent,
    int index, {
    int totalItems = 5,
  }) {
    final begin = (index / totalItems).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: parent,
      curve: Interval(
        begin,
        1.0,
        curve: quickOut,
      ),
    );
  }
}
