// lib/services/inventory_export_service.dart
// Inventory-specific export service for Excel and CSV

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../models/inventory_item.dart';

class InventoryExportService {
  /// Export inventory to Excel format
  Future<String> exportToExcel({
    required List<InventoryItem> items,
    required String fileName,
  }) async {
    final excel = Excel.createExcel();

    // Remove default sheet
    excel.delete('Sheet1');

    // Create Inventory sheet
    final sheet = excel['Inventory Data'];

    // Add title
    _addTitle(sheet, 'Data Inventaris CleanOffice');

    // Add headers
    final headers = [
      'No',
      'Nama Item',
      'Kategori',
      'Stok Saat Ini',
      'Min Stock',
      'Max Stock',
      'Unit',
      'Status',
      'Persentase',
      'Deskripsi',
      'Dibuat',
      'Diupdate',
    ];

    _addHeaders(sheet, headers, startRow: 3);

    // Add data rows
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final rowIndex = i + 4;

      final rowData = [
        (i + 1).toString(),
        item.name,
        _formatCategory(item.category),
        item.currentStock.toString(),
        item.minStock.toString(),
        item.maxStock.toString(),
        item.unit,
        item.statusLabel,
        '${item.stockPercentage.toStringAsFixed(1)}%',
        item.description ?? '-',
        DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt),
        DateFormat('dd/MM/yyyy HH:mm').format(item.updatedAt),
      ];

      for (var colIndex = 0; colIndex < rowData.length; colIndex++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex),
        );
        cell.value = TextCellValue(rowData[colIndex]);

        // Apply conditional formatting for status column
        if (colIndex == 7) {
          cell.cellStyle = _getStatusCellStyle(item.status);
        }
      }
    }

    // Set column widths
    final widths = [5, 25, 15, 12, 12, 12, 8, 15, 12, 30, 18, 18];
    for (var i = 0; i < widths.length; i++) {
      sheet.setColumnWidth(i, widths[i].toDouble());
    }

    // Generate and save file
    final bytes = excel.encode();
    return await _saveAndShareFile(
      bytes: Uint8List.fromList(bytes!),
      fileName: '$fileName.xlsx',
      mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  /// Export inventory to CSV format
  Future<String> exportToCsv({
    required List<InventoryItem> items,
    required String fileName,
  }) async {
    final buffer = StringBuffer();

    // Add headers
    final headers = [
      'No',
      'Nama Item',
      'Kategori',
      'Stok Saat Ini',
      'Min Stock',
      'Max Stock',
      'Unit',
      'Status',
      'Persentase',
      'Deskripsi',
      'Dibuat',
      'Diupdate',
    ];

    buffer.writeln(headers.map(_escapeCsv).join(','));

    // Add data rows
    for (var i = 0; i < items.length; i++) {
      final item = items[i];

      final rowData = [
        (i + 1).toString(),
        item.name,
        _formatCategory(item.category),
        item.currentStock.toString(),
        item.minStock.toString(),
        item.maxStock.toString(),
        item.unit,
        item.statusLabel,
        '${item.stockPercentage.toStringAsFixed(1)}%',
        item.description ?? '-',
        DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt),
        DateFormat('dd/MM/yyyy HH:mm').format(item.updatedAt),
      ];

      buffer.writeln(rowData.map(_escapeCsv).join(','));
    }

    // Convert to bytes and save
    final bytes = Uint8List.fromList(utf8.encode(buffer.toString()));
    return await _saveAndShareFile(
      bytes: bytes,
      fileName: '$fileName.csv',
      mimeType: 'text/csv',
    );
  }

  // ==================== HELPER METHODS ====================

  void _addTitle(Sheet sheet, String title) {
    final cell = sheet.cell(CellIndex.indexByString('A1'));
    cell.value = TextCellValue(title);
    cell.cellStyle = CellStyle(
      bold: true,
      fontSize: 16,
      fontColorHex: ExcelColor.blue,
    );
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('D1'));

    // Add date
    final dateCell = sheet.cell(CellIndex.indexByString('A2'));
    dateCell.value = TextCellValue(
      'Digenerate: ${DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now())}',
    );
    dateCell.cellStyle = CellStyle(fontSize: 11);
  }

  void _addHeaders(Sheet sheet, List<String> headers, {required int startRow}) {
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: startRow),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.blue,
        fontColorHex: ExcelColor.white,
      );
    }
  }

  CellStyle _getStatusCellStyle(StockStatus status) {
    ExcelColor backgroundColor;
    ExcelColor fontColor;

    switch (status) {
      case StockStatus.inStock:
        backgroundColor = ExcelColor.green;
        fontColor = ExcelColor.white;
        break;
      case StockStatus.mediumStock:
        backgroundColor = ExcelColor.blue;
        fontColor = ExcelColor.white;
        break;
      case StockStatus.lowStock:
        backgroundColor = ExcelColor.yellow;
        fontColor = ExcelColor.black;
        break;
      case StockStatus.outOfStock:
        backgroundColor = ExcelColor.red;
        fontColor = ExcelColor.white;
        break;
    }

    return CellStyle(
      bold: true,
      backgroundColorHex: backgroundColor,
      fontColorHex: fontColor,
    );
  }

  String _formatCategory(String category) {
    switch (category.toLowerCase()) {
      case 'alat':
        return 'Alat';
      case 'consumable':
        return 'Consumable';
      case 'ppe':
        return 'PPE';
      default:
        return category.toUpperCase();
    }
  }

  String _escapeCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  Future<String> _saveAndShareFile({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      // Get downloads directory for Android/external storage
      Directory? directory;

      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Tidak dapat mengakses direktori penyimpanan');
      }

      // Create Downloads/CleanOffice folder
      final downloadsPath = '${directory.path}/CleanOffice';
      final downloadsDir = Directory(downloadsPath);

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Write file
      final filePath = '$downloadsPath/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      throw Exception('Gagal menyimpan file: $e');
    }
  }
}

