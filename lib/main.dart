// lib/main.dart
// Clean Office Management System - Main Entry Point

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Core
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/appwrite_client.dart';

// Auth Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/sign_up_screen.dart';

// Employee Screens
import 'screens/employee/employee_home_screen.dart';
import 'screens/employee/create_report_screen.dart';
import 'screens/employee/all_reports_screen.dart';
import 'screens/employee/create_request_screen.dart';

// Cleaner Screens
import 'screens/cleaner/cleaner_home_screen.dart';

// Admin Screens - NEW
import 'screens/admin/dashboard/admin_dashboard_unified_screen.dart';
import 'screens/admin/analytics/analytics_screen.dart';
import 'screens/admin/reports/reports_list_screen.dart';
import 'screens/admin/verification/verification_screen.dart';
import 'screens/admin/cleaners/cleaners_management_screen.dart';

// Shared Screens
import 'screens/shared/profile_screen.dart';
import 'screens/shared/settings_screen.dart';
import 'screens/shared/edit_profile_screen.dart';
import 'screens/shared/change_password_screen.dart';
import 'screens/notification_screen.dart';

// Inventory Screens
import 'screens/inventory/inventory_list_screen.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Appwrite
    try {
      await AppwriteClient().initialize();
      debugPrint('✅ Appwrite initialized successfully');
    } catch (e) {
      debugPrint('⚠️ Appwrite initialization failed: $e');
      // Continue app execution even if Appwrite fails (for development)
    }

    // Initialize Indonesian locale
    await initializeDateFormatting('id_ID', null);

    runApp(const ProviderScope(child: MyApp()));
  }, (error, stack) {
    if (kDebugMode) {
      debugPrint('❌ Unhandled error: $error');
      debugPrint('Stack trace: $stack');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
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

      // Initial route
      initialRoute: AppConstants.loginRoute,

      // Routes
      routes: {
        // ==================== ROOT ====================
        '/': (context) => const LoginScreen(),

        // ==================== AUTH ====================
        AppConstants.loginRoute: (context) => const LoginScreen(),
        '/register': (context) => const SignUpScreen(),
        '/signup': (context) => const SignUpScreen(),

        // ==================== HOME SCREENS ====================
        AppConstants.homeEmployeeRoute: (context) => const EmployeeHomeScreen(),
        AppConstants.homeCleanerRoute: (context) => const CleanerHomeScreen(),
        
        // ADMIN - NEW UNIFIED SCREEN (Mobile + Desktop Responsive)
        AppConstants.homeAdminRoute: (context) => const AdminDashboardUnifiedScreen(),
        '/admin/dashboard': (context) => const AdminDashboardUnifiedScreen(),

        // ==================== ADMIN SCREENS (NEW) ====================
        '/admin/reports': (context) => const ReportsListScreen(),
        '/admin/verification': (context) => const VerificationScreen(),
        '/admin/analytics': (context) => const AnalyticsScreen(),
        '/admin/cleaners': (context) => const CleanersManagementScreen(),
        
        // Analytics (backward compatibility)
        '/analytics': (context) => const AnalyticsScreen(),

        // ==================== EMPLOYEE ROUTES ====================
        '/create_report': (context) => const CreateReportScreen(),
        '/all_reports': (context) => const AllReportsScreen(),
        '/create_request': (context) => const CreateRequestScreen(),

        // ==================== SHARED ROUTES ====================
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/change_password': (context) => const ChangePasswordScreen(),
        '/notifications': (context) => const NotificationScreen(),

        // ==================== INVENTORY ROUTES ====================
        '/inventory': (context) => const InventoryListScreen(),
        '/inventory/list': (context) => const InventoryListScreen(),
      },

      // Handle unknown routes
      onUnknownRoute: (settings) {
        debugPrint('⚠️ Unknown route: ${settings.name}');
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Halaman Tidak Ditemukan'),
              backgroundColor: Colors.red,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Route "${settings.name}" tidak ditemukan',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppConstants.loginRoute,
                    ),
                    child: const Text('Kembali ke Login'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}