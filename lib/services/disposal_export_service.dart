import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../models/transactions/disposal_model.dart';
import '../utils/pdf_template_helper.dart';

/// Service for generating Disposal-related PDF documents
class DisposalExportService {
  
  /// Generate SK Penghapusan Aset (Surat Keputusan)
  /// This is issued when status changes to 'approved'
  static Future<Uint8List> generateSKPenghapusan({
    required DisposalRequest disposal,
    required String assetName,
    required String assetCode,
    required double estimatedValue,
    String? approverName,
    String? approverNip,
    String? approverRank,
  }) async {
    // Load fonts
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final logoBytes = await PdfTemplateHelper.loadLogo();
    
    final pdf = pw.Document();
    
    final skNumber = 'SK/${disposal.code.replaceAll('DSP/', '')}';
    final currentDate = DateTime.now();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Kop Surat
            PdfTemplateHelper.buildKopSurat(
              logoBytes: logoBytes,
              fontRegular: fontRegular,
              fontBold: fontBold,
            ),
            
            // Title
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'SURAT KEPUTUSAN',
                    style: pw.TextStyle(font: fontBold, fontSize: 14),
                  ),
                  pw.Text(
                    'KEPALA BADAN RISET DAN INOVASI DAERAH',
                    style: pw.TextStyle(font: fontBold, fontSize: 12),
                  ),
                  pw.Text(
                    'PROVINSI KALIMANTAN SELATAN',
                    style: pw.TextStyle(font: fontBold, fontSize: 12),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Nomor: $skNumber',
                    style: pw.TextStyle(font: fontRegular, fontSize: 11),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'TENTANG',
                    style: pw.TextStyle(font: fontBold, fontSize: 11),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'PENGHAPUSAN BARANG MILIK DAERAH',
                    style: pw.TextStyle(font: fontBold, fontSize: 11),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 16),
            
            // Menimbang
            _buildConsiderationSection(fontRegular, fontBold, disposal),
            
            pw.SizedBox(height: 12),
            
            // Mengingat
            _buildLegalBasisSection(fontRegular, fontBold),
            
            pw.SizedBox(height: 16),
            
            // MEMUTUSKAN
            pw.Center(
              child: pw.Text(
                'MEMUTUSKAN:',
                style: pw.TextStyle(font: fontBold, fontSize: 12),
              ),
            ),
            
            pw.SizedBox(height: 12),
            
            // Menetapkan
            _buildDecisionSection(fontRegular, fontBold, assetName, assetCode, estimatedValue, disposal),
            
            pw.Spacer(),
            
            // Date and Signature
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 200,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      PdfTemplateHelper.buildDateLine(
                        city: 'Banjarbaru',
                        date: currentDate,
                        fontRegular: fontRegular,
                      ),
                      pw.SizedBox(height: 8),
                      PdfTemplateHelper.buildSignatureBlock(
                        roleLabel: 'Kepala Badan',
                        name: approverName ?? 'Dr. H. GUSTI HATTA, M.Si.',
                        nip: approverNip ?? '196808201994031009',
                        position: 'Kepala Badan Riset dan Inovasi Daerah',
                        rank: approverRank ?? 'Pembina Utama Muda (IV/c)',
                        fontRegular: fontRegular,
                        fontBold: fontBold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    
    return pdf.save();
  }
  
  /// Generate Berita Acara Penghapusan (Execution Document)
  /// This is issued when status changes to 'executed'
  static Future<Uint8List> generateBeritaAcara({
    required DisposalRequest disposal,
    required String assetName,
    required String assetCode,
    required double finalValue,
    required String executionType, // 'sold' or 'destroyed'
    String? executorName,
    String? executorNip,
  }) async {
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final logoBytes = await PdfTemplateHelper.loadLogo();
    
    final pdf = pw.Document();
    
    final baNumber = 'BA/${disposal.code.replaceAll('DSP/', '')}';
    final currentDate = DateTime.now();
    final executionMethod = executionType == 'sold' ? 'Penjualan/Lelang' : 'Pemusnahan/Hibah';
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Kop Surat
            PdfTemplateHelper.buildKopSurat(
              logoBytes: logoBytes,
              fontRegular: fontRegular,
              fontBold: fontBold,
            ),
            
            // Title
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'BERITA ACARA',
                    style: pw.TextStyle(font: fontBold, fontSize: 14),
                  ),
                  pw.Text(
                    'PENGHAPUSAN BARANG MILIK DAERAH',
                    style: pw.TextStyle(font: fontBold, fontSize: 12),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Nomor: $baNumber',
                    style: pw.TextStyle(font: fontRegular, fontSize: 11),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 16),
            
            // Opening paragraph
            pw.Text(
              'Pada hari ini, ${_formatIndonesianDate(currentDate)}, kami yang bertanda tangan di bawah ini:',
              style: pw.TextStyle(font: fontRegular, fontSize: 11, lineSpacing: 4),
            ),
            
            pw.SizedBox(height: 12),
            
            // Asset Details Table
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('DETAIL ASET YANG DIHAPUSKAN:', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                  pw.SizedBox(height: 8),
                  _buildTableRow('Nama Aset', assetName, fontRegular),
                  _buildTableRow('Kode Aset', assetCode, fontRegular),
                  _buildTableRow('Alasan Penghapusan', disposal.reason, fontRegular),
                  _buildTableRow('Metode Eksekusi', executionMethod, fontRegular),
                  _buildTableRow('Nilai Perkiraan', 'Rp ${_formatCurrency(disposal.estimatedValue)}', fontRegular),
                  _buildTableRow('Nilai Akhir', 'Rp ${_formatCurrency(finalValue)}', fontRegular),
                  _buildTableRow('SK Penghapusan', 'SK/${disposal.code.replaceAll('DSP/', '')}', fontRegular),
                ],
              ),
            ),
            
            pw.SizedBox(height: 16),
            
            // Closing paragraph
            pw.Text(
              'Demikian Berita Acara ini dibuat dengan sebenarnya untuk dipergunakan sebagaimana mestinya.',
              style: pw.TextStyle(font: fontRegular, fontSize: 11, lineSpacing: 4),
            ),
            
            pw.Spacer(),
            
            // Signatures (2 columns)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Left: Yang Menyerahkan
                pw.Container(
                  width: 180,
                  child: PdfTemplateHelper.buildSignatureBlock(
                    roleLabel: 'Yang Menyerahkan',
                    name: executorName ?? 'Tim Eksekusi',
                    nip: executorNip ?? '-',
                    position: 'Pengelola BMD',
                    rank: '',
                    fontRegular: fontRegular,
                    fontBold: fontBold,
                  ),
                ),
                // Right: Mengetahui
                pw.Container(
                  width: 180,
                  child: PdfTemplateHelper.buildSignatureBlock(
                    roleLabel: 'Mengetahui',
                    name: 'Dr. H. GUSTI HATTA, M.Si.',
                    nip: '196808201994031009',
                    position: 'Kepala Badan',
                    rank: 'Pembina Utama Muda (IV/c)',
                    fontRegular: fontRegular,
                    fontBold: fontBold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    
    return pdf.save();
  }
  
  // --- Helper Methods ---
  
  static pw.Widget _buildConsiderationSection(pw.Font fontRegular, pw.Font fontBold, DisposalRequest disposal) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Menimbang:', style: pw.TextStyle(font: fontBold, fontSize: 11)),
        pw.SizedBox(height: 4),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildListItem('a.', 'bahwa barang milik daerah sebagaimana tersebut dalam lampiran surat keputusan ini sudah tidak dapat dipergunakan lagi karena ${disposal.reason.toLowerCase()};', fontRegular),
              pw.SizedBox(height: 4),
              _buildListItem('b.', 'bahwa untuk tertib administrasi pengelolaan barang milik daerah, perlu dilakukan penghapusan;', fontRegular),
              pw.SizedBox(height: 4),
              _buildListItem('c.', 'bahwa berdasarkan pertimbangan sebagaimana dimaksud huruf a dan b, perlu menetapkan Surat Keputusan;', fontRegular),
            ],
          ),
        ),
      ],
    );
  }
  
  static pw.Widget _buildLegalBasisSection(pw.Font fontRegular, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Mengingat:', style: pw.TextStyle(font: fontBold, fontSize: 11)),
        pw.SizedBox(height: 4),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildListItem('1.', 'Peraturan Pemerintah Nomor 27 Tahun 2014 tentang Pengelolaan Barang Milik Negara/Daerah;', fontRegular),
              pw.SizedBox(height: 4),
              _buildListItem('2.', 'Peraturan Menteri Dalam Negeri Nomor 19 Tahun 2016 tentang Pedoman Pengelolaan Barang Milik Daerah;', fontRegular),
              pw.SizedBox(height: 4),
              _buildListItem('3.', 'Peraturan Daerah Provinsi Kalimantan Selatan tentang Pengelolaan Barang Milik Daerah;', fontRegular),
            ],
          ),
        ),
      ],
    );
  }
  
  static pw.Widget _buildDecisionSection(pw.Font fontRegular, pw.Font fontBold, String assetName, String assetCode, double estimatedValue, DisposalRequest disposal) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Menetapkan:', style: pw.TextStyle(font: fontBold, fontSize: 11)),
        pw.SizedBox(height: 4),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildListItem('KESATU:', 'Menghapuskan barang milik daerah berupa "$assetName" dengan kode inventaris $assetCode dari daftar barang milik daerah pada Badan Riset dan Inovasi Daerah Provinsi Kalimantan Selatan;', fontRegular),
              pw.SizedBox(height: 4),
              _buildListItem('KEDUA:', 'Nilai perkiraan barang yang dihapuskan sebesar Rp ${_formatCurrency(estimatedValue)} (${_terbilang(estimatedValue.toInt())});', fontRegular),
              pw.SizedBox(height: 4),
              _buildListItem('KETIGA:', 'Keputusan ini berlaku sejak tanggal ditetapkan dengan ketentuan apabila dikemudian hari terdapat kekeliruan akan diadakan perbaikan sebagaimana mestinya.', fontRegular),
            ],
          ),
        ),
      ],
    );
  }
  
  static pw.Widget _buildListItem(String prefix, String text, pw.Font font) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: 40, child: pw.Text(prefix, style: pw.TextStyle(font: font, fontSize: 11))),
        pw.Expanded(child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 11, lineSpacing: 4))),
      ],
    );
  }
  
  static pw.Widget _buildTableRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 140, child: pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10))),
          pw.Text(': ', style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: 10))),
        ],
      ),
    );
  }
  
  static String _formatIndonesianDate(DateTime date) {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
  
  static String _formatCurrency(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
  
  static String _terbilang(int n) {
    if (n == 0) return 'nol rupiah';
    const satuan = ['', 'satu', 'dua', 'tiga', 'empat', 'lima', 'enam', 'tujuh', 'delapan', 'sembilan', 'sepuluh', 'sebelas'];
    
    String result = '';
    if (n < 12) {
      result = satuan[n];
    } else if (n < 20) {
      result = '${satuan[n - 10]} belas';
    } else if (n < 100) {
      result = '${satuan[n ~/ 10]} puluh ${satuan[n % 10]}'.trim();
    } else if (n < 200) {
      result = 'seratus ${_terbilang(n - 100)}'.trim();
    } else if (n < 1000) {
      result = '${satuan[n ~/ 100]} ratus ${_terbilang(n % 100)}'.trim();
    } else if (n < 2000) {
      result = 'seribu ${_terbilang(n - 1000)}'.trim();
    } else if (n < 1000000) {
      result = '${_terbilang(n ~/ 1000)} ribu ${_terbilang(n % 1000)}'.trim();
    } else if (n < 1000000000) {
      result = '${_terbilang(n ~/ 1000000)} juta ${_terbilang(n % 1000000)}'.trim();
    } else {
      result = '${_terbilang(n ~/ 1000000000)} miliar ${_terbilang(n % 1000000000)}'.trim();
    }
    
    return '$result rupiah'.trim();
  }
  
  /// Preview SK PDF in dialog
  static Future<void> previewSK(DisposalRequest disposal, {
    required String assetName,
    required String assetCode,
    required double estimatedValue,
  }) async {
    final pdfBytes = await generateSKPenghapusan(
      disposal: disposal,
      assetName: assetName,
      assetCode: assetCode,
      estimatedValue: estimatedValue,
    );
    
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }
  
  /// Preview Berita Acara PDF in dialog  
  static Future<void> previewBeritaAcara(DisposalRequest disposal, {
    required String assetName,
    required String assetCode,
    required double finalValue,
    required String executionType,
  }) async {
    final pdfBytes = await generateBeritaAcara(
      disposal: disposal,
      assetName: assetName,
      assetCode: assetCode,
      finalValue: finalValue,
      executionType: executionType,
    );
    
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }
}
