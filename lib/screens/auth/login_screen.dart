import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_profile.dart';
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
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _ensureUserProfile(User user) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = await firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        debugPrint('Creating user profile for ${user.email}');

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

  Future<void> _login() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (userCredential.user == null) {
        throw Exception('Login failed: No user returned');
      }

      await _ensureUserProfile(userCredential.user!);

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!mounted) return;

      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }

      final userData = userDoc.data()!;
      final userRole = userData['role'] as String?;

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

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, route);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _handleAuthError(e);
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

  void _handleAuthError(FirebaseAuthException e) {
    String errorMessage;
    String actionLabel = 'OK';
    VoidCallback? actionCallback;

    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'Email belum terdaftar';
        actionLabel = 'DAFTAR';
        actionCallback = () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.pushNamed(context, AppConstants.registerRoute);
        };
        break;

      case 'wrong-password':
        errorMessage = 'Password salah. Silakan coba lagi';
        actionLabel = 'RESET';
        actionCallback = () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.pushNamed(
            context,
            AppConstants.resetPasswordRoute,
            arguments: _emailController.text,
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
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
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
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppConstants.resetPasswordRoute,
                          arguments: _emailController.text,
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
