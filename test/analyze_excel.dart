import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:excel/excel.dart';

void main() {
  test('Analyze Receipt Excel File', () {
    final file = File('assets/kuitansi GANTI OLI 665.xlsx');
    
    if (!file.existsSync()) {
      fail('File not found at ${file.path}');
    }

    try {
      final bytes = file.readAsBytesSync();
      // Use excel: ^4.0.0 syntax
      final excel = Excel.decodeBytes(bytes);

      print('\n=== EXCEL ANALYSIS OUTPUT ===');
      for (var table in excel.tables.keys) {
        print("\n--- Sheet: $table ---");
        var sheet = excel.tables[table]!;
        print('Dimensions: ${sheet.maxRows} rows x ${sheet.maxColumns} cols');

        for (var row in sheet.rows) {
          for (var cell in row) {
            if (cell != null && cell.value != null) {
               var val = cell.value.toString().trim();
               if (val.isNotEmpty) {
                   // Clean output for easy parsing
                   print('[${cell.cellIndex.rowIndex},${cell.cellIndex.columnIndex}] "$val"');
               }
            }
          }
        }
      }
      print('=== END ANALYSIS ===\n');

    } catch (e, stack) {
      print('Error parsing Excel: $e');
      print(stack);
      fail('Exception during parsing');
    }
  });
}
