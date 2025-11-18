// lib/models/export_config_freezed.dart
// Export configuration models - Freezed Version

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'export_config_freezed.freezed.dart';
part 'export_config_freezed.g.dart';

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

@freezed
class ExportConfig with _$ExportConfig {
  const ExportConfig._(); // Private constructor for custom methods

  const factory ExportConfig({
    required ExportFormat format,
    required ReportType reportType,
    DateTime? startDate,
    DateTime? endDate,
    @Default(true) bool includeCharts,
    @Default(false) bool includePhotos,
    @Default(true) bool includeStatistics,
    String? cleanerId,
    String? location,
  }) = _ExportConfig;

  /// Convert dari JSON ke ExportConfig object
  factory ExportConfig.fromJson(Map<String, dynamic> json) => _$ExportConfigFromJson(json);
}

// ==================== EXPORT CONFIG EXTENSION ====================

extension ExportConfigExtension on ExportConfig {
  String get fileName {
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final type = reportType.label.replaceAll(' ', '_');
    final extension = format == ExportFormat.excel ? 'xlsx' : format.name;
    return 'CleanOffice_${type}_$timestamp.$extension';
  }
}

// ==================== EXPORT RESULT ====================

@freezed
class ExportResult with _$ExportResult {
  const ExportResult._(); // Private constructor for custom methods

  const factory ExportResult({
    required bool success,
    String? filePath,
    String? fileName,
    int? fileSize,
    String? error,
    required DateTime exportedAt,
  }) = _ExportResult;

  /// Create successful export result
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

  /// Create failed export result
  factory ExportResult.failure(String error) {
    return ExportResult(
      success: false,
      error: error,
      exportedAt: DateTime.now(),
    );
  }

  /// Convert dari JSON ke ExportResult object
  factory ExportResult.fromJson(Map<String, dynamic> json) => _$ExportResultFromJson(json);
}

// ==================== EXPORT RESULT EXTENSION ====================

extension ExportResultExtension on ExportResult {
  String get fileSizeFormatted {
    if (fileSize == null) return '';
    final kb = fileSize! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(2)} MB';
  }
}

// ==================== REPORT DATA ====================

@freezed
class ReportData with _$ReportData {
  const ReportData._(); // Private constructor for custom methods

  const factory ReportData({
    required String title,
    required String subtitle,
    required DateTime generatedAt,
    DateTime? startDate,
    DateTime? endDate,
    required Map<String, dynamic> summary,
    required List<Map<String, dynamic>> items,
  }) = _ReportData;

  /// Convert dari JSON ke ReportData object
  factory ReportData.fromJson(Map<String, dynamic> json) => _$ReportDataFromJson(json);
}
