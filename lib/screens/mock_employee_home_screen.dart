import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Mock version Employee Home Screen untuk UI Testing
/// Tanpa dependency ke Firebase Auth
class MockEmployeeHomeScreen extends StatelessWidget {
  const MockEmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda Karyawan'),
        backgroundColor: Colors.indigo[700],
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mock: Minta Layanan')),
              );
            },
            tooltip: 'Minta Layanan',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Mock: Riwayat')));
            },
            tooltip: 'Riwayat',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Mock: Profile')));
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress status cards
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildProgressItem('Terkirim', '3', Colors.blue),
                    _buildProgressItem('Dikerjakan', '2', Colors.orange),
                    _buildProgressItem('Selesai', '5', Colors.green),
                  ],
                ),
              ),

              // Header dengan tombol Buat Laporan
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
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mock: Buat Laporan')),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.indigo[600],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Buat Laporan Baru',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.history),
                    SizedBox(width: 8),
                    Text(
                      'Riwayat Laporan Anda',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Mock Reports List
              ..._buildMockReports(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_report_btn',
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Mock: Buat Laporan')));
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
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
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMockReports() {
    final mockReports = [
      {
        'location': 'Toilet Lantai 2',
        'date': DateTime.now().subtract(const Duration(hours: 2)),
        'status': 'Dikerjakan',
        'statusColor': Colors.orange,
      },
      {
        'location': 'Ruang Rapat A-101',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'status': 'Selesai',
        'statusColor': Colors.green,
      },
      {
        'location': 'Area Lobby',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'status': 'Terkirim',
        'statusColor': Colors.blue,
      },
      {
        'location': 'Pantry Lantai 1',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'status': 'Selesai',
        'statusColor': Colors.green,
      },
    ];

    return mockReports.map((report) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 0,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.cleaning_services_outlined,
              color: Colors.indigo,
            ),
          ),
          title: Text(
            report['location'] as String,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            DateFormat('d MMM yyyy').format(report['date'] as DateTime),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: report['statusColor'] as Color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              report['status'] as String,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          onTap: () {
            // Mock action
          },
        ),
      );
    }).toList();
  }
}

