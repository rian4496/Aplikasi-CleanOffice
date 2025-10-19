// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/shared/reset_password_screen.dart';
import 'screens/employee/employee_home_screen.dart';
import 'screens/cleaner/cleaner_home_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/shared/profile_screen.dart';
import 'screens/shared/settings_screen.dart';
import 'screens/shared/edit_profile_screen.dart';
import 'screens/shared/change_password_screen.dart';
import 'screens/notification_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Run app with ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      
      // Initial route
      initialRoute: AppConstants.loginRoute,
      
      // Routes
      routes: {
        AppConstants.loginRoute: (context) => const LoginScreen(),
        AppConstants.registerRoute: (context) => const SignUpScreen(),
        AppConstants.resetPasswordRoute: (context) => const ResetPasswordScreen(),
        AppConstants.homeEmployeeRoute: (context) => const EmployeeHomeScreen(),
        AppConstants.homeCleanerRoute: (context) => const CleanerHomeScreen(),
        AppConstants.homeAdminRoute: (context) => const AdminDashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/change_password': (context) => const ChangePasswordScreen(),
        '/notifications': (context) => const NotificationScreen(),
      },
      
      // Handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      },
    );
  }
}
