// lib/widgets/shared/realtime_notification_listener.dart
// 🔔 Realtime Notification Listener
// Listens to Supabase realtime ticket stream and triggers notifications
// Supports both Web (browser notifications) and Mobile (local notifications)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../models/ticket.dart';
import '../../models/notification_model.dart';
import '../../riverpod/ticket_providers.dart';
import '../../riverpod/settings_provider.dart';
import '../../services/web_notification_service_interface.dart';
import '../../services/notification_local_service.dart';

/// This widget wraps child content and listens for new tickets in realtime.
/// When a new ticket is detected, it shows a notification on Web or Mobile.
class RealtimeNotificationListener extends HookConsumerWidget {
  final Widget child;
  
  const RealtimeNotificationListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final webNotificationService = WebNotificationService();
    final localNotificationService = NotificationLocalService();
    
    // Track previous ticket count to detect new tickets
    final previousTicketIds = useState<Set<String>>({});
    final isInitialized = useState(false);
    
    // Watch settings for sound preference
    final settingsAsync = ref.watch(settingsProvider);
    final soundEnabled = settingsAsync.value?.soundEnabled ?? true;
    
    // Listen to realtime ticket stream
    ref.listen<AsyncValue<List<Ticket>>>(ticketsStreamProvider, (previous, next) {
      next.whenData((tickets) {
        // Build current ticket IDs set
        final currentTicketIds = tickets.map((t) => t.id).toSet();
        
        // Skip first load (initialization)
        if (!isInitialized.value) {
          previousTicketIds.value = currentTicketIds;
          isInitialized.value = true;
          return;
        }
        
        // Find new tickets (IDs that weren't in previous set)
        final newTicketIds = currentTicketIds.difference(previousTicketIds.value);
        
        if (newTicketIds.isNotEmpty) {
          // Get the new ticket details
          final newTickets = tickets.where((t) => newTicketIds.contains(t.id)).toList();
          
          for (final ticket in newTickets) {
            _showTicketNotification(
              ticket, 
              webNotificationService, 
              localNotificationService,
              soundEnabled,
            );
          }
        }
        
        // Update previous IDs for next comparison
        previousTicketIds.value = currentTicketIds;
      });
    });
    
    return child;
  }
  
  void _showTicketNotification(
    Ticket ticket, 
    WebNotificationService webNotificationService,
    NotificationLocalService localNotificationService,
    bool soundEnabled,
  ) {
    // Build notification content based on ticket type
    String title;
    NotificationType notifType;
    
    switch (ticket.type) {
      case TicketType.kerusakan:
        title = '🔧 Laporan Kerusakan Baru';
        notifType = NotificationType.reportAssigned;
        break;
      case TicketType.kebersihan:
        title = '🧹 Laporan Kebersihan Baru';
        notifType = NotificationType.reportAssigned;
        break;
      case TicketType.stockRequest:
        title = '📦 Request Stok Baru';
        notifType = NotificationType.lowStockAlert;
        break;
    }
    
    String body = ticket.title;
    if (ticket.locationName != null && ticket.locationName!.isNotEmpty) {
      body += '\n📍 ${ticket.locationName}';
    }
    
    // Show notification based on platform
    if (kIsWeb) {
      // Web: Use browser notifications
      if (webNotificationService.isEnabled) {
        webNotificationService.showNotification(
          title: title,
          body: body,
        );
      }
      
      // Play sound on web if enabled
      if (soundEnabled) {
        webNotificationService.playSound();
      }
    } else {
      // Mobile: Use local notifications
      final appNotification = AppNotification(
        id: ticket.id,
        userId: ticket.assignedTo ?? '',
        title: title,
        message: body,
        type: notifType,
        createdAt: DateTime.now(),
        read: false,
      );
      
      localNotificationService.showNotification(appNotification);
    }
  }
}
