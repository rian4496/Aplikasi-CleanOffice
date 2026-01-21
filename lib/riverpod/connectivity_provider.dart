// lib/riverpod/connectivity_provider.dart
// Provider untuk monitoring koneksi internet

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

/// Provider untuk memantau status koneksi internet
@riverpod
class ConnectivityNotifier extends _$ConnectivityNotifier {
  StreamSubscription? _subscription;
  final Connectivity _connectivity = Connectivity();

  @override
  bool build() {
    _init();
    ref.onDispose(() {
      _subscription?.cancel();
    });
    return true; // Default connected
  }

  void _init() async {
    // Check initial status
    final result = await _connectivity.checkConnectivity();
    state = _isConnected(result);

    // Listen to changes
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      state = _isConnected(result);
    });
  }

  /// Helper untuk check apakah ada koneksi
  bool _isConnected(List<ConnectivityResult> results) {
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }
}

