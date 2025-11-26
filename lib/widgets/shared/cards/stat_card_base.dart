import 'package:flutter/material.dart';
import '../../../core/design/shared_design_constants.dart';
import '../../../core/design/motion_constants.dart';

/// Universal Stat Card Component
/// Used across all modules (Admin, Employee, Cleaner)
/// Supports pastel backgrounds, icons, values, and trend indicators
class StatCardBase extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final int colorIndex; // 0-5 for rotating pastel palette
  final String? trend; // e.g. "↑ 12%" or "+5 dari kemarin"
  final bool? trendUp; // true = positive, false = negative
  final VoidCallback? onTap;

  const StatCardBase({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.colorIndex = 0,
    this.trend,
    this.trendUp,
    this.onTap,
  });

  @override
  State<StatCardBase> createState() => _StatCardBaseState();
}

class _StatCardBaseState extends State<StatCardBase>
    with SingleTickerProviderStateMixin {
  bool _isTapped = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MotionConstants.quick,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: MotionConstants.tapScaleDown,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: MotionConstants.quickOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isTapped = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() => _isTapped = false);
      _controller.reverse();
      widget.onTap?.call();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      setState(() => _isTapped = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = SharedDesignConstants.getStatCardColors(widget.colorIndex);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          padding: SharedDesignConstants.paddingMd,
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: SharedDesignConstants.borderRadiusMd,
            boxShadow: SharedDesignConstants.shadowCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with circular background
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.foreground.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: colors.foreground,
                  size: SharedDesignConstants.iconSm,
                ),
              ),

              const SizedBox(height: SharedDesignConstants.spaceMd),

              // Label
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.foreground.withValues(alpha: 0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: SharedDesignConstants.spaceXs),

              // Value (large number)
              Text(
                widget.value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colors.foreground,
                  height: 1.2,
                ),
              ),

              // Trend indicator (optional)
              if (widget.trend != null) ...[
                const SizedBox(height: SharedDesignConstants.spaceXs),
                Row(
                  children: [
                    Icon(
                      widget.trendUp == true
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 14,
                      color: widget.trendUp == true
                          ? const Color(0xFF10B981) // Green
                          : const Color(0xFFEF4444), // Red
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.trend!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: widget.trendUp == true
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
