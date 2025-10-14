import 'package:flutter/material.dart';
import 'package:aplikasi_cleanoffice/screens/report_detail_screen.dart';

// Model class for notification data
class _Notification {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color iconColor;
  bool isUnread;

  _Notification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isUnread = false,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // --- Color Palette ---
  static const Color _primaryColor = Color(0xFF2C3E50);
  static const Color _backgroundColor = Color(0xFFF7F9FA);
  static const Color _cardBackgroundColor = Colors.white;
  static const Color _primaryTextColor = Colors.black87;
  static const Color _secondaryTextColor = Color(0xFF757575);

  // --- State: List of notifications ---
  late List<_Notification> _notifications;

  @override
  void initState() {
    super.initState();
    // Initialize mock data
    _notifications = [
      _Notification(
        id: 'report-001',
        icon: Icons.cleaning_services_rounded,
        iconColor: const Color(0xFF4CAF50),
        title: 'Laporan Selesai',
        subtitle: 'Laporan untuk "Toilet Lt. 2" telah diselesaikan oleh Budi.',
        time: '5 menit yang lalu',
        isUnread: true,
      ),
      _Notification(
        id: 'report-002',
        icon: Icons.assignment_late_rounded,
        iconColor: const Color(0xFFFF9800),
        title: 'Laporan Baru Masuk',
        subtitle:
            'Laporan baru untuk "Area Pantry" membutuhkan perhatian Anda.',
        time: '30 menit yang lalu',
        isUnread: true,
      ),
      _Notification(
        id: 'report-003',
        icon: Icons.verified_user_rounded,
        iconColor: const Color(0xFF2196F3),
        title: 'Verifikasi Dibutuhkan',
        subtitle: 'Pekerjaan di "Ruang Rapat A" menunggu verifikasi Anda.',
        time: '1 jam yang lalu',
        isUnread: false,
      ),
      _Notification(
        id: 'user-001',
        icon: Icons.person_add_alt_1_rounded,
        iconColor: const Color(0xFF673AB7),
        title: 'Pengguna Baru Terdaftar',
        subtitle: 'Pengguna baru, Sarah, telah mendaftar sebagai Karyawan.',
        time: '3 jam yang lalu',
        isUnread: false,
      ),
    ];
  }

  String _getStatusFromTitle(String title) {
    if (title.contains('Selesai')) {
      return 'Selesai';
    } else if (title.contains('Baru Masuk')) {
      return 'Terkirim';
    } else if (title.contains('Verifikasi')) {
      return 'Dikerjakan';
    }
    return 'Terkirim'; // Default status
  }

  void _handleNotificationTap(int index) {
    final notification = _notifications[index];

    // 1. Mark as read
    if (notification.isUnread) {
      setState(() {
        notification.isUnread = false;
      });
    }

    // 2. Navigate to detail page if it's a report notification
    if (notification.id.startsWith('report-')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportDetailScreen(
            title: notification.subtitle,
            date: notification.time,
            status: _getStatusFromTitle(notification.title),
          ),
        ),
      );
    }
    // You can add else-if for other notification types, e.g., user profiles
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Notifikasi', style: TextStyle(color: Colors.white)),
        backgroundColor: _primaryColor,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: _cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notification.iconColor.withAlpha((255 * 0.1).round()),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification.icon,
                  color: notification.iconColor,
                  size: 24,
                ),
              ),
              title: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _primaryTextColor,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    notification.subtitle,
                    style: TextStyle(color: _secondaryTextColor, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.time,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
              trailing: notification.isUnread
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3498DB), // Accent color for unread dot
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
              onTap: () => _handleNotificationTap(index),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
          );
        },
      ),
    );
  }
}
