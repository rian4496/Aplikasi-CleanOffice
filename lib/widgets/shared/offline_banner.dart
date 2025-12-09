// lib/widgets/shared/offline_banner.dart
// Banner widget yang ditampilkan saat offline

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/riverpod/connectivity_provider.dart';

/// Banner widget yang muncul di atas layar saat offline
class OfflineBanner extends ConsumerWidget {
  final Widget child;
  
  const OfflineBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(connectivityProvider);
    
    return Column(
      children: [
        // Offline Banner - animated slide down
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isConnected ? 0 : null,
          child: isConnected
              ? const SizedBox.shrink()
              : Material(
                  color: Colors.red[700],
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Anda sedang offline',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        // Main content
        Expanded(child: child),
      ],
    );
  }
}

/// Wrapper widget untuk menampilkan offline status dengan snackbar
/// Gunakan ini jika ingin snackbar daripada banner
class OfflineAwareScaffold extends ConsumerStatefulWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const OfflineAwareScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.scaffoldKey,
  });

  @override
  ConsumerState<OfflineAwareScaffold> createState() => _OfflineAwareScaffoldState();
}

class _OfflineAwareScaffoldState extends ConsumerState<OfflineAwareScaffold> {
  bool _wasOffline = false;

  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(connectivityProvider);
    
    // Show snackbar when connection changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isConnected && !_wasOffline) {
        // Just went offline
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Text('Anda sedang offline'),
              ],
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 3),
          ),
        );
        _wasOffline = true;
      } else if (isConnected && _wasOffline) {
        // Just came back online
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Text('Kembali online'),
              ],
            ),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 2),
          ),
        );
        _wasOffline = false;
      }
    });

    return Scaffold(
      key: widget.scaffoldKey,
      backgroundColor: widget.backgroundColor,
      appBar: widget.appBar,
      body: Column(
        children: [
          // Persistent offline banner at top
          if (!isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: Colors.red[700],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Anda sedang offline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          // Main body
          Expanded(child: widget.body),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
      drawer: widget.drawer,
      endDrawer: widget.endDrawer,
    );
  }
}
