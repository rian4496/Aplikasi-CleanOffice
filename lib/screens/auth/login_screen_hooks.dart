// lib/screens/auth/login_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_profile.dart';
import '../../core/constants/app_constants.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: Auto-disposed controllers
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    // ✅ HOOKS: Reactive state
    final isLoading = useState(false);
    final obscurePassword = useState(true);

    // ✅ HELPER: Ensure user profile exists
    Future<void> ensureUserProfile(User user) async {
      try {
        final firestore = FirebaseFirestore.instance;
        final userDoc = await firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          debugPrint('Creating user profile for ${user.email}');

          // TODO: Consider moving role detection to a service
          // ⚠️ REVIEW: Auto-role detection from email might not be secure
          String role = 'employee';
          if (user.email?.contains('admin') == true) {
            role = 'admin';
          } else if (user.email?.contains('cleaner') == true ||
              user.email?.contains('petugas') == true) {
            role = 'cleaner';
          }

          final profile = UserProfile(
            uid: user.uid,
            displayName: user.displayName ?? user.email?.split('@')[0] ?? 'User',
            email: user.email ?? '',
            role: role,
            joinDate: DateTime.now(),
            status: 'active',
          );

          await firestore.collection('users').doc(user.uid).set(profile.toMap());
          debugPrint('User profile created successfully with role: $role');
        }
      } catch (e) {
        debugPrint('Error ensuring user profile: $e');
        rethrow;
      }
    }

    // ✅ HELPER: Handle auth errors
    void handleAuthError(FirebaseAuthException e) {
      String errorMessage;
      String actionLabel = 'OK';
      VoidCallback? actionCallback;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Email belum terdaftar';
          actionLabel = 'DAFTAR';
          actionCallback = () {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            Navigator.pushNamed(context, AppConstants.registerRoute);
          };
          break;

        case 'wrong-password':
          errorMessage = 'Password salah. Silakan coba lagi';
          actionLabel = 'RESET';
          actionCallback = () {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            Navigator.pushNamed(
              context,
              AppConstants.resetPasswordRoute,
              arguments: emailController.text,
            );
          };
          break;

        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;

        case 'user-disabled':
          errorMessage = 'Akun ini telah dinonaktifkan';
          break;

        case 'too-many-requests':
          errorMessage = 'Terlalu banyak percobaan. Tunggu sebentar';
          break;

        case 'network-request-failed':
          errorMessage = 'Koneksi internet bermasalah';
          break;

        default:
          errorMessage = e.message ?? 'Terjadi kesalahan saat login';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: actionLabel,
            textColor: Colors.white,
            onPressed: actionCallback ??
                () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
          ),
        ),
      );
    }

    // ✅ HELPER: Login function
    Future<void> login() async {
      if (isLoading.value) return;

      if (!formKey.currentState!.validate()) {
        return;
      }

      isLoading.value = true; // ✅ Direct update

      try {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (userCredential.user == null) {
          throw Exception('Login failed: No user returned');
        }

        await ensureUserProfile(userCredential.user!);

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!context.mounted) return;

        if (!userDoc.exists) {
          throw Exception('User profile not found');
        }

        final userData = userDoc.data()!;
        final userRole = userData['role'] as String?;

        // TODO (Phase 5): Replace with go_router navigation
        String route;
        switch (userRole) {
          case 'admin':
            route = AppConstants.homeAdminRoute;
            break;
          case 'cleaner':
            route = AppConstants.homeCleanerRoute;
            break;
          case 'employee':
          default:
            route = AppConstants.homeEmployeeRoute;
            break;
        }

        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, route);
      } on FirebaseAuthException catch (e) {
        if (!context.mounted) return;
        handleAuthError(e);
      } catch (e) {
        if (!context.mounted) return;

        debugPrint('Login error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      } finally {
        if (context.mounted) {
          isLoading.value = false; // ✅ Direct update
        }
      }
    }

    // ✅ BUILD UI
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/login_illustration.png',
                    height: 200,
                    width: 200,
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk ke akun Anda',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 40),

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
                        if (!value.contains('@')) {
                          return 'Email tidak valid';
                        }
                        return null;
                      },
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
                          ),
                          onPressed: () {
                            obscurePassword.value = !obscurePassword.value; // ✅ Direct update
                          },
                        ),
                      ),
                      obscureText: obscurePassword.value,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => login(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Forgot Password
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppConstants.resetPasswordRoute,
                          arguments: emailController.text,
                        ),
                        child: Text(
                          'Lupa Password?',
                          style: TextStyle(
                            color: Colors.indigo[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Login Button
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: ElevatedButton(
                      onPressed: isLoading.value ? null : login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.indigo[600],
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppConstants.registerRoute),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.indigo[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
