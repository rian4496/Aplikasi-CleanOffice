// lib/services/maintenance_export_service.dart
// SIM-ASET: Export maintenance logs to PDF and Excel

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/maintenance_log.dart';
import '../core/utils/date_formatter.dart';

// Conditional import for web download
import 'web_download_stub.dart' if (dart.library.html) 'web_download_web.dart' as web_download;

class MaintenanceExportService {
  /// Export maintenance logs to PDF and open print dialog
  static Future<void> exportToPdf(
    BuildContext context,
    List<MaintenanceLog> logs,
  ) async {
    final pdf = pw.Document();

    // Add header
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'LAPORAN RIWAYAT MAINTENANCE',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'BRIDA Prov. Kalimantan Selatan',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Tanggal: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 10),
            pw.Divider(),
          ],
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'SIM-ASET BRIDA',
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.Text(
              'Halaman ${context.pageNumber} dari ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
        build: (context) => [
          _buildPdfTable(logs),
        ],
      ),
    );

    // Show print dialog
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Laporan_Maintenance_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  static pw.Widget _buildPdfTable(List<MaintenanceLog> logs) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 9,
      ),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
      cellAlignment: pw.Alignment.centerLeft,
      headers: [
        'No',
        'Judul',
        'Aset',
        'Tipe',
        'Prioritas',
        'Status',
        'Teknisi',
        'Tgl Mulai',
        'Tgl Selesai',
        'Biaya',
      ],
      data: logs.asMap().entries.map((entry) {
        final i = entry.key;
        final log = entry.value;
        return [
          '${i + 1}',
          log.title,
          log.assetName ?? '-',
          log.type.displayName,
          log.priority.displayName,
          log.status.displayName,
          log.technicianName ?? '-',
          log.startedAt != null ? DateFormatter.formatDate(log.startedAt!) : '-',
          log.completedAt != null ? DateFormatter.formatDate(log.completedAt!) : '-',
          log.cost != null ? 'Rp ${log.cost.toString()}' : '-', // Simplified formatting
        ];
      }).toList(),
    );
  }

  /// Export maintenance logs to Excel and download
  static Future<void> exportToExcel(
    BuildContext context,
    List<MaintenanceLog> logs,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Riwayat Maintenance'];

    // Remove default sheet
    excel.delete('Sheet1');

    // Header style
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#FF9800'), // Orange
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
    );

    // Headers
    final headers = [
      'No',
      'Judul',
      'Deskripsi',
      'Aset',
      'Tipe Maintenance',
      'Prioritas',
      'Status',
      'Teknisi',
      'Tanggal Jadwal',
      'Tanggal Mulai',
      'Tanggal Selesai',
      'Biaya',
      'Catatan',
    ];

    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Data rows
    for (var i = 0; i < logs.length; i++) {
      final log = logs[i];
      final row = i + 1;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
          IntCellValue(i + 1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
          TextCellValue(log.title);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value =
          TextCellValue(log.description ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value =
          TextCellValue(log.assetName ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value =
          TextCellValue(log.type.displayName);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value =
          TextCellValue(log.priority.displayName);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value =
          TextCellValue(log.status.displayName);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value =
          TextCellValue(log.technicianName ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row)).value =
          TextCellValue(log.scheduledAt != null ? DateFormatter.formatDate(log.scheduledAt!) : '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row)).value =
          TextCellValue(log.startedAt != null ? DateFormatter.formatDate(log.startedAt!) : '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: row)).value =
          TextCellValue(log.completedAt != null ? DateFormatter.formatDate(log.completedAt!) : '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: row)).value =
          DoubleCellValue(log.cost ?? 0);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: row)).value =
          TextCellValue(log.notes ?? '');
    }

    // Set column widths
    sheet.setColumnWidth(0, 5);   // No
    sheet.setColumnWidth(1, 30);  // Judul
    sheet.setColumnWidth(2, 40);  // Deskripsi
    sheet.setColumnWidth(3, 25);  // Aset
    sheet.setColumnWidth(4, 20);  // Tipe
    sheet.setColumnWidth(5, 15);  // Prioritas
    sheet.setColumnWidth(6, 15);  // Status
    sheet.setColumnWidth(7, 25);  // Teknisi
    sheet.setColumnWidth(8, 18);  // Tgl Jadwal
    sheet.setColumnWidth(9, 18);  // Tgl Mulai
    sheet.setColumnWidth(10, 18); // Tgl Selesai
    sheet.setColumnWidth(11, 20); // Biaya
    sheet.setColumnWidth(12, 30); // Catatan

    // Encode and download
    final bytes = excel.encode();
    if (bytes != null) {
      if (kIsWeb) {
        web_download.downloadFile(
          bytes,
          'Laporan_Maintenance_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File Excel berhasil didownload'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
