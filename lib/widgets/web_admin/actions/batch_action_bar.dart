// lib/widgets/web_admin/actions/batch_action_bar.dart
// ✅ Batch Action Bar
// Sliding action bar for batch operations

import 'package:flutter/material.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';

class BatchActionBar extends StatelessWidget {
  final int selectedCount;
  final List<BatchAction> actions;
  final VoidCallback? onClearSelection;

  const BatchActionBar({
    super.key,
    required this.selectedCount,
    required this.actions,
    this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminConstants.spaceLg,
        vertical: AdminConstants.spaceMd,
      ),
      decoration: BoxDecoration(
        color: AdminColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Close button
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onClearSelection,
              iconSize: AdminConstants.iconMd,
            ),
            const SizedBox(width: AdminConstants.spaceSm),
            
            // Selected count
            Text(
              '$selectedCount dipilih',
              style: AdminTypography.body1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            
            // Action buttons
            ...actions.map(
              (action) => Padding(
                padding: const EdgeInsets.only(left: AdminConstants.spaceSm),
                child: _buildActionButton(action),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BatchAction action) {
    return IconButton(
      icon: Icon(action.icon, color: Colors.white),
      onPressed: action.onTap,
      iconSize: AdminConstants.iconMd,
      tooltip: action.label,
    );
  }
}

/// Batch action data class
class BatchAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const BatchAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

