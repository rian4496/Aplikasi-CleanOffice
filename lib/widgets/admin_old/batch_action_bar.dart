import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/riverpod/selection_providers.dart';
import '../../core/theme/app_theme.dart';

class BatchActionBar extends ConsumerWidget {
  final VoidCallback? onVerify;
  final VoidCallback? onDelete;
  final VoidCallback? onAssign;

  const BatchActionBar({
    super.key,
    this.onVerify,
    this.onDelete,
    this.onAssign,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCount = ref.watch(selectedCountProvider);
    final isVisible = ref.watch(selectionModeProvider);

    if (!isVisible) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => clearSelection(ref),
            ),
            const SizedBox(width: 8),
            Text(
              '$selectedCount dipilih',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            if (onVerify != null)
              _ActionButton(
                icon: Icons.verified_user,
                label: 'Verifikasi',
                color: AppTheme.success,
                onTap: onVerify!,
              ),
            if (onAssign != null)
              _ActionButton(
                icon: Icons.person_add,
                label: 'Tugaskan',
                color: AppTheme.info,
                onTap: onAssign!,
              ),
            if (onDelete != null)
              _ActionButton(
                icon: Icons.delete,
                label: 'Hapus',
                color: AppTheme.error,
                onTap: onDelete!,
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: color),
        label: Text(
          label,
          style: TextStyle(color: color),
        ),
        style: TextButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}
