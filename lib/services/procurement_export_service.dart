// lib/services/procurement_export_service.dart
// SIM-ASET: Export procurement requests to PDF and Excel

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/procurement.dart';
import '../core/utils/date_formatter.dart';

// Conditional import for web download
import 'web_download_stub.dart' if (dart.library.html) 'web_download_web.dart' as web_download;

class ProcurementExportService {
  /// Export procurement requests to PDF and open print dialog
  static Future<void> exportToPdf(
    BuildContext context,
    List<ProcurementRequest> requests,
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
                  'REKAP UTILISASI PENGADAAN (RKBMD)',
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
          _buildPdfTable(requests),
        ],
      ),
    );

    // Show print dialog
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Rekap_Pengadaan_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  static pw.Widget _buildPdfTable(List<ProcurementRequest> requests) {
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
        'Judul Pengadaan',
        'Bidang',
        'Tahun',
        'Status',
        'Total Estimasi',
        'Diajukan Oleh',
        'Tanggal',
      ],
      data: requests.asMap().entries.map((entry) {
        final i = entry.key;
        final req = entry.value;
        return [
          '${i + 1}',
          req.title,
          req.departmentName,
          '${req.fiscalYear}',
          req.status.displayName,
          'Rp ${req.totalEstimatedCost.toString()}',
          req.createdByName ?? '-',
          DateFormatter.formatDate(req.createdAt),
        ];
      }).toList(),
    );
  }

  /// Export procurement requests to Excel and download
  static Future<void> exportToExcel(
    BuildContext context,
    List<ProcurementRequest> requests,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Rekap Pengadaan'];

    // Remove default sheet
    excel.delete('Sheet1');

    // Header style
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4CAF50'), // Green
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
    );

    // Headers
    final headers = [
      'No',
      'Judul Pengadaan',
      'Deskripsi',
      'Bidang/Unit',
      'Tahun Anggaran',
      'Status',
      'Total Estimasi Biaya',
      'Diajukan Oleh',
      'Tanggal Pengajuan',
    ];

    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Data rows
    for (var i = 0; i < requests.length; i++) {
      final req = requests[i];
      final row = i + 1;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
          IntCellValue(i + 1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
          TextCellValue(req.title);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value =
          TextCellValue(req.description);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value =
          TextCellValue(req.departmentName);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value =
          IntCellValue(req.fiscalYear);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value =
          TextCellValue(req.status.displayName);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value =
          DoubleCellValue(req.totalEstimatedCost);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value =
          TextCellValue(req.createdByName ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row)).value =
          TextCellValue(DateFormatter.formatDate(req.createdAt));
    }

    // Set column widths
    sheet.setColumnWidth(0, 5);   // No
    sheet.setColumnWidth(1, 35);  // Judul
    sheet.setColumnWidth(2, 40);  // Deskripsi
    sheet.setColumnWidth(3, 25);  // Bidang
    sheet.setColumnWidth(4, 15);  // Tahun
    sheet.setColumnWidth(5, 20);  // Status
    sheet.setColumnWidth(6, 25);  // Estimasi
    sheet.setColumnWidth(7, 25);  // Diajukan Oleh
    sheet.setColumnWidth(8, 20);  // Tanggal

    // Encode and download
    final bytes = excel.encode();
    if (bytes != null) {
      if (kIsWeb) {
        web_download.downloadFile(
          bytes,
          'Rekap_Pengadaan_RKBMD_${DateTime.now().millisecondsSinceEpoch}.xlsx',
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
