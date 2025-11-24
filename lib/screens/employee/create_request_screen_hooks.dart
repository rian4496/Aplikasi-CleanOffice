// lib/screens/employee/create_request_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD
//
// FEATURES:
// - Cleaner picker with availability status
// - Request limit validation (max 3 active)
// - Active request count display
// - Integration with RequestActions
// - Improved error handling
// - Multi-role ready (employee/admin)

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/logging/app_logger.dart';
import '../../providers/riverpod/request_providers.dart';

final _logger = AppLogger('CreateRequestScreen');

class CreateRequestScreen extends HookConsumerWidget {
  const CreateRequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: Auto-disposed controllers
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final locationController = useTextEditingController();
    final descriptionController = useTextEditingController();

    // ✅ HOOKS: State management
    final isSubmitting = useState(false);
    final preferredDateTime = useState<DateTime?>(null);
    final selectedImage = useState<File?>(null);
    final webImage = useState<Uint8List?>(null);
    final selectedCleanerId = useState<String?>(null);
    final selectedCleanerName = useState<String?>(null);

    // ⚠️ REVIEW: Original code has this as 'final bool' (never changes)
    // This seems like a bug - should be state if there's urgent toggle
    // Keeping as-is for now to match original behavior
    const isUrgent = false;

    // ✅ HELPER: Pick image
    Future<void> pickImage(ImageSource source) async {
      try {
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

        if (image != null) {
          if (kIsWeb) {
            final bytes = await image.readAsBytes();
            webImage.value = bytes;
            selectedImage.value = null;
          } else {
            selectedImage.value = File(image.path);
            webImage.value = null;
          }

          _logger.info('Image selected: ${image.name}');
        }
      } catch (e) {
        _logger.error('Image picker error', e);
        showError(context, 'Gagal memilih gambar: $e');
      }
    }

    // ✅ HELPER: Show image source dialog
    void showImageSourceDialog() {
      // TODO (Phase 4): Add permission checks before showing dialog
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
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      );
    }

    // ✅ HELPER: Remove image
    void removeImage() {
      selectedImage.value = null;
      webImage.value = null;
    }

    // ✅ HELPER: Select date time
    Future<void> selectDateTime() async {
      // Pick date first
      final DateTime? date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 30)),
        locale: const Locale('id', 'ID'),
      );

      if (date == null) return;

      // Pick time second
      if (!context.mounted) return;

      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final selectedDT = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        if (selectedDT.isBefore(DateTime.now())) {
          showError(context, 'Waktu tidak boleh di masa lalu');
          return;
        }

        preferredDateTime.value = selectedDT;
      }
    }

    // ✅ HELPER: Show cleaner picker dialog
    Future<void> showCleanerPickerDialog() async {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Pilih Petugas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Cleaner List
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final cleanersAsync = ref.watch(availableCleanersProvider);

                    return cleanersAsync.when(
                      data: (cleaners) {
                        if (cleaners.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_off, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Tidak ada petugas tersedia',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: cleaners.length,
                          itemBuilder: (context, index) {
                            final cleaner = cleaners[index];
                            final isSelected =
                                selectedCleanerId.value == cleaner.id;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: isSelected ? 4 : 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppConstants.primaryColor
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  selectedCleanerId.value = cleaner.id;
                                  selectedCleanerName.value = cleaner.name;
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Avatar
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.grey[300],
                                        backgroundImage: cleaner.photoUrl != null
                                            ? NetworkImage(cleaner.photoUrl!)
                                            : null,
                                        child: cleaner.photoUrl == null
                                            ? Icon(Icons.person,
                                                color: Colors.grey[600], size: 32)
                                            : null,
                                      ),
                                      const SizedBox(width: 16),

                                      // Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cleaner.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.task_alt,
                                                    size: 14,
                                                    color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Tugas aktif: ${cleaner.activeTaskCount}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Select indicator
                                      Icon(
                                        isSelected
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: isSelected
                                            ? AppConstants.primaryColor
                                            : Colors.grey[400],
                                        size: 28,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, _) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Error: $error',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ HELPER: Show confirmation dialog
    Future<bool> showConfirmationDialog() async {
      return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
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
                      locationController.text,
                    ),
                    const Divider(),
                    _buildConfirmationRow(
                      Icons.description,
                      'Deskripsi',
                      descriptionController.text,
                    ),
                    if (selectedCleanerName.value != null) ...[
                      const Divider(),
                      _buildConfirmationRow(
                        Icons.person,
                        'Petugas',
                        selectedCleanerName.value!,
                      ),
                    ],
                    if (preferredDateTime.value != null) ...[
                      const Divider(),
                      _buildConfirmationRow(
                        Icons.access_time,
                        'Waktu',
                        DateFormat('EEEE, dd MMM yyyy - HH:mm', 'id_ID')
                            .format(preferredDateTime.value!),
                      ),
                    ],
                    if (isUrgent) ...[
                      const Divider(),
                      _buildConfirmationRow(
                        Icons.priority_high,
                        'Urgensi',
                        'URGEN',
                        valueColor: Colors.red,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('BATAL'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                  ),
                  child: const Text('KIRIM'),
                ),
              ],
            ),
          ) ??
          false;
    }

    // ✅ HELPER: Submit request
    Future<void> submitRequest() async {
      // Validate form
      if (!formKey.currentState!.validate()) {
        showError(context, 'Mohon lengkapi semua field yang wajib diisi');
        return;
      }

      // ⚠️ BUSINESS LOGIC: Check request limit FIRST (max 3 active)
      try {
        final canCreate = await ref.read(canCreateRequestProvider.future);
        if (!canCreate) {
          showError(
            context,
            'Anda sudah memiliki 3 permintaan aktif. '
            'Tunggu hingga salah satu selesai untuk membuat permintaan baru.',
          );
          return;
        }
      } catch (e) {
        _logger.error('Error checking request limit', e);
        showError(context, 'Gagal memeriksa batas permintaan. Silakan coba lagi.');
        return;
      }

      // Show confirmation
      final confirmed = await showConfirmationDialog();
      if (!confirmed) return;

      isSubmitting.value = true;

      try {
        // Get image bytes if image selected
        Uint8List? imageBytes;
        if (webImage.value != null) {
          imageBytes = webImage.value;
        } else if (selectedImage.value != null) {
          imageBytes = await selectedImage.value!.readAsBytes();
        }

        // Create request using RequestActions
        final actions = ref.read(requestActionsProvider);
        final requestId = await actions.createRequest(
          location: locationController.text.trim(),
          description: descriptionController.text.trim(),
          assignedTo: selectedCleanerId.value,
          assignedToName: selectedCleanerName.value,
          isUrgent: isUrgent,
          preferredDateTime: preferredDateTime.value,
          imageBytes: imageBytes,
        );

        _logger.info('Request created successfully: $requestId');

        if (!context.mounted) return;

        // Show success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedCleanerId.value != null
                        ? 'Permintaan berhasil dibuat dan ditugaskan ke ${selectedCleanerName.value}'
                        : 'Permintaan berhasil dibuat dan menunggu petugas',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );

        // TODO (Phase 5): Replace with go_router navigation
        Navigator.pop(context, true);
      } on ValidationException catch (e) {
        _logger.error('Validation error', e);
        showError(context, e.message);
      } on DatabaseException catch (e) {
        _logger.error('Firestore error', e);
        showError(context, e.message);
      } catch (e) {
        _logger.error('Unexpected error', e);
        showError(context, 'Terjadi kesalahan. Silakan coba lagi.');
      } finally {
        if (context.mounted) {
          isSubmitting.value = false;
        }
      }
    }

    // ✅ BUILD UI
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minta Layanan'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Request Limit Banner
              _buildRequestLimitBanner(ref),

              // 2. Cleaner Picker
              _buildCleanerPicker(
                selectedCleanerId.value,
                selectedCleanerName.value,
                isSubmitting.value,
                showCleanerPickerDialog,
                () {
                  selectedCleanerId.value = null;
                  selectedCleanerName.value = null;
                },
              ),

              const SizedBox(height: 8),

              // 3. Location Input
              _buildLocationInput(locationController, isSubmitting.value),

              const SizedBox(height: 16),

              // 4. Description Input
              _buildDescriptionInput(descriptionController, isSubmitting.value),

              const SizedBox(height: 16),

              // 5. Preferred DateTime Picker
              _buildDateTimePicker(
                preferredDateTime.value,
                isSubmitting.value,
                selectDateTime,
                () => preferredDateTime.value = null,
              ),

              const SizedBox(height: 16),

              // 6. Photo Upload (Optional)
              _buildPhotoUpload(
                selectedImage.value,
                webImage.value,
                isSubmitting.value,
                showImageSourceDialog,
                removeImage,
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 32),

              // 7. Submit Button
              _buildSubmitButton(isSubmitting.value, submitRequest),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ STATIC HELPERS: UI Widgets

  static Widget _buildRequestLimitBanner(WidgetRef ref) {
    final canCreateAsync = ref.watch(canCreateRequestProvider);
    final activeCountAsync = ref.watch(activeRequestCountProvider);

    return canCreateAsync.when(
      data: (canCreate) {
        if (!canCreate) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[300]!, width: 2),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red[700], size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Anda sudah memiliki 3 permintaan aktif. '
                    'Tunggu hingga salah satu selesai untuk membuat permintaan baru.',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return activeCountAsync.when(
          data: (count) => Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Text(
                  'Permintaan aktif: $count/3',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  static Widget _buildCleanerPicker(
    String? selectedCleanerId,
    String? selectedCleanerName,
    bool isSubmitting,
    VoidCallback onPickerTap,
    VoidCallback onClear,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: AppConstants.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Petugas (Opsional)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedCleanerName ?? 'Tidak dipilih - akan di-assign otomatis',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: isSubmitting ? null : onPickerTap,
                  child: Text(
                    selectedCleanerId == null ? 'Pilih' : 'Ubah',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Selected cleaner card
          if (selectedCleanerId != null) ...[
            const Divider(height: 1),
            _buildSelectedCleanerCard(
                selectedCleanerName, isSubmitting, onClear),
          ],
        ],
      ),
    );
  }

  static Widget _buildSelectedCleanerCard(
    String? cleanerName,
    bool isSubmitting,
    VoidCallback onClear,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, color: Colors.grey[600], size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cleanerName ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Petugas Kebersihan',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: isSubmitting ? null : onClear,
          ),
        ],
      ),
    );
  }

  static Widget _buildLocationInput(
    TextEditingController controller,
    bool isSubmitting,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Lokasi *',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              enabled: !isSubmitting,
              decoration: InputDecoration(
                hintText: 'Contoh: Air minum ruang umum pegawai',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lokasi wajib diisi';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDescriptionInput(
    TextEditingController controller,
    bool isSubmitting,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Deskripsi *',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              enabled: !isSubmitting,
              decoration: InputDecoration(
                hintText: 'Jelaskan detail layanan yang dibutuhkan...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                border: const OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Deskripsi wajib diisi';
                }
                if (value.trim().length < 10) {
                  return 'Deskripsi minimal 10 karakter';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDateTimePicker(
    DateTime? preferredDateTime,
    bool isSubmitting,
    VoidCallback onTap,
    VoidCallback onClear,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(Icons.access_time, color: AppConstants.primaryColor),
        title: const Text(
          'Waktu Diinginkan (Opsional)',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        subtitle: Text(
          preferredDateTime != null
              ? DateFormat('EEEE, dd MMM yyyy - HH:mm', 'id_ID')
                  .format(preferredDateTime)
              : 'Pilih waktu yang Anda inginkan',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: preferredDateTime != null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClear,
              )
            : const Icon(Icons.chevron_right),
        onTap: isSubmitting ? null : onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static Widget _buildPhotoUpload(
    File? selectedImage,
    Uint8List? webImage,
    bool isSubmitting,
    VoidCallback onPick,
    VoidCallback onRemove,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (selectedImage != null || webImage != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: kIsWeb
                      ? Image.memory(
                          webImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          selectedImage!,
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
                    onPressed: onRemove,
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
                        selectedImage != null || webImage != null
                            ? 'Foto terlampir'
                            : 'Tambahkan foto untuk detail lebih jelas',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (selectedImage == null && webImage == null)
                  OutlinedButton.icon(
                    onPressed: isSubmitting ? null : onPick,
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
    );
  }

  static Widget _buildSubmitButton(bool isSubmitting, VoidCallback onSubmit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
    );
  }

  static Widget _buildConfirmationRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ],
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
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
