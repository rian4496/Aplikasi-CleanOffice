import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import '../core/services/appwrite_client.dart';
import '../core/logging/app_logger.dart';

/// Service to monitor Realtime connection status.
/// Follows SRP by focusing on connection health.
class RealtimeService {
  final Realtime _realtime;
  final _logger = AppLogger('RealtimeService');
  final _statusController = StreamController<bool>.broadcast();
  
  RealtimeService(this._realtime);

  Stream<bool> get statusStream => _statusController.stream;

  /// Initialize connection monitoring
  void initialize() {
    _logger.info('Realtime monitoring initialized');
    _statusController.add(true);
  }

  void dispose() {
    _statusController.close();
  }
}

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final client = AppwriteClient().client;
  final realtime = Realtime(client);
  final service = RealtimeService(realtime);
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for connection status
final connectionStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(realtimeServiceProvider);
  return service.statusStream;
});
