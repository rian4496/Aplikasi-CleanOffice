// lib/screens/employee/create_request_screen.dart
// 🎯 IMPROVED VERSION - Enhanced UI, Date Picker, Photo Upload, Validation

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';

final _logger = AppLogger('CreateRequestScreen');

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() =>
      _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  bool _isUrgent = false;
  bool _isSubmitting = false;
  DateTime? _preferredDateTime;
  File? _selectedImage;
  Uint8List? _webImage; // For web platform

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ==================== IMAGE PICKER ====================
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          // For web, read bytes
          final bytes = await image.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          // For mobile, use File
          setState(() {
            _selectedImage = File(image.path);
            _webImage = null;
          });
        }
        
        _logger.info('Image selected: ${image.name}');
      }
    } catch (e) {
      _logger.error('Image picker error', e);
      _showError('Gagal memilih gambar: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _webImage = null;
    });
  }

  // ==================== DATE TIME PICKER ====================
  Future<void> _selectDateTime() async {
    // Pick date first
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppConstants.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    // Then pick time
    if (!mounted) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppConstants.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      final selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      // ✅ Validation: Cannot select past time
      if (selectedDateTime.isBefore(DateTime.now())) {
        _showError('Waktu tidak boleh di masa lalu');
        return;
      }

      setState(() {
        _preferredDateTime = selectedDateTime;
      });
    }
  }

  // ==================== CONFIRMATION DIALOG ====================
  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.info_outline, color: AppConstants.primaryColor),
                SizedBox(width: 8),
                Text('Konfirmasi Permintaan'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pastikan data sudah benar:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildConfirmationRow(
                    Icons.location_on,
                    'Lokasi',
                    _locationController.text,
                  ),
                  const Divider(),
                  _buildConfirmationRow(
                    Icons.description,
                    'Deskripsi',
                    _descriptionController.text,
                  ),
                  if (_preferredDateTime != null) ...[
                    const Divider(),
                    _buildConfirmationRow(
                      Icons.access_time,
                      'Waktu',
                      DateFormat('EEEE, dd MMM yyyy - HH:mm', 'id_ID')
                          .format(_preferredDateTime!),
                    ),
                  ],
                  if (_selectedImage != null || _webImage != null) ...[
                    const Divider(),
                    _buildConfirmationRow(
                      Icons.image,
                      'Foto',
                      'Terlampir',
                    ),
                  ],
                  if (_isUrgent) ...[
                    const Divider(),
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'URGEN',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.send),
                label: const Text('Kirim'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildConfirmationRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== SUBMIT REQUEST ====================
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw const AuthException(message: 'User not logged in');
      }

      _logger.info('Creating cleaning request');

      // Upload image if selected (optional)
      String? imageUrl;
      if (_selectedImage != null || _webImage != null) {
        try {
          final storageService = ref.read(storageServiceProvider);
          final bytes = _webImage ?? await _selectedImage!.readAsBytes();
          
          final result = await storageService.uploadImage(
            bytes: bytes,
            folder: 'requests',
            userId: user.uid,
          );

          if (result.isSuccess && result.data != null) {
            imageUrl = result.data;
            _logger.info('✅ Image uploaded: $imageUrl');
          } else {
            _logger.warning('⚠️ Image upload failed: ${result.error}');
            // Continue without image
          }
        } catch (e) {
          _logger.error('Image upload error', e);
          // Continue without image, don't fail the request
        }
      }

      // Create request in Firestore
      final firestore = ref.read(firestoreProvider);
      final docRef = await firestore.collection('requests').add({
        'userId': user.uid,
        'userEmail': user.email,
        'userName': user.displayName ?? 'User',
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'isUrgent': _isUrgent,
        'preferredDateTime': _preferredDateTime,
        'imageUrl': imageUrl,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _logger.info('✅ Request created successfully with ID: ${docRef.id}');

      // Send notification to cleaners/admins
      try {
        await NotificationService().notifyNewRequest(
          requestId: docRef.id,
          location: _locationController.text.trim(),
          isUrgent: _isUrgent,
        );
        _logger.info('✅ Notification sent');
      } catch (e) {
        _logger.warning('⚠️ Failed to send notification: $e');
        // Don't fail the request creation
      }

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Permintaan berhasil dikirim!',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppConstants.successColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate back
      Navigator.pop(context);
    } on FirebaseException catch (e, stackTrace) {
      _logger.error('Create request error', e, stackTrace);
      final exception = FirestoreException.fromFirebase(e);
      _showError(exception.message);
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
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ==================== BUILD UI ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Permintaan Layanan Kebersihan'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==================== INFO CARD ====================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Buat permintaan untuk pembersihan area tertentu. Tim kami akan segera merespons.',
                        style: TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ==================== LOCATION ====================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Autocomplete<String>(
                  fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                    _locationController.text = controller.text;
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Lokasi *',
                        hintText: 'Ketik atau pilih lokasi',
                        prefixIcon: Icon(Icons.location_on, color: AppConstants.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
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
              ),
              const SizedBox(height: 16),

              // ==================== DESCRIPTION ====================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi *',
                    hintText: 'Jelaskan detail yang perlu dibersihkan',
                    prefixIcon: Icon(Icons.description, color: AppConstants.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
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
                  enabled: !_isSubmitting,
                ),
              ),
              const SizedBox(height: 16),

              // ==================== DATE TIME PICKER ====================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: const Text(
                    'Tanggal & Waktu yang Diinginkan',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    _preferredDateTime != null
                        ? DateFormat('EEEE, dd MMM yyyy - HH:mm', 'id_ID')
                            .format(_preferredDateTime!)
                        : 'Pilih tanggal & waktu (opsional)',
                    style: TextStyle(
                      color: _preferredDateTime != null
                          ? AppConstants.primaryColor
                          : Colors.grey[600],
                      fontWeight: _preferredDateTime != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  leading: Icon(
                    Icons.calendar_today,
                    color: AppConstants.primaryColor,
                  ),
                  trailing: _preferredDateTime != null
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _preferredDateTime = null),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _isSubmitting ? null : _selectDateTime,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ==================== PHOTO UPLOAD (OPTIONAL) ====================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (_selectedImage != null || _webImage != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: kIsWeb
                                ? Image.memory(
                                    _webImage!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    _selectedImage!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: _removeImage,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.photo_camera, color: AppConstants.primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Foto (Opsional)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  _selectedImage != null || _webImage != null
                                      ? 'Foto terlampir'
                                      : 'Tambahkan foto untuk detail lebih jelas',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedImage == null && _webImage == null)
                            OutlinedButton.icon(
                              onPressed: _isSubmitting ? null : _showImageSourceDialog,
                              icon: const Icon(Icons.add_a_photo, size: 18),
                              label: const Text('Pilih'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppConstants.primaryColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ==================== URGENT SWITCH ====================
              Container(
                decoration: BoxDecoration(
                  color: _isUrgent ? Colors.red[50] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isUrgent ? Colors.red : Colors.grey[300]!,
                    width: _isUrgent ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isUrgent
                          ? Colors.red.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    'Tandai sebagai Urgen',
                    style: TextStyle(
                      fontWeight: _isUrgent ? FontWeight.bold : FontWeight.w500,
                      color: _isUrgent ? Colors.red[700] : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Permintaan yang perlu segera ditangani',
                    style: TextStyle(
                      color: _isUrgent ? Colors.red[600] : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  value: _isUrgent,
                  onChanged: _isSubmitting
                      ? null
                      : (bool value) {
                          setState(() {
                            _isUrgent = value;
                          });
                        },
                  secondary: Icon(
                    _isUrgent ? Icons.warning : Icons.priority_high,
                    color: _isUrgent ? Colors.red[700] : Colors.grey,
                    size: 32,
                  ),
                  activeColor: Colors.red,
                ),
              ),
              const SizedBox(height: 32),

              // ==================== SUBMIT BUTTON ====================
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.send, size: 22),
                          SizedBox(width: 12),
                          Text(
                            'Kirim Permintaan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),

              // ==================== HELPER TEXT ====================
              Center(
                child: Text(
                  '* = Wajib diisi',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}