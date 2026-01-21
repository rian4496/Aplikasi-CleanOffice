import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';
import '../../../riverpod/agency_providers.dart';
import '../../../models/agency_profile.dart'; // Import AgencyProfile
import '../../../widgets/web_admin/layout/admin_layout_wrapper.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/responsive_helper.dart';
import 'user_management_tab.dart';
import 'audit_logs_tab.dart';

class AdminUserManagementScreen extends HookConsumerWidget {
  const AdminUserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We want 3 tabs here: Profil Instansi, Manajemen User, Audit Logs
    final tabController = useTabController(initialLength: 3);
    final agencyProfileAsync = ref.watch(agencyProfileProvider);
    final isMobile = ResponsiveHelper.isMobile(context);

    // Build content
    Widget content = Padding(
      padding: EdgeInsets.all(isMobile ? 12 : AdminConstants.spaceLg),
      child: Column(
        children: [
           // Header Tabs
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AdminConstants.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: tabController,
                labelColor: AdminColors.primary,
                unselectedLabelColor: AdminColors.textSecondary,
                indicatorColor: AdminColors.primary,
                isScrollable: !isMobile, // Not scrollable on mobile = fills width
                tabAlignment: isMobile ? TabAlignment.fill : TabAlignment.start,
                labelPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 16),
                labelStyle: AdminTypography.h5.copyWith(fontWeight: FontWeight.w600),
                unselectedLabelStyle: AdminTypography.h5.copyWith(fontWeight: FontWeight.w400),
                tabs: [
                  Tab(text: isMobile ? 'Profil' : 'Profil Instansi', icon: const Icon(Icons.business, size: 20)),
                  Tab(text: isMobile ? 'User' : 'Manajemen User', icon: const Icon(Icons.people, size: 20)),
                  Tab(text: isMobile ? 'Audit' : 'Audit Logs', icon: const Icon(Icons.history, size: 20)),
                ],
              ),
            ),
            const SizedBox(height: AdminConstants.spaceMd),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                   // 1. Profil Instansi (Reuse logic from AgencyProfileScreen or its content)
                   agencyProfileAsync.when(
                    data: (profile) => _AgencyProfileContentRef(profile: profile), 
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
                  
                  // 2. User Management
                  const UserManagementTab(),

                  // 3. Audit Logs
                  const AuditLogsTab(),
                ],
              ),
            ),
        ],
      ),
    );

    // For mobile web: wrap with Scaffold + AppBar for back button
    if (isMobile) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
            onPressed: () => context.canPop() ? context.pop() : context.go('/admin/dashboard'),
          ),
          titleSpacing: 0,
          title: const Text('Manajemen User', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18)),
        ),
        body: content,
      );
    }

    // Desktop: use AdminLayoutWrapper
    return AdminLayoutWrapper(
      title: 'Manajemen User & Sistem',
      child: content,
    );
  }
}

// Inline Agency Profile Content (adapted from previous AgencyProfileScreen)
class _AgencyProfileContentRef extends HookConsumerWidget {
  final AgencyProfile profile; 
  const _AgencyProfileContentRef({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameCtrl = useTextEditingController(text: profile.name);
    final addressCtrl = useTextEditingController(text: profile.address);
    final emailCtrl = useTextEditingController(text: profile.email);
    final cityCtrl = useTextEditingController(text: profile.city);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           _buildCard(
            title: 'Informasi Instansi',
            child: Column(
              children: [
                _buildTextField('Nama Instansi', nameCtrl),
                const SizedBox(height: 16),
                _buildTextField('Alamat Lengkap', addressCtrl, maxLines: 2),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return Column(
                        children: [
                          _buildTextField('Email Resmi', emailCtrl),
                          const SizedBox(height: 16),
                          _buildTextField('Kota Administrasi', cityCtrl),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: _buildTextField('Email Resmi', emailCtrl)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('Kota Administrasi', cityCtrl)),
                      ],
                    );
                  }
                ),
                 const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                         ref.read(agencyProfileProvider.notifier).updateProfile(
                          AgencyProfile(
                            id: profile.id,
                            name: nameCtrl.text,
                            shortName: profile.shortName,
                            address: addressCtrl.text,
                            phone: profile.phone,
                            email: emailCtrl.text,
                            website: profile.website,
                            city: cityCtrl.text,
                            signers: profile.signers,
                          )
                         );
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil disimpan')));
                    },
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('Simpan Perubahan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primary,
                       foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                ),
              ],
            )
           ),
           const SizedBox(height: 24),
           _buildSignersSection(context, ref, profile)
        ],
      )
    );
  }
  
  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminConstants.radiusMd),
         border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AdminTypography.h4.copyWith(fontWeight: FontWeight.bold)),
          const Divider(height: 32),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AdminTypography.body2.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _buildSignersSection(BuildContext context, WidgetRef ref, AgencyProfile profile) {
    final signers = profile.signers;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminConstants.radiusMd),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and add button
          // Header with title and add button
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 500) {
                 return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pengaturan Tanda Tangan', style: AdminTypography.h4.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showSignerDialog(context, ref, profile, null),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Tambah Pejabat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                 );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pengaturan Tanda Tangan', style: AdminTypography.h4.copyWith(fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    onPressed: () => _showSignerDialog(context, ref, profile, null),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Tambah Pejabat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              );
            }
          ),
          const Divider(height: 32),
          
          // Signers list
          if (signers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.person_off, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Belum ada pejabat penanda tangan', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;
                
                if (isMobile) {
                  // Mobile Card View
                  return Column(
                    children: signers.map((signer) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AdminColors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          signer.roleLabel,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AdminColors.primary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                Row(
                                  mainAxisSize: MainAxisSize.min, // Compact row
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                      onPressed: () => _showSignerDialog(context, ref, profile, signer),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      tooltip: 'Edit',
                                    ),
                                    const SizedBox(width: 8), // Reduced spacing
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      onPressed: () => _deleteSigner(context, ref, profile, signer),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      tooltip: 'Hapus',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(signer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(signer.position, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('NIP: ${signer.nip}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            if (signer.rank.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(signer.rank, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }

                // Desktop Table View
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AdminColors.primary.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text('Label Peran', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]))),
                          Expanded(flex: 3, child: Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]))),
                          Expanded(flex: 2, child: Text('NIP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]))),
                          Expanded(flex: 2, child: Text('Jabatan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]))),
                          Expanded(flex: 2, child: Text('Pangkat', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]))),
                          const SizedBox(width: 80, child: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    // Table rows
                    ...signers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final signer = entry.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: index.isEven ? Colors.white : Colors.grey[50],
                          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(signer.roleLabel, style: const TextStyle(fontWeight: FontWeight.w600))),
                            Expanded(flex: 3, child: Text(signer.name)),
                            Expanded(flex: 2, child: Text(signer.nip, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
                            Expanded(flex: 2, child: Text(signer.position)),
                            Expanded(flex: 2, child: Text(signer.rank, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
                            SizedBox(
                              width: 80,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                    onPressed: () => _showSignerDialog(context, ref, profile, signer),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    onPressed: () => _deleteSigner(context, ref, profile, signer),
                                    tooltip: 'Hapus',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              }
            ),
        ],
      ),
    );
  }

  void _showSignerDialog(BuildContext context, WidgetRef ref, AgencyProfile profile, AgencySigner? existingSigner) {
    showDialog(
      context: context,
      builder: (ctx) => _SignerFormDialog(
        profile: profile,
        existingSigner: existingSigner,
        onSave: (newSigner) {
          final updatedSigners = List<AgencySigner>.from(profile.signers);
          if (existingSigner != null) {
            // Edit mode: replace existing
            final idx = updatedSigners.indexWhere((s) => s.nip == existingSigner.nip);
            if (idx != -1) updatedSigners[idx] = newSigner;
          } else {
            // Add mode
            updatedSigners.add(newSigner);
          }
          
          ref.read(agencyProfileProvider.notifier).updateProfile(
            AgencyProfile(
              id: profile.id,
              name: profile.name,
              shortName: profile.shortName,
              address: profile.address,
              phone: profile.phone,
              email: profile.email,
              website: profile.website,
              city: profile.city,
              signers: updatedSigners,
            ),
          );
        },
      ),
    );
  }

  void _deleteSigner(BuildContext context, WidgetRef ref, AgencyProfile profile, AgencySigner signer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Hapus Pejabat?'),
        content: Text('Anda yakin ingin menghapus ${signer.name} dari daftar penanda tangan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(c, true), 
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final updatedSigners = profile.signers.where((s) => s.nip != signer.nip).toList();
      ref.read(agencyProfileProvider.notifier).updateProfile(
        AgencyProfile(
          id: profile.id,
          name: profile.name,
          shortName: profile.shortName,
          address: profile.address,
          phone: profile.phone,
          email: profile.email,
          website: profile.website,
          city: profile.city,
          signers: updatedSigners,
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pejabat dihapus')));
      }
    }
  }
}

// ==================== SIGNER FORM DIALOG ====================
class _SignerFormDialog extends StatefulWidget {
  final AgencyProfile profile;
  final AgencySigner? existingSigner;
  final Function(AgencySigner) onSave;

  const _SignerFormDialog({
    required this.profile,
    this.existingSigner,
    required this.onSave,
  });

  @override
  State<_SignerFormDialog> createState() => _SignerFormDialogState();
}

class _SignerFormDialogState extends State<_SignerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _nipCtrl;
  late TextEditingController _positionCtrl;
  late TextEditingController _rankCtrl;
  late String _selectedRoleLabel;
  String? _signatureUrl;
  bool _isUploading = false;

  static const _roleLabels = [
    'Kepala Badan',
    'Kasubbag Umpeg',
    'Bendahara',
    'Pejabat Pengadaan',
    'Mengetahui',
    'Menyetujui',
    'Diperiksa Oleh',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.existingSigner;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _nipCtrl = TextEditingController(text: s?.nip ?? '');
    _positionCtrl = TextEditingController(text: s?.position ?? '');
    _rankCtrl = TextEditingController(text: s?.rank ?? '');
    _selectedRoleLabel = s?.roleLabel ?? _roleLabels.first;
    _signatureUrl = s?.signatureUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nipCtrl.dispose();
    _positionCtrl.dispose();
    _rankCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingSigner != null;

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(isEditing ? 'Edit Pejabat' : 'Tambah Pejabat'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Role Label Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRoleLabel,
                  decoration: const InputDecoration(
                    labelText: 'Label Peran *',
                    border: OutlineInputBorder(),
                  ),
                  items: _roleLabels.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedRoleLabel = v);
                  },
                ),
                const SizedBox(height: 16),

                // Name
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap *',
                    border: OutlineInputBorder(),
                    hintText: 'Dr. Ahmad Yani, M.Sc.',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // NIP
                TextFormField(
                  controller: _nipCtrl,
                  decoration: const InputDecoration(
                    labelText: 'NIP *',
                    border: OutlineInputBorder(),
                    hintText: '197501012000121001',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Position
                TextFormField(
                  controller: _positionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Jabatan *',
                    border: OutlineInputBorder(),
                  hintText: 'Kepala BRIDA',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Rank
                TextFormField(
                  controller: _rankCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Pangkat / Golongan',
                    border: OutlineInputBorder(),
                    hintText: 'Pembina Utama Muda (IV/c)',
                  ),
                ),
                const SizedBox(height: 24),

                // Signature Upload Section
                const Text('Gambar Tanda Tangan (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[50],
                  ),
                  child: Column(
                    children: [
                      // Signature Preview
                      if (_signatureUrl != null && _signatureUrl!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              _signatureUrl!,
                              height: 80,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                            ),
                          ),
                        ),
                      
                      // Upload/Remove Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _isUploading ? null : _pickAndUploadSignature,
                            icon: _isUploading 
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.upload_file),
                            label: Text(_signatureUrl != null ? 'Ganti Gambar' : 'Upload Tanda Tangan'),
                          ),
                          if (_signatureUrl != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => setState(() => _signatureUrl = null),
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'Hapus Gambar',
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Format: PNG/JPG, max 10MB, latar transparan direkomendasikan',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? 'Simpan' : 'Tambah'),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadSignature() async {
    // Use file_picker to select image
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    // Check file size (max 10MB)
    if (file.bytes!.length > 10 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran file maksimal 10MB'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Upload to Supabase Storage
      final supabase = Supabase.instance.client;
      final fileName = 'signature_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final path = 'signatures/$fileName';

      await supabase.storage.from('agency_assets').uploadBinary(
        path,
        file.bytes!,
        fileOptions: FileOptions(contentType: file.extension == 'png' ? 'image/png' : 'image/jpeg'),
      );

      final publicUrl = supabase.storage.from('agency_assets').getPublicUrl(path);

      setState(() {
        _signatureUrl = publicUrl;
        _isUploading = false;
      });
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final newSigner = AgencySigner(
        name: _nameCtrl.text.trim(),
        nip: _nipCtrl.text.trim(),
        position: _positionCtrl.text.trim(),
        rank: _rankCtrl.text.trim(),
        roleLabel: _selectedRoleLabel,
        signatureUrl: _signatureUrl,
      );
      widget.onSave(newSigner);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pejabat ${newSigner.name} berhasil disimpan')),
      );
    }
  }
}
