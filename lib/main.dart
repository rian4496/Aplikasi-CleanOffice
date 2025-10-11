import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/logging/app_logger.dart';
import 'core/constants/app_constants.dart';

// Screens
import 'package:aplikasi_cleanoffice/screens/login_screen.dart';
import 'package:aplikasi_cleanoffice/screens/employee_home_screen.dart';
import 'package:aplikasi_cleanoffice/screens/admin/admin_dashboard_screen.dart';
import 'package:aplikasi_cleanoffice/screens/cleaner_home_screen.dart';
import 'package:aplikasi_cleanoffice/screens/create_report_screen.dart';
import 'package:aplikasi_cleanoffice/screens/create_request_screen.dart';
import 'package:aplikasi_cleanoffice/screens/profile_screen.dart';
import 'package:aplikasi_cleanoffice/screens/edit_profile_screen.dart';
import 'package:aplikasi_cleanoffice/screens/change_password_screen.dart';
import 'package:aplikasi_cleanoffice/screens/request_history_screen.dart';

// DEV MENU - IMPORT INI
import 'package:aplikasi_cleanoffice/screens/dev_menu_screen.dart';

final _logger = AppLogger('Main');

// 🔧 DEVELOPMENT MODE SWITCH
// Set ke true untuk test UI tanpa Firebase Auth
// Set ke false untuk mode production normal
const bool devMode = true; // ← UBAH INI KE false SAAT PRODUCTION

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    _logger.info('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _logger.info('Firebase initialized successfully');

    // Run app with Riverpod
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    _logger.critical('Failed to initialize app', e, stackTrace);
    // Show error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    e.toString(),
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      
      // 🔧 DEVELOPMENT MODE: Langsung ke Dev Menu
      // PRODUCTION MODE: Ke Login Screen
      initialRoute: devMode ? '/dev_menu' : AppConstants.loginRoute,
      
      routes: {
        // Dev Menu Route
        '/dev_menu': (context) => const DevMenuScreen(),
        
        // Normal Routes
        AppConstants.loginRoute: (context) => const LoginScreen(),
        AppConstants.homeEmployeeRoute: (context) => const EmployeeHomeScreen(),
        AppConstants.homeAdminRoute: (context) => const AdminDashboardScreen(),
        AppConstants.homeCleanerRoute: (context) => const CleanerHomeScreen(),
        AppConstants.createReportRoute: (context) => const CreateReportScreen(),
        AppConstants.createRequestRoute: (context) => const CreateRequestScreen(),
        AppConstants.profileRoute: (context) => const ProfileScreen(),
        AppConstants.editProfileRoute: (context) => const EditProfileScreen(),
        AppConstants.changePasswordRoute: (context) => const ChangePasswordScreen(),
        AppConstants.requestHistoryRoute: (context) => const RequestHistoryScreen(),
      },
      
      // Unknown route handler
      onUnknownRoute: (settings) {
        _logger.warning('Unknown route: ${settings.name}');
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(
              child: Text('Page not found'),
            ),
          ),
        );
      },
    );
  }

  /// Build theme untuk aplikasi
  ThemeData _buildTheme() {
    return ThemeData(
      // Material 3
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
      ),
      
      // Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.defaultPadding,
        ),
      ),
      
      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
            vertical: AppConstants.defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
        ),
      ),
      
      // App bar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 2,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: Colors.grey[50],
    );
  }
}