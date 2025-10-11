import 'package:flutter/material.dart';

/// Mock version Cleaner Home Screen untuk UI Testing
/// Tanpa dependency ke Firebase Auth
class MockCleanerHomeScreen extends StatelessWidget {
  const MockCleanerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Petugas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mock: Profile')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildWelcomeCard(context),
                const SizedBox(height: 16),
                _buildStatisticsRow(),
                const SizedBox(height: 24),
                _buildRequestsList(context),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mock: Buat Laporan')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Buat Laporan'),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat Datang,\nPetugas Kebersihan!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hari ini: ${DateTime.now().toString().split(' ')[0]}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatisticCard(
            icon: Icons.check_circle,
            title: 'Selesai',
            value: '8',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatisticCard(
            icon: Icons.pending_actions,
            title: 'Dalam Proses',
            value: '3',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
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
              title,
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(BuildContext context) {
    final mockRequests = [
      {
        'location': 'Toilet Lantai 3',
        'description': 'Perlu dibersihkan secara menyeluruh',
        'isUrgent': true,
      },
      {
        'location': 'Ruang Rapat B-201',
        'description': 'Setelah meeting besar, banyak sampah',
        'isUrgent': false,
      },
      {
        'location': 'Area Parkir Indoor',
        'description': 'Lantai kotor perlu pel',
        'isUrgent': false,
      },
      {
        'location': 'Dapur Karyawan',
        'description': 'Wastafel tersumbat',
        'isUrgent': true,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Permintaan Terbaru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mockRequests.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final request = mockRequests[index];
              final isUrgent = request['isUrgent'] as bool;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isUrgent ? Colors.red[100] : Colors.indigo[100],
                  child: Icon(
                    isUrgent ? Icons.priority_high : Icons.cleaning_services,
                    color: isUrgent ? Colors.red : Colors.indigo,
                  ),
                ),
                title: Text(request['location'] as String),
                subtitle: Text(
                  request['description'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mock: Detail ${request['location']}'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}