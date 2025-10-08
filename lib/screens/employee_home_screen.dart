import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

import 'package:aplikasi_cleanoffice/providers/report_provider.dart';
import 'package:aplikasi_cleanoffice/models/report_model.dart';
import 'report_detail_screen.dart';


class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  bool _isRefreshing = false;
  final _dateFormat = DateFormat('d MMM yyyy');
  final _logger = Logger('EmployeeHomeScreen');

  String _formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green;
      case 'dikerjakan':
        return Colors.orange;
      case 'terkirim':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) {
      _logger.info('Refresh already in progress, skipping');
      return;
    }
    
    _logger.info('Starting refresh operation');
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Get current user ID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _logger.warning('Attempted to refresh while not logged in');
        throw Exception('User not logged in');
      }
      
      _logger.info('Fetching reports for user: ${user.uid}');

      // Fetch reports from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .get();

      _logger.info('Retrieved ${querySnapshot.docs.length} reports from Firestore');
      
      // Convert the documents to Report objects
      final reports = querySnapshot.docs.map((doc) {
        final data = doc.data();
        try {
          return Report(
            id: doc.id,
            title: data['title'] as String,
            location: data['location'] as String,
            date: (data['date'] as Timestamp).toDate(),
            status: data['status'] as String,
            imageUrl: data['imageUrl'] as String?,
            description: data['description'] as String?,
          );
        } catch (e) {
          _logger.warning('Error parsing report document ${doc.id}', e);
          rethrow;
        }
      }).toList();

      // Update the provider
      if (mounted) {
        final reportProvider = Provider.of<ReportProvider>(context, listen: false);
        reportProvider.setReports(reports);
        _logger.info('Successfully updated reports in provider');
      } else {
        _logger.warning('Widget was unmounted before reports could be updated');
      }

    } catch (error) {
      _logger.severe('Error fetching reports', error);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is FirebaseException 
                ? 'Error: ${error.message}' 
                : 'Gagal memperbarui data. Silakan coba lagi.',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'COBA LAGI',
              textColor: Colors.white,
              onPressed: _handleRefresh,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch reports when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleRefresh();
    });
  }

  Widget _buildProgressItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data dari Provider
    final reportProvider = Provider.of<ReportProvider>(context);
    final reports = reportProvider.reports;

    // Menghitung jumlah laporan berdasarkan status
    final int sentCount = reports.where((r) => r.status.toLowerCase() == 'terkirim').length;
    final int inProgressCount = reports.where((r) => r.status.toLowerCase() == 'dikerjakan').length;
    final int doneCount = reports.where((r) => r.status.toLowerCase() == 'selesai').length;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda Karyawan'),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            onPressed: () => Navigator.pushNamed(context, '/employee/request'),
            tooltip: 'Minta Layanan',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/employee/requests'),
            tooltip: 'Riwayat',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi Logout'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('BATAL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('KELUAR'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress status dinamis dari provider
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProgressItem('Terkirim', sentCount.toString(), Colors.blue),
                  _buildProgressItem('Dikerjakan', inProgressCount.toString(), Colors.orange),
                  _buildProgressItem('Selesai', doneCount.toString(), Colors.green),
                ],
              ),
            ),
            // Header dengan tombol Buat Laporan (Tidak berubah)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Laporkan Masalah Kebersihan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => Navigator.pushNamed(context, '/create_report'),
                      child: Container(
                        // ... (Kode Container Tombol Buat Laporan sama seperti sebelumnya)
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.indigo[600],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.camera_alt, color: Colors.white, size: 32),
                            SizedBox(height: 8),
                            Text('Buat Laporan Baru', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Riwayat Laporan section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      // ... (Kode Header Riwayat sama)
                      children: [
                        Icon(Icons.history),
                        SizedBox(width: 8),
                        Text('Riwayat Laporan Anda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _handleRefresh,
                        child: reports.isEmpty
                          ? const Center(child: Text('Belum ada laporan.'))
                          : ListView.builder(
                          itemCount: reports.length,
                          itemBuilder: (context, index) {
                            final report = reports[index];
                            return Dismissible(
                              key: Key(report.id), // Gunakan ID unik dari model
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Hapus Laporan'),
                                    content: const Text('Apakah Anda yakin ingin menghapus laporan ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                        child: const Text('BATAL'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        child: const Text('HAPUS'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (direction) {
                                final deletedReport = report;
                                reportProvider.deleteReport(report.id);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Laporan dihapus'),
                                    action: SnackBarAction(
                                      label: 'BATALKAN',
                                      onPressed: () {
                                        reportProvider.addReport(deletedReport);
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 0,
                                child: ListTile(
                                  leading: Container(
                                    // ... (Kode Leading Icon sama)
                                     padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.cleaning_services_outlined, color: Colors.indigo),
                                  ),
                                  title: Text(
                                    report.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(_formatDate(report.date)),
                                  trailing: Container(
                                    // ... (Kode Trailing Status sama)
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(report.status),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(report.status, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReportDetailScreen(
                                          title: report.title,
                                          date: _formatDate(report.date),
                                          status: report.status,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button tidak diubah
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_report_btn',
        onPressed: () {
          Navigator.pushNamed(context, '/create_report');
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }
}