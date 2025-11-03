// lib/main.dart - UPDATED: Production Firebase Mode

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';

// Auth Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/sign_up_screen.dart'; 

// Employee Screens
import 'screens/employee/employee_home_screen.dart';
import 'screens/employee/create_report_screen.dart';
import 'screens/employee/all_reports_screen.dart';

// Cleaner Screens
import 'screens/cleaner/cleaner_home_screen.dart';

// Admin Screens
import 'screens/admin/admin_dashboard_screen.dart';

// Shared Screens
import 'screens/shared/profile_screen.dart';
import 'screens/shared/settings_screen.dart';
import 'screens/shared/edit_profile_screen.dart';
import 'screens/shared/change_password_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/employee/create_request_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ==================== FIREBASE EMULATOR CONFIG ====================
  // 
  // OPTION A: Use PRODUCTION Firebase (Current Setting)
  // - For testing with real Firebase project
  // - Upload foto will work
  // - Data saved to production Firestore
  //
  // OPTION B: Use LOCAL Emulator (Uncomment code below)
  // - For local development
  // - Need to run: firebase emulators:start
  // - Data saved to local emulator only
  //
  // ==================================================================

  // 🔥 EMULATOR MODE: DISABLED (Using Production Firebase)
 // debugPrint('📱 Using PRODUCTION Firebase');
  
  if (kDebugMode) {
    try {
      // Detect platform - Android emulator uses 10.0.2.2
      // Web/iOS/Desktop use 127.0.0.1
      final emulatorHost = defaultTargetPlatform == TargetPlatform.android 
          ? '10.0.2.2'  // Android emulator
          : '127.0.0.1'; // Web, iOS, Desktop
      
      // Connect to Firebase Emulators
      await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
      await FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);
      
      debugPrint('✅ Connected to Firebase Emulators at $emulatorHost');
    } catch (e) {
      debugPrint('⚠️ Failed to connect to emulators: $e');
    }
  }


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

      // Localization delegates
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
        // ==================== AUTH ====================
        AppConstants.loginRoute: (context) => const LoginScreen(),
        '/register': (context) => const SignUpScreen(),
        '/signup': (context) => const SignUpScreen(),
        
        // ==================== HOME SCREENS ====================
        AppConstants.homeEmployeeRoute: (context) => const EmployeeHomeScreen(),
        AppConstants.homeCleanerRoute: (context) => const CleanerHomeScreen(),
        AppConstants.homeAdminRoute: (context) => const AdminDashboardScreen(),
        
        // ==================== EMPLOYEE ROUTES ====================
        '/create_report': (context) => const CreateReportScreen(),
        '/all_reports': (context) => const AllReportsScreen(),
        '/request_history': (context) => const Scaffold(
          body: Center(child: Text('Request History - Coming Soon')),
        ),
        
        // ==================== SHARED ROUTES ====================
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/change_password': (context) => const ChangePasswordScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/create_request': (context) => const CreateRequestScreen(),
      },
      
      // Handle unknown routes - redirect to login
      onUnknownRoute: (settings) {
        debugPrint('⚠️ Unknown route: ${settings.name}');
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Route Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Route "${settings.name}" tidak ditemukan',
                    style: const TextStyle(fontSize: 16),
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