// lib/services/presence_service.dart
// Presence tracking service with heartbeat mechanism

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/logging/app_logger.dart';
import 'chat_service.dart';
import 'realtime_presence_service.dart';

/// Service to manage user presence with heartbeat mechanism
/// Updates last_seen every minute while user is active
class PresenceService {
  final ChatService _chatService;
  final _logger = AppLogger('PresenceService');
  
  Timer? _heartbeatTimer;
  String? _currentUserId;
  
  /// Heartbeat interval (how often to update last_seen)
  static const Duration heartbeatInterval = Duration(minutes: 1);
  
  /// Online threshold (how long until considered offline)
  static const Duration onlineThreshold = Duration(minutes: 2);

  PresenceService(this._chatService);

  /// Start presence tracking when user logs in
  void startPresence(String userId) {
    // Prevent duplicate timers
    if (_currentUserId == userId && _heartbeatTimer != null) {
      _logger.info('Presence already active for user: $userId');
      return;
    }
    
    // Stop any existing timer
    _heartbeatTimer?.cancel();
    
    _currentUserId = userId;
    _logger.info('Starting presence tracking for user: $userId');
    
    // Update immediately
    _chatService.updateLastSeen(userId);
    
    // Then update every minute
    _heartbeatTimer = Timer.periodic(
      heartbeatInterval,
      (_) {
        _logger.info('Heartbeat: updating last_seen');
        _chatService.updateLastSeen(userId);
      },
    );
  }

  /// Stop presence tracking when user logs out
  void stopPresence() {
    _logger.info('Stopping presence tracking');
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _currentUserId = null;
  }

  /// Check if presence is currently active
  bool get isActive => _heartbeatTimer != null && _currentUserId != null;

  /// Get current user ID being tracked
  String? get currentUserId => _currentUserId;

  /// Manually trigger a heartbeat (e.g., on user interaction)
  void triggerHeartbeat() {
    if (_currentUserId != null) {
      _chatService.updateLastSeen(_currentUserId!);
    }
  }
}

/// Provider for PresenceService
final presenceServiceProvider = Provider<PresenceService>((ref) {
  return PresenceService(ref.read(chatServiceProvider));
});

/// Auto-start presence when user is logged in
/// This provider watches auth state and automatically starts/stops presence
final presenceAutoStartProvider = Provider<void>((ref) {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentSession?.user.id;
  
  if (userId != null) {
    // User is logged in, start presence tracking (both heartbeat and realtime)
    ref.read(presenceServiceProvider).startPresence(userId);
    ref.read(realtimePresenceServiceProvider).joinPresence(userId);
  }
  
  // Listen for auth state changes
  supabase.auth.onAuthStateChange.listen((data) {
    final session = data.session;
    if (session != null) {
      ref.read(presenceServiceProvider).startPresence(session.user.id);
      ref.read(realtimePresenceServiceProvider).joinPresence(session.user.id);
    } else {
      ref.read(presenceServiceProvider).stopPresence();
      ref.read(realtimePresenceServiceProvider).leavePresence();
    }
  });
});
