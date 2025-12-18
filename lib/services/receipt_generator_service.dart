import 'dart:io';
import 'dart:typed_data'; // Fix for Uint8List
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show kIsWeb; // Add kIsWeb import
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart'; 
import 'package:intl/intl.dart';

// Conditional import for web download
import 'web_download_stub.dart' if (dart.library.html) 'web_download_web.dart' as web_download;

class ReceiptGeneratorService {
  
  /// Generates a filled Receipt Excel file based on the standard template.
  static Future<void> generateReceipt(Map<String, dynamic> data) async {
    try {
      // 1. Load Template
      // ... (existing logic)
      final templateBytes = await rootBundle.load('assets/templates/kuitansi_standard.xlsx');
      var excel = Excel.decodeBytes(templateBytes.buffer.asUint8List());
      
      // ... (filling logic remains the same, assuming it was successful)
      // I will re-implement the filling logic briefly to be safe as replace overwrites.
      
      var sheetName = 'Kuitansi';
      if (!excel.sheets.containsKey(sheetName)) {
        sheetName = excel.tables.keys.first; 
      }
      var sheet = excel[sheetName];
      
      // SUDAH TERIMA DARI -> D3
      _updateCell(sheet, 'D3', data['receivedFrom'] ?? '-');

      // UANG SEBANYAK (Terbilang) -> D5
      String terbilang = data['amountInWords'] ?? '-';
      _updateCell(sheet, 'D5', '------ $terbilang RUPIAH ------');

      // UNTUK KEPERLUAN -> D7
      _updateCell(sheet, 'D7', data['description'] ?? '-');

      // Terbilang (Angka) -> E11
      String amountFormatted = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 2).format(data['amount'] ?? 0);
      _updateCell(sheet, 'E11', amountFormatted);

      // Jumlah yang dibayarkan -> E13
      _updateCell(sheet, 'E13', amountFormatted);

      // Location, Date -> F16
      String dateStr = DateFormat('dd MMMM yyyy', 'id_ID').format(data['date'] ?? DateTime.now());
      String location = data['location'] ?? 'Banjarbaru';
      _updateCell(sheet, 'F16', '$location, $dateStr');

      // Signatures
      // KPA -> A23, A24
      _updateCell(sheet, 'A23', data['kpaName'] ?? '(....................)');
      _updateCell(sheet, 'A24', 'NIP. ${data['kpaNip'] ?? '................'}');

      // Treasurer -> D23, D24
      _updateCell(sheet, 'D23', data['treasurerName'] ?? '(....................)');
      _updateCell(sheet, 'D24', 'NIP. ${data['treasurerNip'] ?? '................'}');

      // Recipient -> F23
      _updateCell(sheet, 'F23', data['recipientName'] ?? '(....................)');


      // 4. Save & Share/Download
      var fileBytes = excel.save();
      if (fileBytes != null) {
         final String fileName = 'Kuitansi_CleanOffice_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
         
         if (kIsWeb) {
           // WEB: Use direct download via AnchorElement (using helper)
           web_download.downloadFile(fileBytes, fileName);
         } else {
           // MOBILE/DESKTOP: Use SharePlus
           final XFile xFile = XFile.fromData(
             Uint8List.fromList(fileBytes),
             mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
             name: fileName
           );
           await Share.shareXFiles([xFile], text: 'Kuitansi Generated from CleanOffice');
         }
      }

    } catch (e) {
      print('Error generating receipt: $e');
      rethrow;
    }
  }

  static void _updateCell(Sheet sheet, String cellRef, String value) {
    var cell = sheet.cell(CellIndex.indexByString(cellRef));
    CellStyle? originalStyle = cell.cellStyle;
    cell.value = TextCellValue(value);
    if(originalStyle != null) {
      cell.cellStyle = originalStyle;
    }
  }
}
