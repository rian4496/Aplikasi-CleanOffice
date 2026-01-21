// lib/services/mutation_export_service.dart
// SIM-ASET: Export mutation documents (BA Mutasi Aset)

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../models/transactions/asset_mutation.dart';
import '../utils/pdf_template_helper.dart';

class MutationExportService {
  
  /// Generate BA Mutasi Aset (Berita Acara Mutasi)
  /// Used when asset is transferred between locations/units
  static Future<Uint8List> generateBAMutasi({
    required AssetMutation mutation,
    String? senderName,
    String? senderNip,
    String? receiverName,
    String? receiverNip,
    String? notes,
  }) async {
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final logoBytes = await PdfTemplateHelper.loadLogo();
    
    final pdf = pw.Document();
    final currentDate = DateTime.now();
    final baNumber = 'BA-MUT/${mutation.mutationCode}';
    
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
                    'BERITA ACARA MUTASI ASET',
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
              'Pada hari ini, ${_formatIndonesianDate(currentDate)}, telah dilakukan serah terima mutasi Barang Milik Daerah (BMD) dengan rincian sebagai berikut:',
              style: pw.TextStyle(font: fontRegular, fontSize: 11, lineSpacing: 4),
            ),
            
            pw.SizedBox(height: 16),
            
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
                  pw.Text('INFORMASI ASET:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  pw.SizedBox(height: 8),
                  _buildInfoRow('Nama Aset', mutation.assetName ?? '-', fontRegular),
                  _buildInfoRow('Kode Aset', mutation.assetCode ?? '-', fontRegular),
                  _buildInfoRow('Kode Mutasi', mutation.mutationCode, fontRegular),
                ],
              ),
            ),
            
            pw.SizedBox(height: 12),
            
            // Mutation Info
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('INFORMASI MUTASI:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  pw.SizedBox(height: 8),
                  _buildInfoRow('Lokasi Asal', mutation.originLocationName ?? '-', fontRegular),
                  _buildInfoRow('Lokasi Tujuan', mutation.destinationLocationName ?? '-', fontRegular),
                  _buildInfoRow('Diajukan Oleh', mutation.requesterName ?? '-', fontRegular),
                  _buildInfoRow('Alasan Mutasi', mutation.reason ?? '-', fontRegular),
                  _buildInfoRow('Tanggal Pengajuan', _formatDate(mutation.createdAt), fontRegular),
                ],
              ),
            ),
            
            pw.SizedBox(height: 16),
            
            // Condition Statement
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.green50,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                'Dengan ini dinyatakan bahwa aset tersebut di atas telah diserahterimakan dari ${mutation.originLocationName ?? "lokasi asal"} kepada ${mutation.destinationLocationName ?? "lokasi tujuan"} dalam keadaan baik dan lengkap.',
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
              'Demikian Berita Acara ini dibuat dengan sebenarnya untuk dapat dipergunakan sebagaimana mestinya.',
              style: pw.TextStyle(font: fontRegular, fontSize: 11),
            ),
            
            pw.Spacer(),
            
            // Signatures (3 columns)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildSignatureBlock(
                  'Yang Menyerahkan',
                  senderName ?? 'Kepala ${mutation.originLocationName ?? "Unit Asal"}',
                  senderNip ?? '',
                  fontRegular,
                  fontBold,
                ),
                _buildSignatureBlock(
                  'Yang Menerima',
                  receiverName ?? 'Kepala ${mutation.destinationLocationName ?? "Unit Tujuan"}',
                  receiverNip ?? '',
                  fontRegular,
                  fontBold,
                ),
                _buildSignatureBlock(
                  'Mengetahui',
                  mutation.approverName ?? 'Kasubbag UMPEG',
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
  
  /// Preview BA Mutasi
  static Future<void> previewBAMutasi(AssetMutation mutation, {String? catatan}) async {
    final pdfBytes = await generateBAMutasi(mutation: mutation, notes: catatan);
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }
  
  // --- Helper Methods ---
  
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
  
  static pw.Widget _buildSignatureBlock(String role, String name, String nip, pw.Font fontRegular, pw.Font fontBold) {
    return pw.Container(
      width: 140,
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
  
  /// Generate SK Mutasi (Surat Keputusan Persetujuan Mutasi)
  /// Issued when mutation is approved
  static Future<Uint8List> generateSKMutasi({
    required AssetMutation mutation,
    String? approverName,
    String? approverNip,
    String? approverRank,
  }) async {
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final logoBytes = await PdfTemplateHelper.loadLogo();
    
    final pdf = pw.Document();
    final currentDate = DateTime.now();
    final skNumber = 'SK-MUT/${mutation.mutationCode}';
    
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
                    'MUTASI BARANG MILIK DAERAH',
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
                'a. bahwa untuk optimalisasi penggunaan Barang Milik Daerah, diperlukan perpindahan/mutasi aset;\n'
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
                  pw.Text('KESATU   : Menyetujui mutasi Barang Milik Daerah sebagai berikut:', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
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
                        _buildInfoRow('Nama Aset', mutation.assetName ?? '-', fontRegular),
                        _buildInfoRow('Kode Aset', mutation.assetCode ?? '-', fontRegular),
                        _buildInfoRow('Lokasi Asal', mutation.originLocationName ?? '-', fontRegular),
                        _buildInfoRow('Lokasi Tujuan', mutation.destinationLocationName ?? '-', fontRegular),
                        _buildInfoRow('Alasan', mutation.reason ?? '-', fontRegular),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('KEDUA   : Unit kerja penerima bertanggung jawab atas pemeliharaan dan penggunaan aset.', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
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
  
  /// Preview SK Mutasi
  static Future<void> previewSKMutasi(AssetMutation mutation) async {
    final pdfBytes = await generateSKMutasi(mutation: mutation);
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }
}
