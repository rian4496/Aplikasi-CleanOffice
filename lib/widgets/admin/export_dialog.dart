// lib/widgets/admin/export_dialog.dart
// Export dialog for selecting format and options

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import '../../models/export_config.dart';
import '../../models/report.dart';
import '../../services/export_service.dart';
import '../../providers/riverpod/admin_providers.dart';

class ExportDialog extends ConsumerStatefulWidget {
  const ExportDialog({super.key});

  @override
  ConsumerState<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<ExportDialog> {
  ExportFormat _selectedFormat = ExportFormat.pdf;
  ReportType _selectedReportType = ReportType.weekly;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _includeCharts = true;
  bool _includePhotos = false;
  bool _includeStatistics = true;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFormatSelector(),
            const SizedBox(height: 16),
            _buildReportTypeSelector(),
            if (_selectedReportType == ReportType.custom) ...[
              const SizedBox(height: 16),
              _buildDateRangePicker(),
            ],
            const SizedBox(height: 16),
            _buildOptions(),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.download, size: 24, color: Colors.black),
        const SizedBox(width: 12),
        const Text(
          'Export Laporan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildFormatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Format Export',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Theme(
          data: Theme.of(context).copyWith(
            highlightColor: Colors.grey[200],
            hoverColor: Colors.grey[100],
            focusColor: Colors.grey[200],
            splashColor: Colors.grey[100],
          ),
          child: DropdownButtonFormField<ExportFormat>(
            initialValue: _selectedFormat,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: Colors.white,
            items: ExportFormat.values.map((format) {
              return DropdownMenuItem(
                value: format,
                child: Row(
                  children: [
                    Icon(format.icon, size: 20, color: format.color),
                    const SizedBox(width: 12),
                    Text(format.label),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedFormat = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Laporan',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Theme(
          data: Theme.of(context).copyWith(
            highlightColor: Colors.grey[200],
            hoverColor: Colors.grey[100],
            focusColor: Colors.grey[200],
            splashColor: Colors.grey[100],
          ),
          child: DropdownButtonFormField<ReportType>(
            initialValue: _selectedReportType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: Colors.white,
            items: ReportType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.label),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedReportType = value;
                  if (value != ReportType.custom) {
                    _startDate = null;
                    _endDate = null;
                  }
                });
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedReportType.description,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildDateRangePicker() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: Icon(Icons.calendar_today, size: 16, color: Colors.grey[700]),
            label: Text(
              _startDate != null
                  ? DateFormat('dd/MM/yyyy').format(_startDate!)
                  : 'Tanggal Mulai',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide.none,
            ),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _startDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _startDate = date);
              }
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('s/d'),
        ),
        Expanded(
          child: OutlinedButton.icon(
            icon: Icon(Icons.calendar_today, size: 16, color: Colors.grey[700]),
            label: Text(
              _endDate != null
                  ? DateFormat('dd/MM/yyyy').format(_endDate!)
                  : 'Tanggal Akhir',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide.none,
            ),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _endDate ?? DateTime.now(),
                firstDate: _startDate ?? DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _endDate = date);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opsi Tambahan',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        CheckboxListTile(
          title: const Text('Sertakan Statistik'),
          subtitle: const Text('Ringkasan dan grafik statistik'),
          value: _includeStatistics,
          onChanged: (value) => setState(() => _includeStatistics = value!),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('Sertakan Chart'),
          subtitle: const Text('Visualisasi data dalam bentuk grafik'),
          value: _includeCharts,
          onChanged: (value) => setState(() => _includeCharts = value!),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('Sertakan Foto'),
          subtitle: const Text('Foto bukti laporan (ukuran file lebih besar)'),
          value: _includePhotos,
          onChanged: (value) => setState(() => _includePhotos = value!),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          icon: _isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: Text(_isExporting ? 'Mengexport...' : 'Export'),
          onPressed: _isExporting ? null : _handleExport,
        ),
      ],
    );
  }

  Future<void> _handleExport() async {
    // Validate custom date range
    if (_selectedReportType == ReportType.custom &&
        (_startDate == null || _endDate == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal mulai dan akhir')),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      // Get reports
      final reportsAsync = ref.read(needsVerificationReportsProvider);
      final reports = reportsAsync.when(
        data: (data) => data,
        loading: () => <Report>[],
        error: (e, _) => <Report>[],
      );
      
      // Create config
      final config = ExportConfig(
        format: _selectedFormat,
        reportType: _selectedReportType,
        startDate: _startDate,
        endDate: _endDate,
        includeCharts: _includeCharts,
        includePhotos: _includePhotos,
        includeStatistics: _includeStatistics,
      );

      // Export
      final exportService = ExportService();
      final result = await exportService.exportReports(
        config: config,
        reports: reports,
      );

      if (!mounted) return;

      if (result.success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export berhasil: ${result.fileName}'),
            action: result.filePath != null
                ? SnackBarAction(
                    label: 'Buka Folder',
                    onPressed: () {
                      _openFileLocation(result.filePath!);
                    },
                  )
                : null,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export gagal: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  /// Open file location in file explorer
  Future<void> _openFileLocation(String filePath) async {
    try {
      final file = File(filePath);
      final directory = file.parent;
      
      if (Platform.isWindows) {
        // Open Windows Explorer and select file
        await Process.run('explorer', ['/select,', filePath]);
      } else if (Platform.isMacOS) {
        // Open Finder and select file
        await Process.run('open', ['-R', filePath]);
      } else if (Platform.isLinux) {
        // Open file manager at directory
        final uri = Uri.file(directory.path);
        await launchUrl(uri);
      } else if (Platform.isAndroid || Platform.isIOS) {
        // For mobile, try to open the file
        final uri = Uri.file(filePath);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          throw 'Tidak dapat membuka file di perangkat ini';
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka lokasi file: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
