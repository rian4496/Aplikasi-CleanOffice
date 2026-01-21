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
import '../utils/pdf_template_helper.dart';

// Conditional import for web download
import 'web_download_stub.dart' if (dart.library.html) 'web_download_web.dart' as web_download;

class ProcurementExportService {
  /// Export procurement requests to PDF and open print dialog
  static Future<void> exportToPdf(
    BuildContext context,
    List<ProcurementRequest> requests,
  ) async {
    final pdf = pw.Document();

    // Load fonts and logo for professional header
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final logoBytes = await PdfTemplateHelper.loadLogo();

    // Add header
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Use same professional Kop Surat
            PdfTemplateHelper.buildKopSurat(
              logoBytes: logoBytes,
              fontRegular: fontRegular,
              fontBold: fontBold,
            ),
            // Title
            pw.Center(
              child: pw.Text(
                'Rekap Utilisasi Pengadaan (RKBMD)',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 14,
                ),
              ),
            ),
            pw.SizedBox(height: 16),
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

  /// Generate BA Penerimaan Barang (Berita Acara Penerimaan)
  /// Used when goods from vendor are received
  static Future<void> generateBAPenerimaanBarang({
    required ProcurementRequest procurement,
    required String vendorName,
    required String deliveryDate,
    String? receiverName,
    String? receiverNip,
    String? notes,
  }) async {
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final logoBytes = await PdfTemplateHelper.loadLogo();
    
    final pdf = pw.Document();
    final baNumber = 'BA-PEN/${procurement.id.substring(0, 8).toUpperCase()}';
    final currentDate = DateTime.now();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Kop Surat
            PdfTemplateHelper.buildKopSurat(
              logoBytes: logoBytes,
              fontRegular: fontRegular,
              fontBold: fontBold,
            ),
            
            // Title
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'BERITA ACARA PENERIMAAN BARANG',
                    style: pw.TextStyle(font: fontBold, fontSize: 14),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Nomor: $baNumber',
                    style: pw.TextStyle(font: fontRegular, fontSize: 11),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 16),
            
            // Opening paragraph
            pw.Text(
              'Pada hari ini, ${_formatIndonesianDate(currentDate)}, telah diterima barang dari:',
              style: pw.TextStyle(font: fontRegular, fontSize: 11, lineSpacing: 4),
            ),
            
            pw.SizedBox(height: 12),
            
            // Vendor Info
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Nama Penyedia/Vendor', vendorName, fontRegular),
                  _buildInfoRow('No. Pengadaan', procurement.id.substring(0, 8).toUpperCase(), fontRegular),
                  _buildInfoRow('Judul Pengadaan', procurement.title, fontRegular),
                  _buildInfoRow('Tanggal Pengiriman', deliveryDate, fontRegular),
                ],
              ),
            ),
            
            pw.SizedBox(height: 16),
            
            // Items Table
            pw.Text('DAFTAR BARANG YANG DITERIMA:', style: pw.TextStyle(font: fontBold, fontSize: 11)),
            pw.SizedBox(height: 8),
            _buildItemsTable(procurement.items ?? [], fontRegular, fontBold),
            
            pw.SizedBox(height: 16),
            
            // Condition Statement
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.green50,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                'Barang-barang tersebut diterima dalam keadaan baik dan sesuai dengan spesifikasi yang tercantum dalam dokumen pengadaan.',
                style: pw.TextStyle(font: fontRegular, fontSize: 10, lineSpacing: 4),
              ),
            ),
            
            if (notes != null && notes.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              pw.Text('Catatan:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
              pw.Text(notes, style: pw.TextStyle(font: fontRegular, fontSize: 10)),
            ],
            
            pw.SizedBox(height: 16),
            
            pw.Text(
              'Demikian Berita Acara ini dibuat dengan sebenarnya.',
              style: pw.TextStyle(font: fontRegular, fontSize: 11),
            ),
            
            pw.Spacer(),
            
            // Signatures (3 columns)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Left: Pihak Penyedia
                _buildSignatureColumn('Yang Menyerahkan', vendorName, 'Perwakilan Vendor', fontRegular, fontBold),
                // Center: Penerima
                _buildSignatureColumn('Yang Menerima', receiverName ?? 'Pengelola BMD', receiverNip ?? '-', fontRegular, fontBold),
                // Right: Mengetahui
                _buildSignatureColumn('Mengetahui', 'Kasubbag UMPEG', '', fontRegular, fontBold),
              ],
            ),
          ],
        ),
      ),
    );
    
    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }
  
  static pw.Widget _buildInfoRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 140, child: pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10))),
          pw.Text(': ', style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: 10))),
        ],
      ),
    );
  }
  
  static pw.Widget _buildItemsTable(List<ProcurementItem> items, pw.Font fontRegular, pw.Font fontBold) {
    if (items.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
        child: pw.Text('(Tidak ada item)', style: pw.TextStyle(font: fontRegular, fontSize: 10, color: PdfColors.grey)),
      );
    }
    
    return pw.Table.fromTextArray(
      headers: ['No', 'Nama Barang', 'Spesifikasi', 'Jumlah', 'Satuan', 'Kondisi'],
      data: items.asMap().entries.map((e) {
        final i = e.key;
        final item = e.value;
        return [
          '${i + 1}',
          item.itemName,
          item.description.isNotEmpty ? item.description : '-',
          '${item.quantity}',
          item.unit,
          'Baik',
        ];
      }).toList(),
      headerStyle: pw.TextStyle(font: fontBold, fontSize: 9),
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 8),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignment: pw.Alignment.centerLeft,
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
      columnWidths: {
        0: const pw.FixedColumnWidth(25),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FixedColumnWidth(40),
        4: const pw.FixedColumnWidth(40),
        5: const pw.FixedColumnWidth(45),
      },
    );
  }
  
  static pw.Widget _buildSignatureColumn(String role, String name, String nip, pw.Font fontRegular, pw.Font fontBold) {
    return pw.Container(
      width: 140,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(role, style: pw.TextStyle(font: fontRegular, fontSize: 9)),
          pw.SizedBox(height: 50), // Space for signature
          pw.Container(
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Text(name, style: pw.TextStyle(font: fontBold, fontSize: 9)),
          ),
          if (nip.isNotEmpty && nip != '-')
            pw.Text('NIP. $nip', style: pw.TextStyle(font: fontRegular, fontSize: 8)),
        ],
      ),
    );
  }
  
  static String _formatIndonesianDate(DateTime date) {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
