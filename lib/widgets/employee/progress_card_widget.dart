// lib/widgets/employee/progress_card_widget.dart

import 'package:flutter/material.dart';

/// Enhanced Progress Card dengan gradient, icon, dan animations
class ProgressCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const ProgressCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, animValue, child) {
          return Transform.scale(
            scale: 0.8 + (animValue * 0.2),
            child: Opacity(opacity: animValue, child: child),
          );
        },
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Card(
            elevation: 3,
            shadowColor: color.withAlpha(100),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withAlpha(40),
                    color.withAlpha(20),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon dengan background
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withAlpha(60),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 12),
                  
                  // Animated Value
                  TweenAnimationBuilder<int>(
                    tween: IntTween(
                      begin: 0,
                      end: int.tryParse(value) ?? 0,
                    ),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, val, child) {
                      return Text(
                        val.toString(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: color,
                          height: 1,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  
                  // Label
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}