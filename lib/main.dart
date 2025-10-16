
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'firebase_options.dart' as firebase_options;

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
import 'package:aplikasi_cleanoffice/screens/dev_menu_screen.dart';

final _logger = AppLogger('Main');

const bool devMode = false; // ← UBAH KE false DI PRODUCTION

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    _logger.info('Initializing Firebase...');
    await Firebase.initializeApp(
      options: firebase_options.DefaultFirebaseOptions.currentPlatform, // alias
    );

    // INISIALISASI FORMAT TANGGAL
    await initializeDateFormatting('id_ID', null);

    _logger.info('Firebase initialized successfully');

    runApp(const ProviderScope(child: MyApp()));
  } catch (e, stackTrace) {
    _logger.critical('Failed to initialize app', e, stackTrace);
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
      theme: AppTheme.lightTheme,
      initialRoute: devMode ? '/dev_menu' : '/welcome',
      routes: {
        '/dev_menu': (context) => const DevMenuScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        AppConstants.loginRoute: (context) => const LoginScreen(),
        '/sign-up': (context) => const SignUpScreen(),
        AppConstants.homeEmployeeRoute: (context) => const EmployeeHomeScreen(),
        AppConstants.homeAdminRoute: (context) => const AdminDashboardScreen(),
        AppConstants.homeCleanerRoute: (context) => const CleanerHomeScreen(),
        AppConstants.createReportRoute: (context) => const CreateReportScreen(),
        AppConstants.createRequestRoute: (context) => const CreateRequestScreen(),
        AppConstants.requestHistoryRoute: (context) => const RequestHistoryScreen(),
        AppConstants.profileRoute: (context) => const ProfileScreen(),
        AppConstants.editProfileRoute: (context) => const EditProfileScreen(),
        AppConstants.changePasswordRoute: (context) => const ChangePasswordScreen(),
      },
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