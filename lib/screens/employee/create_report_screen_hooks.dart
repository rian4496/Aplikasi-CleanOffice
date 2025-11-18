// lib/screens/employee/create_report_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/logging/app_logger.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/employee_providers.dart';
import '../../services/storage_service.dart';

final _logger = AppLogger('CreateReportScreen');

class CreateReportScreen extends HookConsumerWidget {
  const CreateReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: Auto-disposed controllers
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final locationController = useTextEditingController();
    final descriptionController = useTextEditingController();

    // ✅ HOOKS: State management (replaces setState)
    final imageBytes = useState<Uint8List?>(null);
    final isUrgent = useState(false);
    final isSubmitting = useState(false);

    // ✅ HELPER: Take picture
    Future<void> takePicture() async {
      try {
        final imagePicker = ImagePicker();
        final pickedImage = await imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: AppConstants.maxImageWidth.toDouble(),
          imageQuality: AppConstants.imageQuality,
        );

        if (pickedImage == null) return;

        final bytes = await pickedImage.readAsBytes();

        _logger.info('Image captured: ${bytes.length} bytes');

        if (!AppConstants.isValidFileSize(bytes.length)) {
          if (!context.mounted) return;
          showError(
            context,
            'Ukuran file terlalu besar. Max ${AppConstants.formatFileSize(AppConstants.maxImageSizeBytes)}',
          );
          return;
        }

        if (bytes.isEmpty) {
          if (!context.mounted) return;
          showError(context, 'Foto tidak valid atau kosong');
          return;
        }

        imageBytes.value = bytes; // ✅ Update state (no setState needed!)

        _logger.info('Image ready for upload: ${bytes.length} bytes');
      } catch (e, stackTrace) {
        _logger.error('Error picking image', e, stackTrace);
        showError(context, 'Gagal mengambil foto: ${e.toString()}');
      }
    }

    // ✅ HELPER: Upload image
    Future<String?> uploadImage() async {
      if (imageBytes.value == null) {
        throw const StorageException(message: 'File foto tidak ditemukan');
      }

      try {
        final user = ref.read(firebaseAuthProvider).currentUser;
        if (user == null) {
          throw const AuthException(message: 'User not logged in');
        }

        _logger.info('Uploading report image for user: ${user.uid}');

        final storageService = ref.read(storageServiceProvider);
        final result = await storageService.uploadImage(
          bytes: imageBytes.value!,
          folder: 'reports',
          userId: user.uid,
        );

        if (result.isSuccess) {
          _logger.info('Image uploaded successfully: ${result.data}');
          return result.data;
        } else {
          _logger.error('Upload failed: ${result.error}');
          throw StorageException(message: result.error ?? 'Upload failed');
        }
      } catch (e, stackTrace) {
        _logger.error('Upload error', e, stackTrace);
        rethrow;
      }
    }

    // ✅ HELPER: Submit report
    Future<void> submitReport() async {
      if (!formKey.currentState!.validate()) return;

      if (imageBytes.value == null) {
        showError(context, 'Mohon ambil foto terlebih dahulu');
        return;
      }

      isSubmitting.value = true; // ✅ Update state

      try {
        _logger.info('Submitting report');

        final imageUrl = await uploadImage();

        if (imageUrl == null) {
          throw const StorageException(message: 'Failed to upload image');
        }

        final actions = ref.read(employeeActionsProvider);
        await actions.createReport(
          location: locationController.text.trim(),
          description: descriptionController.text.trim(),
          imageUrl: imageUrl,
          isUrgent: isUrgent.value,
        );

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text(AppConstants.submitSuccessMessage),
              ],
            ),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);
      } on StorageException catch (e) {
        _logger.error('Storage error', e);
        showError(context, e.message);
      } on FirestoreException catch (e) {
        _logger.error('Firestore error', e);
        showError(context, e.message);
      } catch (e, stackTrace) {
        _logger.error('Unexpected error', e, stackTrace);
        showError(context, AppConstants.genericErrorMessage);
      } finally {
        if (context.mounted) {
          isSubmitting.value = false; // ✅ Update state
        }
      }
    }

    // ✅ BUILD UI
    return Scaffold(
      appBar: AppBar(title: const Text('Laporkan Masalah Kebersihan')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImageSection(
                    imageBytes.value,
                    takePicture,
                    isSubmitting.value,
                  ),
                  const SizedBox(height: AppConstants.largePadding),

                  Autocomplete<String>(
                    fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                      locationController.text = controller.text;
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Lokasi',
                          hintText: 'Ketik atau pilih lokasi',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppConstants.requiredFieldMessage;
                          }
                          return null;
                        },
                        enabled: !isSubmitting.value,
                      );
                    },
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return AppConstants.predefinedLocations.where((location) {
                        return location.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        );
                      });
                    },
                    onSelected: (selection) {
                      locationController.text = selection;
                    },
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      hintText: 'Jelaskan masalah singkat...',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 4,
                    maxLength: AppConstants.maxDescriptionLength,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppConstants.requiredFieldMessage;
                      }
                      if (value.trim().length < AppConstants.minDescriptionLength) {
                        return 'Deskripsi minimal ${AppConstants.minDescriptionLength} karakter';
                      }
                      return null;
                    },
                    enabled: !isSubmitting.value,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  SwitchListTile(
                    title: const Text('Tandai sebagai Urgen'),
                    subtitle: const Text('Masalah yang perlu segera ditangani'),
                    value: isUrgent.value,
                    onChanged: isSubmitting.value
                        ? null
                        : (value) {
                            isUrgent.value = value; // ✅ Direct update!
                          },
                    secondary: Icon(
                      Icons.priority_high,
                      color: isUrgent.value ? AppConstants.errorColor : null,
                    ),
                  ),
                  const SizedBox(height: AppConstants.largePadding),

                  ElevatedButton(
                    onPressed: isSubmitting.value ? null : submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                    ),
                    child: isSubmitting.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send),
                              SizedBox(width: 8),
                              Text(
                                'Kirim Laporan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
          if (isSubmitting.value)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.largePadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: AppConstants.defaultPadding),
                        Text('Mengirim laporan...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ STATIC HELPER: Show error
  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;
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

  // ✅ STATIC HELPER: Build image section
  static Widget _buildImageSection(
    Uint8List? imageBytes,
    VoidCallback onTakePicture,
    bool isSubmitting,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  'Foto Masalah',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Chip(
                  label: Text('Wajib', style: TextStyle(fontSize: 10)),
                  backgroundColor: Colors.red,
                  labelStyle: TextStyle(color: Colors.white),
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            GestureDetector(
              onTap: isSubmitting ? null : onTakePicture,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                  border: Border.all(
                    color: imageBytes == null
                        ? Colors.red.shade400
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: imageBytes != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppConstants.defaultRadius - 2,
                            ),
                            child: Image.memory(
                              imageBytes,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withValues(alpha: 0.5),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                ),
                                onPressed: isSubmitting ? null : onTakePicture,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 60, color: Colors.red.shade300),
                          const SizedBox(height: 8),
                          Text(
                            'Ketuk untuk mengambil foto',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '(Foto masalah kebersihan wajib)',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
