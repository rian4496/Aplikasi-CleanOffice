// lib/services/excel_generator_service.dart
// Excel generator with formatting

import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

import '../models/export_config.dart';

class ExcelGeneratorService {
  /// Generate Excel report with formatting
  Future<Uint8List> generateExcel(
    ReportData data,
    ExportConfig config,
  ) async {
    final excel = Excel.createExcel();
    
    // Remove default sheet
    excel.delete('Sheet1');
    
    // Create Summary sheet
    _createSummarySheet(excel, data);
    
    // Create Details sheet
    _createDetailsSheet(excel, data);
    
    // Generate bytes
    final bytes = excel.encode();
    return Uint8List.fromList(bytes!);
  }

  /// Create summary sheet
  void _createSummarySheet(Excel excel, ReportData data) {
    final sheet = excel['Ringkasan'];
    
    // Title
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('CleanOffice - ${data.title}');
    sheet.cell(CellIndex.indexByString('A1')).cellStyle = CellStyle(
      bold: true,
      fontSize: 16,
      fontColorHex: ExcelColor.blue,
    );
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('D1'));

    // Subtitle
    sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue(data.subtitle);
    sheet.cell(CellIndex.indexByString('A2')).cellStyle = CellStyle(
      fontSize: 12,
      fontColorHex: ExcelColor.black,
    );
    
    // Generated date
    sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue(
      'Digenerate: ${DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(data.generatedAt)}'
    );
    
    // Empty row
    int currentRow = 5;
    
    // Summary statistics header
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow)).value =
        TextCellValue('RINGKASAN STATISTIK');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow)).cellStyle = CellStyle(
      bold: true,
      fontSize: 14,
      backgroundColorHex: ExcelColor.blue,
      fontColorHex: ExcelColor.white,
    );
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow),
    );
    
    currentRow += 2;
    
    // Statistics
    final summary = data.summary;
    final stats = [
      ['Total Laporan', '${summary['total']}'],
      ['Selesai', '${summary['completed']}'],
      ['Pending', '${summary['pending']}'],
      ['Urgent', '${summary['urgent']}'],
      ['Tingkat Penyelesaian', '${(summary['completionRate'] as double).toStringAsFixed(1)}%'],
    ];
    
    for (var stat in stats) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow)).value = 
          TextCellValue(stat[0]);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow)).cellStyle = 
          CellStyle(bold: true);
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow)).value = 
          TextCellValue(stat[1]);
      
      currentRow++;
    }
    
    // Set column widths
    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 15);
  }

  /// Create details sheet
  void _createDetailsSheet(Excel excel, ReportData data) {
    final sheet = excel['Detail Laporan'];
    
    // Headers
    final headers = [
      'No',
      'Lokasi',
      'Deskripsi',
      'Status',
      'Urgent',
      'Tanggal',
      'User',
      'Cleaner',
      'Selesai',
    ];
    
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.blue,
        fontColorHex: ExcelColor.white,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
    }
    
    // Data rows
    for (var i = 0; i < data.items.length; i++) {
      final item = data.items[i];
      final rowIndex = i + 1;
      
      final rowData = [
        '${i + 1}',
        item['location'] ?? '-',
        item['description'] ?? '-',
        item['status'] ?? '-',
        item['urgent'] ?? 'Tidak',
        item['date'] ?? '-',
        item['userName'] ?? '-',
        item['cleanerName'] ?? '-',
        item['completedAt'] ?? '-',
      ];
      
      for (var j = 0; j < rowData.length; j++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex));
        cell.value = TextCellValue(rowData[j]);
        
        // Apply styling
        if (rowIndex % 2 == 0) {
          cell.cellStyle = CellStyle(
            backgroundColorHex: ExcelColor.fromHexString('#F0F0F0'),
          );
        }
      }
    }
    
    // Set column widths
    sheet.setColumnWidth(0, 5);   // No
    sheet.setColumnWidth(1, 20);  // Lokasi
    sheet.setColumnWidth(2, 35);  // Deskripsi
    sheet.setColumnWidth(3, 12);  // Status
    sheet.setColumnWidth(4, 8);   // Urgent
    sheet.setColumnWidth(5, 18);  // Tanggal
    sheet.setColumnWidth(6, 18);  // User
    sheet.setColumnWidth(7, 18);  // Cleaner
    sheet.setColumnWidth(8, 18);  // Selesai
    
    // Freeze first row
    sheet.setRowHeight(0, 25);
  }
}
