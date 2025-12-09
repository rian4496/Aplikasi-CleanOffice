// lib/widgets/admin/role_selector_widget.dart
// Visual role selector widget with chips for user role selection

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class RoleSelectorWidget extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;
  final bool enabled;

  const RoleSelectorWidget({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.badge_outlined, size: 20, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              'Role',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Role Selection Chips
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildRoleChip(
              context,
              role: 'employee',
              label: 'Employee',
              icon: Icons.person_outline,
              color: AppTheme.info,
            ),
            _buildRoleChip(
              context,
              role: 'cleaner',
              label: 'Cleaner',
              icon: Icons.cleaning_services_outlined,
              color: AppTheme.success,
            ),
            _buildRoleChip(
              context,
              role: 'admin',
              label: 'Admin',
              icon: Icons.admin_panel_settings_outlined,
              color: AppTheme.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleChip(
    BuildContext context, {
    required String role,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = selectedRole == role;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => onRoleChanged(role) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.grey[100],
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? color : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? color : Colors.grey[700],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.check_circle,
                  size: 18,
                  color: color,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
