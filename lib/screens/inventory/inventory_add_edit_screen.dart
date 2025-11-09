// lib/screens/inventory/inventory_add_edit_screen.dart
// Add/Edit Inventory Item Screen with full form validation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/inventory_item.dart';
import '../../services/inventory_service.dart';
import '../../services/storage_service.dart';
import '../../providers/riverpod/auth_providers.dart';

class InventoryAddEditScreen extends ConsumerStatefulWidget {
  final InventoryItem? item; // null = Add mode, non-null = Edit mode

  const InventoryAddEditScreen({
    this.item,
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
  File? _imageFile;
  bool _isSaving = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _nameController = TextEditingController(text: item?.name ?? '');
    _currentStockController = TextEditingController(
      text: item?.currentStock.toString() ?? '0',
    );
    _maxStockController = TextEditingController(
      text: item?.maxStock.toString() ?? '100',
    );
    _minStockController = TextEditingController(
      text: item?.minStock.toString() ?? '10',
    );
    _unitController = TextEditingController(text: item?.unit ?? 'pcs');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _selectedCategory = item?.category ?? 'alat';
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

  bool get isEditMode => widget.item != null;

  @override
  Widget build(BuildContext context) {
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
                child: Column(
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
              child: _imageFile != null || widget.item?.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : Image.network(widget.item!.imageUrl!, fit: BoxFit.cover),
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
          if (_imageFile != null || widget.item?.imageUrl != null)
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
    // TODO: Implement image picker
    // For now, show placeholder message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image picker - akan diimplementasikan dengan image_picker package'),
        ),
      );
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Upload image if new image selected
      String? imageUrl = widget.item?.imageUrl;
      if (_imageFile != null) {
        setState(() => _isUploading = true);
        imageUrl = await _storageService.uploadInventoryImage(_imageFile!);
        setState(() => _isUploading = false);
      }

      // Get current user
      final userProfile = ref.read(currentUserProfileProvider).value;
      if (userProfile == null) {
        throw Exception('User not authenticated');
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

        await _inventoryService.updateItem(widget.item!.id, updates);

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
