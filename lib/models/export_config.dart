// lib/models/export_config.dart
// Models for export and report configuration

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// ==================== EXPORT FORMAT ====================

enum ExportFormat {
  pdf('PDF', Icons.picture_as_pdf, Colors.red),
  excel('Excel', Icons.table_chart, Colors.green),
  csv('CSV', Icons.text_snippet, Colors.blue);

  final String label;
  final IconData icon;
  final Color color;

  const ExportFormat(this.label, this.icon, this.color);
}

// ==================== REPORT TYPE ====================

enum ReportType {
  daily('Laporan Harian', 'Ringkasan laporan untuk hari ini'),
  weekly('Laporan Mingguan', 'Ringkasan laporan 7 hari terakhir'),
  monthly('Laporan Bulanan', 'Ringkasan laporan bulan ini'),
  custom('Custom Range', 'Pilih tanggal sendiri'),
  allReports('Semua Laporan', 'Export semua data laporan'),
  cleanerPerformance('Performa Cleaner', 'Laporan kinerja cleaner');

  final String label;
  final String description;

  const ReportType(this.label, this.description);
}

// ==================== EXPORT CONFIG ====================

class ExportConfig extends Equatable {
  final ExportFormat format;
  final ReportType reportType;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool includeCharts;
  final bool includePhotos;
  final bool includeStatistics;
  final String? cleanerId;
  final String? location;

  const ExportConfig({
    required this.format,
    required this.reportType,
    this.startDate,
    this.endDate,
    this.includeCharts = true,
    this.includePhotos = false,
    this.includeStatistics = true,
    this.cleanerId,
    this.location,
  });

  ExportConfig copyWith({
    ExportFormat? format,
    ReportType? reportType,
    DateTime? startDate,
    DateTime? endDate,
    bool? includeCharts,
    bool? includePhotos,
    bool? includeStatistics,
    String? cleanerId,
    String? location,
  }) {
    return ExportConfig(
      format: format ?? this.format,
      reportType: reportType ?? this.reportType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      includeCharts: includeCharts ?? this.includeCharts,
      includePhotos: includePhotos ?? this.includePhotos,
      includeStatistics: includeStatistics ?? this.includeStatistics,
      cleanerId: cleanerId ?? this.cleanerId,
      location: location ?? this.location,
    );
  }

  String get fileName {
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final type = reportType.label.replaceAll(' ', '_');
    final extension = format == ExportFormat.excel ? 'xlsx' : format.name;
    return 'CleanOffice_${type}_$timestamp.$extension';
  }

  @override
  List<Object?> get props => [
        format,
        reportType,
        startDate,
        endDate,
        includeCharts,
        includePhotos,
        includeStatistics,
        cleanerId,
        location,
      ];
}

// ==================== EXPORT RESULT ====================

class ExportResult {
  final bool success;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final String? error;
  final DateTime exportedAt;

  const ExportResult({
    required this.success,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.error,
    required this.exportedAt,
  });

  factory ExportResult.success({
    required String filePath,
    required String fileName,
    required int fileSize,
  }) {
    return ExportResult(
      success: true,
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      exportedAt: DateTime.now(),
    );
  }

  factory ExportResult.failure(String error) {
    return ExportResult(
      success: false,
      error: error,
      exportedAt: DateTime.now(),
    );
  }

  String get fileSizeFormatted {
    if (fileSize == null) return '';
    final kb = fileSize! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(2)} MB';
  }
}

// ==================== REPORT DATA ====================

class ReportData extends Equatable {
  final String title;
  final String subtitle;
  final DateTime generatedAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> items;

  const ReportData({
    required this.title,
    required this.subtitle,
    required this.generatedAt,
    this.startDate,
    this.endDate,
    required this.summary,
    required this.items,
  });

  @override
  List<Object?> get props => [
        title,
        subtitle,
        generatedAt,
        startDate,
        endDate,
        summary,
        items,
      ];
}
