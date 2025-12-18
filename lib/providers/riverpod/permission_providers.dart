// lib/providers/riverpod/permission_providers.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/permission_service.dart';

// ==================== SERVICE PROVIDER ====================

/// Provider untuk PermissionService (singleton)
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

// ==================== PERMISSION STATUS PROVIDERS ====================

/// Provider untuk camera permission status
/// Auto-refresh when app resumes
final cameraPermissionProvider = FutureProvider<PermissionStatus>((ref) async {
  return await Permission.camera.status;
});

/// Provider untuk photos permission status
final photosPermissionProvider = FutureProvider<PermissionStatus>((ref) async {
  return await Permission.photos.status;
});

/// Provider untuk storage permission status
final storagePermissionProvider =
    FutureProvider<PermissionStatus>((ref) async {
  return await Permission.storage.status;
});

/// Provider untuk notification permission status
final notificationPermissionProvider =
    FutureProvider<PermissionStatus>((ref) async {
  return await Permission.notification.status;
});

// ==================== PERMISSION ACTION PROVIDERS ====================

/// Provider untuk camera permission actions
final cameraPermissionActionsProvider =
    Provider<CameraPermissionActions>((ref) {
  final service = ref.watch(permissionServiceProvider);
  return CameraPermissionActions(service, ref);
});

/// Provider untuk photos permission actions
final photosPermissionActionsProvider =
    Provider<PhotosPermissionActions>((ref) {
  final service = ref.watch(permissionServiceProvider);
  return PhotosPermissionActions(service, ref);
});

/// Provider untuk storage permission actions
final storagePermissionActionsProvider =
    Provider<StoragePermissionActions>((ref) {
  final service = ref.watch(permissionServiceProvider);
  return StoragePermissionActions(service, ref);
});

// ==================== ACTION CLASSES ====================

/// Camera permission actions
class CameraPermissionActions {
  final PermissionService _service;
  final Ref _ref;

  CameraPermissionActions(this._service, this._ref);

  Future<PermissionResult> request() async {
    final result = await _service.requestCamera();
    // Refresh provider after request
    _ref.invalidate(cameraPermissionProvider);
    return result;
  }

  Future<bool> isGranted() => _service.isCameraGranted();
}

/// Photos permission actions
class PhotosPermissionActions {
  final PermissionService _service;
  final Ref _ref;

  PhotosPermissionActions(this._service, this._ref);

  Future<PermissionResult> request() async {
    final result = await _service.requestPhotos();
    _ref.invalidate(photosPermissionProvider);
    return result;
  }

  Future<bool> isGranted() => _service.isPhotosGranted();
}

/// Storage permission actions
class StoragePermissionActions {
  final PermissionService _service;
  final Ref _ref;

  StoragePermissionActions(this._service, this._ref);

  Future<PermissionResult> request() async {
    final result = await _service.requestStorage();
    _ref.invalidate(storagePermissionProvider);
    return result;
  }

  Future<bool> isGranted() => _service.isStorageGranted();
}

// ==================== HELPER EXTENSIONS ====================

/// Extension untuk PermissionStatus agar lebih mudah digunakan
extension PermissionStatusX on PermissionStatus {
  bool get isAllowed => this == PermissionStatus.granted;
  bool get isNotAllowed => this != PermissionStatus.granted;
}

