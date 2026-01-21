import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aplikasi_cleanoffice/models/user_role.dart';
import 'package:aplikasi_cleanoffice/riverpod/auth_providers.dart';
import 'package:aplikasi_cleanoffice/screens/employee/employee_home_screen.dart';
import 'package:aplikasi_cleanoffice/screens/cleaner/cleaner_home_screen.dart';
import 'package:aplikasi_cleanoffice/screens/web_admin/dashboard/admin_dashboard.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the user profile provider. Riverpod handles loading/error states.
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return userProfileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text(
                'Gagal memuat data pengguna',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  // Use the auth actions provider to logout
                  await ref.read(authActionsProvider.notifier).logout();
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
      ),
      data: (userProfile) {
        // If user is logged out or profile doesn't exist, redirect to login
        if (userProfile == null) {
          // Use addPostFrameCallback to avoid calling Navigator during a build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          });
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        // Redirect to role-specific screen
        switch (userProfile.role) {
          case UserRole.employee:
            return const EmployeeHomeScreen();
          case UserRole.cleaner:
            return const CleanerHomeScreen();
          case UserRole.admin:
            return const AdminDashboardScreen();
          default:
            // Show error for invalid role
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    const Text(
                      'Peran tidak valid',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Role: ${userProfile.role}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async =>
                          await ref.read(authActionsProvider.notifier).logout(),
                      icon: const Icon(Icons.logout),
                      label: const Text('Kembali ke Login'),
                    ),
                  ],
                ),
              ),
            );
        }
      },
    );
  }
}

