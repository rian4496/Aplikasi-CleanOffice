import 'package:aplikasi_cleanoffice/screens/auth/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_cleanoffice/screens/welcome_screen.dart';
import 'package:aplikasi_cleanoffice/screens/auth/login_screen.dart';
import 'package:aplikasi_cleanoffice/screens/admin/admin_dashboard_screen.dart';
import 'package:aplikasi_cleanoffice/screens/employee/create_report_screen.dart';
import 'package:aplikasi_cleanoffice/screens/employee/create_request_screen.dart';
import 'package:aplikasi_cleanoffice/screens/shared/profile_screen.dart';
import 'package:aplikasi_cleanoffice/screens/shared/edit_profile_screen.dart';
import 'package:aplikasi_cleanoffice/screens/shared/change_password_screen.dart';
import 'package:aplikasi_cleanoffice/screens/request_history_screen.dart';
import 'package:aplikasi_cleanoffice/screens/shared/reset_password_screen.dart';
import 'package:aplikasi_cleanoffice/screens/mock_employee_home_screen.dart';
import 'package:aplikasi_cleanoffice/screens/mock_cleaner_home_screen.dart';
import 'package:aplikasi_cleanoffice/screens/admin/bulk_receipt_screen.dart';
/// Development Menu untuk test UI tanpa Firebase Authentication
/// HANYA UNTUK DEVELOPMENT - JANGAN DIPAKAI DI PRODUCTION!
class DevMenuScreen extends StatelessWidget {
  const DevMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 UI Testing Menu'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Card(
              elevation: 4,
              color: Colors.amber.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 48,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'DEVELOPMENT MODE',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Test UI tanpa Firebase Auth',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Welcome Screen (NEW!)
            _buildSectionTitle('👋 Welcome & Onboarding'),
            _buildScreenCard(
              context,
              title: 'Welcome Screen',
              subtitle: 'Landing page pertama',
              icon: Icons.waving_hand,
              color: Colors.purple,
              screen: const WelcomeScreen(),
            ),

            const SizedBox(height: 24),

            // Authentication Screens
            _buildSectionTitle('🔐 Authentication Screens'),
            _buildScreenCard(
              context,
              title: 'Login Screen',
              subtitle: 'Halaman login',
              icon: Icons.login,
              color: Colors.blue,
              screen: const LoginScreen(),
            ),
            _buildScreenCard(
              context,
              title: 'Sign Up Screen',
              subtitle: 'Halaman registrasi',
              icon: Icons.person_add,
              color: Colors.green,
              screen: const SignUpScreen(),
            ),
            _buildScreenCard(
              context,
              title: 'Reset Password Screen',
              subtitle: 'Halaman reset password',
              icon: Icons.lock_reset,
              color: Colors.orange,
              screen: const ResetPasswordScreen(),
            ),

            const SizedBox(height: 24),

            // Home Screens
            _buildSectionTitle('🏠 Home Screens'),
            _buildScreenCard(
              context,
              title: 'Admin Dashboard',
              subtitle: 'Dashboard admin',
              icon: Icons.dashboard,
              color: Colors.purple,
              screen: const AdminDashboardScreen(),
            ),
            _buildScreenCard(
              context,
              title: 'Employee Home',
              subtitle: 'Beranda karyawan (Mock)',
              icon: Icons.person,
              color: Colors.green,
              screen: const MockEmployeeHomeScreen(),
            ),
            _buildScreenCard(
              context,
              title: 'Cleaner Home',
              subtitle: 'Beranda petugas kebersihan (Mock)',
              icon: Icons.cleaning_services,
              color: Colors.blue,
              screen: const MockCleanerHomeScreen(),
            ),

            const SizedBox(height: 24),

            // Feature Screens
            _buildSectionTitle('✨ Feature Screens'),
            _buildScreenCard(
              context,
              title: 'Create Report',
              subtitle: 'Buat laporan kebersihan',
              icon: Icons.camera_alt,
              color: Colors.indigo,
              screen: const CreateReportScreen(),
            ),
            _buildScreenCard(
              context,
              title: 'Create Request',
              subtitle: 'Buat permintaan kebersihan',
              icon: Icons.add_task,
              color: Colors.teal,
              screen: const CreateRequestScreen(),
            ),
            _buildScreenCard(
              context,
              title: 'Request History',
              subtitle: 'Riwayat permintaan',
              icon: Icons.history,
              color: Colors.brown,
              screen: const RequestHistoryScreen(),
            ),
            _buildScreenCard(
              context,
              title: 'Bulk Receipt Generator',
              subtitle: 'Upload Excel untuk buat kwitansi',
              icon: Icons.receipt_long,
              color: Colors.orange,
              screen: const BulkReceiptScreen(),
            ),

            const SizedBox(height: 24),

            // Profile Screens
            _buildSectionTitle('👤 Profile Screens'),
            _buildScreenCard(
              context,
              title: 'Profile Screen',
              subtitle: 'Halaman profil user',
              icon: Icons.account_circle,
              color: Colors.deepOrange,
              screen: const ProfileScreen(),
            ),
            _buildScreenCard(
              context,
              title: 'Edit Profile',
              subtitle: 'Edit profil user',
              icon: Icons.edit,
              color: Colors.cyan,
              screen: const EditProfileScreen(),
            ),
            _buildScreenCard(
              context,
              title: 'Change Password',
              subtitle: 'Ubah password',
              icon: Icons.vpn_key,
              color: Colors.red,
              screen: const ChangePasswordScreen(),
            ),

            const SizedBox(height: 32),

            // Info Card
            Card(
              elevation: 2,
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(height: 8),
                    Text(
                      'Screen dengan label (Mock) menggunakan data dummy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fokus test tampilan UI saja',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildScreenCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
