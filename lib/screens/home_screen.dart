import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_cleanoffice/models/user_role.dart';
import 'package:aplikasi_cleanoffice/screens/employee_home_screen.dart';
import 'package:aplikasi_cleanoffice/screens/cleaner_home_screen.dart';

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
    } else {
      // Show error for invalid role
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Peran tidak valid'),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Kembali ke Login'),
              ),
            ],
          ),
        ),
      );
    }
  }
}