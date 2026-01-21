import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 900;
            final contentWidth = isDesktop ? 500.0 : double.infinity;

            return Center(
              child: SizedBox(
                width: contentWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    children: [
                      // Spacer to push content to center vertically
                      const Spacer(flex: 2),

                      // Illustration
                      Image.asset(
                        'assets/images/welcome_illustration.png',
                        height: isDesktop ? 350 : 250,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 48),

                      // Title (Aesthetic Minimalist)
                      Text(
                        'SIM-ASET',
                        style: GoogleFonts.outfit( // Minimalist geometric font
                          fontSize: 36,
                          fontWeight: FontWeight.w600, // Semi-bold but not heavy
                          color: const Color(0xFF1E293B), // Slate-800
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subtext
                      Text(
                        'Selamat Datang!',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF64748B), // Slate-500
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      
                      const SizedBox(height: 40),

                      // Minimalist Text Button "Mulai"
                      TextButton(
                        onPressed: () => context.go('/login'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF3B82F6), // Blue-500
                          textStyle: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('Mulai'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                      
                      const Spacer(flex: 3),

                      // Footer Section
                      Column(
                        children: [
                          Text(
                            '© 2025 Clean Office System',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: const Color(0xFF94A3B8), // Slate-400
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Agency Branding
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/logo-pemprov-kalsel.png',
                                height: 28, // Small minimalist logo
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BADAN RISET DAN INOVASI DAERAH',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF334155), // Slate-700
                                      letterSpacing: 1.2, // Wide spacing for official look
                                    ),
                                  ),
                                  Text(
                                    'PROVINSI KALIMANTAN SELATAN',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B), // Slate-500
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
