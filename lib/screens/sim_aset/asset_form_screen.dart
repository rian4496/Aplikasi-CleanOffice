// lib/screens/sim_aset/asset_form_screen.dart
// SIM-ASET: Asset Form Screen (Add/Edit)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../models/asset.dart';
import '../../providers/riverpod/master_data_providers.dart';
import '../../providers/riverpod/auth_providers.dart';

class AssetFormScreen extends ConsumerStatefulWidget {
  final Asset? asset; // null for create, non-null for edit

  const AssetFormScreen({super.key, this.asset});

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
  
  // Dropdown values
  String? _selectedTypeId;
  String? _selectedCategoryId;
  String? _selectedLocationId;
  String? _selectedConditionId;
  String? _selectedDepartmentId;
  String _selectedStatus = 'active';
  
  DateTime? _purchaseDate;
  DateTime? _warrantyUntil;
  
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
    _descriptionController = TextEditingController(text: asset?.description ?? '');
    _qrCodeController = TextEditingController(
      text: asset?.qrCode ?? _generateQrCode(),
    );
    _purchasePriceController = TextEditingController(
      text: asset?.purchasePrice?.toString() ?? '',
    );
    _notesController = TextEditingController(text: asset?.notes ?? '');
    
    if (asset != null) {
      _selectedTypeId = asset.typeId;
      _selectedCategoryId = asset.categoryId;
      _selectedLocationId = asset.locationId;
      _selectedConditionId = asset.conditionId;
      _selectedDepartmentId = asset.departmentId;
      _selectedStatus = asset.status.toDatabase();
      _purchaseDate = asset.purchaseDate;
      _warrantyUntil = asset.warrantyUntil;
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
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(assetTypesProvider);
    final categoriesAsync = ref.watch(assetCategoriesProvider);
    final locationsAsync = ref.watch(locationsProvider);
    final conditionsAsync = ref.watch(assetConditionsProvider);
    final departmentsAsync = ref.watch(departmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Aset' : 'Tambah Aset Baru'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.qr_code),
              onPressed: _showQrCode,
              tooltip: 'Lihat QR Code',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                controller: _qrCodeController,
                                label: 'Kode QR',
                                enabled: !_isEditing,
                                prefixIcon: Icons.qr_code,
                              ),
                            ),
                            if (!_isEditing) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  setState(() {
                                    _qrCodeController.text = _generateQrCode();
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
                        // Type dropdown
                        typesAsync.when(
                          data: (types) => _buildDropdown(
                            label: 'Tipe Aset',
                            value: _selectedTypeId,
                            items: types.map((t) => DropdownMenuItem(
                              value: t.id,
                              child: Text(t.name),
                            )).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTypeId = value;
                                _selectedCategoryId = null; // Reset category
                              });
                            },
                            required: true,
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (_, __) => const Text('Error loading types'),
                        ),
                        const SizedBox(height: 16),

                        // Category dropdown (filtered by type)
                        categoriesAsync.when(
                          data: (categories) {
                            final filtered = _selectedTypeId != null
                                ? categories.where((c) => c.typeId == _selectedTypeId).toList()
                                : categories;
                            return _buildDropdown(
                              label: 'Kategori',
                              value: _selectedCategoryId,
                              items: filtered.map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              )).toList(),
                              onChanged: (value) => setState(() => _selectedCategoryId = value),
                              required: true,
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (_, __) => const Text('Error loading categories'),
                        ),
                        const SizedBox(height: 16),

                        // Department dropdown
                        departmentsAsync.when(
                          data: (departments) => _buildDropdown(
                            label: 'Bidang/Bagian',
                            value: _selectedDepartmentId,
                            items: departments.map((d) => DropdownMenuItem(
                              value: d.id,
                              child: Text(d.name),
                            )).toList(),
                            onChanged: (value) => setState(() => _selectedDepartmentId = value),
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (_, __) => const Text('Error loading departments'),
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
                            items: locations.map((l) => DropdownMenuItem(
                              value: l.id,
                              child: Text('${l.name} (${l.building ?? '-'})'),
                            )).toList(),
                            onChanged: (value) => setState(() => _selectedLocationId = value),
                            required: true,
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (_, __) => const Text('Error loading locations'),
                        ),
                        const SizedBox(height: 16),

                        // Condition dropdown
                        conditionsAsync.when(
                          data: (conditions) => _buildDropdown(
                            label: 'Kondisi',
                            value: _selectedConditionId,
                            items: conditions.map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Row(
                                children: [
                                  Icon(c.icon, size: 18, color: c.color),
                                  const SizedBox(width: 8),
                                  Text(c.name),
                                ],
                              ),
                            )).toList(),
                            onChanged: (value) => setState(() => _selectedConditionId = value),
                            required: true,
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (_, __) => const Text('Error loading conditions'),
                        ),
                        const SizedBox(height: 16),

                        // Status dropdown
                        _buildDropdown(
                          label: 'Status',
                          value: _selectedStatus,
                          items: const [
                            DropdownMenuItem(value: 'active', child: Text('Aktif')),
                            DropdownMenuItem(value: 'inactive', child: Text('Tidak Aktif')),
                            DropdownMenuItem(value: 'disposed', child: Text('Dihapuskan')),
                          ],
                          onChanged: (value) => setState(() => _selectedStatus = value ?? 'active'),
                          required: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Purchase Info Card
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
                                onChanged: (date) => setState(() => _purchaseDate = date),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDatePicker(
                                label: 'Garansi Sampai',
                                value: _warrantyUntil,
                                onChanged: (date) => setState(() => _warrantyUntil = date),
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
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: Icon(_isEditing ? Icons.save : Icons.add),
                        label: Text(_isEditing ? 'Simpan Perubahan' : 'Tambah Aset'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
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
          style: TextStyle(
            color: value != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
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
      final user = ref.read(currentUserProvider);
      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'qr_code': _qrCodeController.text.trim(),
        'category': 'default', // Required field in original schema
        'type_id': _selectedTypeId,
        'category_id': _selectedCategoryId,
        'location_id': _selectedLocationId,
        'condition_id': _selectedConditionId,
        'department_id': _selectedDepartmentId,
        'status': _selectedStatus,
        'purchase_date': _purchaseDate?.toIso8601String(),
        'warranty_until': _warrantyUntil?.toIso8601String(),
        'purchase_price': double.tryParse(_purchasePriceController.text),
        'notes': _notesController.text.trim(),
      };

      if (_isEditing) {
        await _supabase
            .from('assets')
            .update(data)
            .eq('id', widget.asset!.id);
      } else {
        data['created_by'] = user?.id;
        await _supabase.from('assets').insert(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Aset berhasil diupdate' : 'Aset berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
        setState(() => _isLoading = false);
      }
    }
  }
}
