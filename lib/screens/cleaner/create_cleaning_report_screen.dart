import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/cleaner_providers.dart';
import '../../providers/riverpod/supabase_service_providers.dart';
import '../../core/config/supabase_config.dart';

final _logger = AppLogger('CreateCleaningReportScreen');

class CreateCleaningReportScreen extends ConsumerStatefulWidget {
  const CreateCleaningReportScreen({super.key});

  @override
  ConsumerState<CreateCleaningReportScreen> createState() =>
      _CreateCleaningReportScreenState();
}

class _CreateCleaningReportScreenState
    extends ConsumerState<CreateCleaningReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  Uint8List? _imageBytes;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery, // Web doesn't support camera
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );

      if (pickedImage == null) return;

      // Read as bytes (works on both Web & Mobile)
      final bytes = await pickedImage.readAsBytes();

      // Validate file size
      if (!AppConstants.isValidFileSize(bytes.length)) {
        if (!mounted) return;
        _showError(
          'Ukuran file terlalu besar. Max ${AppConstants.formatFileSize(AppConstants.maxImageSizeBytes)}',
        );
        return;
      }

      setState(() {
        _imageBytes = bytes;
      });

      _logger.info('Image selected for cleaning report: ${bytes.length} bytes');
    } catch (e, stackTrace) {
      _logger.error('Error picking image', e, stackTrace);
      _showError('Gagal mengambil foto');
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageBytes == null) return null;

    try {
      final userProfile = ref.read(currentUserProfileProvider).value;
      if (userProfile == null) {
        throw const AuthException(message: 'User not logged in');
      }

      _logger.info('Uploading cleaning report image');

      final storageService = ref.read(supabaseStorageServiceProvider);
      final result = await storageService.uploadImage(
        bytes: _imageBytes!,
        bucket: SupabaseConfig.reportImagesBucket,
        userId: userProfile.uid,
      );

      if (result.isSuccess && result.data != null) {
        _logger.info('Cleaning report image uploaded successfully');
        return result.data;
      } else {
        _logger.error('Upload failed: ${result.error}');
        throw StorageException(message: result.error ?? 'Upload failed');
      }
    } catch (e, stackTrace) {
      _logger.error('Upload image error', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    // Image optional for cleaning reports

    setState(() => _isSubmitting = true);

    try {
      _logger.info('Creating cleaning report');

      // Upload image if exists
      String? imageUrl;
      if (_imageBytes != null) {
        imageUrl = await _uploadImage();
      }

      // Create report
      final actions = ref.read(cleanerActionsProvider.notifier);
      await actions.createCleaningReport(
        title: 'Laporan Kebersihan',
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
      );

      if (!mounted) return;

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
      _logger.error('Storage error', e);
      _showError(e.message);
    } on DatabaseException catch (e) {
      _logger.error('Firestore error', e);
      _showError(e.message);
    } catch (e, stackTrace) {
      _logger.error('Unexpected error', e, stackTrace);
      _showError(AppConstants.genericErrorMessage);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
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
              key: _formKey,
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
                  _buildImageSection(),
                  const SizedBox(height: AppConstants.largePadding),

                  // Location Field with Autocomplete
                  Autocomplete<String>(
                    fieldViewBuilder:
                        (context, controller, focusNode, onSubmit) {
                          _locationController.text = controller.text;
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
                            enabled: !_isSubmitting,
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
                      _locationController.text = selection;
                    },
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
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
                      if (value.trim().length <
                          AppConstants.minDescriptionLength) {
                        return 'Keterangan minimal ${AppConstants.minDescriptionLength} karakter';
                      }
                      return null;
                    },
                    enabled: !_isSubmitting,
                  ),
                  const SizedBox(height: AppConstants.largePadding),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[700],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                    ),
                    child: _isSubmitting
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
          if (_isSubmitting)
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

  Widget _buildImageSection() {
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
              onTap: _isSubmitting ? null : _takePicture,
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
                child: _imageBytes != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppConstants.defaultRadius - 2,
                            ),
                            child: Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
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
                                onPressed: _isSubmitting ? null : _takePicture,
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
}

