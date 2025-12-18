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
  static pw.Widget buildKopSurat({
    required Uint8List logoBytes, 
    required pw.Font fontRegular, 
    required pw.Font fontBold
  }) {
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
                  pw.Text(
                    'BADAN RISET DAN INOVASI DAERAH',
                    style: pw.TextStyle(font: fontRegular, fontSize: 18), // Regular font, uppercase implied by text
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Jalan Dharma Praja I, Komplek Perkantoran Pemerintah Provinsi Kalimantan Selatan Banjarbaru\nE-mail: brida.kalsel@gmail.com',
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
}
