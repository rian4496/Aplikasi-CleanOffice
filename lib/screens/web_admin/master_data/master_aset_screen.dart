// lib/screens/web_admin/master_data/master_aset_screen.dart
// Redesigned: Folder Card Layout for Asset Categories (Grey Folder Icons)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:aplikasi_cleanoffice/core/theme/app_theme.dart';

class MasterAsetScreen extends StatelessWidget {
  const MasterAsetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      appBar: AppBar(
        title: Text('Master Aset', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Pilih Kategori Aset',
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Kelola aset berdasarkan klasifikasi bergerak atau tidak bergerak.',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Folder Cards
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card: Aset Bergerak
                Expanded(
                  child: _buildFolderCard(
                    context,
                    title: 'Aset Bergerak',
                    subtitle: 'Kendaraan, Peralatan, Elektronik',
                    onTap: () => context.push('/admin/assets?type=movable'),
                  ),
                ),
                const SizedBox(width: 24),

                // Card: Aset Tidak Bergerak
                Expanded(
                  child: _buildFolderCard(
                    context,
                    title: 'Aset Tidak Bergerak',
                    subtitle: 'Tanah, Gedung, Bangunan',
                    onTap: () => context.push('/admin/assets?type=immovable'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grey Folder Icon
              Icon(
                LucideIcons.folder,
                size: 48,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
