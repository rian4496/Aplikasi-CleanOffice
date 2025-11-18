// lib/screens/auth/sign_up_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

import '../../models/user_profile.dart';

final _logger = Logger('SignUpScreen');

class SignUpScreen extends HookConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: Auto-disposed controllers
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final nameController = useTextEditingController();

    // ✅ HOOKS: State management
    final isLoading = useState(false);
    final obscurePassword = useState(true);
    final obscureConfirmPassword = useState(true);

    // ⚠️ REVIEW: Auto-role detection from email (security concern!)
    // TODO: Consider moving to a centralized service with admin approval
    String determineRoleFromEmail(String email) {
      if (email.contains('admin') || email.contains('admin')) {
        return 'admin';
      } else if (email.contains('cleaner') || email.contains('petugas')) {
        return 'cleaner';
      } else {
        return 'employee';
      }
    }

    // ✅ HELPER: Create user profile
    Future<void> createUserProfile(User user) async {
      try {
        _logger.info('Creating user profile in Firestore for ${user.uid}');

        final firestore = FirebaseFirestore.instance;
        final role = determineRoleFromEmail(user.email ?? '');

        final profile = UserProfile(
          uid: user.uid,
          displayName: nameController.text.trim(),
          email: user.email ?? '',
          role: role,
          joinDate: DateTime.now(),
          status: 'active',
        );

        await firestore.collection('users').doc(user.uid).set(profile.toMap());

        _logger.info('User profile created successfully with role: $role');
      } catch (e) {
        _logger.severe('Error creating user profile: $e');
        rethrow;
      }
    }

    // ✅ HELPER: Register
    Future<void> register() async {
      if (isLoading.value) return;

      if (!formKey.currentState!.validate()) {
        return;
      }

      // ⚠️ REVIEW: Password confirmation validation
      if (passwordController.text != confirmPasswordController.text) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password tidak cocok'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      isLoading.value = true; // ✅ Direct state update

      try {
        _logger.info(
          'Attempting to create user account for: ${emailController.text}',
        );

        // ⚠️ TODO: Consider moving to auth service/provider
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        final user = userCredential.user;
        if (user == null) {
          throw Exception('Failed to create user - user is null');
        }

        _logger.info('Firebase Auth account created: ${user.uid}');

        await user.updateDisplayName(nameController.text.trim());
        _logger.info('Display name updated');

        await createUserProfile(user);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Registrasi berhasil! Silakan login.')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );

        if (!context.mounted) return;
        // TODO (Phase 5): Replace with go_router navigation
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        _logger.warning('Registration failed: ${e.code}', e);

        if (!context.mounted) return;

        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage =
                'Email sudah terdaftar. Silakan login atau gunakan email lain.';
            break;
          case 'invalid-email':
            errorMessage = 'Format email tidak valid';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Registrasi dengan email dan password tidak diizinkan';
            break;
          case 'weak-password':
            errorMessage = 'Password terlalu lemah. Gunakan minimal 6 karakter';
            break;
          case 'network-request-failed':
            errorMessage = 'Koneksi internet bermasalah. Periksa koneksi Anda';
            break;
          default:
            errorMessage = e.message ?? 'Terjadi kesalahan saat registrasi';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      } catch (e) {
        _logger.severe('Unexpected error during registration', e);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Terjadi kesalahan yang tidak terduga',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(e.toString(), style: const TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      } finally {
        if (context.mounted) {
          isLoading.value = false; // ✅ Direct state update
        }
      }
    }

    // ✅ BUILD UI
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon
                  Icon(
                    Icons.person_add,
                    size: 90,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buat akun baru',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // Name Field
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        if (value.length < 3) {
                          return 'Nama minimal 3 karakter';
                        }
                        return null;
                      },
                      enabled: !isLoading.value,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Email tidak valid';
                        }
                        return null;
                      },
                      enabled: !isLoading.value,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            obscurePassword.value = !obscurePassword.value;
                          },
                        ),
                      ),
                      obscureText: obscurePassword.value,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                      enabled: !isLoading.value,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: TextFormField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            obscureConfirmPassword.value =
                                !obscureConfirmPassword.value;
                          },
                        ),
                      ),
                      obscureText: obscureConfirmPassword.value,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi password tidak boleh kosong';
                        }
                        if (value != passwordController.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => register(),
                      enabled: !isLoading.value,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Register Button
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: ElevatedButton(
                      onPressed: isLoading.value ? null : register,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.indigo[600],
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.indigo[200],
                      ),
                      child: isLoading.value
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Mendaftar...'),
                              ],
                            )
                          : const Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Note
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Role ditentukan otomatis dari email',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
