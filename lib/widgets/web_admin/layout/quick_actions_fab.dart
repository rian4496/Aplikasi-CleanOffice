// lib/widgets/web_admin/layout/quick_actions_fab.dart
// ➕ Quick Actions FAB
// Floating Action Button with expandable quick actions

import 'package:flutter/material.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_constants.dart';

class QuickActionsFAB extends StatefulWidget {
  final List<FABAction> actions;
  final VoidCallback? onMainTap;

  const QuickActionsFAB({
    super.key,
    required this.actions,
    this.onMainTap,
  });

  @override
  State<QuickActionsFAB> createState() => _QuickActionsFABState();
}

class _QuickActionsFABState extends State<QuickActionsFAB>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AdminConstants.animationNormal,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: AdminConstants.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Action items (stacked, animated)
        ...List.generate(
          widget.actions.length,
          (index) => _buildActionButton(
            widget.actions[index],
            index,
          ),
        ),
        const SizedBox(height: AdminConstants.spaceMd),
        // Main FAB
        FloatingActionButton(
          onPressed: widget.onMainTap ?? _toggle,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0, // 45 degrees rotation
            duration: AdminConstants.animationNormal,
            child: Icon(
              _isExpanded ? Icons.close : Icons.add,
              size: AdminConstants.fabIconSize,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(FABAction action, int index) {
    return ScaleTransition(
      scale: _expandAnimation,
      child: FadeTransition(
        opacity: _expandAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AdminConstants.spaceSm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label
              if (_isExpanded)
                Container(
                  margin: const EdgeInsets.only(right: AdminConstants.spaceSm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AdminConstants.spaceMd,
                    vertical: AdminConstants.spaceSm,
                  ),
                  decoration: BoxDecoration(
                    color: AdminColors.surface,
                    borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                    boxShadow: AdminConstants.shadowCard,
                  ),
                  child: Text(
                    action.label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              // Mini FAB
              if (_isExpanded)
                FloatingActionButton.small(
                  onPressed: () {
                    action.onTap();
                    _toggle(); // Close after tap
                  },
                  backgroundColor: action.color ?? AdminColors.primary,
                  child: Icon(action.icon, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// FAB Action data class
class FABAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const FABAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
}

