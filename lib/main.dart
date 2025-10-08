import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/user_profile_provider.dart';
import 'providers/work_schedule_provider.dart';

// Import semua screen
import 'package:aplikasi_cleanoffice/screens/create_report_screen.dart';
import 'package:aplikasi_cleanoffice/screens/employee_home_screen.dart';
import 'package:aplikasi_cleanoffice/screens/login_screen.dart';

// Fungsi main diubah menjadi async
void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Configure logging
  Logger.root.level = Level.ALL; // Set log level
  Logger.root.onRecord.listen((record) {
    // In development, print to console with more details
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      debugPrint('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      debugPrint('Stack trace:\n${record.stackTrace}');
    }
  });

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => WorkScheduleProvider()),
      ],
      child: MaterialApp(
      title: 'Clean Office',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      initialRoute: '/login',
      // Pastikan semua rute sudah terdaftar
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home_employee': (context) => const EmployeeHomeScreen(),
        '/create_report': (context) => const CreateReportScreen(),
      },
    ),
    );
  }
}