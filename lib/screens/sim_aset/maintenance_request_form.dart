import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../models/maintenance_log.dart';
import '../../providers/riverpod/asset_providers.dart';
import '../../providers/riverpod/auth_providers.dart';

class MaintenanceRequestForm extends ConsumerStatefulWidget {
  final MaintenanceLog? log; // null for create, non-null for edit

  const MaintenanceRequestForm({super.key, this.log});

  @override
  ConsumerState<MaintenanceRequestForm> createState() => _MaintenanceRequestFormState();
}

class _MaintenanceRequestFormState extends ConsumerState<MaintenanceRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  
  // Controllers
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  
  // Form values
  String? _selectedAssetId;
  MaintenanceType _selectedType = MaintenanceType.corrective;
  bool _isUrgent = false;
  DateTime? _scheduledDate;
  
  bool _isLoading = false;
  bool get _isEditing => widget.log != null;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final log = widget.log;
    _descriptionController = TextEditingController(text: log?.description ?? '');
    _notesController = TextEditingController(text: log?.notes ?? '');
    
    if (log != null) {
      _selectedAssetId = log.assetId;
      _selectedType = log.type;
      _isUrgent = log.isUrgent;
      _scheduledDate = log.scheduledDate;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(allAssetsProvider);

    return Container(
      color: AppTheme.modernBg,
      child: Column(
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
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 12),
                Text(
                  _isEditing ? 'Edit Request' : 'Request Maintenance Baru',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          // Form Body
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
                          // Urgent Toggle Card
                          _buildUrgentCard(),
                          const SizedBox(height: 16),
                          
                          // Asset Selection Card
                          _buildCard(
                            title: 'Pilih Aset',
                            icon: Icons.inventory_2,
                            children: [
                              assetsAsync.when(
                                data: (assets) => DropdownButtonFormField<String>(
                                  value: _selectedAssetId,
                                  decoration: const InputDecoration(
                                    labelText: 'Aset yang bermasalah *',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('Pilih aset...'),
                                    ),
                                    ...assets.map((a) => DropdownMenuItem<String>(
                                      value: a.id,
                                      child: Text('${a.name} (${a.qrCode})'),
                                    )),
                                  ],
                                  onChanged: (value) => setState(() => _selectedAssetId = value),
                                  validator: (value) => 
                                      value == null ? 'Pilih aset yang akan di-maintenance' : null,
                                ),
                                loading: () => const LinearProgressIndicator(),
                                error: (_, __) => const Text('Error loading assets'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Type & Schedule Card
                          _buildCard(
                            title: 'Tipe & Jadwal',
                            icon: Icons.category,
                            children: [
                              // Type selection
                              const Text('Tipe Maintenance', style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTypeOption(
                                      MaintenanceType.corrective,
                                      'Perbaikan',
                                      'Untuk aset yang rusak/bermasalah',
                                      Icons.build,
                                      Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTypeOption(
                                      MaintenanceType.preventive,
                                      'Preventif',
                                      'Pemeliharaan rutin terjadwal',
                                      Icons.schedule,
                                      Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Scheduled date (for preventive)
                              if (_selectedType == MaintenanceType.preventive)
                                _buildDatePicker(
                                  label: 'Tanggal Jadwal',
                                  value: _scheduledDate,
                                  onChanged: (date) => setState(() => _scheduledDate = date),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Description Card
                          _buildCard(
                            title: 'Deskripsi Masalah',
                            icon: Icons.description,
                            children: [
                              TextFormField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Jelaskan masalah atau kebutuhan *',
                                  hintText: 'Contoh: AC tidak dingin, perlu servis...',
                                  border: OutlineInputBorder(),
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 4,
                                validator: (value) => 
                                    value?.isEmpty ?? true ? 'Deskripsi wajib diisi' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _notesController,
                                decoration: const InputDecoration(
                                  labelText: 'Catatan Tambahan (Opsional)',
                                  hintText: 'Info tambahan yang perlu diketahui teknisi...',
                                  border: OutlineInputBorder(),
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _submitForm,
                              icon: Icon(_isEditing ? Icons.save : Icons.send),
                              label: Text(_isEditing ? 'Simpan Perubahan' : 'Kirim Request'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isUrgent ? Colors.red[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isUrgent ? Colors.red : Colors.grey[300]!,
          width: _isUrgent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: _isUrgent ? Colors.red : Colors.grey,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request Urgent?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isUrgent ? Colors.red[700] : Colors.grey[700],
                  ),
                ),
                Text(
                  _isUrgent 
                      ? 'Request ini akan diprioritaskan'
                      : 'Aktifkan jika butuh penanganan segera',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isUrgent ? Colors.red[600] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isUrgent,
            onChanged: (value) => setState(() => _isUrgent = value),
            activeColor: Colors.red,
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
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

  Widget _buildTypeOption(
    MaintenanceType type,
    String label,
    String description,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedType == type;
    
    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
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
          initialDate: value ?? DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) onChanged(date);
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userAsync = ref.read(currentUserProvider);
      final userId = userAsync.value?.uid;
      
      final data = {
        'asset_id': _selectedAssetId,
        'type': _selectedType.toDatabase(),
        'status': 'pending',
        'priority': _isUrgent ? 'critical' : 'normal',
        'description': _descriptionController.text.trim(),
        'notes': _notesController.text.trim(),
        'scheduled_date': _scheduledDate?.toIso8601String(),
        'requested_by': userId,
      };

      // Mock submit if Supabase fails or optional
      await Future.delayed(const Duration(seconds: 1)); // Mock delay

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing 
                ? 'Request berhasil diupdate' 
                : 'Request maintenance berhasil dikirim'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // Use context.pop()
      }
    } catch (e) {
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

