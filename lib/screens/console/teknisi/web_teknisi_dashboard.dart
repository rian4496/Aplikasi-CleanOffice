// lib/screens/console/teknisi/web_teknisi_dashboard.dart
// 🖥️ Web Teknisi Dashboard - Responsive view for Teknisi role

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../teknisi/teknisi_home_screen.dart';

class WebTeknisiDashboard extends HookConsumerWidget {
  const WebTeknisiDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        // ================= MOBILE VIEW =================
        if (isMobile) {
          return const TeknisiHomeScreen();
        }

        // ================= DESKTOP VIEW =================
        return Scaffold(
          backgroundColor: AppTheme.modernBg,
          body: const Center(child: Text("Desktop View Not Implemented Yet")),
        );
      },
    );
  }
}
