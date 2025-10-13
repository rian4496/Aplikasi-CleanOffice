import 'package:aplikasi_cleanoffice/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

/// Welcome Screen - Landing page sebelum login
/// Clean design tanpa border/container berlebihan
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA), // Very Light Gray
              Color(0xFFFFFFFF), // Pure White
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ilustrasi dengan animasi
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Image.asset(
                          'assets/images/welcome_illustration.png',
                          height: 200,
                          fit: BoxFit.contain,
                          // Fallback jika image tidak ada
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderIllustration();
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Title
                      Text(
                        'Hello',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[800],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'Selamat datang di Clean Office,\nkelola kebersihan kantor Anda dengan mudah',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Login Button (Filled)
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.indigo[600],
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Sign Up Button (Outlined)
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: OutlinedButton( // <-- Ganti menjadi OutlinedButton
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom( // <-- Gunakan OutlinedButton.styleFrom
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            // Atur warna teks dan garis tepi
                            foregroundColor: Colors.indigo[600], 
                            side: BorderSide(
                              color: Colors.indigo[600]!, // <-- Tambahkan ini untuk warna garis tepi
                              width: 1.5, // Atur ketebalan garis jika perlu
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                        // Text Copyright
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center, // Agar teks rata tengah
                        children: [
                          // Jarak Teks
                          const SizedBox(height: 30), 

                          Text(
                            '© 2025 Clean Office',
                            style: TextStyle(
                              color: Colors.grey[600], // Warna abu-abu yang soft
                              fontSize: 12,
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
        ),
      ),
    );
  }

  // Placeholder jika image tidak ada
  Widget _buildPlaceholderIllustration() {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.waving_hand,
            size: 80,
            color: Colors.indigo[850],
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome Illustration',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}