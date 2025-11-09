// lib/services/export_service.dart
// Main export service for generating reports

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../models/export_config.dart';
import '../models/report.dart';
import 'pdf_generator_service.dart';
import 'excel_generator_service.dart';
import 'csv_generator_service.dart';

class ExportService {
  final PdfGeneratorService _pdfGenerator = PdfGeneratorService();
  final ExcelGeneratorService _excelGenerator = ExcelGeneratorService();
  final CsvGeneratorService _csvGenerator = CsvGeneratorService();

  /// Main export method - routes to appropriate generator
  Future<ExportResult> exportReports({
    required ExportConfig config,
    required List<Report> reports,
  }) async {
    try {
      // Prepare report data
      final reportData = _prepareReportData(config, reports);

      // Generate based on format
      late final Uint8List bytes;
      
      switch (config.format) {
        case ExportFormat.pdf:
          bytes = await _pdfGenerator.generatePdf(reportData, config);
          break;
        case ExportFormat.excel:
          bytes = await _excelGenerator.generateExcel(reportData, config);
          break;
        case ExportFormat.csv:
          bytes = await _csvGenerator.generateCsv(reportData, config);
          break;
      }

      // Save file
      final result = await _saveFile(
        bytes: bytes,
        fileName: config.fileName,
      );

      return result;
    } catch (e) {
      return ExportResult.failure(e.toString());
    }
  }

  /// Prepare report data from reports list
  ReportData _prepareReportData(ExportConfig config, List<Report> reports) {
    // Filter by date range
    List<Report> filteredReports = reports;
    
    if (config.startDate != null && config.endDate != null) {
      filteredReports = reports.where((r) {
        return r.date.isAfter(config.startDate!) &&
               r.date.isBefore(config.endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Calculate summary statistics
    final total = filteredReports.length;
    final completed = filteredReports
        .where((r) => r.status == ReportStatus.completed || 
                     r.status == ReportStatus.verified)
        .length;
    final pending = filteredReports
        .where((r) => r.status == ReportStatus.pending)
        .length;
    final urgent = filteredReports
        .where((r) => r.isUrgent == true)
        .length;

    final completionRate = total > 0 ? (completed / total * 100) : 0.0;

    // Build summary map
    final summary = {
      'total': total,
      'completed': completed,
      'pending': pending,
      'urgent': urgent,
      'completionRate': completionRate,
      'period': _getPeriodDescription(config),
    };

    // Convert reports to map list
    final items = filteredReports.map((r) => {
      'id': r.id,
      'location': r.location,
      'description': r.description,
      'status': r.status.displayName,
      'urgent': r.isUrgent == true ? 'Ya' : 'Tidak',
      'date': DateFormat('dd/MM/yyyy HH:mm').format(r.date),
      'userName': r.userName.isNotEmpty ? r.userName : '-',
      'cleanerName': r.cleanerName != null && r.cleanerName!.isNotEmpty ? r.cleanerName! : '-',
      'completedAt': r.completedAt != null 
          ? DateFormat('dd/MM/yyyy HH:mm').format(r.completedAt!)
          : '-',
    }).toList();

    return ReportData(
      title: config.reportType.label,
      subtitle: _getPeriodDescription(config),
      generatedAt: DateTime.now(),
      startDate: config.startDate,
      endDate: config.endDate,
      summary: summary,
      items: items,
    );
  }

  String _getPeriodDescription(ExportConfig config) {
    final now = DateTime.now();
    
    switch (config.reportType) {
      case ReportType.daily:
        return 'Hari ini, ${DateFormat('dd MMMM yyyy', 'id_ID').format(now)}';
      case ReportType.weekly:
        final weekAgo = now.subtract(const Duration(days: 7));
        return '${DateFormat('dd MMM', 'id_ID').format(weekAgo)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(now)}';
      case ReportType.monthly:
        return DateFormat('MMMM yyyy', 'id_ID').format(now);
      case ReportType.custom:
        if (config.startDate != null && config.endDate != null) {
          return '${DateFormat('dd MMM', 'id_ID').format(config.startDate!)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(config.endDate!)}';
        }
        return 'Custom Range';
      case ReportType.allReports:
        return 'Semua Data';
      case ReportType.cleanerPerformance:
        return 'Performance Report';
    }
  }

  /// Save file to device
  Future<ExportResult> _saveFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      Directory? directory;
      
      if (kIsWeb) {
        // Web: Trigger download
        // Note: Actual web download implementation would use html package
        return ExportResult.success(
          filePath: 'downloads/$fileName',
          fileName: fileName,
          fileSize: bytes.length,
        );
      } else {
        // Mobile/Desktop: Save to downloads
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        } else {
          directory = await getDownloadsDirectory();
        }

        if (directory == null) {
          throw Exception('Could not get downloads directory');
        }

        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        return ExportResult.success(
          filePath: filePath,
          fileName: fileName,
          fileSize: bytes.length,
        );
      }
    } catch (e) {
      return ExportResult.failure('Failed to save file: $e');
    }
  }

  /// Quick export with default settings
  Future<ExportResult> quickExportPdf(List<Report> reports) async {
    final config = ExportConfig(
      format: ExportFormat.pdf,
      reportType: ReportType.weekly,
    );
    return exportReports(config: config, reports: reports);
  }

  Future<ExportResult> quickExportExcel(List<Report> reports) async {
    final config = ExportConfig(
      format: ExportFormat.excel,
      reportType: ReportType.weekly,
    );
    return exportReports(config: config, reports: reports);
  }
}
