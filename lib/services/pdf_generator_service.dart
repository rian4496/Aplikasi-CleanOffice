// lib/services/pdf_generator_service.dart
// Professional PDF generator for reports

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../models/export_config.dart';

class PdfGeneratorService {
  /// Generate professional PDF report
  Future<Uint8List> generatePdf(
    ReportData data,
    ExportConfig config,
  ) async {
    final pdf = pw.Document();

    // Add pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader(data),
          pw.SizedBox(height: 20),
          _buildSummary(data),
          pw.SizedBox(height: 20),
          if (config.includeStatistics) ...[
            _buildStatistics(data),
            pw.SizedBox(height: 20),
          ],
          _buildDataTable(data),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    return pdf.save();
  }

  /// Build PDF header
  pw.Widget _buildHeader(ReportData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'CleanOffice',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Sistem Manajemen Kebersihan',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  data.title,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  data.subtitle,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 2, color: PdfColors.blue800),
        pw.SizedBox(height: 8),
        pw.Text(
          'Digenerate: ${DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(data.generatedAt)}',
          style: const pw.TextStyle(
            fontSize: 9,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  /// Build summary section
  pw.Widget _buildSummary(ReportData data) {
    final summary = data.summary;
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Ringkasan',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Total Laporan', '${summary['total']}', PdfColors.blue),
              _buildSummaryItem('Selesai', '${summary['completed']}', PdfColors.green),
              _buildSummaryItem('Pending', '${summary['pending']}', PdfColors.orange),
              _buildSummaryItem('Urgent', '${summary['urgent']}', PdfColors.red),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  /// Build statistics section
  pw.Widget _buildStatistics(ReportData data) {
    final summary = data.summary;
    final completionRate = summary['completionRate'] as double? ?? 0.0;
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Statistik',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Tingkat Penyelesaian:'),
              pw.Text(
                '${completionRate.toStringAsFixed(1)}%',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: completionRate >= 80 ? PdfColors.green : PdfColors.orange,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            height: 10,
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: completionRate.toInt(),
                  child: pw.Container(
                    height: 20,
                    decoration: pw.BoxDecoration(
                      color: completionRate >= 80 ? PdfColors.green : PdfColors.orange,
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: (100 - completionRate).toInt(),
                  child: pw.Container(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build data table
  pw.Widget _buildDataTable(ReportData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Detail Laporan',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 9,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.blue800,
          ),
          cellStyle: const pw.TextStyle(fontSize: 8),
          cellHeight: 25,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerLeft,
            2: pw.Alignment.center,
            3: pw.Alignment.center,
            4: pw.Alignment.centerLeft,
            5: pw.Alignment.centerLeft,
          },
          headerPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          cellPadding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          border: pw.TableBorder.all(color: PdfColors.grey300),
          headers: [
            'Lokasi',
            'Deskripsi',
            'Status',
            'Urgent',
            'Tanggal',
            'Cleaner',
          ],
          data: data.items.map((item) => [
            item['location'] ?? '-',
            _truncateText(item['description'] ?? '-', 30),
            item['status'] ?? '-',
            item['urgent'] ?? 'Tidak',
            _formatDate(item['date']),
            item['cleanerName'] ?? '-',
          ]).toList(),
        ),
      ],
    );
  }

  /// Build footer
  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Halaman ${context.pageNumber} dari ${context.pagesCount}',
        style: const pw.TextStyle(
          fontSize: 9,
          color: PdfColors.grey600,
        ),
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    if (date is String) return date.split(' ')[0]; // Get date part only
    return '-';
  }
}
