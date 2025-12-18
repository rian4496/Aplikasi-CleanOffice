import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';
import '../../../providers/riverpod/agency_providers.dart';
import '../../../models/agency_profile.dart';
import '../../../widgets/web_admin/layout/admin_layout_wrapper.dart';
import 'user_management_tab.dart';
import 'audit_logs_tab.dart';

class AdminSettingsScreen extends HookConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 3);
    final agencyProfileAsync = ref.watch(agencyProfileProvider);

    return AdminLayoutWrapper(
      title: 'Pengaturan Sistem',
      child: Padding(
        padding: const EdgeInsets.all(AdminConstants.spaceLg),
        child: Column(
          children: [
            // Header Tabs
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AdminConstants.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                tabs: const [
                  Tab(text: 'Profil Instansi', icon: Icon(Icons.business)),
                  Tab(text: 'Manajemen User', icon: Icon(Icons.people)),
                  Tab(text: 'Audit Logs', icon: Icon(Icons.history)),
                ],
              ),
            ),
            const SizedBox(height: AdminConstants.spaceMd),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  agencyProfileAsync.when(
                    data: (profile) => _AgencyProfileTab(profile: profile),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error loading profile: $err')),
                  ),
                  _UserManagementTab(),
                  _AuditLogTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 1. Agency Profile Tab
class _AgencyProfileTab extends HookConsumerWidget {
  final AgencyProfile profile;

  const _AgencyProfileTab({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Basic form controllers (simplified)
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
                Row(
                  children: [
                    Expanded(child: _buildTextField('Email Resmi', emailCtrl)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('Kota Administrasi', cityCtrl)),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Save Logic
                       ref.read(agencyProfileProvider.notifier).updateProfile(
                        AgencyProfile(
                          id: profile.id,
                          name: nameCtrl.text,
                          shortName: profile.shortName,
                          address: addressCtrl.text,
                          phone: profile.phone, // TODO: add controller
                          email: emailCtrl.text,
                          website: profile.website, // TODO: add controller
                          city: cityCtrl.text,
                          signers: profile.signers,
                        )
                       );
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil disimpan')));
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan Perubahan'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildCard(
            title: 'Pengaturan Tanda Tangan (Signing Block)',
            child: Column(
              children: [
                if (profile.signers.isEmpty)
                   const Center(child: Text('Belum ada penandatangan diatur.', style: TextStyle(color: Colors.grey)))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: profile.signers.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final signer = profile.signers[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text((index + 1).toString())),
                        title: Text(signer.name),
                        subtitle: Text('${signer.roleLabel} - ${signer.position}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Delete logic
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                   OutlinedButton.icon(
                    onPressed: () {
                      // Add signer dialog
                    },
                     icon: const Icon(Icons.add),
                     label: const Text('Tambah Penandatangan'),
                   )
              ],
            ),
          ),
        ],
      ),
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
          Text(title, style: AdminTypography.h4),
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
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// 2. User Management Tab (wraps the imported UserManagementTab)
class _UserManagementTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: UserManagementTab(),
    );
  }
}

// 3. Audit Log Tab
class _AuditLogTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: AuditLogsTab(),
    );
  }
}
