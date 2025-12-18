import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/logging/app_logger.dart';

/// Service to monitor Supabase Realtime connection status.
class RealtimeService {
  final SupabaseClient _supabase;
  final _logger = AppLogger('RealtimeService');
  final _statusController = StreamController<bool>.broadcast();
  RealtimeChannel? _channel;
  
  RealtimeService(this._supabase);

  Stream<bool> get statusStream => _statusController.stream;

  /// Initialize connection monitoring
  void initialize() {
    _logger.info('Realtime monitoring initialized');
    
    // Create a presence channel to monitor connection
    _channel = _supabase.channel('connection-status');
    
    _channel!
      .onPresenceSync((payload) {
        _logger.info('Realtime presence sync');
        _statusController.add(true);
      })
      .onPresenceJoin((payload) {
        _logger.info('Realtime presence join');
        _statusController.add(true);
      })
      .subscribe((status, error) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          _logger.info('Realtime connected');
          _statusController.add(true);
        } else if (status == RealtimeSubscribeStatus.closed) {
          _logger.warning('Realtime disconnected');
          _statusController.add(false);
        } else if (error != null) {
          _logger.error('Realtime error', error);
          _statusController.add(false);
        }
      });
    
    // Initially connected
    _statusController.add(true);
  }

  /// Subscribe to table changes
  RealtimeChannel subscribeToTable(
    String table, {
    required void Function(PostgresChangePayload payload) onInsert,
    void Function(PostgresChangePayload payload)? onUpdate,
    void Function(PostgresChangePayload payload)? onDelete,
  }) {
    final channel = _supabase.channel('public:$table');
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: table,
      callback: onInsert,
    );
    
    if (onUpdate != null) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: table,
        callback: onUpdate,
      );
    }
    
    if (onDelete != null) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: table,
        callback: onDelete,
      );
    }
    
    channel.subscribe();
    return channel;
  }

  void dispose() {
    _channel?.unsubscribe();
    _statusController.close();
  }
}

/// Provider for RealtimeService
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final supabase = Supabase.instance.client;
  final service = RealtimeService(supabase);
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for connection status
final connectionStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(realtimeServiceProvider);
  return service.statusStream;
});

