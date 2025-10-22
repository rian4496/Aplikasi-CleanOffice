import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
import '../../core/error/exceptions.dart';
import '../../models/user_profile.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/profile_providers.dart';

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
    } on FirestoreException catch (e) {
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil'), elevation: 0),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 64,
                        backgroundColor: Colors.grey[200],
                        child: ClipOval(
                          child: SizedBox(
                            width: 128,
                            height: 128,
                            child: _imageFile != null
                                ? Image.file(_imageFile!, fit: BoxFit.cover)
                                : _currentPhotoUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: _currentPhotoUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.person,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: AppConstants.primaryColor,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: isSaving ? null : _showImageSourceDialog,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppConstants.requiredFieldMessage;
                  }
                  return null;
                },
                enabled: !isSaving,
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  prefixIcon: Icon(Icons.phone),
                  hintText: 'Opsional',
                ),
                keyboardType: TextInputType.phone,
                enabled: !isSaving,
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi Kerja',
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'Opsional',
                ),
                enabled: !isSaving,
              ),
              const SizedBox(height: AppConstants.largePadding),

              // Save Button
              ElevatedButton(
                onPressed: isSaving ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
