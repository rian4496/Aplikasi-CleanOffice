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
    required List<Map<String, dynamic>> items,
    required ReportFilter filter,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();
    
    // Load Noto Sans for letter content (isi surat)
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    
    // Standard Times New Roman for BRIDA title in Kop Surat
    final fontTimes = pw.Font.times();
    final fontTimesBold = pw.Font.timesBold();

    // Load Logo
    final logoBytes = await PdfTemplateHelper.loadLogo();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          PdfTemplateHelper.buildKopSurat(
            logoBytes: logoBytes,
            fontRegular: fontRegular,
            fontBold: fontBold,
          ),
          // Date Line (right-aligned) - after Kop Surat
          pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 16),
            child: pw.Text(
              '${profile.city}, ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())}',
              style: pw.TextStyle(font: fontRegular, fontSize: 11),
            ),
          ),
          _buildTitle('LAPORAN INVENTARIS BARANG (KIB)', filter, fontBold),
          pw.SizedBox(height: 16),
          _buildInventoryTable(items, fontRegular, fontBold),
          pw.SizedBox(height: 32),
          _buildSigningBlock(profile.signers, fontRegular, fontBold),
        ],
        footer: (context) => _buildFooter(context, fontRegular),
      ),
    );

    return pdf.save();
  }

  /// Generate Mutation Report (Mutasi Aset)
  Future<Uint8List> generateMutationReport({
    required AgencyProfile profile,
    required List<Map<String, dynamic>> items,
    required ReportFilter filter,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();
    
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final logoBytes = await PdfTemplateHelper.loadLogo();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          PdfTemplateHelper.buildKopSurat(
            logoBytes: logoBytes,
            fontRegular: fontRegular,
            fontBold: fontBold,
          ),
          PdfTemplateHelper.buildDateLine(
            city: profile.city, 
            date: DateTime.now(), 
            fontRegular: fontRegular
          ),
          _buildTitle('LAPORAN MUTASI ASET', filter, fontBold),
          pw.SizedBox(height: 16),
          _buildMutationTable(items, fontRegular, fontBold),
          pw.SizedBox(height: 32),
          _buildSigningBlock(profile.signers, fontRegular, fontBold),
        ],
        footer: (context) => _buildFooter(context, fontRegular),
      ),
    );

    return pdf.save();
  }

  /// Generate Disposal Report
  Future<Uint8List> generateDisposalReport({
    required AgencyProfile profile,
    required List<Map<String, dynamic>> items,
    required ReportFilter filter,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();
    
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final logoBytes = await PdfTemplateHelper.loadLogo();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          PdfTemplateHelper.buildKopSurat(
            logoBytes: logoBytes,
            fontRegular: fontRegular,
            fontBold: fontBold,
          ),
          PdfTemplateHelper.buildDateLine(
            city: profile.city, 
            date: DateTime.now(), 
            fontRegular: fontRegular
          ),
          _buildTitle('LAPORAN PENGHAPUSAN BARANG', filter, fontBold),
          pw.SizedBox(height: 16),
          _buildDisposalTable(items, fontRegular, fontBold),
          pw.SizedBox(height: 32),
          _buildSigningBlock(profile.signers, fontRegular, fontBold),
        ],
        footer: (context) => _buildFooter(context, fontRegular),
      ),
    );

    return pdf.save();
  }

  /// Generate Maintenance Report
  Future<Uint8List> generateMaintenanceReport({
    required AgencyProfile profile,
    required List<Map<String, dynamic>> items,
    required ReportFilter filter,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();
    
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final logoBytes = await PdfTemplateHelper.loadLogo();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          PdfTemplateHelper.buildKopSurat(
            logoBytes: logoBytes,
            fontRegular: fontRegular,
            fontBold: fontBold,
          ),
          PdfTemplateHelper.buildDateLine(
            city: profile.city, 
            date: DateTime.now(), 
            fontRegular: fontRegular
          ),
          _buildTitle('RIWAYAT PEMELIHARAAN ASET', filter, fontBold),
          pw.SizedBox(height: 16),
          _buildMaintenanceTable(items, fontRegular, fontBold),
          pw.SizedBox(height: 32),
          _buildSigningBlock(profile.signers, fontRegular, fontBold),
        ],
        footer: (context) => _buildFooter(context, fontRegular),
      ),
    );

    return pdf.save();
  }

  /// Generate Loan Report
  Future<Uint8List> generateLoanReport({
    required AgencyProfile profile,
    required List<Map<String, dynamic>> items,
    required ReportFilter filter,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();
    
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final logoBytes = await PdfTemplateHelper.loadLogo();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          PdfTemplateHelper.buildKopSurat(
            logoBytes: logoBytes,
            fontRegular: fontRegular,
            fontBold: fontBold,
          ),
          PdfTemplateHelper.buildDateLine(
            city: profile.city, 
            date: DateTime.now(), 
            fontRegular: fontRegular
          ),
          _buildTitle('REKAPITULASI PEMINJAMAN ASET', filter, fontBold),
          pw.SizedBox(height: 16),
          _buildLoanTable(items, fontRegular, fontBold),
          pw.SizedBox(height: 32),
          _buildSigningBlock(profile.signers, fontRegular, fontBold),
        ],
        footer: (context) => _buildFooter(context, fontRegular),
      ),
    );

    return pdf.save();
  }

  // ==================== 6. STOCK REPORT (STOK OPNAME) ====================
  Future<Uint8List> generateStockReport({
    required AgencyProfile profile,
    required List<Map<String, dynamic>> items,
    required ReportFilter filter,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final logoBytes = await PdfTemplateHelper.loadLogo();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          PdfTemplateHelper.buildKopSurat(
            logoBytes: logoBytes,
            fontRegular: fontRegular,
            fontBold: fontBold,
          ),
          PdfTemplateHelper.buildDateLine(
            city: profile.city, 
            date: DateTime.now(), 
            fontRegular: fontRegular
          ),
          _buildTitle('LAPORAN KELUAR MASUK BARANG (STOK OPNAME)', filter, fontBold),
          pw.SizedBox(height: 16),
          _buildStockTable(items, fontRegular, fontBold),
          pw.SizedBox(height: 24),
          _buildSigningBlock(profile.signers, fontRegular, fontBold),
        ],
        footer: (context) => _buildFooter(context, fontRegular),
      ),
    );

    return pdf.save();
  }
  
  // ==================== 7. BUDGET REPORT (ANGGARAN) ====================
  Future<Uint8List> generateBudgetReport({
    required AgencyProfile profile,
    required List<Map<String, dynamic>> items,
    required ReportFilter filter,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final logoBytes = await PdfTemplateHelper.loadLogo();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat, 
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          PdfTemplateHelper.buildKopSurat(
            logoBytes: logoBytes,
            fontRegular: fontRegular,
            fontBold: fontBold,
          ),
          PdfTemplateHelper.buildDateLine(
            city: profile.city, 
            date: DateTime.now(), 
            fontRegular: fontRegular
          ),
          _buildTitle('LAPORAN REALISASI ANGGARAN', filter, fontBold),
          pw.SizedBox(height: 16),
          _buildBudgetTable(items, fontRegular, fontBold),
          pw.SizedBox(height: 24),
          _buildSigningBlock(profile.signers, fontRegular, fontBold),
        ],
        footer: (context) => _buildFooter(context, fontRegular),
      ),
    );

    return pdf.save();
  }

  // ==================== 8. EMPLOYEE REPORT (PEGAWAI) ====================
  Future<Uint8List> generateEmployeeReport({
    required AgencyProfile profile,
    required List<Map<String, dynamic>> items,
    required ReportFilter filter,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final logoBytes = await PdfTemplateHelper.loadLogo();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat, 
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          PdfTemplateHelper.buildKopSurat(
            logoBytes: logoBytes,
            fontRegular: fontRegular,
            fontBold: fontBold,
          ),
          PdfTemplateHelper.buildDateLine(
            city: profile.city, 
            date: DateTime.now(), 
            fontRegular: fontRegular
          ),
          _buildTitle('DAFTAR PEGAWAI', filter, fontBold),
          pw.SizedBox(height: 16),
          _buildEmployeeTable(items, fontRegular, fontBold),
          pw.SizedBox(height: 24),
          _buildSigningBlock(profile.signers, fontRegular, fontBold),
        ],
        footer: (context) => _buildFooter(context, fontRegular),
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildEmployeeTable(List<Map<String, dynamic>> items, pw.Font fontRegular, pw.Font fontBold) {
    return pw.Table.fromTextArray(
      headers: ['No', 'NIP', 'Nama Lengkap', 'Jabatan', 'Tipe Pegawai', 'Status'],
      data: List<List<dynamic>>.generate(items.length, (index) {
        final item = items[index];
        return [
          (index + 1).toString(),
          item['nip'] ?? '-',
          item['full_name'] ?? item['fullName'] ?? '-',
          item['position'] ?? '-',
          item['employee_type'] ?? item['employeeType'] ?? '-',
          _getStatusLabel(item['status'] ?? 'active'),
        ];
      }),
      // Plain header - no fill, regular font (not bold)
      headerStyle: pw.TextStyle(font: fontRegular, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(), // No background fill
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignments: {
        0: pw.Alignment.center,
        5: pw.Alignment.center,
      },
      cellAlignments: {
        0: pw.Alignment.center,
        5: pw.Alignment.center,
      },
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),  // No
        1: const pw.FlexColumnWidth(2),    // NIP
        2: const pw.FlexColumnWidth(3),    // Nama
        3: const pw.FlexColumnWidth(2.5),  // Jabatan
        4: const pw.FlexColumnWidth(1.5),  // Tipe
        5: const pw.FixedColumnWidth(50),  // Status
      },
    );
  }

  /// Convert status to Indonesian label
  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'AKTIF';
      case 'inactive':
        return 'NON-AKTIF';
      case 'blacklisted':
        return 'BLACKLIST';
      default:
        return status.toUpperCase();
    }
  }

  // ==================== 9. VENDOR REPORT ====================
  Future<Uint8List> generateVendorReport({
    required AgencyProfile profile,
    required List<Map<String, dynamic>> items,
    required ReportFilter filter,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final logoBytes = await PdfTemplateHelper.loadLogo();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          PdfTemplateHelper.buildKopSurat(
            logoBytes: logoBytes,
            fontRegular: fontRegular,
            fontBold: fontBold,
          ),
          PdfTemplateHelper.buildDateLine(
            city: profile.city,
            date: DateTime.now(),
            fontRegular: fontRegular
          ),
          _buildTitle('DAFTAR VENDOR / PENYEDIA', filter, fontBold),
          pw.SizedBox(height: 16),
          _buildVendorTable(items, fontRegular, fontBold),
          pw.SizedBox(height: 24),
          _buildSigningBlock(profile.signers, fontRegular, fontBold),
        ],
        footer: (context) => _buildFooter(context, fontRegular),
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildVendorTable(List<Map<String, dynamic>> items, pw.Font fontRegular, pw.Font fontBold) {
    return pw.Table.fromTextArray(
      headers: ['No', 'Nama Vendor', 'Kategori', 'Kontak', 'No. Telp', 'Alamat', 'Status'],
      data: List<List<dynamic>>.generate(items.length, (index) {
        final item = items[index];
        return [
          (index + 1).toString(),
          item['name'] ?? '-',
          item['category'] ?? '-',
          item['contact_person'] ?? item['contactPerson'] ?? '-',
          item['phone'] ?? '-',
          item['address'] ?? '-',
          _getStatusLabel(item['status'] ?? 'active'),
        ];
      }),
      // Plain header - no fill, regular font (consistent style)
      headerStyle: pw.TextStyle(font: fontRegular, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(), // No background fill
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignments: {
        0: pw.Alignment.center,
        6: pw.Alignment.center,
      },
      cellAlignments: {
        0: pw.Alignment.center,
        6: pw.Alignment.center,
      },
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
      columnWidths: {
        0: const pw.FixedColumnWidth(25),  // No
        1: const pw.FlexColumnWidth(3),    // Nama Vendor
        2: const pw.FlexColumnWidth(1.5),  // Kategori
        3: const pw.FlexColumnWidth(2),    // Kontak
        4: const pw.FlexColumnWidth(1.5),  // No. Telp
        5: const pw.FlexColumnWidth(2.5),  // Alamat
        6: const pw.FixedColumnWidth(50),  // Status
      },
    );
  }

  // ==================== 10. ORGANIZATION REPORT ====================
  Future<Uint8List> generateOrganizationReport({
    required AgencyProfile profile,
    required List<Map<String, dynamic>> items,
    required ReportFilter filter,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final logoBytes = await PdfTemplateHelper.loadLogo();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          PdfTemplateHelper.buildKopSurat(
            logoBytes: logoBytes,
            fontRegular: fontRegular,
            fontBold: fontBold,
          ),
          PdfTemplateHelper.buildDateLine(
            city: profile.city,
            date: DateTime.now(),
            fontRegular: fontRegular
          ),
          _buildTitle('DAFTAR UNIT ORGANISASI', filter, fontBold),
          pw.SizedBox(height: 16),
          _buildOrganizationTable(items, fontRegular, fontBold),
          pw.SizedBox(height: 24),
          _buildSigningBlock(profile.signers, fontRegular, fontBold),
        ],
        footer: (context) => _buildFooter(context, fontRegular),
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildOrganizationTable(List<Map<String, dynamic>> items, pw.Font fontRegular, pw.Font fontBold) {
    return pw.Table.fromTextArray(
      headers: ['No', 'Kode Unit', 'Nama Unit', 'Tipe'],
      data: List<List<dynamic>>.generate(items.length, (index) {
        final item = items[index];
        return [
          (index + 1).toString(),
          item['code'] ?? '-',
          item['name'] ?? '-',
          item['type'] ?? '-',
        ];
      }),
      // Plain header - no fill, regular font (consistent style)
      headerStyle: pw.TextStyle(font: fontRegular, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(), // No background fill
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignments: {
        0: pw.Alignment.center,
      },
      cellAlignments: {
        0: pw.Alignment.center,
      },
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
      columnWidths: {
        0: const pw.FixedColumnWidth(25),  // No
        1: const pw.FlexColumnWidth(1.5),  // Kode Unit
        2: const pw.FlexColumnWidth(3),    // Nama Unit
        3: const pw.FlexColumnWidth(1.5),  // Tipe
      },
    );
  }

  pw.Widget _buildStockTable(List<Map<String, dynamic>> items, pw.Font fontRegular, pw.Font fontBold) {
    // Custom Table to simulate "Merged Header" for "Barang Masuk-Keluar"
    
    // Header Cell Helper
    pw.Widget headerCell(String text, {double? height}) {
      return pw.Container(
        height: height,
        alignment: pw.Alignment.center, 
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(text, style: pw.TextStyle(font: fontBold, fontSize: 9), textAlign: pw.TextAlign.center),
      );
    }

    // Headers
    final headerRow = pw.TableRow(
      verticalAlignment: pw.TableCellVerticalAlignment.middle, 
      children: [
        headerCell('No'),
        headerCell('Kode'),
        headerCell('Nama Barang'),
        headerCell('Stok Awal'), 
        // Merged Column Header
        pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // Top Part: Title
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              alignment: pw.Alignment.center,
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(width: 0.5, color: PdfColors.black)),
              ),
              child: pw.Text('Pergerakan Barang', style: pw.TextStyle(font: fontBold, fontSize: 9)),
            ),
            // Bottom Part: Masuk | Keluar
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    alignment: pw.Alignment.center,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(right: pw.BorderSide(width: 0.5, color: PdfColors.black)),
                    ),
                    child: pw.Text('Masuk', style: pw.TextStyle(font: fontBold, fontSize: 9)),
                  ),
                ),
                pw.Expanded(
                   child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    alignment: pw.Alignment.center,
                    child: pw.Text('Keluar', style: pw.TextStyle(font: fontBold, fontSize: 9)),
                  ),
                ),
              ],
            ),
          ],
        ),
        headerCell('Stok Akhir'),
        headerCell('Keterangan'),
      ],
    );

    // Data Rows
    final rows = items.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final item = entry.value;
      
      return pw.TableRow(
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          _buildCell(index.toString(), fontRegular, align: pw.TextAlign.center),
          _buildCell(item['code']?.toString() ?? '-', fontRegular, align: pw.TextAlign.center),
          _buildCell(item['name'] ?? '', fontRegular),
          _buildCell(item['initial_stock']?.toString() ?? '0', fontRegular, align: pw.TextAlign.center),
          // Merged Data Cell (Masuk | Keluar)
          pw.Container(
             child: pw.Row(
               children: [
                 pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      alignment: pw.Alignment.center,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(right: pw.BorderSide(width: 0.5, color: PdfColors.black)),
                      ),
                      child: pw.Text(item['in']?.toString() ?? '0', style: pw.TextStyle(font: fontRegular, fontSize: 9), textAlign: pw.TextAlign.center),
                    ),
                 ),
                 pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      alignment: pw.Alignment.center,
                      child: pw.Text(item['out']?.toString() ?? '0', style: pw.TextStyle(font: fontRegular, fontSize: 9), textAlign: pw.TextAlign.center),
                    ),
                 ),
               ],
             ),
          ),
          _buildCell(item['final_stock']?.toString() ?? '0', fontRegular, align: pw.TextAlign.center),
          _buildCell(item['description'] ?? '', fontRegular),
        ],
      );
    }).toList();

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
      columnWidths: {
        0: const pw.FixedColumnWidth(25),  // No
        1: const pw.FixedColumnWidth(55),  // Kode (Widened)
        2: const pw.FlexColumnWidth(2.5),  // Nama Barang (Widened for balance)
        3: const pw.FixedColumnWidth(50),  // Stok Awal
        4: const pw.FixedColumnWidth(90),  // Pergerakan (Masuk+Keluar)
        5: const pw.FixedColumnWidth(50),  // Stok Akhir
        6: const pw.FlexColumnWidth(1.5),  // Keterangan
      },
      children: [
        headerRow,
        ...rows,
      ],
    );
  }

  pw.Widget _buildHeaderCell(String text, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 10), textAlign: pw.TextAlign.center),
    );
  }

  pw.Widget _buildCell(String text, pw.Font font, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 9), textAlign: align),
    );
  }
  
  pw.Widget _buildCellWithoutBorder(String text, pw.Font font, {pw.TextAlign align = pw.TextAlign.left}) {
     return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: align == pw.TextAlign.center ? pw.Alignment.center : pw.Alignment.centerLeft,
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 9), textAlign: align),
    );
  }

  pw.Widget _buildBudgetTable(List<Map<String, dynamic>> items, pw.Font fontRegular, pw.Font fontBold) {
     return pw.Table.fromTextArray(
      headers: ['No', 'Tahun', 'Sumber Dana', 'Pagu Anggaran', 'Realisasi', 'Sisa Anggaran', '%'],
      data: List<List<dynamic>>.generate(items.length, (index) {
        final item = items[index];
        return [
          (index + 1).toString(),
          item['year'] ?? '',
          item['source'] ?? '',
          item['total'] ?? '',
          item['realized'] ?? '',
          item['remaining'] ?? '',
          item['percentage'] ?? '',
        ];
      }),
      // Plain header - no fill, regular font (consistent style)
      headerStyle: pw.TextStyle(font: fontRegular, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(), // No background fill
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.centerRight,
      },
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.centerRight,
      },
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FixedColumnWidth(50),
        2: const pw.FlexColumnWidth(3),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(2),
        5: const pw.FlexColumnWidth(2),
        6: const pw.FixedColumnWidth(40),
      },
    );
  }

  // NOTE: Kop Surat now uses shared PdfTemplateHelper.buildKopSurat for consistency

  /// 2. DOCUMENT TITLE
  pw.Widget _buildTitle(String title, ReportFilter filter, pw.Font fontBold) {
    // If startDate == endDate, show "Per Tanggal" (for master data reports)
    // Otherwise show "Periode: ... s/d ..." (for transactional reports)
    final bool isSingleDate = filter.startDate.year == filter.endDate.year &&
        filter.startDate.month == filter.endDate.month &&
        filter.startDate.day == filter.endDate.day;
    
    final String dateText = isSingleDate
        ? 'Per Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(filter.startDate)}'
        : 'Periode: ${DateFormat('dd MMM yyyy').format(filter.startDate)} s/d ${DateFormat('dd MMM yyyy').format(filter.endDate)}';
    
    return pw.SizedBox(
      width: double.infinity,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(font: fontBold, fontSize: 14),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            dateText,
            style: const pw.TextStyle(fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 3. INVENTORY TABLE
  pw.Widget _buildInventoryTable(
    List<Map<String, dynamic>> items,
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
        item['code']?.toString() ?? '-',
        item['name']?.toString() ?? '-',
        item['nup']?.toString() ?? '-',
        item['brand']?.toString() ?? '-',
        item['year']?.toString() ?? '-',
        item['condition']?.toString() ?? '-',
        item['price']?.toString() ?? '-',
        item['description']?.toString() ?? '-',
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      // Plain header - no fill, regular font (consistent style)
      headerStyle: pw.TextStyle(font: fontRegular, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(), // No background fill
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.center,
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
      columnWidths: {
        0: const pw.FixedColumnWidth(25),  // No
        1: const pw.FixedColumnWidth(70),  // Kode Barang
        2: const pw.FlexColumnWidth(2),    // Nama Barang
        3: const pw.FixedColumnWidth(30),  // NUP
        4: const pw.FixedColumnWidth(50),  // Merk/Type
        5: const pw.FixedColumnWidth(35),  // Tahun
        6: const pw.FixedColumnWidth(55),  // Kondisi
        7: const pw.FixedColumnWidth(70),  // Harga
        8: const pw.FlexColumnWidth(1.5),  // Keterangan - made flexible
      },
    );
  }

  /// 3b. MUTATION TABLE
  pw.Widget _buildMutationTable(
    List<Map<String, dynamic>> items,
    pw.Font fontRegular,
    pw.Font fontBold,
  ) {
    // Define Headers
    final headers = [
      'No',
      'Kode',
      'Tanggal',
      'Nama Aset',
      'Dari',
      'Ke',
      'Pengaju',
      'Status',
    ];

    // Data Rows
    final data = items.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final item = entry.value;
      return [
        index.toString(),
        item['code']?.toString() ?? '-',
        // Parse date safely
        item['date'] != null ? DateFormat('dd/MM/yy').format(DateTime.parse(item['date'])) : '-',
        item['asset_name']?.toString() ?? '-',
        item['origin']?.toString() ?? '-',
        item['destination']?.toString() ?? '-',
        item['requester']?.toString() ?? '-',
        _getStatusLabel(item['status']?.toString() ?? ''),
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(font: fontRegular, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(),
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 8), // Smaller font for many columns
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.center,
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
      columnWidths: {
        0: const pw.FixedColumnWidth(20),  // No
        1: const pw.FixedColumnWidth(60),  // Kode
        2: const pw.FixedColumnWidth(40),  // Tanggal
        3: const pw.FlexColumnWidth(2),    // Aset
        4: const pw.FlexColumnWidth(1.2),  // Dari
        5: const pw.FlexColumnWidth(1.2),  // Ke
        6: const pw.FlexColumnWidth(1.5),  // Pengaju
        7: const pw.FixedColumnWidth(45),  // Status
      },
    );
  }

  /// 4. SIGNING BLOCK - Official format
  /// Format: roleLabel, signature space, underlined name, rank, NIP
  pw.Widget _buildSigningBlock(
    List<AgencySigner> signers,
    pw.Font fontRegular,
    pw.Font fontBold,
  ) {
    if (signers.isEmpty) {
      // Fallback if no signers configured
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('Mengetahui,', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
              pw.SizedBox(height: 50),
              pw.Text('_______________________', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
              pw.Text('Kepala BRIDA', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
            ],
          ),
        ],
      );
    }

    // Use first signer for single signature block (right-aligned)
    final signer = signers.first;
    
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Role Label (e.g., "Kasubbag Umpeg,")
            pw.Text(
              '${signer.roleLabel},',
              style: pw.TextStyle(font: fontRegular, fontSize: 10),
            ),
            pw.SizedBox(height: 8),
            
            // Space for signature image or manual signature
            pw.SizedBox(height: 50),
            
            pw.SizedBox(height: 8),
            
            // Underlined Name
            pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
              ),
              padding: const pw.EdgeInsets.only(bottom: 2),
              child: pw.Text(
                signer.name,
                style: pw.TextStyle(font: fontBold, fontSize: 10),
              ),
            ),
            pw.SizedBox(height: 2),
            
            // Rank (Pangkat/Golongan)
            pw.Text(
              signer.rank,
              style: pw.TextStyle(font: fontRegular, fontSize: 9),
            ),
            
            // NIP
            pw.Text(
              'NIP. ${signer.nip}',
              style: pw.TextStyle(font: fontRegular, fontSize: 9),
            ),
          ],
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
      // Plain header - no fill, regular font (consistent style)
      headerStyle: pw.TextStyle(font: fontRegular, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(), // No background fill
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.center,
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
    );
  }

  /// Helper: Build Maintenance Table
  pw.Widget _buildMaintenanceTable(List<Map<String, dynamic>> items, pw.Font fontRegular, pw.Font fontBold) {
    final headers = <String>['No', 'Tanggal', 'Aset', 'Jenis', 'Deskripsi', 'Teknisi', 'Biaya', 'Status'];
    final data = <List<String>>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final createdAt = item['created_at']?.toString().split('T').first ?? '-';
      final cost = item['cost'] ?? item['estimated_cost'] ?? 0;
      final costStr = cost > 0 ? 'Rp ${cost.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}' : '-';
      
      // Truncate description to max 40 characters
      String desc = item['description']?.toString() ?? item['details']?.toString() ?? '-';
      if (desc.length > 40) desc = '${desc.substring(0, 37)}...';
      
      data.add(<String>[
        (i + 1).toString(),
        createdAt,
        item['assets']?['name']?.toString() ?? item['asset_name']?.toString() ?? '-',
        item['type']?.toString() ?? item['maintenance_type']?.toString() ?? '-',
        desc,
        item['assigned_to_user']?['display_name']?.toString() ?? item['technician']?.toString() ?? '-',
        costStr,
        item['status']?.toString() ?? '-',
      ]);
    }
    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      // Plain header - no fill, regular font (consistent style)
      headerStyle: pw.TextStyle(font: fontRegular, fontSize: 9),
      headerDecoration: const pw.BoxDecoration(), // No background fill
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 8),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.center,
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
      columnWidths: {
        0: const pw.FixedColumnWidth(20),   // No
        1: const pw.FixedColumnWidth(50),   // Tanggal
        2: const pw.FlexColumnWidth(1.5),   // Aset
        3: const pw.FixedColumnWidth(50),   // Jenis
        4: const pw.FlexColumnWidth(2),     // Deskripsi
        5: const pw.FlexColumnWidth(1.2),   // Teknisi
        6: const pw.FixedColumnWidth(55),   // Biaya
        7: const pw.FixedColumnWidth(45),   // Status
      },
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
      // Plain header - no fill, regular font (consistent style)
      headerStyle: pw.TextStyle(font: fontRegular, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(), // No background fill
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.center,
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
    );
  }
}
