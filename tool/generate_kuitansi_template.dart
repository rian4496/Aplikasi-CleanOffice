import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  var excel = Excel.createExcel();
  
  // Remove default sheet
  if (excel.sheets.containsKey('Sheet1')) {
    excel.delete('Sheet1');
  }
  
  Sheet sheet = excel['Kuitansi'];
  
  // Helper to set cell value and style
  void setCell(String cellRef, dynamic value, {bool bold = false, bool center = false, int fontSize = 12, bool underline = false}) {
    var cell = sheet.cell(CellIndex.indexByString(cellRef));
    cell.value = TextCellValue(value.toString());
    
    CellStyle style = CellStyle(
      fontFamily: getFontFamily(FontFamily.Arial),
      fontSize: fontSize,
      bold: bold,
      underline: underline ? Underline.Single : Underline.None,
      horizontalAlign: center ? HorizontalAlign.Center : HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );
    cell.cellStyle = style;
  }

  // --- COLUMN WIDTHS ---
  // A: Labels (e.g. "Jumlah yang dibayarkan") -> Width ~25
  sheet.setColumnWidth(0, 25.0); 
  // B: Empty spacer -> Width ~2
  sheet.setColumnWidth(1, 2.0);
  // C: Colon ":" -> Width ~2
  sheet.setColumnWidth(2, 2.0);
  // D: Main Content -> Width ~60
  sheet.setColumnWidth(3, 60.0);
  // E: Content Continuation / Amount -> Width ~20
  sheet.setColumnWidth(4, 20.0);

  // --- HEADER ---
  setCell('A1', 'KWITANSI', bold: true, center: true, fontSize: 16, underline: true);
  sheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("F1")); // Merge Title
  
  // Row 3: SUDAH TERIMA DARI
  setCell('A3', 'SUDAH TERIMA DARI');
  setCell('C3', ':');
  setCell('D3', '[Nama Pengirim / Instansi]', bold: false); 
  sheet.merge(CellIndex.indexByString("D3"), CellIndex.indexByString("F3")); // Merge Content

  // Row 5: UANG SEBANYAK
  setCell('A5', 'UANG SEBANYAK');
  setCell('C5', ':');
  setCell('D5', '------ [TERBILANG RUPIAH] ------', bold: true, center: true); 
  sheet.merge(CellIndex.indexByString("D5"), CellIndex.indexByString("F5")); // Merge Content

  // Row 7: UNTUK KEPERLUAN
  setCell('A7', 'UNTUK KEPERLUAN');
  setCell('C7', ':');
  // Enable wrap text for description
  var descCell = sheet.cell(CellIndex.indexByString("D7"));
  descCell.value = TextCellValue('[Deskripsi Keperluan Pembayaran]');
  descCell.cellStyle = CellStyle(
    fontFamily: getFontFamily(FontFamily.Arial),
    fontSize: 12,
    verticalAlign: VerticalAlign.Top,
    textWrapping: TextWrapping.WrapText,
  );
  sheet.merge(CellIndex.indexByString("D7"), CellIndex.indexByString("F9")); // Merge 3 rows down for description space

  // Row 11: Terbilang
  setCell('A11', 'Terbilang');
  setCell('C11', ':');
  setCell('D11', 'Rp.');
  setCell('E11', '850.000,00', bold: true); // Example

  // Row 13: Jumlah yang dibayarkan
  setCell('A13', 'Jumlah yang dibayarkan', bold: true);
  setCell('C13', ':');
  setCell('D13', 'Rp.', bold: true);
  setCell('E13', '850.000,00', bold: true); // Example

  // --- FOOTER (SIGNATURES) ---
  // Row 16: City, Date
  setCell('F16', 'Banjarbaru, [Tanggal]', center: true);

  // Row 18: Titles (Merge 2 columns each for breathing room)
  // KPA (A-B)
  setCell('A18', 'Mengetahui/menyetujui', center: true);
  sheet.merge(CellIndex.indexByString("A18"), CellIndex.indexByString("B18"));
  setCell('A19', 'Kuasa Pengguna Anggaran', center: true);
  sheet.merge(CellIndex.indexByString("A19"), CellIndex.indexByString("B19"));

  // Bendahara (C-D)
  setCell('D18', 'Lunas dibayar', center: true); 
  // sheet.merge(CellIndex.indexByString("D18"), CellIndex.indexByString("E18")); // Might conflict with F
  setCell('D19', 'Bendahara Pengeluaran', center: true);

  // Penerima (F)
  setCell('F18', 'Yang Menerima', center: true);

  // Row 23: Names
  // KPA
  setCell('A23', '[Nama KPA]', bold: true, underline: true, center: true);
  sheet.merge(CellIndex.indexByString("A23"), CellIndex.indexByString("B23"));
  setCell('A24', 'NIP. [NIP KPA]', center: true);
  sheet.merge(CellIndex.indexByString("A24"), CellIndex.indexByString("B24"));

  // Bendahara
  setCell('D23', '[Nama Bendahara]', bold: true, underline: true, center: true);
  setCell('D24', 'NIP. [NIP Bendahara]', center: true);

  // Penerima
  setCell('F23', '[Nama Penerima]', bold: true, underline: true, center: true);
  
  // Save file
  var fileBytes = excel.save();
  var directory = Directory('assets/templates');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  
  File('assets/templates/kuitansi_standard.xlsx')
    ..createSync(recursive: true)
    ..writeAsBytesSync(fileBytes!);
    
  print('Template generated at assets/templates/kuitansi_standard.xlsx');
}
