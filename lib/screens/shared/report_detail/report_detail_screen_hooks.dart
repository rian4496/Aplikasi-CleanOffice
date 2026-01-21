// lib/screens/shared/report_detail/report_detail_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/report.dart';
import '../../../riverpod/auth_providers.dart';

// Widget components
import '../../../widgets/report/report_header.dart';
import '../../../widgets/report/report_info_sections.dart';
import '../../../widgets/report/report_timeline.dart';
import '../../../widgets/report/report_images_section.dart';
import '../../../widgets/report/report_verification_section.dart';

// Role-specific actions
import '../../../widgets/role_actions/cleaner_actions.dart';
import '../../../widgets/role_actions/employee_actions.dart';
import '../../../widgets/role_actions/admin_actions.dart';

/// Universal Report Detail Screen
/// Supports: Employee, Cleaner, Admin roles
/// ✅ MIGRATED: Simple conversion (ConsumerWidget → HookConsumerWidget)
class ReportDetailScreen extends HookConsumerWidget {
  final Report report;
  final String? overrideRole; // For testing or explicit role

  const ReportDetailScreen({
    super.key,
    required this.report,
    this.overrideRole,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Detect current user role
    final userRole = overrideRole ?? ref.watch(currentUserRoleProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==================== SHARED COMPONENTS ====================

            // Header: Status Badge + Location + Urgent
            ReportHeader(report: report),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Problem Image (if exists)
                  ReportImagesSection(report: report),

                  // Info Sections: Location, Description, Reporter, Date
                  ReportInfoSections(report: report),

                  const SizedBox(height: 24),

                  // Timeline
                  ReportTimeline(report: report),

                  const SizedBox(height: 24),

                  // Completion Photo (if completed)
                  if (report.completionImageUrl != null &&
                      report.completionImageUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: ReportCompletionPhotoSection(report: report),
                    ),

                  // Verification Info (if verified)
                  if (report.status == ReportStatus.verified &&
                      report.verifiedByName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: ReportVerificationSection(report: report),
                    ),

                  // ==================== ROLE-SPECIFIC ACTIONS ====================

                  _buildRoleSpecificActions(
                    context,
                    ref,
                    userRole,
                    currentUserId,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build action buttons based on user role
  Widget _buildRoleSpecificActions(
    BuildContext context,
    WidgetRef ref,
    String? userRole,
    String? currentUserId,
  ) {
    // No role detected = no actions
    if (userRole == null) {
      return const SizedBox.shrink();
    }

    // TODO (Phase 5): Replace role switch with go_router route-based permissions
    switch (userRole) {
      case 'cleaner':
        return CleanerActions(
          report: report,
          currentUserId: currentUserId,
        );

      case 'employee':
        return EmployeeActions(
          report: report,
          currentUserId: currentUserId,
        );

      case 'admin':
        return AdminActions(
          report: report,
          currentUserId: currentUserId,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

