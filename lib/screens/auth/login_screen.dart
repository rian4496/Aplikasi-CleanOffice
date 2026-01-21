// lib/screens/auth/login_screen.dart
// ✅ MIGRATED TO SUPABASE

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'login_screen_web.dart';
import '../../services/supabase_auth_service.dart';
import '../../core/error/exceptions.dart';
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
  final _authService = SupabaseAuthService();
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
      debugPrint('Attempting login with Supabase...');

      final userProfile = await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      debugPrint('Login successful! Role: ${userProfile.role}, Status: ${userProfile.status}, Verification: ${userProfile.verificationStatus}');

      // Note: Verification checks are now handled in SupabaseAuthService.signInWithEmailAndPassword()
      // The service will throw AuthException if user is not verified or inactive

      // Continue with normal routing for approved users
      String route;
      
      // Check if running on Web to redirect to Console/Web Dashboard
      if (kIsWeb) {
        switch (userProfile.role) {
          case 'admin':
          case 'kasubbag_umpeg': // Kasubbag uses Admin Dashboard on Web
             route = '/admin/dashboard';
             break;
          case 'cleaner':
            route = '/console/cleaner/dashboard';
            break;
          case 'employee':
            route = '/console/employee/dashboard';
            break;
          case 'teknisi':
            route = '/admin/helpdesk';
            break;
          default:
            route = '/login';
        }
      } else {
        // Mobile App Routing
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
      }

      if (!mounted) return;
      context.go(route);
    } on AuthException catch (e) {
      if (!mounted) return;

      debugPrint('Login auth error: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: e.code == 'not-verified' ? Colors.orange : Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    } on DatabaseException catch (e) {
      if (!mounted) return;

      debugPrint('Login database error: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      debugPrint('Login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat login: ${e.toString()}'),
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


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          // Use the new Web Layout for larger screens
          return const LoginScreenWeb();
        }
        
        // Use existing Mobile Layout
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
                          cursorColor: Colors.black,
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
                              borderSide: BorderSide(color: Colors.grey[400]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[600]!, width: 2),
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
                          cursorColor: Colors.black,
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
                              borderSide: BorderSide(color: Colors.grey[400]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[600]!, width: 2),
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
                            onPressed: () => context.push(AppConstants.registerRoute),
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
      },
    );
  }
}

