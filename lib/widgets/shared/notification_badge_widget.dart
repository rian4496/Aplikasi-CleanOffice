// lib/widgets/shared/notification_badge_widget.dart
// Reusable badge widget for notifications and counts

import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  final Color? badgeColor;
  final bool showDot; // Show red dot instead of count
  final double? dotSize;
  
  const NotificationBadge({
    required this.count,
    required this.child,
    this.badgeColor,
    this.showDot = false,
    this.dotSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show badge if count is 0 and not showing dot
    if (count == 0 && !showDot) {
      return child;
    }
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        
        // Badge/Dot overlay
        if (count > 0 || showDot)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: showDot 
                  ? EdgeInsets.all(dotSize ?? 6)
                  : const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor ?? Colors.red,
                shape: showDot ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: showDot ? null : BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: BoxConstraints(
                minWidth: showDot ? (dotSize ?? 12) : 18,
                minHeight: showDot ? (dotSize ?? 12) : 18,
              ),
              child: showDot
                  ? null
                  : Text(
                      count > 99 ? '99+' : count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
      ],
    );
  }
}

/// Simplified badge for icon buttons
class IconBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? badgeColor;
  
  const IconBadge({
    required this.icon,
    required this.count,
    this.onPressed,
    this.iconColor,
    this.badgeColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationBadge(
      count: count,
      badgeColor: badgeColor,
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }
}
