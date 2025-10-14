import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/logging/app_logger.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';

// Screens
import 'package:aplikasi_cleanoffice/screens/welcome_screen.dart';
import 'package:aplikasi_cleanoffice/screens/login_screen.dart';
import 'package:aplikasi_cleanoffice/screens/sign_up_screen.dart';
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
const bool devMode = false; // ← UBAH INI KE false SAAT PRODUCTION

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
    runApp(const ProviderScope(child: MyApp()));
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

      // ✨ Menggunakan AppTheme.lightTheme yang sudah ada
      theme: AppTheme.lightTheme,

      // 🔧 DEVELOPMENT MODE: Langsung ke Dev Menu
      // PRODUCTION MODE: Ke Welcome Screen (bukan langsung Login)
      initialRoute: devMode ? '/dev_menu' : '/welcome',

      routes: {
        // Dev Menu Route
        '/dev_menu': (context) => const DevMenuScreen(),

        // Auth Routes - UPDATED!
        '/welcome': (context) => const WelcomeScreen(),
        AppConstants.loginRoute: (context) => const LoginScreen(),
        '/sign-up': (context) => const SignUpScreen(), // CHANGED from /register
        // Home Routes
        AppConstants.homeEmployeeRoute: (context) => const EmployeeHomeScreen(),
        AppConstants.homeAdminRoute: (context) => const AdminDashboardScreen(),
        AppConstants.homeCleanerRoute: (context) => const CleanerHomeScreen(),

        // Feature Routes
        AppConstants.createReportRoute: (context) => const CreateReportScreen(),
        AppConstants.createRequestRoute: (context) =>
            const CreateRequestScreen(),
        AppConstants.requestHistoryRoute: (context) =>
            const RequestHistoryScreen(),

        // Profile Routes
        AppConstants.profileRoute: (context) => const ProfileScreen(),
        AppConstants.editProfileRoute: (context) => const EditProfileScreen(),
        AppConstants.changePasswordRoute: (context) =>
            const ChangePasswordScreen(),
      },

      // Unknown route handler
      onUnknownRoute: (settings) {
        _logger.warning('Unknown route: ${settings.name}');
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Page not found')),
          ),
        );
      },
    );
  }
}
