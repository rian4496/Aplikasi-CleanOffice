// lib/services/csv_generator_service.dart
// Simple CSV generator

import 'dart:convert';
import 'dart:typed_data';

import '../models/export_config.dart';

class CsvGeneratorService {
  /// Generate CSV file
  Future<Uint8List> generateCsv(
    ReportData data,
    ExportConfig config,
  ) async {
    final buffer = StringBuffer();
    
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
    
    buffer.writeln(headers.map(_escapeCsv).join(','));
    
    // Data rows
    for (var i = 0; i < data.items.length; i++) {
      final item = data.items[i];
      
      final row = [
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
      
      buffer.writeln(row.map((e) => _escapeCsv(e.toString())).join(','));
    }
    
    // Convert to UTF-8 bytes
    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }

  /// Escape CSV field (handle commas, quotes, newlines)
  String _escapeCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
