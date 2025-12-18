// lib/widgets/web_admin/layout/responsive_layout_builder.dart
// 📐 Responsive Layout Builder
// Helper widget untuk build different layouts based on screen size

import 'package:flutter/material.dart';
import '../../../core/design/admin_constants.dart';

/// Responsive layout builder
/// Builds different widgets based on screen breakpoints
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayoutBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Desktop layout
        if (AdminConstants.isDesktop(width) && desktop != null) {
          return desktop!;
        }

        // Tablet layout
        if (AdminConstants.isTablet(width) && tablet != null) {
          return tablet!;
        }

        // Mobile layout (fallback)
        return mobile;
      },
    );
  }
}

/// Helper extension for MediaQuery
extension ResponsiveHelper on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < AdminConstants.breakpointMobile;
  bool get isTablet {
    final width = MediaQuery.of(this).size.width;
    return width >= AdminConstants.breakpointMobile && width < AdminConstants.breakpointTablet;
  }
  bool get isDesktop => MediaQuery.of(this).size.width >= AdminConstants.breakpointTablet;

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}

