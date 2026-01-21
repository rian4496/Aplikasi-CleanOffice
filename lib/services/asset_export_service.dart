import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/asset.dart';
import '../models/agency_profile.dart';
import '../utils/pdf_template_helper.dart';
import '../widgets/sim_aset/pdf_preview_dialog.dart';

// Conditional import for web download
import 'web_download_stub.dart' if (dart.library.html) 'web_download_web.dart' as web_download;

class AssetExportService {
  /// Export assets to PDF and open print dialog
  /// [options] - Export options for orientation and photo inclusion
  /// [signer] - Optional signer data for signature block
  /// [city] - City name for date line (default: Banjarbaru)
  static Future<void> exportToPdf(
    BuildContext context,
    List<Asset> assets, {
    List<dynamic>? categories,
    List<dynamic>? locations,
    bool isLandscape = true,
    bool includePhoto = false,
    AgencySigner? signer,
    String city = 'Banjarbaru',
  }) async {
    final pdf = pw.Document();

    // Create lookup maps for category and location resolution
    final categoryMap = <String, String>{};
    if (categories != null) {
      for (final cat in categories) {
        categoryMap[cat.id] = cat.name;
      }
    }
    final locationMap = <String, String>{};
    if (locations != null) {
      for (final loc in locations) {
        locationMap[loc.id] = loc.name;
      }
    }

    // Load fonts for Kop Surat (keep Roboto as original)
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    
    // Load Noto Sans fonts for letter content (isi surat)
    final contentFontRegular = await PdfGoogleFonts.notoSansRegular();
    final contentFontBold = await PdfGoogleFonts.notoSansBold();
    
    // Load Times New Roman-like font for BRIDA title
    final bridaTitleFont = await PdfGoogleFonts.notoSerifBold();
    
    final logoBytes = await PdfTemplateHelper.loadLogo();

    // Pre-load images if needed
    Map<String, pw.MemoryImage?> assetImages = {};
    if (includePhoto) {
      for (final asset in assets) {
        if (asset.imageUrl != null && asset.imageUrl!.isNotEmpty) {
          try {
            final imageBytes = await _downloadImage(asset.imageUrl!);
            if (imageBytes != null) {
              assetImages[asset.id] = pw.MemoryImage(imageBytes);
            }
          } catch (_) {
            // Ignore failed downloads
          }
        }
      }
    }

    // Load signature image if signer provided
    pw.MemoryImage? signatureImage;
    if (signer?.signatureUrl != null) {
      signatureImage = await PdfTemplateHelper.loadSignatureImage(signer!.signatureUrl);
    }

    // Determine page format
    final pageFormat = isLandscape 
        ? PdfPageFormat.a4.landscape 
        : PdfPageFormat.a4;

    // Add header
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(20),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Kop Surat - Noto Sans, except BRIDA title (Roboto)
            PdfTemplateHelper.buildKopSurat(
              logoBytes: logoBytes,
              fontRegular: contentFontRegular,
              fontBold: contentFontBold,
              fontBridaTitle: bridaTitleFont, // Times New Roman-like for BRIDA title
            ),
            // Date Line (right-aligned) - uses Noto Sans
            PdfTemplateHelper.buildDateLine(
              city: city,
              date: DateTime.now(),
              fontRegular: contentFontRegular,
            ),
            pw.SizedBox(height: 16),
            // Title
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'LAPORAN INVENTARIS BARANG (KIB)',
                    style: pw.TextStyle(
                      font: contentFontBold,
                      fontSize: 14,
                    ),
                  ),
                  pw.Text(
                    'Periode: ${DateTime.now().year}',
                    style: pw.TextStyle(
                      font: contentFontRegular,
                      fontSize: 10,
                    ),
                  ),
                ],
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
          includePhoto 
              ? _buildPdfTableWithPhoto(assets, assetImages, categoryMap, locationMap)
              : _buildPdfTable(assets, categoryMap, locationMap),
          pw.SizedBox(height: 30),
          // Signature Block
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              signer != null 
                ? PdfTemplateHelper.buildSignatureBlock(
                    roleLabel: signer.roleLabel,
                    name: signer.name,
                    nip: signer.nip,
                    position: signer.position,
                    rank: signer.rank,
                    signatureImage: signatureImage,
                    fontRegular: contentFontRegular,
                    fontBold: contentFontBold,
                  )
                : pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Mengetahui,', style: pw.TextStyle(font: contentFontRegular, fontSize: 10)),
                      pw.SizedBox(height: 50),
                      pw.Text('_______________________', style: pw.TextStyle(font: contentFontRegular, fontSize: 10)),
                      pw.Text('Kepala BRIDA', style: pw.TextStyle(font: contentFontRegular, fontSize: 10)),
                    ],
                  ),
            ],
          ),
        ],
      ),
    );

    // Show custom scrollable preview dialog
    final pdfBytes = await pdf.save();
    if (context.mounted) {
      await showPdfPreviewDialog(
        context: context,
        pdfGenerator: () async => pdfBytes,
        title: 'Preview - Laporan Inventaris Barang',
        fileName: 'Laporan_KIB_BRIDA_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }

  /// Download image from URL
  static Future<Uint8List?> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static pw.Widget _buildPdfTable(
    List<Asset> assets,
    Map<String, String> categoryMap,
    Map<String, String> locationMap,
  ) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
      cellAlignment: pw.Alignment.centerLeft,
      headers: [
        'No',
        'Nama Aset',
        'Kategori',
        'Lokasi',
        'Kondisi',
        'Status',
      ],
      data: assets.asMap().entries.map((entry) {
        final i = entry.key;
        final a = entry.value;
        // Resolve category and location by ID
        final categoryName = categoryMap[a.categoryId] ?? a.category;
        final locationName = locationMap[a.locationId] ?? a.locationName ?? '-';
        return [
          '${i + 1}',
          a.name,
          categoryName,
          locationName,
          a.condition.displayName,
          a.status.displayName,
        ];
      }).toList(),
    );
  }

  /// Build PDF table with photo column
  static pw.Widget _buildPdfTableWithPhoto(
    List<Asset> assets,
    Map<String, pw.MemoryImage?> assetImages,
    Map<String, String> categoryMap,
    Map<String, String> locationMap,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FixedColumnWidth(20),  // No - smaller
        1: const pw.FixedColumnWidth(45),  // Foto - smaller
        2: const pw.FlexColumnWidth(2.5),  // Nama
        3: const pw.FlexColumnWidth(1.5),  // Kategori
        4: const pw.FlexColumnWidth(1.5),  // Lokasi
        5: const pw.FlexColumnWidth(1),    // Kondisi
        6: const pw.FlexColumnWidth(0.8),  // Status
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _headerCell('No'),
            _headerCell('Foto'),
            _headerCell('Nama Aset'),
            _headerCell('Kategori'),
            _headerCell('Lokasi'),
            _headerCell('Kondisi'),
            _headerCell('Status'),
          ],
        ),
        // Data rows
        ...assets.asMap().entries.map((entry) {
          final i = entry.key;
          final a = entry.value;
          final image = assetImages[a.id];
          // Resolve category and location by ID
          final categoryName = categoryMap[a.categoryId] ?? a.category;
          final locationName = locationMap[a.locationId] ?? a.locationName ?? '-';
          
          return pw.TableRow(
            children: [
              _dataCell('${i + 1}'),
              pw.Container(
                padding: const pw.EdgeInsets.all(2),
                height: 40,
                alignment: pw.Alignment.center,
                child: image != null
                    ? pw.Image(image, fit: pw.BoxFit.contain, height: 35)
                    : pw.Text('-', style: const pw.TextStyle(fontSize: 7)),
              ),
              _dataCell(a.name),
              _dataCell(categoryName),
              _dataCell(locationName),
              _dataCell(a.condition.displayName),
              _dataCell(a.status.displayName),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _headerCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _dataCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 8)),
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
