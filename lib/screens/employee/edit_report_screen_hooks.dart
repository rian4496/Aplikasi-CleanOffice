// lib/screens/employee/edit_report_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/report.dart';
import '../../providers/riverpod/employee_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/universal_image.dart';

/// Edit Report Screen - Form to update existing report
/// ✅ MIGRATED: ConsumerStatefulWidget → HookConsumerWidget
class EditReportScreen extends HookConsumerWidget {
  final Report report;

  const EditReportScreen({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: Form key
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // ✅ HOOKS: Auto-disposed controllers with initial values
    final titleController = useTextEditingController(text: report.title);
    final locationController = useTextEditingController(text: report.location);
    final descriptionController = useTextEditingController(
      text: report.description ?? '',
    );

    // ✅ HOOKS: State management
    final imageBytes = useState<Uint8List?>(null);
    final isUrgent = useState(report.isUrgent);
    final isLoading = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Laporan'),
        elevation: 0,
      ),
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    TextFormField(
                      controller: titleController,
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
                      enabled: !isLoading.value,
                    ),
                    const SizedBox(height: 16),

                    // Location Field
                    TextFormField(
                      controller: locationController,
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
                      enabled: !isLoading.value,
                    ),
                    const SizedBox(height: 16),

                    // Description Field
                    TextFormField(
                      controller: descriptionController,
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
                      enabled: !isLoading.value,
                    ),
                    const SizedBox(height: 16),

                    // Urgent Toggle
                    SwitchListTile(
                      title: const Text('Laporan Urgent'),
                      subtitle: const Text('Tandai jika membutuhkan perhatian segera'),
                      value: isUrgent.value,
                      onChanged: isLoading.value
                          ? null
                          : (value) {
                              isUrgent.value = value;
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

                    // Image Preview
                    if (imageBytes.value != null)
                      // New image preview
                      Stack(
                        children: [
                          UniversalImage(
                            imageBytes: imageBytes.value,
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
                              onPressed: isLoading.value
                                  ? null
                                  : () {
                                      imageBytes.value = null;
                                    },
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (report.imageUrl != null)
                      // Existing image preview
                      UniversalImage(
                        imageUrl: report.imageUrl,
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
                      onPressed: isLoading.value
                          ? null
                          : () => _showImageSourceDialog(context, imageBytes),
                      icon: const Icon(Icons.camera_alt),
                      label: Text(imageBytes.value != null || report.imageUrl != null
                          ? 'Ganti Foto'
                          : 'Tambah Foto'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: isLoading.value
                          ? null
                          : () => _submitUpdate(
                                context,
                                ref,
                                formKey,
                                titleController,
                                locationController,
                                descriptionController,
                                imageBytes,
                                isUrgent,
                                isLoading,
                                report,
                              ),
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

  // ==================== STATIC HELPERS: IMAGE HANDLING ====================

  /// Pick image from gallery
  /// ✅ Web-compatible: Uses bytes instead of File
  static Future<void> _pickImage(
    BuildContext context,
    ValueNotifier<Uint8List?> imageBytes,
  ) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        imageBytes.value = bytes;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal mengambil foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Take photo with camera
  /// ⚠️ Web fallback: Camera not supported on web
  static Future<void> _takePhoto(
    BuildContext context,
    ValueNotifier<Uint8List?> imageBytes,
  ) async {
    if (kIsWeb) {
      // Web doesn't support camera, fallback to gallery
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kamera tidak didukung di web, silakan pilih dari galeri'),
        ),
      );
      return;
    }

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        imageBytes.value = bytes;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal mengambil foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show dialog to select image source (camera or gallery)
  /// ⚠️ Web: Camera option hidden on web platform
  static void _showImageSourceDialog(
    BuildContext context,
    ValueNotifier<Uint8List?> imageBytes,
  ) {
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
                  _takePhoto(context, imageBytes);
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, imageBytes);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ACTION HANDLERS ====================

  /// Submit updated report
  /// ⚠️ BUSINESS LOGIC: Only upload new image if user changed it
  static Future<void> _submitUpdate(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    TextEditingController titleController,
    TextEditingController locationController,
    TextEditingController descriptionController,
    ValueNotifier<Uint8List?> imageBytes,
    ValueNotifier<bool> isUrgent,
    ValueNotifier<bool> isLoading,
    Report report,
  ) async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      // Update report via provider
      await ref.read(employeeActionsProvider).updateReport(
            reportId: report.id,
            title: titleController.text.trim(),
            location: locationController.text.trim(),
            description: descriptionController.text.trim(),
            isUrgent: isUrgent.value,
            imageBytes: imageBytes.value, // Only upload if user changed image
          );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Laporan berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true = updated
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal memperbarui: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
