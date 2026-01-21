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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: MediaQuery.of(context).size.width < 900 ? IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin/dashboard'),
        ) : null,
       title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Master Aset', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFolderCard(
                        context,
                        title: 'Aset Bergerak',
                        subtitle: 'Kendaraan, Peralatan, Elektronik',
                        onTap: () => context.push('/admin/assets?type=movable'),
                        isCenter: true,
                      ),
                      const SizedBox(height: 16),
                      _buildFolderCard(
                        context,
                        title: 'Aset Tidak Bergerak',
                        subtitle: 'Tanah, Gedung, Bangunan',
                        onTap: () => context.push('/admin/assets?type=immovable'),
                        isCenter: true,
                      ),
                    ],
                  );
                }
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _buildFolderCard(
                          context,
                          title: 'Aset Bergerak',
                          subtitle: 'Kendaraan, Peralatan, Elektronik',
                          onTap: () => context.push('/admin/assets?type=movable'),
                        ),
                      ),
                      const SizedBox(width: 24),
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
                );
              },
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
    bool isCenter = false,
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
                color: Colors.grey.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
                textAlign: isCenter ? TextAlign.center : TextAlign.start,
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
                textAlign: isCenter ? TextAlign.center : TextAlign.start,
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
