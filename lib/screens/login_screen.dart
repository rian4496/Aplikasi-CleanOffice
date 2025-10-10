import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import 'register_screen.dart';
import 'reset_password_screen.dart';

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

  /// FIXED: Auto-create profile jika belum ada
  Future<void> _ensureUserProfile(User user) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = await firestore.collection('users').doc(user.uid).get();

      // Jika profile belum ada, buat profile baru
      if (!userDoc.exists) {
        debugPrint('Creating user profile for ${user.email}');
        
        // Tentukan role default berdasarkan email
        String role = 'employee'; // default
        if (user.email?.contains('admin') == true) {
          role = 'supervisor';
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

  /// FIXED: Login dengan auto-create profile
  Future<void> _login() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Login ke Firebase Authentication
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user == null) {
        throw Exception('Login failed: No user returned');
      }

      // Step 2: Pastikan user profile ada di Firestore
      await _ensureUserProfile(userCredential.user!);

      // Step 3: Load user role untuk routing
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

      // Step 4: Navigate berdasarkan role
      String route;
      switch (userRole) {
        case 'supervisor':
          route = '/home_admin';
          break;
        case 'cleaner':
          route = '/home_cleaner';
          break;
        case 'employee':
        default:
          route = '/home_employee';
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterScreen()),
          );
        };
        break;
        
      case 'wrong-password':
        errorMessage = 'Password salah. Silakan coba lagi';
        actionLabel = 'RESET';
        actionCallback = () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(
                initialEmail: _emailController.text,
              ),
            ),
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
          onPressed: actionCallback ?? () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cleaning_services,
                      size: 64,
                      color: Colors.indigo[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // App Title
                  Text(
                    'Clean Office',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sistem Manajemen Kebersihan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Email Field
                  TextFormField(
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
                  const SizedBox(height: 20),
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResetPasswordScreen(
                            initialEmail: _emailController.text,
                          ),
                        ),
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
                  const SizedBox(height: 16),
                  // Login Button
                  ElevatedButton(
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        ),
                        child: Text(
                          'Daftar Sekarang',
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