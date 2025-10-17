import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/app_constants.dart';
import '../core/error/exceptions.dart';
import '../core/logging/app_logger.dart';
import '../providers/riverpod/auth_providers.dart';
import '../providers/riverpod/employee_providers.dart';

final _logger = AppLogger('CreateReportScreen');

class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // ✅ FIXED: Hanya gunakan Uint8List (in-memory)
  Uint8List? _imageBytes;
  
  bool _isUrgent = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    // ✅ No file cleanup needed - bytes will be garbage collected
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );

      if (pickedImage == null) return;

      // ✅ FIXED: Read image as bytes immediately (no file system involved)
      final bytes = await pickedImage.readAsBytes();
      
      _logger.info('Image captured: ${bytes.length} bytes');

      // Validate file size
      if (!AppConstants.isValidFileSize(bytes.length)) {
        if (!mounted) return;
        _showError(
          'Ukuran file terlalu besar. Max ${AppConstants.formatFileSize(AppConstants.maxImageSizeBytes)}',
        );
        return;
      }

      // Validate image is not empty
      if (bytes.isEmpty) {
        if (!mounted) return;
        _showError('Foto tidak valid atau kosong');
        return;
      }

      setState(() {
        _imageBytes = bytes;
      });

      _logger.info('Image ready for upload: ${bytes.length} bytes');
    } catch (e, stackTrace) {
      _logger.error('Error picking image', e, stackTrace);
      _showError('Gagal mengambil foto: ${e.toString()}');
    }
  }

  Future<String?> _uploadImage() async {
    // ✅ FIXED: Validasi bytes exist
    if (_imageBytes == null || _imageBytes!.isEmpty) {
      throw const StorageException(message: 'File foto tidak ditemukan');
    }

    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw const AuthException(message: 'User not logged in');
      }

      _logger.info('Uploading report image for user: ${user.uid}');
      _logger.info('Image size: ${_imageBytes!.length} bytes');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'report_$timestamp.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(
        '${AppConstants.reportImagesPath}/${user.uid}/$fileName',
      );

      // ✅ FIXED: Upload directly from bytes (no file involved!)
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': user.uid,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Use putData instead of putFile
      final uploadTask = await storageRef.putData(_imageBytes!, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      _logger.info('Image uploaded successfully: $downloadUrl');

      return downloadUrl;
    } on FirebaseException catch (e, stackTrace) {
      _logger.error('Upload image error', e, stackTrace);
      throw StorageException.fromFirebase(e);
    } catch (e, stackTrace) {
      _logger.error('Unexpected upload error', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ FIXED: Validasi foto WAJIB
    if (_imageBytes == null) {
      _showError('Mohon ambil foto terlebih dahulu');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      _logger.info('Submitting report');

      final imageUrl = await _uploadImage();

      if (imageUrl == null) {
        throw const StorageException(message: 'Failed to upload image');
      }

      final actions = ref.read(employeeActionsProvider);
      await actions.createReport(
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        isUrgent: _isUrgent,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
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
      _showError(e.message);
    } on FirestoreException catch (e) {
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
      appBar: AppBar(title: const Text('Laporkan Masalah Kebersihan')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImageSection(),
                  const SizedBox(height: AppConstants.largePadding),

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

                  TextFormField(
                    controller: _descriptionController,
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
                      if (value.trim().length <
                          AppConstants.minDescriptionLength) {
                        return 'Deskripsi minimal ${AppConstants.minDescriptionLength} karakter';
                      }
                      return null;
                    },
                    enabled: !_isSubmitting,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  SwitchListTile(
                    title: const Text('Tandai sebagai Urgen'),
                    subtitle: const Text('Masalah yang perlu segera ditangani'),
                    value: _isUrgent,
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            setState(() => _isUrgent = value);
                          },
                    secondary: Icon(
                      Icons.priority_high,
                      color: _isUrgent ? AppConstants.errorColor : null,
                    ),
                  ),
                  const SizedBox(height: AppConstants.largePadding),

                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
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
                  'Foto Masalah',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                // ✅ Badge wajib
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
              onTap: _isSubmitting ? null : _takePicture,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultRadius,
                  ),
                  border: Border.all(
                    // ✅ Red border jika belum ada foto
                    color: _imageBytes == null 
                        ? Colors.red.shade400 
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: _imageBytes != null
                    ? Stack(
                        children: [
                          // ✅ FIXED: Display image dari bytes
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
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 60, color: Colors.red.shade300),
                          const SizedBox(height: 8),
                          Text(
                            'Ketuk untuk mengambil foto',
                            style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
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