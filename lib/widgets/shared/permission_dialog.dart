// lib/widgets/permission_dialog.dart

import 'package:flutter/material.dart';
import '../../services/permission_service.dart';

/// Reusable Permission Dialog
///
/// Menampilkan dialog ketika permission ditolak atau permanently denied
///
/// Usage:
/// ```dart
/// if (result.isDenied) {
///   showPermissionDialog(
///     context,
///     title: 'Izin Kamera Diperlukan',
///     message: result.message ?? 'Izinkan akses kamera',
///     isPermanentlyDenied: result.isPermanentlyDenied,
///   );
/// }
/// ```
Future<void> showPermissionDialog(
  BuildContext context, {
  required String title,
  required String message,
  required bool isPermanentlyDenied,
  VoidCallback? onRetry,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: !isPermanentlyDenied,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(
            isPermanentlyDenied ? Icons.lock : Icons.info_outline,
            color: isPermanentlyDenied ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (isPermanentlyDenied) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Buka Pengaturan → Aplikasi → CleanOffice → Izin',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!isPermanentlyDenied)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
        if (isPermanentlyDenied)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionService().openAppSettings();
            },
            child: const Text('Buka Pengaturan'),
          )
        else if (onRetry != null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry();
            },
            child: const Text('Coba Lagi'),
          ),
      ],
    ),
  );
}

/// Permission BottomSheet (Alternative UI)
///
/// Tampilan yang lebih menarik untuk explain kenapa butuh permission
Future<void> showPermissionBottomSheet(
  BuildContext context, {
  required String title,
  required String description,
  required IconData icon,
  required VoidCallback onAllow,
}) async {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: Colors.blue.shade700),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Nanti Saja'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onAllow();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Izinkan'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Simple helper untuk quick permission check dengan auto-dialog
///
/// Usage:
/// ```dart
/// final allowed = await checkAndRequestPermission(
///   context,
///   ref,
///   permissionType: PermissionType.camera,
/// );
/// if (allowed) {
///   // Proceed with action
/// }
/// ```
enum PermissionType { camera, photos, storage, notification }

Future<bool> checkAndRequestPermission(
  BuildContext context, {
  required PermissionType permissionType,
  bool showRationale = true,
}) async {
  final service = PermissionService();
  PermissionResult? result;

  // Show rationale bottom sheet first (optional)
  if (showRationale) {
    String title = '';
    String description = '';
    IconData icon = Icons.info;

    switch (permissionType) {
      case PermissionType.camera:
        title = 'Akses Kamera';
        description =
            'Kami memerlukan akses kamera untuk mengambil foto laporan kebersihan dan foto profil Anda';
        icon = Icons.camera_alt;
        break;
      case PermissionType.photos:
        title = 'Akses Galeri';
        description =
            'Kami memerlukan akses galeri untuk memilih foto dari perangkat Anda';
        icon = Icons.photo_library;
        break;
      case PermissionType.storage:
        title = 'Akses Penyimpanan';
        description =
            'Kami memerlukan akses penyimpanan untuk menyimpan file export (PDF, Excel)';
        icon = Icons.folder;
        break;
      case PermissionType.notification:
        title = 'Akses Notifikasi';
        description =
            'Kami memerlukan akses notifikasi untuk memberi tahu Anda tentang update laporan dan request';
        icon = Icons.notifications;
        break;
    }

    bool? shouldRequest = false;
    await showPermissionBottomSheet(
      context,
      title: title,
      description: description,
      icon: icon,
      onAllow: () => shouldRequest = true,
    );

    if (shouldRequest != true) return false;
  }

  // Request permission
  switch (permissionType) {
    case PermissionType.camera:
      result = await service.requestCamera();
      break;
    case PermissionType.photos:
      result = await service.requestPhotos();
      break;
    case PermissionType.storage:
      result = await service.requestStorage();
      break;
    case PermissionType.notification:
      result = await service.requestNotification();
      break;
  }

  // Handle result
  if (result.isGranted) {
    return true;
  } else if (result.isDenied) {
    if (context.mounted) {
      await showPermissionDialog(
        context,
        title: 'Izin Diperlukan',
        message: result.message ?? 'Mohon izinkan akses untuk melanjutkan',
        isPermanentlyDenied: result.isPermanentlyDenied,
        onRetry: () async {
          // Retry logic could be added here
        },
      );
    }
    return false;
  }

  return false;
}

