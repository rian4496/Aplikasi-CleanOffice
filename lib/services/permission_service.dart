// lib/services/permission_service.dart

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

/// Result pattern untuk permission handling
class PermissionResult {
  final bool isGranted;
  final bool isDenied;
  final bool isPermanentlyDenied;
  final String? message;

  const PermissionResult({
    required this.isGranted,
    required this.isDenied,
    required this.isPermanentlyDenied,
    this.message,
  });

  factory PermissionResult.granted() => const PermissionResult(
        isGranted: true,
        isDenied: false,
        isPermanentlyDenied: false,
      );

  factory PermissionResult.denied({String? message}) => PermissionResult(
        isGranted: false,
        isDenied: true,
        isPermanentlyDenied: false,
        message: message,
      );

  factory PermissionResult.permanentlyDenied({String? message}) =>
      PermissionResult(
        isGranted: false,
        isDenied: true,
        isPermanentlyDenied: true,
        message: message,
      );
}

/// Centralized Permission Service
///
/// Handles all permission requests dengan:
/// - Proper error handling
/// - User-friendly messages
/// - Settings redirection untuk permanent denial
///
/// Usage:
/// ```dart
/// final permissionService = PermissionService();
/// final result = await permissionService.requestCamera();
/// if (result.isGranted) {
///   // Proceed with camera action
/// } else if (result.isPermanentlyDenied) {
///   // Show dialog to open settings
/// }
/// ```
class PermissionService {
  // Singleton pattern
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // ==================== CAMERA PERMISSION ====================

  /// Request camera permission
  /// Returns PermissionResult dengan status detail
  Future<PermissionResult> requestCamera() async {
    try {
      final status = await Permission.camera.status;

      // Already granted
      if (status.isGranted) {
        return PermissionResult.granted();
      }

      // Permanently denied - redirect to settings
      if (status.isPermanentlyDenied) {
        return PermissionResult.permanentlyDenied(
          message:
              'Akses kamera ditolak secara permanen. Silakan aktifkan di pengaturan aplikasi.',
        );
      }

      // Request permission
      final result = await Permission.camera.request();

      if (result.isGranted) {
        return PermissionResult.granted();
      } else if (result.isPermanentlyDenied) {
        return PermissionResult.permanentlyDenied(
          message:
              'Akses kamera ditolak secara permanen. Silakan aktifkan di pengaturan aplikasi.',
        );
      } else {
        return PermissionResult.denied(
          message:
              'Akses kamera diperlukan untuk mengambil foto laporan dan profil.',
        );
      }
    } catch (e) {
      debugPrint('❌ Error requesting camera permission: $e');
      return PermissionResult.denied(
        message: 'Gagal meminta izin kamera: $e',
      );
    }
  }

  // ==================== PHOTOS/GALLERY PERMISSION ====================

  /// Request photos/gallery permission
  /// Handles both Android (READ_MEDIA_IMAGES) and iOS (Photo Library)
  Future<PermissionResult> requestPhotos() async {
    try {
      final status = await Permission.photos.status;

      if (status.isGranted) {
        return PermissionResult.granted();
      }

      if (status.isPermanentlyDenied) {
        return PermissionResult.permanentlyDenied(
          message:
              'Akses galeri ditolak secara permanen. Silakan aktifkan di pengaturan aplikasi.',
        );
      }

      final result = await Permission.photos.request();

      if (result.isGranted) {
        return PermissionResult.granted();
      } else if (result.isPermanentlyDenied) {
        return PermissionResult.permanentlyDenied(
          message:
              'Akses galeri ditolak secara permanen. Silakan aktifkan di pengaturan aplikasi.',
        );
      } else {
        return PermissionResult.denied(
          message:
              'Akses galeri diperlukan untuk memilih foto laporan dan profil.',
        );
      }
    } catch (e) {
      debugPrint('❌ Error requesting photos permission: $e');
      return PermissionResult.denied(
        message: 'Gagal meminta izin galeri: $e',
      );
    }
  }

  // ==================== STORAGE PERMISSION ====================

  /// Request storage permission (untuk export PDF/Excel)
  /// Android <13: READ_EXTERNAL_STORAGE
  /// Android 13+: Managed automatically
  Future<PermissionResult> requestStorage() async {
    try {
      final status = await Permission.storage.status;

      if (status.isGranted) {
        return PermissionResult.granted();
      }

      if (status.isPermanentlyDenied) {
        return PermissionResult.permanentlyDenied(
          message:
              'Akses penyimpanan ditolak secara permanen. Silakan aktifkan di pengaturan aplikasi.',
        );
      }

      final result = await Permission.storage.request();

      if (result.isGranted) {
        return PermissionResult.granted();
      } else if (result.isPermanentlyDenied) {
        return PermissionResult.permanentlyDenied(
          message:
              'Akses penyimpanan ditolak secara permanen. Silakan aktifkan di pengaturan aplikasi.',
        );
      } else {
        return PermissionResult.denied(
          message:
              'Akses penyimpanan diperlukan untuk menyimpan file export (PDF, Excel).',
        );
      }
    } catch (e) {
      debugPrint('❌ Error requesting storage permission: $e');
      return PermissionResult.denied(
        message: 'Gagal meminta izin penyimpanan: $e',
      );
    }
  }

  // ==================== NOTIFICATION PERMISSION ====================

  /// Request notification permission (Android 13+)
  Future<PermissionResult> requestNotification() async {
    try {
      final status = await Permission.notification.status;

      if (status.isGranted) {
        return PermissionResult.granted();
      }

      if (status.isPermanentlyDenied) {
        return PermissionResult.permanentlyDenied(
          message:
              'Akses notifikasi ditolak secara permanen. Silakan aktifkan di pengaturan aplikasi.',
        );
      }

      final result = await Permission.notification.request();

      if (result.isGranted) {
        return PermissionResult.granted();
      } else if (result.isPermanentlyDenied) {
        return PermissionResult.permanentlyDenied(
          message:
              'Akses notifikasi ditolak secara permanen. Silakan aktifkan di pengaturan aplikasi.',
        );
      } else {
        return PermissionResult.denied(
          message:
              'Akses notifikasi diperlukan untuk menerima update laporan dan request.',
        );
      }
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');
      return PermissionResult.denied(
        message: 'Gagal meminta izin notifikasi: $e',
      );
    }
  }

  // ==================== HELPER METHODS ====================

  /// Open app settings
  /// Digunakan ketika permission permanently denied
  Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      debugPrint('❌ Error opening app settings: $e');
      return false;
    }
  }

  /// Check apakah permission sudah granted (tanpa request)
  Future<bool> isCameraGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  Future<bool> isPhotosGranted() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  Future<bool> isStorageGranted() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  Future<bool> isNotificationGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  // ==================== COMBINED PERMISSIONS ====================

  /// Request both camera and photos permission
  /// Berguna untuk image picker yang support both camera dan gallery
  Future<Map<String, PermissionResult>> requestCameraAndPhotos() async {
    final cameraResult = await requestCamera();
    final photosResult = await requestPhotos();

    return {
      'camera': cameraResult,
      'photos': photosResult,
    };
  }

  /// Request multiple permissions sekaligus
  Future<Map<Permission, PermissionStatus>> requestMultiple(
    List<Permission> permissions,
  ) async {
    try {
      return await permissions.request();
    } catch (e) {
      debugPrint('❌ Error requesting multiple permissions: $e');
      return {};
    }
  }
}

