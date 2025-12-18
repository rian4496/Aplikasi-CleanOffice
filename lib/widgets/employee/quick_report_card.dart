// lib/widgets/employee/quick_report_card.dart
// Quick report creation card for employee

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';

class QuickReportCard extends ConsumerWidget {
  const QuickReportCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/employee/create-report'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_circle,
                  size: 48,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Buat Laporan Baru',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Laporkan masalah kebersihan dengan cepat',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildQuickOption(
                    icon: Icons.camera_alt,
                    label: 'Foto',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/employee/create-report',
                        arguments: {'openCamera': true},
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildQuickOption(
                    icon: Icons.warning,
                    label: 'Urgent',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/employee/create-report',
                        arguments: {'isUrgent': true},
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildQuickOption(
                    icon: Icons.location_on,
                    label: 'Lokasi',
                    onTap: () {
                      Navigator.pushNamed(context, '/employee/create-report');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

