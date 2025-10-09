import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_cleanoffice/models/user_role.dart';
import 'package:aplikasi_cleanoffice/screens/employee_home_screen.dart';
import 'package:aplikasi_cleanoffice/screens/cleaner_home_screen.dart';
import 'package:aplikasi_cleanoffice/screens/supervisor/supervisor_dashboard_screen.dart'; // TAMBAHAN

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (mounted && docSnapshot.exists) {
        final userData = docSnapshot.data();
        setState(() {
          _userRole = userData?['role'] as String?;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If role not loaded yet, show loading indicator
    if (_userRole == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Check authentication and role
    final userRef = FirebaseAuth.instance.currentUser;
    if (userRef == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const SizedBox();
    }

    // Redirect to role-specific screen or show error
    if (_userRole == UserRole.employee) {
      return const EmployeeHomeScreen();
    } else if (_userRole == UserRole.cleaner) {
      return const CleanerHomeScreen();
    } else if (_userRole == UserRole.supervisor) { // TAMBAHAN
      return const SupervisorDashboardScreen();
    } else {
      // Show error for invalid role
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              const Text(
                'Peran tidak valid',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Role: $_userRole',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Kembali ke Login'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}