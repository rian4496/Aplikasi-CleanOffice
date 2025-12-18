import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import '../models/report.dart';
import '../models/export_config.dart';
import '../utils/pdf_template_helper.dart';

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
      // Load Fonts
      final fontKopRegular = pw.Font.times();
      final fontKopBold = pw.Font.timesBold();
      final fontBodyRegular = await PdfGoogleFonts.nunitoExtraLight();
      final fontBodyBold = await PdfGoogleFonts.nunitoBold();
      
      final logoBytes = await PdfTemplateHelper.loadLogo();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // 1. Official Kop Surat (Times New Roman)
              PdfTemplateHelper.buildKopSurat(
                logoBytes: logoBytes,
                fontRegular: fontKopRegular,
                fontBold: fontKopBold,
              ),
              pw.SizedBox(height: 20),

              // 2. Title (Nunito)
              pw.Center(
                child: pw.Text(
                  'LAPORAN KEBERSIHAN',
                  style: pw.TextStyle(font: fontBodyBold, fontSize: 14, decoration: pw.TextDecoration.underline),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // 3. Table (Nunito)
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                headerStyle: pw.TextStyle(font: fontBodyBold, color: PdfColors.black),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                cellStyle: pw.TextStyle(font: fontBodyRegular, fontSize: 10),
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
      
      // Use layoutPdf to trigger the native Print Dialog (which supports Save as PDF too)
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: fileName,
      );
      
      return ExportResult.success('', 'Print Dialog Opened');
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
      final fileName = 'laporan_kebersihan_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
      final fileBytes = excel.save();
      
      if (fileBytes != null) {
        if (kIsWeb) {
          // Direct download on Web
          await FilePicker.platform.saveFile(
             dialogTitle: 'Simpan Laporan Excel',
             fileName: fileName,
             bytes: Uint8List.fromList(fileBytes),
          );
          return ExportResult.success('', fileName);
        } else {
          // Mobile/Desktop Share
          final directory = await getTemporaryDirectory();
          final path = '${directory.path}/$fileName';
          final file = File(path);
          await file.writeAsBytes(fileBytes);
          await Share.shareXFiles([XFile(path)], text: 'Laporan Kebersihan Excel');
          return ExportResult.success(path, fileName);
        }
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
  // --- Generic Export Methods ---

  Future<ExportResult> exportGenericData({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> data,
    required ExportFormat format,
  }) async {
    try {
      if (format == ExportFormat.pdf) {
        return await _exportGenericToPdf(title, headers, data);
      } else {
        return await _exportGenericToExcel(title, headers, data);
      }
    } catch (e) {
      return ExportResult.failure(e.toString());
    }
  }

  Future<ExportResult> _exportGenericToPdf(String title, List<String> headers, List<List<dynamic>> data) async {
    try {
      final pdf = pw.Document();
      // Load Fonts
      final fontKopRegular = pw.Font.times();
      final fontKopBold = pw.Font.timesBold();
      final fontBodyRegular = await PdfGoogleFonts.nunitoExtraLight();
      final fontBodyBold = await PdfGoogleFonts.nunitoBold();
      
      final logoBytes = await PdfTemplateHelper.loadLogo();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // 1. Official Kop Surat (Times New Roman)
              PdfTemplateHelper.buildKopSurat(
                  logoBytes: logoBytes,
                  fontRegular: fontKopRegular,
                  fontBold: fontKopBold
              ),
              pw.SizedBox(height: 20),

              // 2. Title (Nunito)
              pw.Center(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(font: fontBodyBold, fontSize: 14, decoration: pw.TextDecoration.underline),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // 3. Table (Nunito)
              pw.Table.fromTextArray(
                context: context,
                headers: headers,
                data: data.map((row) => row.map((e) => e.toString()).toList()).toList(),
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                headerStyle: pw.TextStyle(font: fontBodyBold, color: PdfColors.black),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                headerHeight: 25,
                cellStyle: pw.TextStyle(font: fontBodyRegular, fontSize: 10),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft, // Adjust as needed
                },
              ),
            ];
          },
        ),
      );

      final cleanTitle = title.toLowerCase().replaceAll(' ', '_');
      final fileName = '${cleanTitle}_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
      
      // Use layoutPdf to trigger the native Print Dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: fileName,
      );
      
      return ExportResult.success('', 'Print Dialog Opened');
    } catch (e) {
      return ExportResult.failure(e.toString());
    }
  }

  Future<ExportResult> _exportGenericToExcel(String title, List<String> headers, List<List<dynamic>> data) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      
      // Header
      sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());
      
      // Data
      for (var row in data) {
        sheetObject.appendRow(row.map((e) => TextCellValue(e.toString())).toList());
      }
      
      // Save
      final cleanTitle = title.toLowerCase().replaceAll(' ', '_');
      final fileName = '${cleanTitle}_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
      final fileBytes = excel.save();
      
      if (fileBytes != null) {
        if (kIsWeb) {
          // Direct download on Web
          await FilePicker.platform.saveFile(
             dialogTitle: 'Simpan Excel',
             fileName: fileName,
             bytes: Uint8List.fromList(fileBytes),
          );
          return ExportResult.success('', fileName);
        } else {
           // Mobile/Desktop Share
          final directory = await getTemporaryDirectory();
          final path = '${directory.path}/$fileName';
          final file = File(path);
          await file.writeAsBytes(fileBytes);
          await Share.shareXFiles([XFile(path)], text: '$title Excel');
          return ExportResult.success(path, fileName);
        }
      } else {
        return ExportResult.failure('Failed to generate Excel file');
      }
    } catch (e) {
      return ExportResult.failure(e.toString());
    }
  }
}

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});
