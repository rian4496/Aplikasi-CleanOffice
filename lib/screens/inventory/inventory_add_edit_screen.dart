// lib/screens/inventory/inventory_add_edit_screen.dart
// Add/Edit Inventory Item Screen with full form validation

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Added import
import 'package:image_picker/image_picker.dart';
// import 'dart:io'; // REMOVED for Web Compatibility
import 'dart:typed_data';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/inventory_item.dart';
import '../../services/inventory_service.dart';
import '../../services/storage_service.dart';
import '../../providers/riverpod/auth_providers.dart';

class InventoryAddEditScreen extends ConsumerStatefulWidget {
  final InventoryItem? item; // null = Add mode, non-null = Edit mode
  final String? itemId; // Optional: passing ID instead of object (for deep linking)

  const InventoryAddEditScreen({
    this.item,
    this.itemId,
    super.key,
  });

  @override
  ConsumerState<InventoryAddEditScreen> createState() => _InventoryAddEditScreenState();
}

class _InventoryAddEditScreenState extends ConsumerState<InventoryAddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inventoryService = InventoryService();
  final _storageService = StorageService();

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _currentStockController;
  late final TextEditingController _maxStockController;
  late final TextEditingController _minStockController;
  late final TextEditingController _unitController;
  late final TextEditingController _descriptionController;

  // State
  late String _selectedCategory;
  XFile? _imageFile; // Changed from File? to XFile? for web support
  Uint8List? _imageBytes; // Added for Web Compatibility
  bool _isSaving = false;
  bool _isUploading = false;
  bool _isLoading = false;
  InventoryItem? _fetchedItem; // Store fetched item if itemId was used

  InventoryItem? get _item => widget.item ?? _fetchedItem; // Helper to get the active item

  @override
  void initState() {
    super.initState();
    _initializeControllers(); // Initialize with defaults first
    
    // If ID provided but object not, fetch it
    if (widget.item == null && widget.itemId != null) {
      _fetchItem(widget.itemId!);
    } else if (widget.item != null) {
      _populateControllers(widget.item!); // Populate if object already exists
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _currentStockController = TextEditingController(text: '0');
    _maxStockController = TextEditingController(text: '100');
    _minStockController = TextEditingController(text: '10');
    _unitController = TextEditingController(text: 'pcs');
    _descriptionController = TextEditingController();
    _selectedCategory = 'alat';
  }

  void _populateControllers(InventoryItem item) {
    _nameController.text = item.name;
    _currentStockController.text = item.currentStock.toString();
    _maxStockController.text = item.maxStock.toString();
    _minStockController.text = item.minStock.toString();
    _unitController.text = item.unit;
    _descriptionController.text = item.description ?? '';
    _selectedCategory = item.category;
  }

  Future<void> _fetchItem(String id) async {
    setState(() => _isLoading = true);
    try {
      final item = await _inventoryService.getItemById(id);
      if (mounted) {
        setState(() {
          _fetchedItem = item;
          _populateControllers(item);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
         setState(() => _isLoading = false);
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading item: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentStockController.dispose();
    _maxStockController.dispose();
    _minStockController.dispose();
    _unitController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get isEditMode => _item != null;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
       return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveHelper.padding(context)),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: isDesktop ? 800 : double.infinity),
              child: Form(
                key: _formKey,
                child: isDesktop
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LEFT COLUMN: Image & Description
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    _buildImagePicker(),
                                    const SizedBox(height: 24),
                                    _buildDescription(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              // RIGHT COLUMN: Basic Info & Stock
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    _buildBasicInfo(),
                                    const SizedBox(height: 24),
                                    _buildStockInfo(),
                                    const SizedBox(height: 32),
                                    _buildActionButtons(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildImagePicker(),
                          const SizedBox(height: 24),
                          _buildBasicInfo(),
                          const SizedBox(height: 24),
                          _buildStockInfo(),
                          const SizedBox(height: 24),
                          _buildDescription(),
                          const SizedBox(height: 32),
                          _buildActionButtons(),
                          const SizedBox(height: 24),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== APP BAR ====================
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        isEditMode ? 'Edit Item Inventaris' : 'Tambah Item Inventaris',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEditMode ? Icons.edit : Icons.add_box,
              color: AppTheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditMode ? 'Edit Item' : 'Item Baru',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEditMode
                      ? 'Perbarui informasi item inventaris'
                      : 'Tambahkan item baru ke inventaris',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== IMAGE PICKER ====================
  Widget _buildImagePicker() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              const Icon(Icons.image, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Foto Item',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'Opsional',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _imageFile != null || _item?.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _imageFile != null
                          ? (kIsWeb || _imageBytes != null
                              ? Image.memory(_imageBytes!, fit: BoxFit.cover) 
                              : const SizedBox()) // Fallback
                          : Image.network(_item!.imageUrl!, fit: BoxFit.cover),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'Tap untuk menambah foto',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          if (_imageFile != null || _item?.imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus Foto'),
                onPressed: () => setState(() => _imageFile = null),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== BASIC INFO ====================
  Widget _buildBasicInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Informasi Dasar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Category Selector
          const Text(
            'Kategori',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: ItemCategory.values.map((category) {
              return DropdownMenuItem(
                value: category.name,
                child: Row(
                  children: [
                    Icon(category.icon, size: 20, color: category.color),
                    const SizedBox(width: 12),
                    Text(category.label),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Pilih kategori item';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Name Field
          const Text(
            'Nama Item',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Contoh: Sapu Ijuk',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label_outline),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama item harus diisi';
              }
              if (value.trim().length < 3) {
                return 'Nama item minimal 3 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Unit Field
          const Text(
            'Satuan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _unitController,
            decoration: const InputDecoration(
              hintText: 'Contoh: pcs, liter, box',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.straighten),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Satuan harus diisi';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ==================== STOCK INFO ====================
  Widget _buildStockInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Row(
            children: [
              Icon(Icons.inventory_2, color: AppTheme.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Informasi Stok',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Current Stock
          const Text(
            'Stok Saat Ini',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _currentStockController,
            decoration: const InputDecoration(
              hintText: '0',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.inventory),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Stok saat ini harus diisi';
              }
              final stock = int.tryParse(value);
              if (stock == null || stock < 0) {
                return 'Stok harus angka positif';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Min/Max Stock Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stok Minimal',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _minStockController,
                      decoration: const InputDecoration(
                        hintText: '10',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning_amber),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Stok minimal harus diisi';
                        }
                        final minStock = int.tryParse(value);
                        if (minStock == null || minStock < 0) {
                          return 'Harus angka positif';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stok Maksimal',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _maxStockController,
                      decoration: const InputDecoration(
                        hintText: '100',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.vertical_align_top),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Stok maksimal harus diisi';
                        }
                        final maxStock = int.tryParse(value);
                        if (maxStock == null || maxStock <= 0) {
                          return 'Harus lebih dari 0';
                        }
                        final minStock = int.tryParse(_minStockController.text);
                        if (minStock != null && maxStock <= minStock) {
                          return 'Harus > min';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== DESCRIPTION ====================
  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              const Icon(Icons.description_outlined, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Deskripsi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'Opsional',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              hintText: 'Tambahkan deskripsi atau catatan untuk item ini...',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  // ==================== ACTION BUTTONS ====================
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.close),
            label: const Text('Batal'),
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(isEditMode ? Icons.save : Icons.add),
            label: Text(_isSaving
                ? (isEditMode ? 'Menyimpan...' : 'Menambahkan...')
                : (isEditMode ? 'Simpan Perubahan' : 'Tambah Item')),
            onPressed: _isSaving ? null : _saveItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== METHODS ====================

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    // Show bottom sheet to choose source
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                title: const Text('Kamera'),
                subtitle: const Text('Ambil foto baru'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.green),
                ),
                title: const Text('Galeri'),
                subtitle: const Text('Pilih dari galeri'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (mounted) {
          setState(() {
            _imageFile = pickedFile; 
            _imageBytes = bytes;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Upload image if new image selected
      String? imageUrl = _item?.imageUrl;
      if (_imageFile != null) {
        setState(() => _isUploading = true);
        imageUrl = await _storageService.uploadInventoryImage(_imageFile!);
        setState(() => _isUploading = false);
      }

      // Get current user with fallback
      final userProfile = ref.read(currentUserProfileProvider).value;
      String userId;
      String userName;

      if (userProfile != null) {
        userId = userProfile.uid;
        userName = userProfile.displayName;
      } else {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          userId = session.user.id;
          userName = session.user.email ?? 'Unknown User';
        } else {
          throw Exception('User not authenticated');
        }
      }

      final now = DateTime.now();

      if (isEditMode) {
        // Update existing item
        final updates = {
          'name': _nameController.text.trim(),
          'category': _selectedCategory,
          'currentStock': int.parse(_currentStockController.text),
          'maxStock': int.parse(_maxStockController.text),
          'minStock': int.parse(_minStockController.text),
          'unit': _unitController.text.trim(),
          'description': _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          'imageUrl': imageUrl,
          'updatedAt': now.toIso8601String(),
        };

        await _inventoryService.updateItem(
          _item!.id, 
          updates,
          performedBy: userId,
          performedByName: userName,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item berhasil diperbarui'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Add new item
        final newItem = InventoryItem(
          id: 'inv_${now.millisecondsSinceEpoch}',
          name: _nameController.text.trim(),
          category: _selectedCategory,
          currentStock: int.parse(_currentStockController.text),
          maxStock: int.parse(_maxStockController.text),
          minStock: int.parse(_minStockController.text),
          unit: _unitController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          imageUrl: imageUrl,
          createdAt: now,
          updatedAt: now,
        );

        await _inventoryService.addItem(newItem);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item berhasil ditambahkan'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

