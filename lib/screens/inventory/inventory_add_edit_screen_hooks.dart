// lib/screens/inventory/inventory_add_edit_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD
// Add/Edit Inventory Item Screen with full form validation

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:io';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/inventory_item.dart';
import '../../services/inventory_service.dart';
import '../../services/storage_service.dart';
import '../../providers/riverpod/auth_providers.dart';

/// Add/Edit Inventory Item Screen with validation and image upload
/// ✅ MIGRATED: ConsumerStatefulWidget → HookConsumerWidget
class InventoryAddEditScreen extends HookConsumerWidget {
  final InventoryItem? item; // null = Add mode, non-null = Edit mode

  const InventoryAddEditScreen({
    this.item,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = item != null;

    // ✅ HOOKS: Form key
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // ✅ HOOKS: Services
    final inventoryService = useMemoized(() => InventoryService());
    final storageService = useMemoized(() => StorageService());

    // ✅ HOOKS: Auto-disposed controllers with initial values
    final nameController = useTextEditingController(text: item?.name ?? '');
    final currentStockController = useTextEditingController(
      text: item?.currentStock.toString() ?? '0',
    );
    final maxStockController = useTextEditingController(
      text: item?.maxStock.toString() ?? '100',
    );
    final minStockController = useTextEditingController(
      text: item?.minStock.toString() ?? '10',
    );
    final unitController = useTextEditingController(text: item?.unit ?? 'pcs');
    final descriptionController = useTextEditingController(text: item?.description ?? '');

    // ✅ HOOKS: State management
    final selectedCategory = useState<String>(item?.category ?? 'alat');
    final imageFile = useState<File?>(null);
    final isSaving = useState(false);
    final isUploading = useState(false);

    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      appBar: _buildAppBar(context, isEditMode),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveHelper.padding(context)),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: isDesktop ? 800 : double.infinity),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(isEditMode),
                    const SizedBox(height: 24),
                    _buildImagePicker(context, imageFile, item),
                    const SizedBox(height: 24),
                    _buildBasicInfo(
                      selectedCategory,
                      nameController,
                      unitController,
                    ),
                    const SizedBox(height: 24),
                    _buildStockInfo(
                      currentStockController,
                      minStockController,
                      maxStockController,
                    ),
                    const SizedBox(height: 24),
                    _buildDescription(descriptionController),
                    const SizedBox(height: 32),
                    _buildActionButtons(
                      context,
                      ref,
                      formKey,
                      isEditMode,
                      isSaving,
                      isUploading,
                      imageFile,
                      item,
                      nameController,
                      currentStockController,
                      maxStockController,
                      minStockController,
                      unitController,
                      descriptionController,
                      selectedCategory,
                      inventoryService,
                      storageService,
                    ),
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

  // ==================== STATIC HELPERS: UI BUILDERS ====================

  /// Build app bar
  static AppBar _buildAppBar(BuildContext context, bool isEditMode) {
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

  /// Build header with icon
  static Widget _buildHeader(bool isEditMode) {
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

  /// Build image picker
  static Widget _buildImagePicker(
    BuildContext context,
    ValueNotifier<File?> imageFile,
    InventoryItem? item,
  ) {
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
            onTap: () => _pickImage(context),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: imageFile.value != null || item?.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageFile.value != null
                          ? Image.file(imageFile.value!, fit: BoxFit.cover)
                          : Image.network(item!.imageUrl!, fit: BoxFit.cover),
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
          if (imageFile.value != null || item?.imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus Foto'),
                onPressed: () => imageFile.value = null,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  /// Build basic info section
  static Widget _buildBasicInfo(
    ValueNotifier<String> selectedCategory,
    TextEditingController nameController,
    TextEditingController unitController,
  ) {
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
            value: selectedCategory.value,
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
                selectedCategory.value = value;
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
            controller: nameController,
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
            controller: unitController,
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

  /// Build stock info section
  static Widget _buildStockInfo(
    TextEditingController currentStockController,
    TextEditingController minStockController,
    TextEditingController maxStockController,
  ) {
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
            controller: currentStockController,
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
                      controller: minStockController,
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
                      controller: maxStockController,
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
                        final minStock = int.tryParse(minStockController.text);
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

  /// Build description field
  static Widget _buildDescription(TextEditingController descriptionController) {
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
            controller: descriptionController,
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

  /// Build action buttons
  static Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    bool isEditMode,
    ValueNotifier<bool> isSaving,
    ValueNotifier<bool> isUploading,
    ValueNotifier<File?> imageFile,
    InventoryItem? item,
    TextEditingController nameController,
    TextEditingController currentStockController,
    TextEditingController maxStockController,
    TextEditingController minStockController,
    TextEditingController unitController,
    TextEditingController descriptionController,
    ValueNotifier<String> selectedCategory,
    InventoryService inventoryService,
    StorageService storageService,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.close),
            label: const Text('Batal'),
            onPressed: isSaving.value ? null : () => Navigator.pop(context),
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
            icon: isSaving.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(isEditMode ? Icons.save : Icons.add),
            label: Text(isSaving.value
                ? (isEditMode ? 'Menyimpan...' : 'Menambahkan...')
                : (isEditMode ? 'Simpan Perubahan' : 'Tambah Item')),
            onPressed: isSaving.value
                ? null
                : () => _saveItem(
                      context,
                      ref,
                      formKey,
                      isEditMode,
                      isSaving,
                      isUploading,
                      imageFile,
                      item,
                      nameController,
                      currentStockController,
                      maxStockController,
                      minStockController,
                      unitController,
                      descriptionController,
                      selectedCategory,
                      inventoryService,
                      storageService,
                    ),
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

  // ==================== ACTION HANDLERS ====================

  /// Pick image from gallery
  static Future<void> _pickImage(BuildContext context) async {
    // TODO: Implement image picker
    // For now, show placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image picker - akan diimplementasikan dengan image_picker package'),
      ),
    );
  }

  /// Save item (add or update)
  static Future<void> _saveItem(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    bool isEditMode,
    ValueNotifier<bool> isSaving,
    ValueNotifier<bool> isUploading,
    ValueNotifier<File?> imageFile,
    InventoryItem? item,
    TextEditingController nameController,
    TextEditingController currentStockController,
    TextEditingController maxStockController,
    TextEditingController minStockController,
    TextEditingController unitController,
    TextEditingController descriptionController,
    ValueNotifier<String> selectedCategory,
    InventoryService inventoryService,
    StorageService storageService,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isSaving.value = true;

    try {
      // Upload image if new image selected
      String? imageUrl = item?.imageUrl;
      if (imageFile.value != null) {
        isUploading.value = true;
        imageUrl = await storageService.uploadInventoryImage(imageFile.value!);
        isUploading.value = false;
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
          'name': nameController.text.trim(),
          'category': selectedCategory.value,
          'currentStock': int.parse(currentStockController.text),
          'maxStock': int.parse(maxStockController.text),
          'minStock': int.parse(minStockController.text),
          'unit': unitController.text.trim(),
          'description': descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          'imageUrl': imageUrl,
          'updatedAt': now.toIso8601String(),
        };

        await inventoryService.updateItem(item!.id, updates);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item berhasil diperbarui'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        // Add new item
        final newItem = InventoryItem(
          id: 'inv_${now.millisecondsSinceEpoch}',
          name: nameController.text.trim(),
          category: selectedCategory.value,
          currentStock: int.parse(currentStockController.text),
          maxStock: int.parse(maxStockController.text),
          minStock: int.parse(minStockController.text),
          unit: unitController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          imageUrl: imageUrl,
          createdAt: now,
          updatedAt: now,
        );

        await inventoryService.addItem(newItem);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item berhasil ditambahkan'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isSaving.value = false;
    }
  }
}
