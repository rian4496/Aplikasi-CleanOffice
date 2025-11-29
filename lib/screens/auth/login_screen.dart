// lib/screens/auth/login_screen.dart
// ✅ MIGRATED TO APPWRITE

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import '../../services/appwrite_auth_service.dart';
import '../../core/constants/app_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AppwriteAuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Ensure user profile exists in database (same logic as Firebase version)
  /// This is now handled by AppwriteAuthService.signInWithEmailAndPassword()
  /// which fetches the profile from Appwrite database after authentication
  ///
  /// If profile doesn't exist, the service will throw an error
  /// User must be registered first via sign_up_screen.dart

  Future<void> _login() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('Attempting login with Appwrite...');

      final userProfile = await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      debugPrint('Login successful! Role: ${userProfile.role}, Status: ${userProfile.status}, Verification: ${userProfile.verificationStatus}');

      // ✅ Check if user account is pending approval
      if (userProfile.verificationStatus == 'pending') {
        // Force logout
        await _authService.signOut();
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Akun Anda menunggu verifikasi admin. Silakan coba lagi nanti.',
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 5),
          ),
        );
        return;  // Stop login process
      }

      // ✅ Check if user account was rejected
      if (userProfile.verificationStatus == 'rejected') {
        await _authService.signOut();
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Akun Anda ditolak oleh admin. Hubungi administrator untuk info lebih lanjut.',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }

      // Continue with normal routing for approved users
      String route;
      switch (userProfile.role) {
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

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, route);
    } on AppwriteException catch (e) {
      if (!mounted) return;
      _handleAppwriteError(e);
    } catch (e) {
      if (!mounted) return;

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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle Appwrite authentication errors
  /// Maps Appwrite error codes to user-friendly Indonesian messages
  /// Similar to Firebase error handling but with Appwrite codes:
  /// - 401: Invalid credentials (user-not-found or wrong-password equivalent)
  /// - 404: User not found
  /// - 429: Too many requests (too-many-requests equivalent)
  /// - 400: Invalid data (invalid-email equivalent)
  /// - 0/null: Network error (network-request-failed equivalent)
  void _handleAppwriteError(AppwriteException e) {
    String errorMessage;
    String actionLabel = 'OK';
    VoidCallback? actionCallback;

    debugPrint('Appwrite error code: ${e.code}, message: ${e.message}');

    switch (e.code) {
      case 401:
        // Equivalent to Firebase 'user-not-found' or 'wrong-password'
        errorMessage = 'Email atau password salah';
        break;

      case 404:
        // Equivalent to Firebase 'user-not-found'
        errorMessage = 'Email belum terdaftar';
        actionLabel = 'DAFTAR';
        actionCallback = () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.pushNamed(context, AppConstants.registerRoute);
        };
        break;

      case 429:
        // Equivalent to Firebase 'too-many-requests'
        errorMessage = 'Terlalu banyak percobaan. Tunggu sebentar';
        break;

      case 400:
        // Equivalent to Firebase 'invalid-email' or validation errors
        if (e.message?.contains('password') ?? false) {
          errorMessage = 'Password tidak valid';
        } else if (e.message?.contains('email') ?? false) {
          errorMessage = 'Format email tidak valid';
        } else {
          errorMessage = 'Data tidak valid';
        }
        break;

      case 0:
      case null:
        // Equivalent to Firebase 'network-request-failed'
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
          onPressed:
              actionCallback ??
              () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
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
                      controller: _emailController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.email, color: Colors.black),
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
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.lock, color: Colors.black),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
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
                        onPressed: () {
                          // TODO: Implement forgot password with Appwrite
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur reset password akan segera tersedia'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
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
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.indigo[600],
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
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
                        onPressed: () => Navigator.pushNamed(context, AppConstants.registerRoute),
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
