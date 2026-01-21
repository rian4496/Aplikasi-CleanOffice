import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui' as ui; // For ImageFilter
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Assuming Auth Providers exist
import '../../riverpod/auth_providers.dart';

class LoginScreenWeb extends HookConsumerWidget {
  const LoginScreenWeb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isLoading = useState(false);
    final isObscure = useState(true);

    // Login Logic
    Future<void> handleLogin() async {
      if (isLoading.value) return;
      isLoading.value = true;
      try {
        await ref.read(authActionsProvider.notifier).login(
          emailController.text, 
          passwordController.text
        );
        
        if (context.mounted) {
          context.go('/admin/dashboard');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login Gagal: ${e.toString()}')),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. ORIGINAL BACKGROUND SHAPES
           Positioned.fill(
            child: CustomPaint(
              painter: _BackgroundPainter(),
            ),
          ),
          
          // Optional: Watermark
          Positioned(
            right: -100,
            bottom: -100,
            child: Opacity(
              opacity: 0.03,
              child: Opacity(
              opacity: 0.1, // Increased opacity slightly for better visibility
              child: Image.asset(
                'assets/images/logo-pemprov-kalsel.png',
                width: 600,
                height: 600,
              ),
            ),
            ),
          ),

          // 2. HEADER (FIXED TOP) - Restoring User Request
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _buildHeader(context),
            ),
          ),

          // 3. Main Content (Center)
          Positioned.fill(
            top: 60, // Reduced top spacing slightly
            child: Center(
              // User requested "JANGAN BUAT SCROLLABLE" (Don't make it scrollable)
              // We remove SingleChildScrollView to force fixed size, 
              // but we wrap in a Center/ConstrainedBox to ensure it fits.
              // If screen is extremely small, overflow might happen, but user explicitly asked for "Original/No Scroll".
              child: Container(
                margin: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxWidth: 400), // Slightly smaller width (420 -> 400)
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20), // Slightly smaller radius
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32), // Compact Padding
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Shrink to fit content
                    children: [
                      // Logo Area
                      Image.asset(
                        'assets/images/logo-pemprov-kalsel.png',
                        height: 80, // Increased size slightly
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.account_balance, size: 64, color: Color(0xFF1A4D8C)),
                      ).animate().fadeIn(duration: 600.ms).scale(),
                      
                      const SizedBox(height: 16), // Reduced
                      
                      Text(
                        'SIM-ASET BRIDA',
                        style: GoogleFonts.inter(
                          fontSize: 24, // Slightly smaller (28 -> 24)
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A4D8C),
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 4),
                      Text(
                        'Sistem Manajemen Aset\nBadan Riset dan Inovasi Daerah',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.blueGrey[600],
                          height: 1.4,
                          fontSize: 13, // Slightly smaller
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      
                      const SizedBox(height: 32), // Reduced (40 -> 32)

                      // Form
                      _buildTextField(
                        label: 'Email / Username',
                        controller: emailController,
                        icon: Icons.email_outlined,
                        hintText: 'nama@kalselprov.go.id',
                        textInputAction: TextInputAction.next,
                      ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0),
                      
                      const SizedBox(height: 16), // Reduced (20 -> 16)
                      
                      _buildTextField(
                        label: 'Kata Sandi',
                        controller: passwordController,
                        icon: Icons.lock_outline,
                        hintText: '••••••••',
                        isPassword: true,
                        isObscure: isObscure,
                        textInputAction: TextInputAction.done,
                        onSubmitted: handleLogin,
                      ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 24), // Reduced (32 -> 24)
                      
                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 45, // Slightly smaller (50 -> 45)
                        child: FilledButton(
                          onPressed: isLoading.value ? null : handleLogin,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1A4D8C),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: isLoading.value 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('MASUK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
                        ),
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 20),
                      Text(
                        '© ${DateTime.now().year} Badan Riset dan Inovasi Daerah',
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        children: [
          // Logo Left
          // Logo Left
          Row(
            children: [
              Image.asset(
                'assets/images/logo-pemprov-kalsel.png',
                height: 50,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance, size: 40, color: Color(0xFF5E35B1)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PEMERINTAH PROVINSI',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.black87),
                  ),
                  Text(
                    'KALIMANTAN SELATAN',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.black87),
                  ),
                  Text(
                    'BADAN RISET DAN INOVASI DAERAH',
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[700], letterSpacing: 0.5),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Menu Right
          _buildMenuLink('Home'),
          _buildMenuLink('Informasi'),
          _buildMenuLink('Manual'),
          _buildMenuLink('Petunjuk'),
        ],
      ),
    );
  }

  Widget _buildMenuLink(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () {},
        child: Text(title, style: TextStyle(color: Colors.grey[800], fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildTextField({
    required String label, 
    required TextEditingController controller, 
    required IconData icon,
    String? hintText,
    bool isPassword = false,
    ValueNotifier<bool>? isObscure,
    TextInputAction? textInputAction,
    VoidCallback? onSubmitted,
  }) {
    return _LoginInput(
      label: label,
      controller: controller,
      icon: icon,
      hintText: hintText,
      isPassword: isPassword,
      isObscure: isObscure,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
    );
  }
}

class _LoginInput extends HookWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? hintText;
  final bool isPassword;
  final ValueNotifier<bool>? isObscure;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;

  const _LoginInput({
    required this.label,
    required this.controller,
    required this.icon,
    this.hintText,
    this.isPassword = false,
    this.isObscure,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final focusNode = useFocusNode();
    // Rebuild when focus changes to update colors
    useListenable(focusNode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(), 
          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: isPassword && (isObscure?.value ?? true),
          textInputAction: textInputAction,
          onSubmitted: (_) => onSubmitted?.call(),
          style: TextStyle(
            color: focusNode.hasFocus ? Colors.black87 : Colors.grey[600],
          ),
          decoration: InputDecoration(
            hintText: hintText ?? label,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(
              icon, 
              color: focusNode.hasFocus ? const Color(0xFF5E35B1) : Colors.grey
            ),
            suffixIcon: isPassword ? IconButton(
              icon: Icon((isObscure?.value ?? true) ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                if (isObscure != null) {
                  isObscure!.value = !isObscure!.value;
                }
              },
            ) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), 
              borderSide: BorderSide(color: Colors.grey[300]!)
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), 
              borderSide: BorderSide(color: Colors.grey[300]!)
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), 
              borderSide: const BorderSide(color: Color(0xFF5E35B1), width: 2)
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // 1. Light Blue Shape (Top Right)
    paint.color = const Color(0xFF81D4FA).withValues(alpha: 0.5); // Light Blue
    var path1 = Path();
    path1.moveTo(size.width * 0.6, 0); // Start top-center-right
    path1.quadraticBezierTo(
      size.width * 0.7, size.height * 0.4, 
      size.width, size.height * 0.3
    );
    path1.lineTo(size.width, 0);
    path1.close();
    canvas.drawPath(path1, paint);

    // 2. Darker Blue Shape (Bottom Right)
    paint.color = const Color(0xFF29B6F6); // Cyan/Blue
    var path2 = Path();
    path2.moveTo(size.width, size.height * 0.5);
    path2.quadraticBezierTo(
      size.width * 0.7, size.height * 0.7, 
      size.width * 0.8, size.height
    ); // Curve in
    path2.lineTo(size.width, size.height);
    path2.close();
    canvas.drawPath(path2, paint);
    
    // 3. Bottom Corner Bubble
    paint.color = const Color(0xFF4FC3F7).withValues(alpha: 0.8);
    canvas.drawCircle(Offset(size.width * 0.9, size.height), 150, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
