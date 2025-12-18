// lib/main.dart
// Clean Office Management System - Main Entry Point
// ✅ MIGRATED TO SUPABASE

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart'; // ✅ Toastification

// Core
import 'core/theme/app_theme.dart';
import 'core/config/supabase_config.dart';

// Router
import 'core/router/app_router.dart';

// Filter patterns untuk skip noisy logs
const _skipLogPatterns = [
  'heartbeat',
  'Received heartbeat',
  'realtime server',
];

bool _shouldSkipLog(String? message) {
  if (message == null) return false;
  final lower = message.toLowerCase();
  for (final pattern in _skipLogPatterns) {
    if (lower.contains(pattern.toLowerCase())) {
      return true;
    }
  }
  return false;
}

void main() async {
  // Override debugPrint untuk filter noisy logs
  debugPrint = (String? message, {int? wrapWidth}) {
    if (!_shouldSkipLog(message)) {
      debugPrintSynchronously(message ?? '', wrapWidth: wrapWidth);
    }
  };

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // ==================== SUPABASE INITIALIZATION ====================
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        debug: kDebugMode,
      );
      debugPrint('✅ Supabase initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Supabase initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      // Continue app execution even if Supabase fails (for development)
    }

    // Initialize Indonesian locale for date formatting
    await initializeDateFormatting('id_ID', null);

    runApp(const ProviderScope(child: MyApp()));
  }, (error, stack) {
    // Global error handler
    if (kDebugMode) {
      debugPrint('❌ Unhandled error: $error');
      debugPrint('Stack trace: $stack');
    }
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Clean Office',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      
      // Localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Indonesian
        Locale('en', 'US'), // English
      ],
      locale: const Locale('id', 'ID'),

      // Router Config
      routerConfig: router,
      
      // ✅ Toastification Wrapper (Global Notifications)
      builder: (context, child) {
        return ToastificationWrapper(
          child: child!,
        );
      },
    );
  }
}
