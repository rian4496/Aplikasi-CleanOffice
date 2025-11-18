// lib/screens/cleaner/create_cleaning_report_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/cleaner_providers.dart';

/// Screen for cleaners to create cleaning reports
/// ✅ MIGRATED: ConsumerStatefulWidget → HookConsumerWidget
class CreateCleaningReportScreen extends HookConsumerWidget {
  const CreateCleaningReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: Form key
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // ✅ HOOKS: Logger
    final logger = useMemoized(() => AppLogger('CreateCleaningReportScreen'));

    // ✅ HOOKS: Auto-disposed controllers
    final locationController = useTextEditingController();
    final descriptionController = useTextEditingController();

    // ✅ HOOKS: State management
    final selectedImage = useState<File?>(null);
    final isSubmitting = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan Kebersihan'),
        backgroundColor: Colors.indigo[700],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info Card
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: AppConstants.defaultPadding),
                          const Expanded(
                            child: Text(
                              'Laporan untuk area yang sudah Anda bersihkan',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.largePadding),

                  // Image Section (Optional)
                  _buildImageSection(context, selectedImage, isSubmitting, logger),
                  const SizedBox(height: AppConstants.largePadding),

                  // Location Field with Autocomplete
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

                  // Description Field
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Keterangan',
                      hintText: 'Jelaskan pekerjaan yang sudah dilakukan...',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 4,
                    maxLength: AppConstants.maxDescriptionLength,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppConstants.requiredFieldMessage;
                      }
                      if (value.trim().length < AppConstants.minDescriptionLength) {
                        return 'Keterangan minimal ${AppConstants.minDescriptionLength} karakter';
                      }
                      return null;
                    },
                    enabled: !isSubmitting.value,
                  ),
                  const SizedBox(height: AppConstants.largePadding),

                  // Submit Button
                  ElevatedButton(
                    onPressed: isSubmitting.value
                        ? null
                        : () => _submitReport(
                              context,
                              ref,
                              formKey,
                              locationController,
                              descriptionController,
                              selectedImage,
                              isSubmitting,
                              logger,
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[700],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                    ),
                    child: isSubmitting.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
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

  // ==================== STATIC HELPERS ====================

  /// Build image section
  static Widget _buildImageSection(
    BuildContext context,
    ValueNotifier<File?> selectedImage,
    ValueNotifier<bool> isSubmitting,
    AppLogger logger,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text(
                  'Foto (Opsional)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Chip(
                  label: Text('Opsional', style: TextStyle(fontSize: 10)),
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            GestureDetector(
              onTap: isSubmitting.value
                  ? null
                  : () => _takePicture(context, selectedImage, logger),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultRadius,
                  ),
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                ),
                child: selectedImage.value != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppConstants.defaultRadius - 2,
                            ),
                            child: Image.file(
                              selectedImage.value!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withValues(
                                alpha: 0.5,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                ),
                                onPressed: isSubmitting.value
                                    ? null
                                    : () => _takePicture(context, selectedImage, logger),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Ketuk untuk ambil foto',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '(Jika diperlukan)',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
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

  /// Take picture
  static Future<void> _takePicture(
    BuildContext context,
    ValueNotifier<File?> selectedImage,
    AppLogger logger,
  ) async {
    try {
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );

      if (pickedImage == null) return;

      final file = File(pickedImage.path);

      // Validate file size
      final bytes = await file.length();
      if (!AppConstants.isValidFileSize(bytes)) {
        if (!context.mounted) return;
        _showError(
          context,
          'Ukuran file terlalu besar. Max ${AppConstants.formatFileSize(AppConstants.maxImageSizeBytes)}',
        );
        return;
      }

      selectedImage.value = file;
      logger.info('Image selected for cleaning report');
    } catch (e, stackTrace) {
      logger.error('Error picking image', e, stackTrace);
      if (!context.mounted) return;
      _showError(context, 'Gagal mengambil foto');
    }
  }

  /// Upload image to Firebase Storage
  static Future<String?> _uploadImage(
    WidgetRef ref,
    File? selectedImage,
    AppLogger logger,
  ) async {
    if (selectedImage == null) return null;

    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw const AuthException(message: 'User not logged in');
      }

      logger.info('Uploading cleaning report image');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'cleaning_report_$timestamp.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(
            '${AppConstants.reportImagesPath}/${user.uid}/$fileName',
          );

      final uploadTask = await storageRef.putFile(selectedImage);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      logger.info('Cleaning report image uploaded successfully');
      return downloadUrl;
    } on FirebaseException catch (e, stackTrace) {
      logger.error('Upload image error', e, stackTrace);
      throw StorageException.fromFirebase(e);
    }
  }

  /// Submit cleaning report
  static Future<void> _submitReport(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    TextEditingController locationController,
    TextEditingController descriptionController,
    ValueNotifier<File?> selectedImage,
    ValueNotifier<bool> isSubmitting,
    AppLogger logger,
  ) async {
    if (!formKey.currentState!.validate()) return;

    // Image optional for cleaning reports

    isSubmitting.value = true;

    try {
      logger.info('Creating cleaning report');

      // Upload image if exists
      String? imageUrl;
      if (selectedImage.value != null) {
        imageUrl = await _uploadImage(ref, selectedImage.value, logger);
      }

      // Create report
      final actions = ref.read(cleanerActionsProvider.notifier);
      await actions.createCleaningReport(
        location: locationController.text.trim(),
        description: descriptionController.text.trim(),
        imageUrl: imageUrl,
      );

      if (!context.mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Laporan kebersihan berhasil dibuat'),
            ],
          ),
          backgroundColor: AppConstants.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    } on StorageException catch (e) {
      logger.error('Storage error', e);
      if (!context.mounted) return;
      _showError(context, e.message);
    } on FirestoreException catch (e) {
      logger.error('Firestore error', e);
      if (!context.mounted) return;
      _showError(context, e.message);
    } catch (e, stackTrace) {
      logger.error('Unexpected error', e, stackTrace);
      if (!context.mounted) return;
      _showError(context, AppConstants.genericErrorMessage);
    } finally {
      if (context.mounted) {
        isSubmitting.value = false;
      }
    }
  }

  /// Show error snackbar
  static void _showError(BuildContext context, String message) {
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
}
