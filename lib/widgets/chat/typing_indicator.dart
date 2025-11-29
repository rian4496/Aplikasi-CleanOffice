// lib/widgets/chat/typing_indicator.dart
// Widget untuk menampilkan indikator typing

import 'package:flutter/material.dart';

import '../../core/design/admin_colors.dart';
import '../../core/design/admin_typography.dart';

/// Typing Indicator Widget
/// Shows "sedang mengetik..." when users are typing
class TypingIndicator extends StatefulWidget {
  final List<String> typingUserNames;

  const TypingIndicator({
    super.key,
    required this.typingUserNames,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.typingUserNames.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Animated typing dots
          _buildAnimatedDots(),
          const SizedBox(width: 8),
          // Typing text
          Expanded(
            child: Text(
              _buildTypingText(),
              style: AdminTypography.caption.copyWith(
                color: AdminColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Build animated typing dots
  Widget _buildAnimatedDots() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        );
      },
    );
  }

  /// Build single animated dot
  Widget _buildDot(int index) {
    final delay = index * 0.2;
    final progress = (_animation.value + delay) % 1.0;
    final opacity = progress < 0.5 ? progress * 2 : (1 - progress) * 2;

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AdminColors.primary.withValues(alpha: 0.3 + (opacity * 0.7)),
      ),
    );
  }

  /// Build typing text
  String _buildTypingText() {
    final names = widget.typingUserNames;
    if (names.isEmpty) return '';

    if (names.length == 1) {
      return '${names[0]} sedang mengetik...';
    } else if (names.length == 2) {
      return '${names[0]} dan ${names[1]} sedang mengetik...';
    } else {
      return '${names[0]} dan ${names.length - 1} lainnya sedang mengetik...';
    }
  }
}
