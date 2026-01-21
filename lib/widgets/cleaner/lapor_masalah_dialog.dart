// lib/widgets/cleaner/lapor_masalah_dialog.dart
// ✅ RECREATED: Matches "Lapor Masalah" Dialog Screenshot
// Header with Megaphone, Title, Subtitle, Styled Fields, and Actions

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../riverpod/auth_providers.dart';
import '../../riverpod/cleaner_providers.dart';
import '../../riverpod/supabase_service_providers.dart';
import '../../riverpod/ticket_providers.dart';
import '../../core/config/supabase_config.dart';
import '../../models/location.dart';

final _logger = AppLogger('LaporMasalahDialog');

class LaporMasalahDialog extends ConsumerStatefulWidget {
  const LaporMasalahDialog({super.key});

  @override
  ConsumerState<LaporMasalahDialog> createState() => _LaporMasalahDialogState();
}

class _LaporMasalahDialogState extends ConsumerState<LaporMasalahDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _customLocationController = TextEditingController();
  String? _selectedLocationId;
  String? _selectedLocationName;
  bool _isCustomLocation = false;
  Uint8List? _imageBytes;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _customLocationController.dispose();
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

      final bytes = await pickedImage.readAsBytes();
      
      if (!AppConstants.isValidFileSize(bytes.length)) {
         if(!mounted) return;
         _showError('Ukuran file terlalu besar');
         return;
      }

      setState(() {
        _imageBytes = bytes;
      });
    } catch (e) {
      _showError('Gagal mengambil foto');
    }
  }

  Future<String?> _uploadImage() async {
      if (_imageBytes == null) return null;
      try {
        final userProfile = ref.read(currentUserProfileProvider).value;
        if (userProfile == null) throw const AuthException(message: 'User not logged in');

        final storageService = ref.read(supabaseStorageServiceProvider);
        final result = await storageService.uploadImage(
          bytes: _imageBytes!,
          bucket: SupabaseConfig.reportImagesBucket,
          userId: userProfile.uid,
        );

        if (result.isSuccess) return result.data;
        throw StorageException(message: result.error ?? 'Upload failed');
      } catch (e) {
        rethrow;
      }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Get location based on mode
    final locationToSubmit = _isCustomLocation 
        ? _customLocationController.text.trim()
        : _selectedLocationName;
    
    if (locationToSubmit == null || locationToSubmit.isEmpty) {
      _showError('Lokasi harus diisi');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? imageUrl;
      if (_imageBytes != null) {
        imageUrl = await _uploadImage();
      }

      final actions = ref.read(cleanerActionsProvider.notifier);
      await actions.createCleaningReport(
        title: _titleController.text.trim(),
        location: locationToSubmit,
        description: 'Laporan via Dialog',
        imageUrl: imageUrl,
      );

      if (!mounted) return;
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil dikirim'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      _showError('Gagal mengirim laporan');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(locationListProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF), // Blue-50
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.campaign_rounded, color: Color(0xFF3B82F6), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lapor Masalah',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Laporkan temuan baru di lapangan',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Fields
                _buildLabel('Judul Laporan'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _titleController,
                  hint: 'Contoh: Lantai licin di Lobby',
                  icon: Icons.edit_note_rounded,
                ),
                const SizedBox(height: 16),

                _buildLabel('Lokasi'),
                const SizedBox(height: 8),
                
                // Toggle for custom location
                Row(
                  children: [
                    Checkbox(
                      value: _isCustomLocation,
                      onChanged: (val) {
                        setState(() {
                          _isCustomLocation = val ?? false;
                          if (_isCustomLocation) {
                            _selectedLocationId = null;
                            _selectedLocationName = null;
                          } else {
                            _customLocationController.clear();
                          }
                        });
                      },
                      activeColor: const Color(0xFF3B82F6),
                      visualDensity: VisualDensity.compact,
                    ),
                    Text(
                      'Lokasi tidak terdaftar',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Conditional: Dropdown or Text Input
                if (_isCustomLocation)
                  _buildTextField(
                    controller: _customLocationController,
                    hint: 'Ketik nama lokasi',
                    icon: Icons.place_outlined,
                  )
                else
                  _buildLocationDropdown(locationsAsync),
                const SizedBox(height: 16),

                _buildLabel('Foto Bukti (Opsional)'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    alignment: Alignment.center,
                    child: _imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF3B82F6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tap untuk ambil foto',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                            'Kirim Laporan',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF64748B),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC), // Slate-50
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
    );
  }

  Widget _buildLocationDropdown(AsyncValue<List<Location>> locationsAsync) {
    return locationsAsync.when(
      data: (locations) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedLocationId,
            isExpanded: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(Icons.place_outlined, color: Color(0xFF94A3B8), size: 20),
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            hint: Text(
              'Pilih lokasi',
              style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
            ),
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E293B)),
            items: locations.map((loc) {
              return DropdownMenuItem<String>(
                value: loc.id,
                child: Text(loc.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLocationId = value;
                _selectedLocationName = locations.firstWhere((l) => l.id == value).name;
              });
            },
            validator: (value) => value == null ? 'Pilih lokasi' : null,
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('Gagal memuat lokasi', style: GoogleFonts.inter(color: Colors.red)),
      ),
    );
  }
}

