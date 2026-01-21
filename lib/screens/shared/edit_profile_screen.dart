import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../models/user_profile.dart';
import '../../riverpod/auth_providers.dart';
import '../../riverpod/profile_providers.dart';
import 'package:google_fonts/google_fonts.dart';

final _logger = AppLogger('EditProfileScreen');

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  File? _imageFile;
  String? _currentPhotoUrl;
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await ref.read(currentUserProfileProvider.future);
      if (profile != null && mounted) {
        setState(() {
          _userProfile = profile;
          _nameController.text = profile.displayName;
          _phoneController.text = profile.phoneNumber ?? '';
          _locationController.text = profile.location ?? '';
          _currentPhotoUrl = profile.photoURL;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.error('Load profile error', e);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: AppConstants.imageQuality,
      ); 

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final bytes = await file.length();

        if (!AppConstants.isValidFileSize(bytes)) {
          _showError(
            'Ukuran file terlalu besar. Max ${AppConstants.formatFileSize(AppConstants.maxImageSizeBytes)}',
          );
          return;
        }

        setState(() {
          _imageFile = file;
        });
      }
    } catch (e, stackTrace) {
      _logger.error('Pick image error', e, stackTrace);
      _showError('Gagal memilih foto');
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
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_currentPhotoUrl != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Hapus Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePicture();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeProfilePicture() async {
    if (_currentPhotoUrl == null || _userProfile == null) return;

    try {
      final actions = ref.read(profileActionsProvider.notifier);
      await actions.deleteProfilePicture(_currentPhotoUrl!, _userProfile!.uid);

      setState(() {
        _currentPhotoUrl = null;
        _imageFile = null;
      });

      _showSuccess('Foto profil berhasil dihapus');
    } on StorageException catch (e) {
      _logger.error('Delete photo error', e);
      _showError(e.message);
    } catch (e) {
      _logger.error('Unexpected error', e);
      _showError(AppConstants.genericErrorMessage);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || _userProfile == null) return;

    try {
      final actions = ref.read(profileActionsProvider.notifier);

      if (_imageFile != null) {
        // Update with new photo
        await actions.updateProfileWithPhoto(
          imageFile: _imageFile!,
          profile: _userProfile!.copyWith(
            displayName: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            location: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
          ),
        );
      } else {
        // Update without photo
        await actions.updateProfile(
          _userProfile!.copyWith(
            displayName: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            location: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
          ),
        );
      }

      if (!mounted) return;

      _showSuccess(AppConstants.updateSuccessMessage);

      // Return true to indicate successful update
      Navigator.pop(context, true);
    } on StorageException catch (e) {
      _logger.error('Storage error', e);
      _showError(e.message);
    } on DatabaseException catch (e) {
      _logger.error('Firestore error', e);
      _showError(e.message);
    } catch (e, stackTrace) {
      _logger.error('Update profile error', e, stackTrace);
      _showError(AppConstants.genericErrorMessage);
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

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileActionsProvider);
    final isSaving = profileState.isLoading;

    if (_isLoading) {
      return const Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Profil',
          style: GoogleFonts.inter(
            color: const Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[200]!, width: 1), // Simple border instead of shadow
                      ),
                      padding: const EdgeInsets.all(2),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[100],
                        child: ClipOval(
                          child: SizedBox(
                            width: 120,
                            height: 120,
                            child: _imageFile != null
                                ? Image.file(_imageFile!, fit: BoxFit.cover)
                                : _currentPhotoUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: _currentPhotoUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) => Icon(Icons.person, size: 60, color: Colors.grey[400]),
                                      )
                                    : Icon(Icons.person, size: 60, color: Colors.grey[400]),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Material(
                        color: const Color(0xFF3B82F6), // Blue-500
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: isSaving ? null : _showImageSourceDialog,
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Name Field
              _buildTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                enabled: !isSaving,
              ),
              const SizedBox(height: 24),

              // Phone Field
              _buildTextField(
                controller: _phoneController,
                label: 'Nomor Telepon',
                enabled: !isSaving,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // Location Field
              _buildTextField(
                controller: _locationController,
                label: 'Lokasi Kerja',
                enabled: !isSaving,
              ),
              const SizedBox(height: 48),

              // Save Button
              ElevatedButton(
                onPressed: isSaving ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6), // Blue-500
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Radius 12
                ),
                child: isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white), strokeWidth: 2))
                    : Text(
                        'Simpan Perubahan',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E293B), // Slate-900
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(color: const Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: 'Masukkan $label',
            hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)), // Slate-400
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Slate-200
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Slate-200
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5), // Blue-500
            ),
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF8FAFC), // Slate-50 disabled
          ),
          validator: (value) => value == null || value.trim().isEmpty ? AppConstants.requiredFieldMessage : null,
        ),
      ],
    );
  }
}

