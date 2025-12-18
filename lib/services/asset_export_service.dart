// lib/services/asset_export_service.dart
// SIM-ASET: Export assets to PDF and Excel

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/asset.dart';

// Conditional import for web download
import 'web_download_stub.dart' if (dart.library.html) 'web_download_web.dart' as web_download;

class AssetExportService {
  /// Export assets to PDF and open print dialog
  static Future<void> exportToPdf(
    BuildContext context,
    List<Asset> assets,
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
                  'LAPORAN DAFTAR ASET',
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
          _buildPdfTable(assets),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Mengetahui,'),
                  pw.SizedBox(height: 50),
                  pw.Text('_______________________'),
                  pw.Text('Kepala BRIDA'),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    // Show print dialog
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Daftar_Aset_BRIDA_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  static pw.Widget _buildPdfTable(List<Asset> assets) {
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
        'Kode QR',
        'Nama Aset',
        'Kategori',
        'Lokasi',
        'Kondisi',
        'Status',
        'Tgl Pembelian',
        'Harga',
      ],
      data: assets.asMap().entries.map((entry) {
        final i = entry.key;
        final a = entry.value;
        return [
          '${i + 1}',
          a.qrCode,
          a.name,
          a.category,
          a.locationName ?? '-',
          a.condition.displayName,
          a.status.displayName,
          a.purchaseDateFormatted ?? '-',
          a.purchasePriceFormatted ?? '-',
        ];
      }).toList(),
    );
  }

  /// Export assets to Excel and download
  static Future<void> exportToExcel(
    BuildContext context,
    List<Asset> assets,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Daftar Aset'];

    // Remove default sheet
    excel.delete('Sheet1');

    // Header style
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4A90D9'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
    );

    // Headers
    final headers = [
      'No',
      'Kode QR',
      'Nama Aset',
      'Deskripsi',
      'Kategori',
      'Lokasi',
      'Kondisi',
      'Status',
      'Tanggal Pembelian',
      'Harga Pembelian',
      'Garansi Sampai',
      'Catatan',
    ];

    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Data rows
    for (var i = 0; i < assets.length; i++) {
      final a = assets[i];
      final row = i + 1;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
          IntCellValue(i + 1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
          TextCellValue(a.qrCode);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value =
          TextCellValue(a.name);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value =
          TextCellValue(a.description ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value =
          TextCellValue(a.category);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value =
          TextCellValue(a.locationName ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value =
          TextCellValue(a.condition.displayName);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value =
          TextCellValue(a.status.displayName);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row)).value =
          TextCellValue(a.purchaseDateFormatted ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row)).value =
          TextCellValue(a.purchasePriceFormatted ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: row)).value =
          TextCellValue(a.warrantyUntilFormatted ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: row)).value =
          TextCellValue(a.notes ?? '');
    }

    // Set column widths
    sheet.setColumnWidth(0, 5);   // No
    sheet.setColumnWidth(1, 18);  // QR Code
    sheet.setColumnWidth(2, 30);  // Nama
    sheet.setColumnWidth(3, 40);  // Deskripsi
    sheet.setColumnWidth(4, 15);  // Kategori
    sheet.setColumnWidth(5, 20);  // Lokasi
    sheet.setColumnWidth(6, 12);  // Kondisi
    sheet.setColumnWidth(7, 10);  // Status
    sheet.setColumnWidth(8, 15);  // Tgl Pembelian
    sheet.setColumnWidth(9, 18);  // Harga
    sheet.setColumnWidth(10, 15); // Garansi
    sheet.setColumnWidth(11, 30); // Catatan

    // Encode and download
    final bytes = excel.encode();
    if (bytes != null) {
      if (kIsWeb) {
        web_download.downloadFile(
          bytes,
          'Daftar_Aset_BRIDA_${DateTime.now().millisecondsSinceEpoch}.xlsx',
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
