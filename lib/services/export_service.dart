import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../models/report.dart';
import '../models/export_config.dart';

class ExportResult {
  final bool success;
  final String? filePath;
  final String? fileName;
  final String? error;

  ExportResult({
    required this.success,
    this.filePath,
    this.fileName,
    this.error,
  });

  factory ExportResult.success(String path, String name) {
    return ExportResult(success: true, filePath: path, fileName: name);
  }

  factory ExportResult.failure(String error) {
    return ExportResult(success: false, error: error);
  }
}

class ExportService {
  
  Future<ExportResult> exportReports({
    required ExportConfig config,
    required List<Report> reports,
  }) async {
    try {
      if (config.format == ExportFormat.pdf) {
        return await _exportToPdf(reports, config);
      } else {
        return await _exportToExcel(reports, config);
      }
    } catch (e) {
      return ExportResult.failure(e.toString());
    }
  }

  Future<ExportResult> _exportToPdf(List<Report> reports, ExportConfig config) async {
    try {
      final pdf = pw.Document();
      final font = await PdfGoogleFonts.nunitoExtraLight();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text('Laporan Kebersihan', style: pw.TextStyle(font: font, fontSize: 24)),
              ),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Tanggal', 'Lokasi', 'Petugas', 'Status', 'Urgent'],
                  ...reports.map((report) => [
                    DateFormat('dd/MM/yyyy').format(report.date),
                    report.location,
                    report.cleanerName ?? '-',
                    report.status.label,
                    report.isUrgent ? 'Ya' : 'Tidak',
                  ]),
                ],
              ),
            ];
          },
        ),
      );

      final fileName = 'laporan_kebersihan_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
      final output = await Printing.sharePdf(bytes: await pdf.save(), filename: fileName);
      
      // Printing.sharePdf returns void/bool depending on version, but we can assume success if no error
      // For file path, Printing handles it. We return a success message.
      return ExportResult.success('', fileName);
    } catch (e) {
      return ExportResult.failure(e.toString());
    }
  }

  Future<ExportResult> _exportToExcel(List<Report> reports, ExportConfig config) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Laporan'];
      
      // Header
      sheetObject.appendRow([
        TextCellValue('Tanggal'), 
        TextCellValue('Lokasi'), 
        TextCellValue('Petugas'), 
        TextCellValue('Status'), 
        TextCellValue('Urgent')
      ]);
      
      // Data
      for (var report in reports) {
        sheetObject.appendRow([
          TextCellValue(DateFormat('dd/MM/yyyy').format(report.date)),
          TextCellValue(report.location),
          TextCellValue(report.cleanerName ?? '-'),
          TextCellValue(report.status.label),
          TextCellValue(report.isUrgent ? 'Ya' : 'Tidak'),
        ]);
      }
      
      // Save
      final directory = await getTemporaryDirectory();
      final fileName = 'laporan_kebersihan_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
      final path = '${directory.path}/$fileName';
      final file = File(path);
      final fileBytes = excel.save();
      
      if (fileBytes != null) {
        await file.writeAsBytes(fileBytes);
        await Share.shareXFiles([XFile(path)], text: 'Laporan Kebersihan Excel');
        return ExportResult.success(path, fileName);
      } else {
        return ExportResult.failure('Failed to generate Excel file');
      }
    } catch (e) {
      return ExportResult.failure(e.toString());
    }
  }
  
  // Keep old methods for compatibility if needed, or redirect
  Future<void> exportToPdf(List<Report> reports) async {
    await _exportToPdf(reports, ExportConfig(format: ExportFormat.pdf, reportType: ReportType.custom));
  }

  Future<void> exportToExcel(List<Report> reports) async {
    await _exportToExcel(reports, ExportConfig(format: ExportFormat.excel, reportType: ReportType.custom));
  }
}

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});
