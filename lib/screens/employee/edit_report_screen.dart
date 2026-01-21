// lib/screens/employee/edit_report_screen.dart
// ✅ FIXED: Web support dengan UniversalImage

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/report.dart';
import '../../riverpod/employee_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/shared/universal_image.dart';

class EditReportScreen extends ConsumerStatefulWidget {
  final Report report;

  const EditReportScreen({
    super.key,
    required this.report,
  });

  @override
  ConsumerState<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends ConsumerState<EditReportScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  
  // ✅ Web-compatible: Simpan bytes instead of File
  Uint8List? _imageBytes;

  bool _isUrgent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.report.title);
    _locationController = TextEditingController(text: widget.report.location);
    _descriptionController = TextEditingController(text: widget.report.description ?? '');
    _isUrgent = widget.report.isUrgent;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      // ✅ Convert to bytes (works on both mobile and web)
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _takePhoto() async {
    if (kIsWeb) {
      // Web doesn't support camera, fallback to gallery
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kamera tidak didukung di web, silakan pilih dari galeri'),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!kIsWeb) // Only show camera option on mobile
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // ✅ Pass bytes instead of File for web compatibility
      await ref.read(employeeActionsProvider).updateReport(
        reportId: widget.report.id,
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        isUrgent: _isUrgent,
        imageBytes: _imageBytes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Laporan berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true = updated
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal memperbarui: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Laporan'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Judul tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Location Field
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lokasi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description Field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Catatan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Urgent Toggle
                    SwitchListTile(
                      title: const Text('Laporan Urgent'),
                      subtitle: const Text('Tandai jika membutuhkan perhatian segera'),
                      value: _isUrgent,
                      onChanged: (value) {
                        setState(() => _isUrgent = value);
                      },
                      thumbColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppTheme.error;
                          }
                          return Colors.grey.shade400;
                        },
                      ),
                    ),

                    // Image Section
                    Text(
                      'Foto Laporan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    
                    // ✅ Use UniversalImage for cross-platform compatibility
                    if (_imageBytes != null)
                      // New image preview
                      Stack(
                        children: [
                          UniversalImage(
                            imageBytes: _imageBytes,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _imageBytes = null;
                                });
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (widget.report.imageUrl != null)
                      // Existing image preview
                      UniversalImage(
                        imageUrl: widget.report.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(12),
                      )
                    else
                      // No image placeholder
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(Icons.image, size: 64, color: Colors.grey),
                        ),
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Change Photo Button
                    OutlinedButton.icon(
                      onPressed: _showImageSourceDialog,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(_imageBytes != null || widget.report.imageUrl != null 
                          ? 'Ganti Foto' 
                          : 'Tambah Foto'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitUpdate,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Simpan Perubahan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
