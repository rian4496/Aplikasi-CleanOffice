// lib/screens/shared/edit_profile_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD
// Edit Profile Screen with photo upload

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../models/user_profile.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/profile_providers.dart';

/// Edit Profile Screen with photo upload
/// ✅ MIGRATED: ConsumerStatefulWidget → HookConsumerWidget
class EditProfileScreen extends HookConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: Form key and logger
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final logger = useMemoized(() => AppLogger('EditProfileScreen'));

    // ✅ HOOKS: Auto-disposed controllers
    final nameController = useTextEditingController();
    final phoneController = useTextEditingController();
    final locationController = useTextEditingController();

    // ✅ HOOKS: State management
    final imageFile = useState<File?>(null);
    final currentPhotoUrl = useState<String?>(null);
    final userProfile = useState<UserProfile?>(null);
    final isLoading = useState(true);

    // ✅ HOOKS: Load user profile on mount
    useEffect(() {
      Future<void> loadUserProfile() async {
        try {
          final profile = await ref.read(currentUserProfileProvider.future);
          if (profile != null) {
            userProfile.value = profile;
            nameController.text = profile.displayName;
            phoneController.text = profile.phoneNumber ?? '';
            locationController.text = profile.location ?? '';
            currentPhotoUrl.value = profile.photoURL;
            isLoading.value = false;
          }
        } catch (e) {
          logger.error('Load profile error', e);
          isLoading.value = false;
        }
      }

      loadUserProfile();
      return null;
    }, const []);

    final profileState = ref.watch(profileActionsProvider);
    final isSaving = profileState.isLoading;

    if (isLoading.value) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 64,
                        backgroundColor: Colors.grey[200],
                        child: ClipOval(
                          child: SizedBox(
                            width: 128,
                            height: 128,
                            child: imageFile.value != null
                                ? Image.file(imageFile.value!, fit: BoxFit.cover)
                                : currentPhotoUrl.value != null
                                    ? CachedNetworkImage(
                                        imageUrl: currentPhotoUrl.value!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) => Icon(
                                          Icons.person,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: AppConstants.primaryColor,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: isSaving
                              ? null
                              : () => _showImageSourceDialog(
                                    context,
                                    ref,
                                    imageFile,
                                    currentPhotoUrl,
                                    userProfile,
                                    logger,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),

              // Name Field
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppConstants.requiredFieldMessage;
                  }
                  return null;
                },
                enabled: !isSaving,
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Phone Field
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  prefixIcon: Icon(Icons.phone),
                  hintText: 'Opsional',
                ),
                keyboardType: TextInputType.phone,
                enabled: !isSaving,
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Location Field
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi Kerja',
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'Opsional',
                ),
                enabled: !isSaving,
              ),
              const SizedBox(height: AppConstants.largePadding),

              // Save Button
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () => _updateProfile(
                          context,
                          ref,
                          formKey,
                          userProfile,
                          imageFile,
                          nameController,
                          phoneController,
                          locationController,
                          logger,
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== STATIC HELPERS ====================

  /// Show image source selection dialog
  static void _showImageSourceDialog(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<File?> imageFile,
    ValueNotifier<String?> currentPhotoUrl,
    ValueNotifier<UserProfile?> userProfile,
    AppLogger logger,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery, imageFile, logger);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera, imageFile, logger);
              },
            ),
            if (currentPhotoUrl.value != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Hapus Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePicture(
                    context,
                    ref,
                    currentPhotoUrl,
                    imageFile,
                    userProfile,
                    logger,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Pick image from gallery or camera
  static Future<void> _pickImage(
    BuildContext context,
    ImageSource source,
    ValueNotifier<File?> imageFile,
    AppLogger logger,
  ) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final bytes = await file.length();

        if (!AppConstants.isValidFileSize(bytes)) {
          _showError(
            context,
            'Ukuran file terlalu besar. Max ${AppConstants.formatFileSize(AppConstants.maxImageSizeBytes)}',
          );
          return;
        }

        imageFile.value = file;
      }
    } catch (e, stackTrace) {
      logger.error('Pick image error', e, stackTrace);
      _showError(context, 'Gagal memilih foto');
    }
  }

  /// Remove profile picture
  static Future<void> _removeProfilePicture(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<String?> currentPhotoUrl,
    ValueNotifier<File?> imageFile,
    ValueNotifier<UserProfile?> userProfile,
    AppLogger logger,
  ) async {
    if (currentPhotoUrl.value == null || userProfile.value == null) return;

    try {
      final actions = ref.read(profileActionsProvider.notifier);
      await actions.deleteProfilePicture(
        currentPhotoUrl.value!,
        userProfile.value!.uid,
      );

      currentPhotoUrl.value = null;
      imageFile.value = null;

      _showSuccess(context, 'Foto profil berhasil dihapus');
    } on StorageException catch (e) {
      logger.error('Delete photo error', e);
      _showError(context, e.message);
    } catch (e) {
      logger.error('Unexpected error', e);
      _showError(context, AppConstants.genericErrorMessage);
    }
  }

  /// Update profile with or without photo
  static Future<void> _updateProfile(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    ValueNotifier<UserProfile?> userProfile,
    ValueNotifier<File?> imageFile,
    TextEditingController nameController,
    TextEditingController phoneController,
    TextEditingController locationController,
    AppLogger logger,
  ) async {
    if (!formKey.currentState!.validate() || userProfile.value == null) return;

    try {
      final actions = ref.read(profileActionsProvider.notifier);

      if (imageFile.value != null) {
        // Update with new photo
        await actions.updateProfileWithPhoto(
          imageFile: imageFile.value!,
          profile: userProfile.value!.copyWith(
            displayName: nameController.text.trim(),
            phoneNumber: phoneController.text.trim().isEmpty
                ? null
                : phoneController.text.trim(),
            location: locationController.text.trim().isEmpty
                ? null
                : locationController.text.trim(),
          ),
        );
      } else {
        // Update without photo
        await actions.updateProfile(
          userProfile.value!.copyWith(
            displayName: nameController.text.trim(),
            phoneNumber: phoneController.text.trim().isEmpty
                ? null
                : phoneController.text.trim(),
            location: locationController.text.trim().isEmpty
                ? null
                : locationController.text.trim(),
          ),
        );
      }

      if (!context.mounted) return;

      _showSuccess(context, AppConstants.updateSuccessMessage);

      // Return true to indicate successful update
      Navigator.pop(context, true);
    } on StorageException catch (e) {
      logger.error('Storage error', e);
      _showError(context, e.message);
    } on DatabaseException catch (e) {
      logger.error('Firestore error', e);
      _showError(context, e.message);
    } catch (e, stackTrace) {
      logger.error('Update profile error', e, stackTrace);
      _showError(context, AppConstants.genericErrorMessage);
    }
  }

  /// Show error snackbar
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snackbar
  static void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
