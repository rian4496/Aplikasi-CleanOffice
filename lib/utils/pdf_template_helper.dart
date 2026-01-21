import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class PdfTemplateHelper {
  
  /// Downloads the official logo or returns a placeholder
  /// Downloads the official logo or returns a placeholder
  static Future<Uint8List> loadLogo() async {
    try {
      // 1. Try Local Asset first (Fast & Efficient)
      return (await rootBundle.load('assets/images/logo-pemprov-kalsel.png')).buffer.asUint8List();
    } catch (_) {
      try {
        // 2. Fallback to Network
        final response = await http.get(Uri.parse('https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/Coat_of_arms_of_South_Kalimantan.svg/1200px-Coat_of_arms_of_South_Kalimantan.svg.png'));
        if (response.statusCode == 200) {
          return response.bodyBytes;
        }
      } catch (e) {
        // Ignore
      }
    }
    // Return transparent or placeholder if failed
    return Uint8List(0);
  }

  /// Builds the "Kop Surat" header widget
  /// [fontBridaTitle] - Font for "BADAN RISET DAN INOVASI DAERAH" (keep Roboto)
  /// [fontRegular], [fontBold] - Font for other kop surat text (Noto Sans)
  static pw.Widget buildKopSurat({
    required Uint8List logoBytes, 
    required pw.Font fontRegular, 
    required pw.Font fontBold,
    pw.Font? fontBridaTitle, // Optional: separate font for BRIDA title
  }) {
    // Use fontBridaTitle if provided, otherwise fallback to fontRegular
    final bridaTitleFont = fontBridaTitle ?? fontRegular;
    
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Logo
            if (logoBytes.isNotEmpty)
              pw.Container(
                width: 70,
                height: 80,
                child: pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.contain),
              ),
            
            pw.SizedBox(width: 20),
            
            // Text Header
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'PEMERINTAH PROVINSI KALIMANTAN SELATAN',
                    style: pw.TextStyle(font: fontBold, fontSize: 16),
                    textAlign: pw.TextAlign.center,
                  ),
                   pw.SizedBox(height: 4),
                  // BRIDA title - Times New Roman (official style)
                  pw.Text(
                    'BADAN RISET DAN INOVASI DAERAH',
                    style: pw.TextStyle(font: pw.Font.times(), fontSize: 18),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Jl. Dharma Praja I, Komplek Perkantoran Pemerintah Provinsi Kalimantan Selatan\nE-mail: brida.kalsel@gmail.com',
                    style: pw.TextStyle(font: fontRegular, fontSize: 10),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        // Thick Double Line
        pw.Container(
          height: 3,
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.black, width: 3), // Main thick line
            ),
          ),
        ),
         pw.Container(
          height: 1, // Detailed thin line below
           margin: const pw.EdgeInsets.only(top: 1),
          color: PdfColors.black,
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  /// Builds an official-style signature block for PDF reports
  /// Format:
  /// Role Label (e.g., "Kepala Badan,")
  /// [Signature Image]
  /// Full Name (underlined)
  /// Rank
  /// NIP. xxxx
  /// 
  /// NOTE: City and date should be placed at top-right of letter separately,
  /// use buildDateLine() for that.
  static pw.Widget buildSignatureBlock({
    required String roleLabel,
    required String name,
    required String nip,
    required String position,
    required String rank,
    pw.MemoryImage? signatureImage,
    required pw.Font fontRegular,
    required pw.Font fontBold,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Role Label (e.g., "Kepala Badan,", "Kasubbag Umpeg,")
        pw.Text(
          '$roleLabel,',
          style: pw.TextStyle(font: fontRegular, fontSize: 10),
        ),
        pw.SizedBox(height: 8),
        
        // Signature Image (or space for manual signature)
        if (signatureImage != null)
          pw.Container(
            width: 80,
            height: 50,
            child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
          )
        else
          pw.SizedBox(height: 50), // Space for manual signature
        
        pw.SizedBox(height: 8),
        
        // Underlined Name
        pw.Container(
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
          ),
          padding: const pw.EdgeInsets.only(bottom: 2),
          child: pw.Text(
            name,
            style: pw.TextStyle(font: fontBold, fontSize: 10),
          ),
        ),
        pw.SizedBox(height: 2),
        
        // Rank (Pangkat/Golongan)
        pw.Text(
          rank,
          style: pw.TextStyle(font: fontRegular, fontSize: 9),
        ),
        
        // NIP
        pw.Text(
          'NIP. $nip',
          style: pw.TextStyle(font: fontRegular, fontSize: 9),
        ),
      ],
    );
  }

  /// Builds the date line for official letters (placed at top-right after Kop Surat)
  /// Format: "Banjarbaru, 01 Januari 2026"
  static pw.Widget buildDateLine({
    required String city,
    required DateTime date,
    required pw.Font fontRegular,
  }) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        '$city, ${_formatIndonesianDate(date)}',
        style: pw.TextStyle(font: fontRegular, fontSize: 10),
      ),
    );
  }

  /// Format date to Indonesian format
  static String _formatIndonesianDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Download signature image from URL
  static Future<pw.MemoryImage?> loadSignatureImage(String? url) async {
    if (url == null || url.isEmpty) return null;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return pw.MemoryImage(response.bodyBytes);
      }
    } catch (_) {}
    return null;
  }
}
