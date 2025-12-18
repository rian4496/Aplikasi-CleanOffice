// lib/widgets/web_admin/realtime_indicator_widget.dart
// Live/Online indicator to show real-time connectivity status

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/riverpod/system_providers.dart';

class RealtimeIndicator extends ConsumerWidget {
  const RealtimeIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isOnline ? Colors.green : Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isOnline ? Colors.green : Colors.grey, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          
          // Status text
          Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              color: isOnline ? Colors.green : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact version for AppBar with Connectivity Check
class RealtimeIndicatorCompact extends ConsumerWidget {
  const RealtimeIndicatorCompact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status Dot
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOnline ? Colors.greenAccent : Colors.grey,
            shape: BoxShape.circle,
            boxShadow: isOnline ? [
              BoxShadow(
                color: Colors.greenAccent.withOpacity(0.6),
                blurRadius: 4,
                spreadRadius: 1,
              )
            ] : null,
          ),
        ),
        const SizedBox(width: 8),
        
        // Status Text
        Text(
          isOnline ? 'ONLINE' : 'OFFLINE',
          style: TextStyle(
            color: Colors.white.withOpacity(isOnline ? 1.0 : 0.7),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
