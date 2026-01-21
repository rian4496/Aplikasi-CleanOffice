// lib/screens/employee/create_request_screen.dart
// ✅ REFACTORED VERSION - Phase 2 Complete
// 
// NEW FEATURES:
// - Cleaner picker with availability status
// - Request limit validation (max 3 active)
// - Active request count display
// - Integration with RequestActions
// - Improved error handling
// - Multi-role ready (employee/admin)

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// ==================== NEW IMPORTS ====================
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../riverpod/request_providers.dart';

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

  final bool _isUrgent = false;
  bool _isSubmitting = false;
  DateTime? _preferredDateTime;
  File? _selectedImage;
  Uint8List? _webImage; // For web platform
  
  // ==================== NEW STATE VARIABLES ====================
  String? _selectedCleanerId;
  String? _selectedCleanerName;

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
          final bytes = await image.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
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

  // ==================== TIME PICKER (TODAY ONLY) ====================
  Future<void> _selectDateTime() async {
    // Pick time only - request is for TODAY
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.inputOnly,
      helpText: 'Pilih jam layanan',
      cancelText: 'Batal',
      confirmText: 'OK',
      hourLabelText: 'Jam',
      minuteLabelText: 'Menit',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.grey[600]!,  // Grey cursor
              onSurface: Colors.black87,
            ),
            // Time picker specific theme
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: Colors.black87,
              dayPeriodTextColor: Colors.black87,
              dayPeriodColor: Colors.transparent,
              helpTextStyle: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,  // Bold "Pilih jam layanan"
              ),
              cancelButtonStyle: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Colors.grey[700]),
              ),
              confirmButtonStyle: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Colors.grey[700]),
              ),
              hourMinuteColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.grey[200]!;
                }
                return Colors.transparent;
              }),
              inputDecorationTheme: InputDecorationTheme(
                border: InputBorder.none,  // Remove border completely
                enabledBorder: InputBorder.none,  // Remove border
                focusedBorder: InputBorder.none,  // Remove border on focus
                filled: false,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            // Center text in input fields
            textTheme: TextTheme(
              headlineMedium: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // Check if selected time is in the past (only for today)
      if (selectedDateTime.isBefore(DateTime.now())) {
        _showError('Waktu tidak boleh di masa lalu');
        return;
      }

      setState(() {
        _preferredDateTime = selectedDateTime;
      });
    }
  }

  // ==================== NEW: REQUEST LIMIT BANNER ====================
  Widget _buildRequestLimitBanner() {
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

  // ==================== NEW: CLEANER PICKER ====================
  Widget _buildCleanerPicker() {
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
                        _selectedCleanerName ?? 
                        'Tidak dipilih - akan di-assign otomatis',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _isSubmitting ? null : _showCleanerPickerDialog,
                  child: Text(
                    _selectedCleanerId == null ? 'Pilih' : 'Ubah',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Selected cleaner card
          if (_selectedCleanerId != null) ...[
            const Divider(height: 1),
            _buildSelectedCleanerCard(),
          ],
        ],
      ),
    );
  }

  // ==================== NEW: SELECTED CLEANER CARD ====================
  Widget _buildSelectedCleanerCard() {
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
                  _selectedCleanerName ?? 'Unknown',
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
            onPressed: _isSubmitting
                ? null
                : () {
                    setState(() {
                      _selectedCleanerId = null;
                      _selectedCleanerName = null;
                    });
                  },
          ),
        ],
      ),
    );
  }

  // ==================== NEW: CLEANER PICKER DIALOG ====================
  Future<void> _showCleanerPickerDialog() async {
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
                          return _buildCleanerListItem(cleaner);
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

  // ==================== NEW: CLEANER LIST ITEM ====================
  Widget _buildCleanerListItem(CleanerProfile cleaner) {
    final isSelected = _selectedCleanerId == cleaner.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppConstants.primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCleanerId = cleaner.id;
            _selectedCleanerName = cleaner.name;
          });
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
                    ? Icon(Icons.person, color: Colors.grey[600], size: 32)
                    : null,
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        Icon(Icons.task_alt, size: 14, color: Colors.grey[600]),
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
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? AppConstants.primaryColor : Colors.grey[400],
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== CONFIRMATION DIALOG ====================
  Future<bool> _showConfirmationDialog() async {
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
                    _locationController.text,
                  ),
                  const Divider(),
                  _buildConfirmationRow(
                    Icons.description,
                    'Deskripsi',
                    _descriptionController.text,
                  ),
                  if (_selectedCleanerName != null) ...[
                    const Divider(),
                    _buildConfirmationRow(
                      Icons.person,
                      'Petugas',
                      _selectedCleanerName!,
                    ),
                  ],
                  if (_preferredDateTime != null) ...[
                    const Divider(),
                    _buildConfirmationRow(
                      Icons.access_time,
                      'Jam Layanan',
                      'Hari ini, ${DateFormat('HH:mm', 'id_ID').format(_preferredDateTime!)}',
                    ),
                  ],
                  if (_isUrgent) ...[
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

  Widget _buildConfirmationRow(
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

  // ==================== REFACTORED: SUBMIT REQUEST ====================
  Future<void> _submitRequest() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      _showError('Mohon lengkapi semua field yang wajib diisi');
      return;
    }

    // Check request limit FIRST
    try {
      final canCreate = await ref.read(canCreateRequestProvider.future);
      if (!canCreate) {
        _showError(
          'Anda sudah memiliki 3 permintaan aktif. '
          'Tunggu hingga salah satu selesai untuk membuat permintaan baru.',
        );
        return;
      }
    } catch (e) {
      _logger.error('Error checking request limit', e);
      _showError('Gagal memeriksa batas permintaan. Silakan coba lagi.');
      return;
    }

    // Show confirmation
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isSubmitting = true);

    try {
      // Get image bytes if image selected
      Uint8List? imageBytes;
      if (_webImage != null) {
        imageBytes = _webImage;
      } else if (_selectedImage != null) {
        imageBytes = await _selectedImage!.readAsBytes();
      }

      // Create request using RequestActions
      final actions = ref.read(requestActionsProvider);
      final requestId = await actions.createRequest(
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        assignedTo: _selectedCleanerId,
        assignedToName: _selectedCleanerName,
        isUrgent: _isUrgent,
        preferredDateTime: _preferredDateTime,
        imageBytes: imageBytes,
      );

      _logger.info('Request created successfully: $requestId');

      if (!mounted) return;

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedCleanerId != null
                      ? 'Permintaan berhasil dibuat dan ditugaskan ke $_selectedCleanerName'
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

      // Navigate back with result
      Navigator.pop(context, true);
    } on ValidationException catch (e) {
      _logger.error('Validation error', e);
      _showError(e.message);
    } on DatabaseException catch (e) {
      _logger.error('Firestore error', e);
      _showError(e.message);
    } catch (e) {
      _logger.error('Unexpected error', e);
      _showError('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ==================== ERROR HANDLER ====================
  void _showError(String message) {
    if (!mounted) return;
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

  // ==================== BUILD METHOD ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minta Layanan'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Request Limit Banner (NEW)
              _buildRequestLimitBanner(),

              // 2. Cleaner Picker (NEW)
              _buildCleanerPicker(),

              const SizedBox(height: 8),

              // 3. Location Input
              _buildLocationInput(),

              const SizedBox(height: 16),

              // 4. Description Input
              _buildDescriptionInput(),

              const SizedBox(height: 16),

              // 5. Preferred DateTime Picker
              _buildDateTimePicker(),

              const SizedBox(height: 16),

              // 6. Photo Upload (Optional)
              _buildPhotoUpload(),

              const SizedBox(height: 16),
             
              const SizedBox(height: 32),

              // 8. Submit Button
              _buildSubmitButton(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== EXISTING WIDGETS (UNCHANGED) ====================

  Widget _buildLocationInput() {
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
              controller: _locationController,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                hintText: 'Contoh: Air minum ruang umum pegawai',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                border: OutlineInputBorder(),
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

  Widget _buildDescriptionInput() {
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
              controller: _descriptionController,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                hintText: 'Jelaskan detail layanan yang dibutuhkan...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                border: OutlineInputBorder(),
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

  Widget _buildDateTimePicker() {
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
          'Jam Layanan Diinginkan (Opsional)',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        subtitle: Text(
          _preferredDateTime != null
              ? 'Hari ini, ${DateFormat('HH:mm', 'id_ID').format(_preferredDateTime!)}'
              : 'Pilih jam berapa Anda ingin layanan dilakukan',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: _preferredDateTime != null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _preferredDateTime = null),
              )
            : const Icon(Icons.chevron_right),
        onTap: _isSubmitting ? null : _selectDateTime,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPhotoUpload() {
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
          if (_selectedImage != null || _webImage != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
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
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
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
}
