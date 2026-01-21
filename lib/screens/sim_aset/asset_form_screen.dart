// lib/screens/sim_aset/asset_form_screen.dart
// SIM-ASET: Asset Form Screen (Add/Edit)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../models/asset.dart';
import '../../riverpod/dropdown_providers.dart' hide locationsProvider;
import '../../riverpod/master_crud_controllers.dart'; // For organizationsProvider, employeesStreamProvider
import '../../riverpod/auth_providers.dart';
import '../../services/barcode_lookup_service.dart';
import '../../widgets/shared/barcode_scanner_dialog.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../riverpod/supabase_service_providers.dart';
import '../../riverpod/asset_providers.dart';

class AssetFormScreen extends ConsumerStatefulWidget {
  final Asset? asset; // null for create, non-null for edit
  final String? assetType; // 'movable' or 'immovable' - from folder navigation

  const AssetFormScreen({super.key, this.asset, this.assetType});

  @override
  ConsumerState<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends ConsumerState<AssetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _qrCodeController;
  late TextEditingController _purchasePriceController;

  late TextEditingController _notesController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;

  // Dropdown values
  String? _selectedTypeId;
  String? _selectedCategoryId;
  String? _selectedCategoryName; // Track category name for dynamic labels
  String? _selectedLocationId;
  String? _selectedConditionId;
  String? _selectedConditionCode; // Track condition code for database
  String? _selectedDepartmentId;
  String? _selectedOrganizationId; // FK to organizations
  String? _selectedCustodianId; // Pemegang Aset (movable only)
  String _selectedStatus = 'active';

  DateTime? _purchaseDate;

  DateTime? _warrantyUntil;

  // Image Helper
  XFile? _newImageFile;
  String? _existingImageUrl;
  bool _isUploadingImage = false;

  bool _isLoading = false;
  bool get _isEditing => widget.asset != null;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final asset = widget.asset;
    _nameController = TextEditingController(text: asset?.name ?? '');
    _descriptionController = TextEditingController(
      text: asset?.description ?? '',
    );
    _qrCodeController = TextEditingController(
      text: asset?.qrCode ?? _generateQrCode(),
    );
    _purchasePriceController = TextEditingController(
      text: asset?.purchasePrice?.toString() ?? '',
    );
    _notesController = TextEditingController(text: asset?.notes ?? '');
    _brandController = TextEditingController(text: asset?.brand != '-' ? asset?.brand : '');
    _modelController = TextEditingController(text: asset?.model != '-' ? asset?.model : '');

    if (asset != null) {
      _selectedTypeId = asset.typeId;
      _selectedCategoryId = asset.categoryId;
      _selectedLocationId = asset.locationId;
      _selectedConditionId = asset.conditionId;
      _selectedDepartmentId = asset.departmentId;
      _selectedOrganizationId = asset.organizationId;
      _selectedCustodianId = asset.custodianId;
      _selectedStatus = asset.status.toDatabase();
      _purchaseDate = asset.purchaseDate;

      _warrantyUntil = asset.warrantyUntil;
      _existingImageUrl = asset.imageUrl;
    }
  }

  String _generateQrCode() {
    final uuid = const Uuid().v4();
    return 'BRIDA-${uuid.substring(0, 8).toUpperCase()}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _qrCodeController.dispose();
    _purchasePriceController.dispose();
    _purchasePriceController.dispose();
    _notesController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  // NEW: Image Picker Logic
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _newImageFile = pickedFile;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil gambar')),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _newImageFile = null;
      _existingImageUrl = null;
    });
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(assetTypesProvider);
    final categoriesAsync = ref.watch(assetCategoriesProvider);
    final locationsAsync = ref.watch(locationsProvider);
    final conditionsAsync = ref.watch(assetConditionsProvider);
    final departmentsAsync = ref.watch(departmentsProvider);
    final organizationsAsync = ref.watch(organizationsProvider);

    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      body: Column(
        children: [
          // Custom Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (widget.assetType != null) {
                      context.go('/admin/assets?type=${widget.assetType}');
                    } else {
                      context.go('/admin/master/aset');
                    }
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  _isEditing 
                      ? 'Edit Aset' 
                      : widget.assetType == 'movable'
                          ? 'Tambah Baru Aset Bergerak'
                          : widget.assetType == 'immovable'
                              ? 'Tambah Baru Aset Tidak Bergerak'
                              : 'Tambah Aset Baru',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                // Scan button for new movable assets
                if (!_isEditing && widget.assetType == 'movable')
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _scanBarcode,
                    tooltip: 'Scan Barcode',
                  ),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.qr_code),
                    onPressed: _showQrCode,
                    tooltip: 'Lihat QR Code',
                  ),
              ],
            ),
          ),

          // Scrollable Form Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // NEW: Image Upload Section
                          Center(
                            child: GestureDetector(
                              onTap: () => _showImagePickerOptions(),
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                  image: _newImageFile != null
                                      ? DecorationImage(
                                          image: kIsWeb 
                                              ? NetworkImage(_newImageFile!.path) 
                                              : FileImage(File(_newImageFile!.path)) as ImageProvider,
                                          fit: BoxFit.cover,
                                        )
                                      : _existingImageUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(_existingImageUrl!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                ),
                                child: _newImageFile == null && _existingImageUrl == null
                                    ? const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
                                          SizedBox(height: 4),
                                          Text('Foto Aset', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                        ],
                                      )
                                    : Align(
                                        alignment: Alignment.topRight,
                                        child: InkWell(
                                          onTap: _removeImage,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close, size: 16, color: Colors.red),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Basic Info Card
                          _buildCard(
                            title: 'Informasi Dasar',
                            icon: Icons.info_outline,
                            children: [
                              _buildTextField(
                                controller: _nameController,
                                label: 'Nama Aset',
                                hint: 'Contoh: Laptop Dell Latitude 5520',
                                required: true,
                              ),
                              const SizedBox(height: 16),
                                _buildTextField(
                                controller: _descriptionController,
                                label: 'Deskripsi',
                                hint: 'Deskripsi detail aset',
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _brandController,
                                      label: 'Merk / Brand',
                                      hint: 'Contoh: Dell, Toyota, Samsung',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _modelController,
                                      label: 'Tipe / Model',
                                      hint: 'Contoh: Latitude 5420',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Hide Kode Aset for immovable assets
                              if (widget.assetType != 'immovable')
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _qrCodeController,
                                        label: _selectedCategoryName?.toLowerCase().contains('kendaraan') == true
                                            ? 'Nomor Polisi'
                                            : 'Kode Aset',
                                        // Vehicles can always edit plate number; other assets can't edit QR
                                        enabled: _selectedCategoryName?.toLowerCase().contains('kendaraan') == true || !_isEditing,
                                        prefixIcon: _selectedCategoryName?.toLowerCase().contains('kendaraan') == true
                                            ? Icons.directions_car
                                            : Icons.qr_code,
                                      ),
                                    ),
                                    // Only show generate button for non-vehicles when adding new asset
                                    if (!_isEditing && _selectedCategoryName?.toLowerCase().contains('kendaraan') != true) ...[
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.refresh),
                                        onPressed: () {
                                          setState(() {
                                            _qrCodeController.text =
                                                _generateQrCode();
                                          });
                                        },
                                        tooltip: 'Generate baru',
                                      ),
                                    ],
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Classification Card
                          _buildCard(
                            title: 'Klasifikasi',
                            icon: Icons.category_outlined,
                            children: [
                              // Type dropdown - ONLY show if Type is unknown AND not editing
                              // (User feedback: Classification should be implicit in Add/Edit contexts)
                              if (widget.assetType == null && !_isEditing)
                                typesAsync.when(
                                  data: (types) => _buildDropdown(
                                    label: 'Tipe Aset',
                                    value: _selectedTypeId,
                                    items: types
                                        .map(
                                          (t) => DropdownMenuItem(
                                            value: t.id,
                                            child: Text(t.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedTypeId = value;
                                        _selectedCategoryId =
                                            null; // Reset category
                                      });
                                    },
                                    required: true,
                                  ),
                                  loading: () => const LinearProgressIndicator(),
                                  error: (_, __) =>
                                      const Text('Error loading types'),
                                ),
                                if (widget.assetType == null && !_isEditing)
                                const SizedBox(height: 16),

                              // Category dropdown (filtered by type or assetType)
                              categoriesAsync.when(
                                data: (categories) {
                                  // Filter by assetType from folder, or by selected type
                                  final filtered = widget.assetType == 'movable'
                                      ? categories.where((c) => 
                                          ['kendaraan', 'komputer', 'lab', 'elektronik', 'furniture', 'alat_kantor'].contains(c.code)
                                        ).toList()
                                      : widget.assetType == 'immovable'
                                          ? categories.where((c) => 
                                              ['gedung', 'tanah', 'infrastruktur', 'instalasi'].contains(c.code)
                                            ).toList()
                                          : _selectedTypeId != null
                                              ? categories.where((c) => c.typeId == _selectedTypeId).toList()
                                              : categories;
                                  
                                  return _buildDropdown<String>(
                                    label: 'Kategori',
                                    value: _selectedCategoryId,
                                    items: filtered
                                        .map(
                                          (c) => DropdownMenuItem<String>(
                                            value: c.id,
                                            child: Text(c.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      final selectedCategory = filtered.firstWhere(
                                        (c) => c.id == value,
                                        orElse: () => filtered.first,
                                      );
                                      setState(() {
                                        _selectedCategoryId = value;
                                        _selectedCategoryName = selectedCategory.name;
                                      });
                                    },
                                    required: true,
                                  );
                                },
                                loading: () => const LinearProgressIndicator(),
                                error: (_, __) =>
                                    const Text('Error loading categories'),
                              ),
                              const SizedBox(height: 16),

                              // Department dropdown - hide for immovable assets
                              if (widget.assetType != 'immovable')
                                departmentsAsync.when(
                                  data: (departments) => _buildDropdown(
                                    label: 'Bidang/Bagian',
                                    value: _selectedDepartmentId,
                                    items: departments
                                        .map(
                                          (d) => DropdownMenuItem(
                                            value: d.id,
                                            child: Text(d.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) => setState(
                                      () => _selectedDepartmentId = value,
                                    ),
                                  ),
                                  loading: () => const LinearProgressIndicator(),
                                  error: (_, __) =>
                                      const Text('Error loading departments'),
                                ),
                              if (widget.assetType != 'immovable')
                                const SizedBox(height: 16),
                              
                              // Organization dropdown
                              organizationsAsync.when(
                                data: (orgs) => _buildDropdown(
                                  label: 'Unit Organisasi Pemilik',
                                  value: _selectedOrganizationId,
                                  items: orgs
                                      .map(
                                        (o) => DropdownMenuItem(
                                          value: o.id,
                                          child: Text(o.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) => setState(
                                    () => _selectedOrganizationId = value,
                                  ),
                                ),
                                loading: () => const LinearProgressIndicator(),
                                error: (_, __) =>
                                    const Text('Error loading organizations'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Location & Condition Card
                          _buildCard(
                            title: 'Lokasi & Kondisi',
                            icon: Icons.location_on_outlined,
                            children: [
                              // Location dropdown
                              locationsAsync.when(
                                data: (locations) => _buildDropdown(
                                  label: 'Lokasi',
                                  value: _selectedLocationId,
                                  items: locations
                                      .map(
                                        (l) => DropdownMenuItem(
                                          value: l.id,
                                          child: Text(
                                            '${l.name} (${l.building ?? '-'})',
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) => setState(
                                    () => _selectedLocationId = value,
                                  ),
                                  required: true,
                                ),
                                loading: () => const LinearProgressIndicator(),
                                error: (_, __) =>
                                    const Text('Error loading locations'),
                              ),
                              const SizedBox(height: 16),

                              // Condition dropdown
                              conditionsAsync.when(
                                data: (conditions) => _buildDropdown(
                                  label: 'Kondisi',
                                  value: _selectedConditionId,
                                  items: conditions
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c.id,
                                          child: Row(
                                            children: [
                                              Icon(
                                                c.icon,
                                                size: 18,
                                                color: c.color,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(c.name),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    final selectedCondition = conditions.firstWhere(
                                      (c) => c.id == value,
                                      orElse: () => conditions.first,
                                    );
                                    setState(() {
                                      _selectedConditionId = value;
                                      _selectedConditionCode = selectedCondition.code;
                                    });
                                  },
                                  required: true,
                                ),
                                loading: () => const LinearProgressIndicator(),
                                error: (_, __) =>
                                    const Text('Error loading conditions'),
                              ),
                              const SizedBox(height: 16),

                              // Status dropdown
                              _buildDropdown(
                                label: 'Status',
                                value: _selectedStatus,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'active',
                                    child: Text('Aktif'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'inactive',
                                    child: Text('Tidak Aktif'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'disposed',
                                    child: Text('Dihapuskan'),
                                  ),
                                ],
                                onChanged: (value) => setState(
                                  () => _selectedStatus = value ?? 'active',
                                ),
                                required: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Pemegang Aset Card - only for movable assets
                          if (widget.assetType == 'movable')
                            _buildCard(
                              title: 'Pemegang Aset',
                              icon: Icons.person_outline,
                              children: [
                                Consumer(
                                  builder: (context, ref, _) {
                                    final employeesAsync = ref.watch(employeesProvider);
                                    return employeesAsync.when(
                                      data: (employees) => _buildDropdown<String>(
                                        label: 'Pegawai Penanggung Jawab',
                                        value: _selectedCustodianId ?? '',
                                        items: <DropdownMenuItem<String>>[
                                          const DropdownMenuItem<String>(
                                            value: '',
                                            child: Text('- Belum Ada Pemegang -'),
                                          ),
                                          ...employees.map(
                                            (e) => DropdownMenuItem<String>(
                                              value: e.id,
                                              child: Text('${e.fullName} (${e.nip})'),
                                            ),
                                          ),
                                        ],
                                        onChanged: (value) => setState(
                                          () => _selectedCustodianId = value?.isEmpty == true ? null : value,
                                        ),
                                      ),
                                      loading: () => const LinearProgressIndicator(),
                                      error: (_, __) =>
                                          const Text('Error loading employees'),
                                    );
                                  },
                                ),
                              ],
                            ),
                          if (widget.assetType == 'movable')
                            const SizedBox(height: 16),

                          // Purchase Info Card - hide for immovable assets
                          if (widget.assetType != 'immovable')
                            _buildCard(
                              title: 'Informasi Pembelian',
                              icon: Icons.shopping_cart_outlined,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDatePicker(
                                        label: 'Tanggal Pembelian',
                                        value: _purchaseDate,
                                        onChanged: (date) =>
                                            setState(() => _purchaseDate = date),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildDatePicker(
                                        label: 'Garansi Sampai',
                                        value: _warrantyUntil,
                                        onChanged: (date) =>
                                            setState(() => _warrantyUntil = date),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _purchasePriceController,
                                  label: 'Harga Pembelian (Rp)',
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                  prefixIcon: Icons.attach_money,
                                ),
                              ],
                            ),
                          if (widget.assetType != 'immovable')
                            const SizedBox(height: 16),

                          // Notes Card
                          _buildCard(
                            title: 'Catatan',
                            icon: Icons.note_alt_outlined,
                            children: [
                              _buildTextField(
                                controller: _notesController,
                                label: 'Catatan Tambahan',
                                hint: 'Catatan khusus tentang aset ini',
                                maxLines: 4,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Submit Button
                          // Submit Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _submitForm,
                                icon: Icon(_isEditing ? Icons.save : Icons.add, color: Colors.white),
                                label: Text(
                                  _isEditing ? 'Simpan Perubahan' : 'Tambah Aset',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboardType,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (value) => value?.isEmpty ?? true ? '$label wajib diisi' : null
          : null,
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    bool required = false,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem<T>(value: null, child: Text('Pilih $label')),
        ...items,
      ],
      onChanged: onChanged,
      validator: required
          ? (value) => value == null ? '$label wajib dipilih' : null
          : null,
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          value != null
              ? '${value.day}/${value.month}/${value.year}'
              : 'Pilih tanggal',
          style: TextStyle(color: value != null ? Colors.black : Colors.grey),
        ),
      ),
    );
  }

  // ==================== BARCODE SCANNING ====================
  Future<void> _scanBarcode() async {
    // Show scanner dialog
    final barcode = await BarcodeScannerDialog.show(
      context,
      title: 'Scan Barcode Aset',
    );

    if (barcode == null || !mounted) return;

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            SizedBox(width: 12),
            Text('Mencari informasi produk...'),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );

    // Lookup barcode in API
    final productInfo = await BarcodeLookupService.lookup(barcode);

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (productInfo != null && productInfo.name != null) {
      // Auto-fill form fields
      setState(() {
        _nameController.text = productInfo.displayName;
        if (productInfo.description != null) {
          _descriptionController.text = productInfo.description!;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk ditemukan: ${productInfo.displayName}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Product not found - just use barcode as name
      setState(() {
        _nameController.text = 'Aset $barcode';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk tidak ditemukan di database. Barcode: $barcode'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showQrCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Aset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Icon(Icons.qr_code_2, size: 150),
            ),
            const SizedBox(height: 16),
            Text(
              _qrCodeController.text,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Print QR Code
              Navigator.pop(context);
            },
            icon: const Icon(Icons.print),
            label: const Text('Print'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userAsync = ref.read(currentUserProvider);
      final userId = userAsync.value?.uid;
      String? resolvedTypeId = _selectedTypeId;
      
      // Auto-resolve Type ID if not selected manually (Hidden dropdown)
      if (resolvedTypeId == null && widget.assetType != null) {
        final types = await ref.read(assetTypesProvider.future);
        try {
          // Match by code, handling potential localization differences
          final type = types.firstWhere((t) {
            final code = (t.code ?? '').toLowerCase();
            final urlType = widget.assetType!.toLowerCase();
            return code == urlType ||
                   (urlType == 'movable' && (code == 'bergerak' || code == 'lancart')) ||
                   (urlType == 'immovable' && (code == 'tidak_bergerak' || code == 'tetap'));
          });
          resolvedTypeId = type.id;
        } catch (_) {
          // If not found, let it be null (validation might catch it if required)
        }
      }

      // Handle Image Upload
      String? finalImageUrl = _existingImageUrl;
      
      if (_newImageFile != null) {
        // Upload new image
        final storageService = ref.read(supabaseStorageServiceProvider);
        finalImageUrl = await storageService.uploadInventoryImage(_newImageFile!);
      } else if (_existingImageUrl == null && widget.asset?.imageUrl != null) {
        // If existing image was nullified (deleted by user), finalImageUrl is already null
        // But if we just didn't touch it, we might need to keep it?
        // Actually _existingImageUrl starts as widget.asset?.imageUrl
        // If _removeImage() was called, _existingImageUrl became null.
        // So finalImageUrl is correct as is.
      }

      final data = <String, dynamic>{
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'asset_code': _qrCodeController.text.trim(),
        'status': _selectedStatus,
        'price': double.tryParse(_purchasePriceController.text) ?? 0,
        'notes': _notesController.text.trim(),
        'notes': _notesController.text.trim(),
        'brand': _brandController.text.trim().isEmpty ? '-' : _brandController.text.trim(),
        'model': _modelController.text.trim().isEmpty ? '-' : _modelController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // Only add FK fields if they have valid values (prevents constraint violations)
      if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
        data['category_id'] = _selectedCategoryId;
      }
      if (_selectedDepartmentId != null && _selectedDepartmentId!.isNotEmpty) {
        data['department_id'] = _selectedDepartmentId;
      }
      if (_selectedConditionId != null && _selectedConditionId!.isNotEmpty) {
        data['condition_id'] = _selectedConditionId;
      }
      if (_selectedConditionCode != null && _selectedConditionCode!.isNotEmpty) {
        data['condition'] = _selectedConditionCode;
      }
      if (_selectedLocationId != null && _selectedLocationId!.isNotEmpty) {
        data['location_id'] = _selectedLocationId;
      }
      if (_selectedOrganizationId != null && _selectedOrganizationId!.isNotEmpty) {
        data['organization_id'] = _selectedOrganizationId;
      }
      // Custodian (Pemegang Aset) - can be null
      if (_selectedCustodianId != null && _selectedCustodianId!.isNotEmpty) {
        data['custodian_id'] = _selectedCustodianId;
      } else {
        data['custodian_id'] = null; // Allow clearing custodian
      }
      if (finalImageUrl != null && finalImageUrl.isNotEmpty) {
        data['image_url'] = finalImageUrl;
      }
      if (_purchaseDate != null) {
        data['purchase_date'] = _purchaseDate!.toIso8601String().split('T').first;
      }
      if (_warrantyUntil != null) {
        data['warranty_until'] = _warrantyUntil!.toIso8601String().split('T').first;
      }

      if (_isEditing) {
        // Log custodian change if custodian was modified
        final oldCustodianId = widget.asset?.custodianId;
        final newCustodianId = _selectedCustodianId;
        
        if (oldCustodianId != newCustodianId) {
          // Log to custodian history
          await _supabase.from('asset_custodian_history').insert({
            'asset_id': widget.asset!.id,
            'old_custodian_id': oldCustodianId,
            'new_custodian_id': newCustodianId?.isEmpty == true ? null : newCustodianId,
            'change_reason': 'Perubahan pemegang aset melalui edit form',
          });
        }
        
        await _supabase.from('assets').update(data).eq('id', widget.asset!.id);
      } else {
        // 'created_by' now exists in assets table
        final result = await _supabase.from('assets').insert(data).select().single();
        
        // Log initial custodian assignment if set
        if (_selectedCustodianId != null && _selectedCustodianId!.isNotEmpty) {
          await _supabase.from('asset_custodian_history').insert({
            'asset_id': result['id'],
            'old_custodian_id': null,
            'new_custodian_id': _selectedCustodianId,
            'change_reason': 'Pemegang awal saat pendaftaran aset',
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Aset berhasil diupdate'
                  : 'Aset berhasil ditambahkan',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Auto-refresh Asset List
        ref.refresh(allAssetsProvider);

        if (widget.assetType != null) {
          context.go('/admin/assets?type=${widget.assetType}');
        } else {
          context.go('/admin/master/aset');
        }
      }
    } catch (e) {
      debugPrint('Error submit form: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
