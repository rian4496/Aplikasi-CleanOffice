import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Check connectivity status
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

// Derived provider for simple boolean (isOnline)
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityProvider);
  
  return connectivityAsync.when(
    data: (results) {
      // If any result is mobile, wifi, or ethernet, we have connection
      return results.contains(ConnectivityResult.mobile) ||
             results.contains(ConnectivityResult.wifi) ||
             results.contains(ConnectivityResult.ethernet);
    },
    loading: () => true, // Assume online while loading
    error: (_, __) => false,
  );
});
