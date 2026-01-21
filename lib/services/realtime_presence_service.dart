// lib/services/realtime_presence_service.dart
// Real-time presence tracking using Supabase Presence feature

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/logging/app_logger.dart';

/// Service for real-time user presence tracking using Supabase Presence
/// This provides instant online/offline status updates without database polling
class RealtimePresenceService {
  final _logger = AppLogger('RealtimePresence');
  final SupabaseClient _supabase;
  
  RealtimeChannel? _presenceChannel;
  String? _currentUserId;
  
  // Stream controller for online users set
  final _onlineUsersController = StreamController<Set<String>>.broadcast();
  
  /// Stream of currently online user IDs
  Stream<Set<String>> get onlineUsersStream => _onlineUsersController.stream;
  
  /// Current set of online users (cached)
  Set<String> _currentOnlineUsers = {};
  Set<String> get currentOnlineUsers => _currentOnlineUsers;

  RealtimePresenceService(this._supabase);

  /// Join the presence channel and start tracking
  void joinPresence(String userId) {
    if (_currentUserId == userId && _presenceChannel != null) {
      _logger.info('Already tracking presence for user: $userId');
      return;
    }
    
    _currentUserId = userId;
    _logger.info('Joining presence channel for user: $userId');
    
    // Create presence channel
    _presenceChannel = _supabase.channel(
      'online-users',
      opts: const RealtimeChannelConfig(self: true),
    );
    
    _presenceChannel!
      .onPresenceSync((payload) {
        _handlePresenceSync();
      })
      .onPresenceJoin((payload) {
        _logger.info('User joined: ${payload.newPresences}');
        _handlePresenceSync();
      })
      .onPresenceLeave((payload) {
        _logger.info('User left: ${payload.leftPresences}');
        _handlePresenceSync();
      })
      .subscribe((status, error) async {
        if (status == RealtimeSubscribeStatus.subscribed) {
          _logger.info('Presence channel subscribed, tracking user...');
          // Track this user as online
          await _presenceChannel!.track({
            'user_id': userId,
            'online_at': DateTime.now().toUtc().toIso8601String(),
          });
        } else if (status == RealtimeSubscribeStatus.channelError) {
          _logger.error('Presence channel error', error);
        }
      });
  }

  /// Handle presence sync events
  void _handlePresenceSync() {
    if (_presenceChannel == null) return;
    
    final presenceState = _presenceChannel!.presenceState();
    final onlineIds = <String>{};
    
    // Extract user IDs from all presence entries
    // presenceState is List<SinglePresenceState>
    for (var state in presenceState) {
      // Each state has presences list
      for (var presence in state.presences) {
        final userId = presence.payload['user_id'];
        if (userId != null) {
          onlineIds.add(userId.toString());
        }
      }
    }
    
    _currentOnlineUsers = onlineIds;
    _onlineUsersController.add(onlineIds);
    _logger.info('Online users updated: ${onlineIds.length} users online');
  }

  /// Check if a specific user is online
  bool isUserOnline(String userId) {
    return _currentOnlineUsers.contains(userId);
  }

  /// Leave the presence channel
  void leavePresence() {
    _logger.info('Leaving presence channel');
    _presenceChannel?.untrack();
    _presenceChannel?.unsubscribe();
    _presenceChannel = null;
    _currentUserId = null;
    _currentOnlineUsers = {};
    _onlineUsersController.add({});
  }

  /// Dispose resources
  void dispose() {
    leavePresence();
    _onlineUsersController.close();
  }
}

/// Provider for RealtimePresenceService (singleton)
final realtimePresenceServiceProvider = Provider<RealtimePresenceService>((ref) {
  final service = RealtimePresenceService(Supabase.instance.client);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Stream provider for online users
final onlineUsersStreamProvider = StreamProvider<Set<String>>((ref) {
  final presenceService = ref.watch(realtimePresenceServiceProvider);
  return presenceService.onlineUsersStream;
});

/// Provider to check if specific user is online
final isUserOnlineProvider = Provider.family<bool, String>((ref, userId) {
  final onlineUsers = ref.watch(onlineUsersStreamProvider);
  return onlineUsers.whenOrNull(data: (users) => users.contains(userId)) ?? false;
});
