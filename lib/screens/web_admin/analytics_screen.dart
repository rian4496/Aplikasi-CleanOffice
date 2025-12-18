import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../services/asset_export_service.dart';
import '../../services/maintenance_export_service.dart';
import '../../services/procurement_export_service.dart';
import '../../providers/riverpod/asset_providers.dart';
import '../../providers/riverpod/maintenance_providers.dart';
// import '../../providers/riverpod/procurement_providers.dart'; // TODO: Create this provider

class AnalyticsReportScreen extends ConsumerStatefulWidget {
  const AnalyticsReportScreen({super.key});

  @override
  ConsumerState<AnalyticsReportScreen> createState() => _AnalyticsReportScreenState();
}

class _AnalyticsReportScreenState extends ConsumerState<AnalyticsReportScreen> {
  // Flag to prevent multiple clicks
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.modernBg,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                const Icon(Icons.analytics_outlined, color: AppTheme.primary, size: 28),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Laporan & Analitik',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Export data dan analisis performa',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSectionHeader('Export Data'),
                const SizedBox(height: 16),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildExportCard(
                        title: 'Laporan Aset',
                        description: 'Daftar aset, kondisi, dan nilai valuasi',
                        icon: Icons.inventory_2,
                        color: Colors.blue,
                        isLoading: _isGenerating,
                        onPdf: () => _generateAssetReport(isPdf: true),
                        onExcel: () => _generateAssetReport(isPdf: false),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildExportCard(
                        title: 'Riwayat Maintenance',
                        description: 'Log perbaikan dan biaya maintenance',
                        icon: Icons.build,
                        color: Colors.orange,
                        isLoading: _isGenerating,
                        onPdf: () => _generateMaintenanceReport(isPdf: true),
                        onExcel: () => _generateMaintenanceReport(isPdf: false),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildExportCard(
                        title: 'Rekap Pengadaan',
                        description: 'Usulan pengadaan barang dan status',
                        icon: Icons.shopping_cart,
                        color: Colors.green,
                        isLoading: _isGenerating,
                        onPdf: () => _generateProcurementReport(isPdf: true),
                        onExcel: () => _generateProcurementReport(isPdf: false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAssetReport({required bool isPdf}) async {
    if (_isGenerating) return;

    setState(() => _isGenerating = true);

    try {
      // 1. Fetch data directly from provider
      final assets = await ref.read(allAssetsProvider.future);

      if (assets.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada data aset untuk diexport')),
          );
        }
        return;
      }

      if (!mounted) return;

      // 2. Generate
      if (isPdf) {
        await AssetExportService.exportToPdf(context, assets);
      } else {
        await AssetExportService.exportToExcel(context, assets);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat laporan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _generateMaintenanceReport({required bool isPdf}) async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);

    try {
      final logs = await ref.read(allMaintenanceLogsProvider.future);

      if (logs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada riwayat maintenance')),
          );
        }
        return;
      }

      if (!mounted) return;

      if (isPdf) {
        await MaintenanceExportService.exportToPdf(context, logs);
      } else {
        await MaintenanceExportService.exportToExcel(context, logs);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat laporan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _generateProcurementReport({required bool isPdf}) async {
    // TODO: Implement procurement provider first
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Procurement providers belum diimplementasikan'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showNotImplemented() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ini belum tersedia')),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Container(width: 40, height: 4, color: AppTheme.primary, margin: const EdgeInsets.only(bottom: 8)),
      ],
    );
  }

  Widget _buildExportCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onPdf,
    required VoidCallback onExcel,
    bool isLoading = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : onPdf,
                    icon: isLoading 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : onExcel,
                    icon: const Icon(Icons.table_chart, size: 16),
                    label: const Text('Excel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

