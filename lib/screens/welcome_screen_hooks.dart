// lib/screens/welcome_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'auth/login_screen.dart';
import 'auth/sign_up_screen.dart';

/// Welcome Screen - Landing page sebelum login
class WelcomeScreen extends HookConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: Animation controller
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );

    // ✅ HOOKS: Memoized animations
    final fadeAnimation = useMemoized(
      () => CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
      [controller],
    );

    final slideAnimation = useMemoized(
      () => Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      ),
      [controller],
    );

    // ✅ HOOKS: Auto-start animation on mount
    useEffect(() {
      controller.forward();
      return null; // No cleanup needed
    }, const []);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF), // Pure White
              Color(0xFFFFFFFF), // Pure White
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
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
                          return Transform.scale(scale: value, child: child);
                        },
                        child: Image.asset(
                          'assets/images/welcome_illustration.png',
                          height: 200,
                          width: 200,
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
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),

                      const SizedBox(height: 40),

                      // Login Button (Filled)
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO (Phase 5): Replace with go_router navigation
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
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO (Phase 5): Replace with go_router navigation
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: Colors.indigo[600],
                            side: BorderSide(
                              color: Colors.indigo[600]!,
                              width: 1.5,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          Text(
                            '© 2025 Clean Office',
                            style: TextStyle(
                              color: Colors.grey[600],
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

  // ✅ STATIC HELPER: Placeholder illustration
  static Widget _buildPlaceholderIllustration() {
    return SizedBox(
      height: 200,
      width: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.waving_hand, size: 80, color: Colors.indigo[800]),
          const SizedBox(height: 8),
          Text(
            'Welcome Illustration',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

