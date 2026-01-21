// lib/services/loan_export_service.dart
// SIM-ASET: Export loan documents (Surat Peminjaman, BA Serah Terima)

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../models/transactions/loan_model.dart';
import '../utils/pdf_template_helper.dart';

class LoanExportService {
  
  /// Generate Surat Peminjaman (Loan Request Letter)
  /// Used when borrower submits a loan request
  static Future<Uint8List> generateSuratPeminjaman({
    required LoanRequest loan,
    String? approverName,
    String? approverNip,
  }) async {
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final logoBytes = await PdfTemplateHelper.loadLogo();
    
    final pdf = pw.Document();
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
            
            // Date Line
            PdfTemplateHelper.buildDateLine(
              city: 'Banjarbaru',
              date: currentDate,
              fontRegular: fontRegular,
            ),
            
            pw.SizedBox(height: 16),
            
            // Title
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'SURAT PERJANJIAN PEMINJAMAN',
                    style: pw.TextStyle(font: fontBold, fontSize: 14),
                  ),
                  pw.Text(
                    'BARANG MILIK DAERAH',
                    style: pw.TextStyle(font: fontBold, fontSize: 14),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Nomor: ${loan.requestNumber}',
                    style: pw.TextStyle(font: fontRegular, fontSize: 11),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 12),
            
            // Opening
            pw.Text(
              'Pada hari ini, ${_formatIndonesianDate(loan.startDate)}, telah dibuat perjanjian peminjaman antara:',
              style: pw.TextStyle(font: fontRegular, fontSize: 11, lineSpacing: 4),
            ),
            
            pw.SizedBox(height: 12),
            
            // Party 1 - BRIDA
            _buildPartySection(
              '1.',
              'BADAN RISET DAN INOVASI DAERAH PROVINSI KALIMANTAN SELATAN',
              'yang selanjutnya disebut PIHAK PERTAMA (Pemberi Pinjaman)',
              fontRegular,
              fontBold,
            ),
            
            pw.SizedBox(height: 12),
            
            // Party 2 - Borrower
            _buildPartySection(
              '2.',
              loan.borrowerName,
              'yang selanjutnya disebut PIHAK KEDUA (Peminjam)',
              fontRegular,
              fontBold,
            ),
            
            pw.SizedBox(height: 16),
            
            // Asset Info
            pw.Text('Dengan ini menyatakan bahwa PIHAK KEDUA meminjam barang milik daerah sebagai berikut:', 
              style: pw.TextStyle(font: fontRegular, fontSize: 11)),
            pw.SizedBox(height: 8),
            
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Nama Aset', loan.assetName, fontRegular),
                  _buildInfoRow('Kondisi', loan.assetCondition, fontRegular),
                  _buildInfoRow('Keperluan', loan.purpose ?? '-', fontRegular),
                  _buildInfoRow('Tanggal Mulai', _formatDate(loan.startDate), fontRegular),
                  _buildInfoRow('Durasi', '${loan.durationYears} Tahun', fontRegular),
                  _buildInfoRow('Tanggal Berakhir', _formatDate(loan.endDate), fontRegular),
                ],
              ),
            ),
            
            pw.SizedBox(height: 16),
            
            // Terms
            pw.Text('KETENTUAN:', style: pw.TextStyle(font: fontBold, fontSize: 11)),
            pw.SizedBox(height: 4),
            _buildTermsList(fontRegular),
            
            pw.Spacer(),
            
            // Signatures
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildSignatureBlock('PIHAK KEDUA', loan.borrowerName, '', fontRegular, fontBold),
                _buildSignatureBlock('PIHAK PERTAMA', approverName ?? 'Kepala BRIDA', approverNip ?? '', fontRegular, fontBold),
              ],
            ),
          ],
        ),
      ),
    );
    
    return pdf.save();
  }
  
  /// Generate BA Serah Terima (Handover/Return Document)
  /// Used when asset is handed over or returned
  static Future<Uint8List> generateBASerahTerima({
    required LoanRequest loan,
    required String type, // 'handover' or 'return'
    String? assetConditionOnReturn,
    String? notes,
    String? receiverName,
    String? receiverNip,
  }) async {
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final logoBytes = await PdfTemplateHelper.loadLogo();
    
    final pdf = pw.Document();
    final currentDate = DateTime.now();
    final isHandover = type == 'handover';
    final baType = isHandover ? 'PENYERAHAN' : 'PENGEMBALIAN';
    final baNumber = 'BA-${isHandover ? 'PSR' : 'KMB'}/${loan.requestNumber.replaceAll('/', '-')}';
    
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
                    'BERITA ACARA $baType',
                    style: pw.TextStyle(font: fontBold, fontSize: 14),
                  ),
                  pw.Text(
                    'BARANG MILIK DAERAH',
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
            pw.SizedBox(height: 12),
            
            // Opening
            pw.Text(
              'Pada hari ini, ${_formatIndonesianDate(currentDate)}, telah dilakukan ${baType.toLowerCase()} barang milik daerah dengan rincian sebagai berikut:',
              style: pw.TextStyle(font: fontRegular, fontSize: 11, lineSpacing: 4),
            ),
            
            pw.SizedBox(height: 12),
            
            // Asset Info
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('INFORMASI PEMINJAMAN:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  pw.SizedBox(height: 8),
                  _buildInfoRow('No. Perjanjian', loan.requestNumber, fontRegular),
                  _buildInfoRow('Peminjam', loan.borrowerName, fontRegular),
                  _buildInfoRow('Alamat', loan.borrowerAddress, fontRegular),
                  pw.Divider(),
                  pw.Text('INFORMASI ASET:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  pw.SizedBox(height: 8),
                  _buildInfoRow('Nama Aset', loan.assetName, fontRegular),
                  _buildInfoRow('Kondisi Awal', loan.assetCondition, fontRegular),
                  if (!isHandover && assetConditionOnReturn != null)
                    _buildInfoRow('Kondisi Saat Dikembalikan', assetConditionOnReturn, fontRegular),
                ],
              ),
            ),
            
            pw.SizedBox(height: 16),
            
            // Condition Statement
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: isHandover ? PdfColors.blue50 : PdfColors.green50,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                isHandover 
                    ? 'Dengan ini dinyatakan bahwa barang tersebut di atas telah diserahkan kepada PIHAK KEDUA (Peminjam) dalam kondisi baik dan lengkap.'
                    : 'Dengan ini dinyatakan bahwa barang tersebut di atas telah dikembalikan oleh PIHAK KEDUA (Peminjam) kepada PIHAK PERTAMA dalam kondisi ${assetConditionOnReturn ?? 'baik'}.',
                style: pw.TextStyle(font: fontRegular, fontSize: 10, lineSpacing: 4),
              ),
            ),
            
            if (notes != null && notes.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              pw.Text('Catatan:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
              pw.Text(notes, style: pw.TextStyle(font: fontRegular, fontSize: 10)),
            ],
            
            pw.SizedBox(height: 16),
            
            pw.Text(
              'Demikian Berita Acara ini dibuat dengan sebenarnya untuk dipergunakan sebagaimana mestinya.',
              style: pw.TextStyle(font: fontRegular, fontSize: 11),
            ),
            
            pw.Spacer(),
            
            // Signatures
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildSignatureBlock(
                  isHandover ? 'Yang Menerima' : 'Yang Menyerahkan',
                  loan.borrowerName,
                  'Peminjam',
                  fontRegular,
                  fontBold,
                ),
                _buildSignatureBlock(
                  isHandover ? 'Yang Menyerahkan' : 'Yang Menerima',
                  receiverName ?? 'Pengelola BMD',
                  receiverNip ?? '',
                  fontRegular,
                  fontBold,
                ),
                _buildSignatureBlock(
                  'Mengetahui',
                  'Kasubbag UMPEG',
                  '',
                  fontRegular,
                  fontBold,
                ),
              ],
            ),
          ],
        ),
      ),
    );
    
    return pdf.save();
  }
  
  /// Preview Surat Peminjaman
  static Future<void> previewSuratPeminjaman(LoanRequest loan) async {
    final pdfBytes = await generateSuratPeminjaman(loan: loan);
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }
  
  /// Preview BA Serah Terima (Handover)
  static Future<void> previewBASerahTerimaPenyerahan(LoanRequest loan) async {
    final pdfBytes = await generateBASerahTerima(loan: loan, type: 'handover');
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }
  
  /// Preview BA Serah Terima (Return)
  static Future<void> previewBASerahTerimaPengembalian(LoanRequest loan, {String? kondisi, String? catatan}) async {
    final pdfBytes = await generateBASerahTerima(
      loan: loan, 
      type: 'return',
      assetConditionOnReturn: kondisi ?? 'Baik',
      notes: catatan,
    );
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }
  
  // --- Helper Methods ---
  
  static pw.Widget _buildPartySection(String number, String name, String role, pw.Font fontRegular, pw.Font fontBold) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: 20, child: pw.Text(number, style: pw.TextStyle(font: fontRegular, fontSize: 11))),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(name, style: pw.TextStyle(font: fontBold, fontSize: 11)),
              pw.Text(role, style: pw.TextStyle(font: fontRegular, fontSize: 10, fontStyle: pw.FontStyle.italic)),
            ],
          ),
        ),
      ],
    );
  }
  
  static pw.Widget _buildInfoRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 120, child: pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10))),
          pw.Text(': ', style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: 10))),
        ],
      ),
    );
  }
  
  static pw.Widget _buildTermsList(pw.Font font) {
    final terms = [
      'PIHAK KEDUA wajib menjaga dan memelihara barang dengan baik.',
      'PIHAK KEDUA dilarang memindahtangankan atau mengubah peruntukan barang.',
      'PIHAK KEDUA wajib mengembalikan barang dalam kondisi baik sesuai jangka waktu.',
      'Segala kerusakan yang terjadi menjadi tanggung jawab PIHAK KEDUA.',
      'Perjanjian ini dapat diperpanjang dengan persetujuan tertulis PIHAK PERTAMA.',
    ];
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: terms.asMap().entries.map((e) => 
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(width: 20, child: pw.Text('${e.key + 1}.', style: pw.TextStyle(font: font, fontSize: 10))),
              pw.Expanded(child: pw.Text(e.value, style: pw.TextStyle(font: font, fontSize: 10))),
            ],
          ),
        )
      ).toList(),
    );
  }
  
  static pw.Widget _buildSignatureBlock(String role, String name, String nip, pw.Font fontRegular, pw.Font fontBold) {
    return pw.Container(
      width: 150,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(role, style: pw.TextStyle(font: fontRegular, fontSize: 9)),
          pw.SizedBox(height: 50),
          pw.Container(
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Text(name, style: pw.TextStyle(font: fontBold, fontSize: 9)),
          ),
          if (nip.isNotEmpty)
            pw.Text('NIP. $nip', style: pw.TextStyle(font: fontRegular, fontSize: 8)),
        ],
      ),
    );
  }
  
  static String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
  
  static String _formatIndonesianDate(DateTime date) {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
  
  /// Generate SK Peminjaman (Surat Keputusan Persetujuan Peminjaman)
  /// Issued when loan is approved
  static Future<Uint8List> generateSKPeminjaman({
    required LoanRequest loan,
    String? approverName,
    String? approverNip,
    String? approverRank,
  }) async {
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final logoBytes = await PdfTemplateHelper.loadLogo();
    
    final pdf = pw.Document();
    final currentDate = DateTime.now();
    final skNumber = 'SK-PINJAM/${loan.requestNumber.replaceAll('/', '')}';
    
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
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(width: 1)),
                    ),
                    child: pw.Text(
                      'SURAT KEPUTUSAN',
                      style: pw.TextStyle(font: fontBold, fontSize: 14, letterSpacing: 2),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'KEPALA BADAN RISET DAN INOVASI DAERAH',
                    style: pw.TextStyle(font: fontBold, fontSize: 11),
                  ),
                  pw.Text(
                    'PROVINSI KALIMANTAN SELATAN',
                    style: pw.TextStyle(font: fontBold, fontSize: 11),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Nomor: $skNumber',
                    style: pw.TextStyle(font: fontRegular, fontSize: 11),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'TENTANG',
                    style: pw.TextStyle(font: fontRegular, fontSize: 10),
                  ),
                  pw.Text(
                    'PERSETUJUAN PEMINJAMAN BARANG MILIK DAERAH',
                    style: pw.TextStyle(font: fontBold, fontSize: 11),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 12),
            
            // Menimbang
            pw.Text('Menimbang:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20, top: 4),
              child: pw.Text(
                'a. bahwa untuk kepentingan pelaksanaan tugas pemerintahan, perlu memberikan persetujuan peminjaman Barang Milik Daerah;\n'
                'b. bahwa berdasarkan pertimbangan sebagaimana dimaksud pada huruf a, perlu ditetapkan Surat Keputusan;',
                style: pw.TextStyle(font: fontRegular, fontSize: 10, lineSpacing: 4),
              ),
            ),
            
            pw.SizedBox(height: 12),
            
            // Mengingat
            pw.Text('Mengingat:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20, top: 4),
              child: pw.Text(
                '1. Peraturan Pemerintah Nomor 27 Tahun 2014 tentang Pengelolaan Barang Milik Negara/Daerah;\n'
                '2. Peraturan Menteri Dalam Negeri Nomor 19 Tahun 2016 tentang Pedoman Pengelolaan Barang Milik Daerah;\n'
                '3. Peraturan Daerah Provinsi Kalimantan Selatan tentang Pengelolaan Barang Milik Daerah;',
                style: pw.TextStyle(font: fontRegular, fontSize: 10, lineSpacing: 4),
              ),
            ),
            
            pw.SizedBox(height: 12),
            
            // MEMUTUSKAN
            pw.Center(
              child: pw.Text('MEMUTUSKAN:', style: pw.TextStyle(font: fontBold, fontSize: 11)),
            ),
            
            pw.SizedBox(height: 12),
            
            // Menetapkan
            pw.Text('Menetapkan:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
            pw.SizedBox(height: 4),
            
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('KESATU   : Memberikan persetujuan peminjaman Barang Milik Daerah kepada:', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Peminjam', loan.borrowerName, fontRegular),
                        _buildInfoRow('Alamat', loan.borrowerAddress, fontRegular),
                        _buildInfoRow('Nama Aset', loan.assetName, fontRegular),
                        _buildInfoRow('Durasi', '${loan.durationYears} Tahun', fontRegular),
                        _buildInfoRow('Periode', '${_formatDate(loan.startDate)} s.d. ${_formatDate(loan.endDate)}', fontRegular),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('KEDUA   : Peminjam berkewajiban menjaga dan memelihara barang serta mengembalikan dalam kondisi baik.', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                  pw.SizedBox(height: 4),
                  pw.Text('KETIGA  : Surat Keputusan ini berlaku sejak tanggal ditetapkan.', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                ],
              ),
            ),
            
            pw.Spacer(),
            
            // Signature
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Ditetapkan di Banjarbaru', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                    pw.Text('Pada tanggal ${_formatDate(currentDate)}', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                    pw.SizedBox(height: 8),
                    pw.Text('KEPALA BADAN RISET DAN INOVASI DAERAH', style: pw.TextStyle(font: fontBold, fontSize: 9)),
                    pw.Text('PROVINSI KALIMANTAN SELATAN', style: pw.TextStyle(font: fontBold, fontSize: 9)),
                    pw.SizedBox(height: 50),
                    pw.Container(
                      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
                      padding: const pw.EdgeInsets.only(bottom: 2),
                      child: pw.Text(approverName ?? 'Kepala BRIDA', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                    ),
                    if (approverRank != null && approverRank.isNotEmpty)
                      pw.Text(approverRank, style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                    if (approverNip != null && approverNip.isNotEmpty)
                      pw.Text('NIP. $approverNip', style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
    
    return pdf.save();
  }
  
  /// Preview SK Peminjaman
  static Future<void> previewSKPeminjaman(LoanRequest loan) async {
    final pdfBytes = await generateSKPeminjaman(loan: loan);
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }
}
