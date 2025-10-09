import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

/// Screen untuk menampilkan detail permintaan kebersihan
/// dan memungkinkan cleaner untuk accept, start, complete request
class RequestDetailScreen extends StatefulWidget {
  final String requestId;

  const RequestDetailScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Permintaan'),
        backgroundColor: Colors.indigo[700],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .doc(widget.requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Permintaan tidak ditemukan'),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] as String? ?? 'pending';
          final isUrgent = data['isUrgent'] as bool? ?? false;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header dengan status
                _buildHeader(data, status, isUrgent),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Foto jika ada
                      if (data['imageUrl'] != null && 
                          (data['imageUrl'] as String).isNotEmpty)
                        _buildImage(data['imageUrl'] as String),

                      const SizedBox(height: 16),

                      // Informasi Detail
                      _buildInfoSection('Lokasi', data['location'] as String? ?? '-', 
                          Icons.location_on),
                      const SizedBox(height: 12),
                      
                      _buildInfoSection('Deskripsi', 
                          data['description'] as String? ?? '-', 
                          Icons.description),
                      const SizedBox(height: 12),

                      _buildInfoSection('Pelapor', 
                          data['requesterName'] as String? ?? '-', 
                          Icons.person),
                      const SizedBox(height: 12),

                      if (data['requesterEmail'] != null)
                        _buildInfoSection('Email', 
                            data['requesterEmail'] as String, 
                            Icons.email),

                      const SizedBox(height: 12),
                      
                      _buildInfoSection('Dibuat', 
                          _formatDateTime(data['createdAt']), 
                          Icons.calendar_today),

                      const SizedBox(height: 24),

                      // Timeline
                      _buildTimeline(data),

                      const SizedBox(height: 24),

                      // Action Buttons
                      _buildActionButtons(status, data),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> data, String status, bool isUrgent) {
    Color statusColor = _getStatusColor(status);
    String statusText = _getStatusText(status);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.indigo[700]!,
            Colors.indigo[500]!,
          ],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              if (isUrgent) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.priority_high, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'URGENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data['location'] as String? ?? 'Lokasi tidak diketahui',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, size: 64),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.indigo[700]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timeline',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildTimelineItem(
              'Dibuat',
              data['createdAt'],
              Icons.add_circle_outline,
              Colors.blue,
            ),
            if (data['acceptedAt'] != null)
              _buildTimelineItem(
                'Diterima',
                data['acceptedAt'],
                Icons.check_circle_outline,
                Colors.green,
              ),
            if (data['startedAt'] != null)
              _buildTimelineItem(
                'Mulai Dikerjakan',
                data['startedAt'],
                Icons.play_circle_outline,
                Colors.orange,
              ),
            if (data['completedAt'] != null)
              _buildTimelineItem(
                'Selesai',
                data['completedAt'],
                Icons.done_all,
                Colors.purple,
                isLast: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String label,
    dynamic timestamp,
    IconData icon,
    Color color, {
    bool isLast = false,
  }) {
    String timeText = '-';
    if (timestamp != null) {
      if (timestamp is Timestamp) {
        timeText = DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate());
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(String status, Map<String, dynamic> data) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final assignedCleanerId = data['cleanerId'] as String?;

    // Jika request sudah completed, tidak ada action
    if (status == 'completed') {
      return Card(
        color: Colors.green[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Permintaan ini sudah diselesaikan',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Jika pending, tampilkan tombol Accept
    if (status == 'pending') {
      return ElevatedButton.icon(
        onPressed: _isProcessing ? null : () => _acceptRequest(data),
        icon: const Icon(Icons.check),
        label: const Text('Terima Permintaan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    // Jika sudah diterima tapi belum dimulai
    if (status == 'accepted' && assignedCleanerId == currentUser?.uid) {
      return ElevatedButton.icon(
        onPressed: _isProcessing ? null : () => _startRequest(data),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Mulai Pengerjaan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    // Jika sedang dikerjakan
    if (status == 'in_progress' && assignedCleanerId == currentUser?.uid) {
      return ElevatedButton.icon(
        onPressed: _isProcessing ? null : () => _completeRequest(data),
        icon: const Icon(Icons.done),
        label: const Text('Tandai Selesai'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    // Jika request sudah diambil oleh cleaner lain
    if (assignedCleanerId != null && assignedCleanerId != currentUser?.uid) {
      return Card(
        color: Colors.orange[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.orange),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Permintaan ini sedang ditangani petugas lain',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _acceptRequest(Map<String, dynamic> data) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terima Permintaan'),
        content: const Text('Apakah Anda yakin ingin menerima permintaan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('TERIMA'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .update({
        'status': 'accepted',
        'cleanerId': currentUser.uid,
        'cleanerName': currentUser.displayName ?? 'Petugas',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan berhasil diterima'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _startRequest(Map<String, dynamic> data) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mulai Pengerjaan'),
        content: const Text('Apakah Anda siap memulai pengerjaan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('MULAI'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .update({
        'status': 'in_progress',
        'startedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengerjaan dimulai'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _completeRequest(Map<String, dynamic> data) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tandai Selesai'),
        content: const Text(
          'Apakah Anda yakin pekerjaan sudah selesai? '
          'Status akan berubah menjadi completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('SELESAI'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pekerjaan berhasil diselesaikan!'),
          backgroundColor: Colors.purple,
        ),
      );

      // Navigate back setelah selesai
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null) return '-';
    if (timestamp is Timestamp) {
      return DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate());
    }
    return '-';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'accepted':
        return 'Diterima';
      case 'in_progress':
        return 'Sedang Dikerjakan';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }
}