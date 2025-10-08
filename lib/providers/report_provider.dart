import 'package:flutter/foundation.dart';
import 'package:aplikasi_cleanoffice/models/report_model.dart';

class ReportProvider with ChangeNotifier {
  // Daftar laporan kita, diawali dengan beberapa data dummy
  // Using fixed dates for demo data
  final List<Report> _reports = [
    Report(
      id: 'r1', 
      title: 'Area Lobby - Sampah Penuh', 
      location: 'Area Lobby', 
      date: DateTime(2025, 10, 6), // yesterday
      status: 'Dikerjakan',
      imageUrl: '',
      description: 'Tempat sampah di area lobby sudah penuh dan perlu segera dikosongkan.',
    ),
    Report(
      id: 'r2', 
      title: 'Dapur Karyawan - Bocor', 
      location: 'Dapur Karyawan', 
      date: DateTime(2025, 10, 5), // 2 days ago
      status: 'Terkirim',
      imageUrl: '',
      description: 'Terdapat kebocoran pada pipa air di area dapur karyawan.',
    ),
  ];

  // Cara untuk Halaman Beranda 'membaca' daftar laporan
  List<Report> get reports {
    return [..._reports];
  }

  // Mendapatkan laporan berdasarkan ID
  Report? getReportById(String id) {
    try {
      return _reports.firstWhere((report) => report.id == id);
    } catch (e) {
      return null;
    }
  }

  // Mendapatkan laporan berdasarkan status
  List<Report> getReportsByStatus(String status) {
    return _reports.where((report) => report.status.toLowerCase() == status.toLowerCase()).toList();
  }

  // Menambahkan laporan baru
  void addReport(Report report) {
    _reports.insert(0, report); // insert di posisi 0 agar muncul paling atas
    notifyListeners();
  }

  // Menghapus laporan
  void deleteReport(String reportId) {
    _reports.removeWhere((report) => report.id == reportId);
    notifyListeners();
  }

  // Mengupdate status laporan
  void updateReportStatus(String reportId, String newStatus) {
    final reportIndex = _reports.indexWhere((report) => report.id == reportId);
    if (reportIndex >= 0) {
      final oldReport = _reports[reportIndex];
      _reports[reportIndex] = Report(
        id: oldReport.id,
        title: oldReport.title,
        location: oldReport.location,
        date: oldReport.date,
        status: newStatus,
        imageUrl: oldReport.imageUrl,
        description: oldReport.description,
      );
      notifyListeners();
    }
  }

  // Mengatur ulang semua laporan (untuk sync dengan Firestore)
  void setReports(List<Report> newReports) {
    _reports.clear();
    _reports.addAll(newReports);
    notifyListeners();
  }
}