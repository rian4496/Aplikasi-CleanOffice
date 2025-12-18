import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../models/agency_profile.dart';
import '../models/inventory_item.dart';
import '../models/report_filter.dart';
import '../utils/pdf_template_helper.dart'; // Re-use logo loader if useful

class PdfReportService {
  /// Generate Inventory Report (KIB style)
  Future<Uint8List> generateInventoryReport({
    required AgencyProfile profile,
    required List<InventoryItem> items,
    required ReportFilter filter,
  }) async {
    final pdf = pw.Document();
    
    // Load Fonts (Use standard fonts for now to avoid async loading issues unless cached)
    // In production, load Google Fonts: Roboto or OpenSans
    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    // Load Logo
    final logoBytes = await PdfTemplateHelper.loadLogo();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape, // Wide format for tables
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(profile, logoBytes, fontRegular, fontBold),
          _buildTitle('LAPORAN INVENTARIS BARANG (KIB)', filter, fontBold),
          pw.SizedBox(height: 16),
          _buildInventoryTable(items, fontRegular, fontBold),
          pw.SizedBox(height: 32),
          _buildSigningBlock(profile.signers, profile.city, fontRegular, fontBold),
        ],
        footer: (context) => _buildFooter(context, fontRegular),
      ),
    );

    return pdf.save();
  }

  // Helper to load logo
  Future<Uint8List> _loadLogo() async {
    try {
      final bytes = await rootBundle.load('assets/images/logo-pemprov-kalsel.png');
      return bytes.buffer.asUint8List();
    } catch (e) {
      return Uint8List(0);
    }
  }

  /// Generate Disposal Report (Laporan Penghapusan)
  Future<Uint8List> generateDisposalReport({
    required AgencyProfile profile,
    required List<Map<String, dynamic>> items, 
    required ReportFilter filter,
  }) async {
    final logoBytes = await _loadLogo();
    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(profile, logoBytes, fontRegular, fontBold),
          _buildTitle('LAPORAN PENGHAPUSAN ASET', filter, fontBold),
          pw.SizedBox(height: 20),
          _buildDisposalTable(items, fontRegular, fontBold),
          pw.SizedBox(height: 30),
          _buildSigningBlock(profile.signers, profile.city, fontRegular, fontBold),
        ],
        footer: (context) => _buildFooter(context, fontRegular),
      ),
    );

    return doc.save();
  }

  /// Generate Maintenance Report
  Future<Uint8List> generateMaintenanceReport({
    required AgencyProfile profile,
    required List<Map<String, dynamic>> items,
    required ReportFilter filter,
  }) async {
    final logoBytes = await _loadLogo();
    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
         pageFormat: PdfPageFormat.a4.landscape,
         margin: const pw.EdgeInsets.all(32),
         build: (context) => [
           _buildHeader(profile, logoBytes, fontRegular, fontBold),
           _buildTitle('LAPORAN PEMELIHARAAN ASET', filter, fontBold),
           pw.SizedBox(height: 20),
           _buildMaintenanceTable(items, fontRegular, fontBold),
           pw.SizedBox(height: 30),
           _buildSigningBlock(profile.signers, profile.city, fontRegular, fontBold),
         ],
         footer: (context) => _buildFooter(context, fontRegular),
      ),
    );
    return doc.save();
  }

  /// Generate Loan Report
  Future<Uint8List> generateLoanReport({
    required AgencyProfile profile,
    required List<Map<String, dynamic>> items,
    required ReportFilter filter,
  }) async {
    final logoBytes = await _loadLogo();
    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
         pageFormat: PdfPageFormat.a4.landscape,
         margin: const pw.EdgeInsets.all(32),
         build: (context) => [
           _buildHeader(profile, logoBytes, fontRegular, fontBold),
           _buildTitle('REKAP PEMINJAMAN ASET', filter, fontBold),
           pw.SizedBox(height: 20),
           _buildLoanTable(items, fontRegular, fontBold),
           pw.SizedBox(height: 30),
           _buildSigningBlock(profile.signers, profile.city, fontRegular, fontBold),
         ],
         footer: (context) => _buildFooter(context, fontRegular),
      ),
    );
    return doc.save();
  }

  /// 1. KOP SURAT (Header)
  pw.Widget _buildHeader(
    AgencyProfile profile,
    Uint8List logoBytes,
    pw.Font fontRegular,
    pw.Font fontBold,
  ) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Logo
            if (logoBytes.isNotEmpty)
              pw.Container(
                width: 60,
                height: 70,
                margin: const pw.EdgeInsets.only(right: 16),
                child: pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.contain),
              ),
            
            // Text Details
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'PEMERINTAH PROVINSI KALIMANTAN SELATAN', // Hardcoded province for now, or add to profile
                    style: pw.TextStyle(font: fontBold, fontSize: 14),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    profile.name.toUpperCase(), // Dinas Name
                    style: pw.TextStyle(font: fontBold, fontSize: 16),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '${profile.address}\nTelp: ${profile.phone} | Email: ${profile.email}',
                    style: pw.TextStyle(font: fontRegular, fontSize: 10),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        // Double Line Separator
        pw.Container(
          height: 3,
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.black, width: 2),
            ),
          ),
        ),
        pw.Container(
          height: 1,
          margin: const pw.EdgeInsets.only(top: 1),
          color: PdfColors.black,
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  /// 2. DOCUMENT TITLE
  pw.Widget _buildTitle(String title, ReportFilter filter, pw.Font fontBold) {
    return pw.Column(
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(font: fontBold, fontSize: 14, decoration: pw.TextDecoration.underline),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Periode: ${DateFormat('dd MMM yyyy').format(filter.startDate)} s/d ${DateFormat('dd MMM yyyy').format(filter.endDate)}',
          style: const pw.TextStyle(fontSize: 10),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  /// 3. INVENTORY TABLE
  pw.Widget _buildInventoryTable(
    List<InventoryItem> items,
    pw.Font fontRegular,
    pw.Font fontBold,
  ) {
    // Define Headers
    final headers = [
      'No',
      'Kode Barang',
      'Nama Barang',
      'NUP',
      'Merk/Type',
      'Tahun',
      'Kondisi',
      'Harga',
      'Keterangan',
    ];

    // Data Rows
    final data = items.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final item = entry.value;
      return [
        index.toString(),
        item.category, // Using category as proxy for code
        item.name, // Using name field
        '001', // Example NUP
        '-', // No brand field in InventoryItem
        DateFormat('yyyy').format(item.createdAt), // Using createdAt
        item.statusLabel, // Using statusLabel for condition
        '-', // No price field in InventoryItem
        item.statusLabel, // Status description
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.center,
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
      columnWidths: {
        0: const pw.FixedColumnWidth(30), // No
        1: const pw.FixedColumnWidth(80), // Kode
        2: const pw.FlexColumnWidth(2),   // Nama
        3: const pw.FixedColumnWidth(40), // NUP
        7: const pw.FixedColumnWidth(80), // Harga
      },
    );
  }

  /// 4. SIGNING BLOCK
  pw.Widget _buildSigningBlock(
    List<AgencySigner> signers,
    String city,
    pw.Font fontRegular,
    pw.Font fontBold,
  ) {
    if (signers.isEmpty) return pw.SizedBox();

    // Format Date: "Banjarbaru, 12 Desember 2025"
    final dateStr = '$city, ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())}';

    // Layout signers. If 1 -> Center. If 2 -> Left & Right. If 3 -> Left, Right, Center (below).
    // Simplifying to max 3 columns for now.
    
    return pw.Column(
      children: [
        // Date line (usually aligned with the right-most signer)
        pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Text(dateStr, style: pw.TextStyle(font: fontRegular)),
        ),
        
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: signers.map((signer) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(signer.roleLabel, style: pw.TextStyle(font: fontRegular)),
                pw.SizedBox(height: 60), // Space for signature
                pw.Text(
                  signer.name,
                  style: pw.TextStyle(font: fontBold, decoration: pw.TextDecoration.underline),
                ),
                pw.Text('NIP. ${signer.nip}', style: pw.TextStyle(font: fontRegular)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Utility: Page Number Footer
  pw.Widget _buildFooter(pw.Context context, pw.Font fontRegular) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Halaman ${context.pageNumber} dari ${context.pagesCount}',
        style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColors.grey),
      ),
    );
  }

  /// Helper: Build Disposal Table
  pw.Widget _buildDisposalTable(List<Map<String, dynamic>> items, pw.Font fontRegular, pw.Font fontBold) {
    final headers = <String>['No', 'Kode', 'Nama Aset', 'Alasan', 'Metode', 'Status', 'Tanggal'];
    final data = <List<String>>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      data.add(<String>[
        (i + 1).toString(),
        item['code']?.toString() ?? '-',
        item['asset_name']?.toString() ?? '-',
        item['reason']?.toString() ?? '-',
        item['method']?.toString() ?? '-',
        item['status']?.toString() ?? '-',
        item['created_at']?.toString().split('T').first ?? '-',
      ]);
    }
    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.center,
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
    );
  }

  /// Helper: Build Maintenance Table
  pw.Widget _buildMaintenanceTable(List<Map<String, dynamic>> items, pw.Font fontRegular, pw.Font fontBold) {
    final headers = <String>['No', 'No. Tiket', 'Aset', 'Teknisi', 'Deskripsi', 'Status'];
    final data = <List<String>>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      data.add(<String>[
        (i + 1).toString(),
        item['ticket_number']?.toString() ?? '-',
        item['master_assets']?['name']?.toString() ?? '-',
        item['assigned_to_user']?['display_name']?.toString() ?? '-',
        item['details']?.toString() ?? '-',
        item['status']?.toString() ?? '-',
      ]);
    }
    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.center,
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
    );
  }

  /// Helper: Build Loan Table
  pw.Widget _buildLoanTable(List<Map<String, dynamic>> items, pw.Font fontRegular, pw.Font fontBold) {
    final headers = <String>['No', 'No. Surat', 'Peminjam', 'Aset', 'Tgl Mulai', 'Durasi', 'Status'];
    final data = <List<String>>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      data.add(<String>[
        (i + 1).toString(),
        item['request_number']?.toString() ?? '-',
        item['borrower_name']?.toString() ?? '-',
        item['asset_name']?.toString() ?? '-',
        item['start_date']?.toString().split('T').first ?? '-',
        '${item['duration_years']?.toString() ?? '-'} Tahun',
        item['status']?.toString() ?? '-',
      ]);
    }
    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.center,
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
    );
  }
}
