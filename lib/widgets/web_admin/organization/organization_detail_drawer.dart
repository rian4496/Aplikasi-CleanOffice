// lib/widgets/web_admin/organization/organization_detail_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/master/organization.dart';
import '../../../models/user_profile.dart';
import '../../../providers/riverpod/admin_providers.dart'; // For profiles
import '../../../providers/riverpod/organization_stats_provider.dart'; // For stats
import 'assign_employee_dialog.dart';

class OrganizationDetailDrawer extends ConsumerWidget {
  final Organization organization;
  final VoidCallback onClose;
  final Function(Organization) onEdit;
  final Function(Organization) onDelete;

  const OrganizationDetailDrawer({
    super.key,
    required this.organization,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Fetch Employees for this unit
    final allUsersAsync = ref.watch(pendingVerificationUsersProvider); // Returns all users
    final employees = allUsersAsync.maybeWhen(
      data: (users) => users.where((u) => u.departmentId == organization.id).toList(),
      orElse: () => <UserProfile>[],
    );

    // 2. Fetch Stats 
    final statsAsync = ref.watch(statsForOrganizationProvider(organization.id));
    final assetCount = statsAsync.maybeWhen(
      data: (stats) => stats.assetCount,
      orElse: () => 0,
    );

    return Container(
      width: 400,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Detail Unit',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Info Section
                _buildInfoSection(),
                const SizedBox(height: 24),

                // Stats Summary
                _buildStatsSummary(employees.length, assetCount),
                const SizedBox(height: 24),

                // Employees List Header & Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pegawai (${employees.length})',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AssignEmployeeDialog(
                            organization: organization,
                            onSaved: () {
                              // Optional: Refresh specific providers if needed, handled in dialog
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add_alt, size: 16),
                      label: const Text('Assign Pegawai'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (employees.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50], 
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: const Text('Belum ada pegawai di unit ini.', style: TextStyle(color: Colors.grey)),
                  )
                else
                  ...employees.map((emp) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      child: Text(emp.displayName[0], style: TextStyle(color: AppTheme.primary)),
                      radius: 16,
                    ),
                    title: Text(emp.displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(emp.role, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  )),
              ],
            ),
          ),

          // Footer Actions
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onDelete(organization),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Hapus'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => onEdit(organization),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.business, color: AppTheme.primary, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    organization.name,
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getTypeColor(organization.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _getTypeColor(organization.type).withOpacity(0.3)),
                        ),
                        child: Text(
                          organization.type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                            color: _getTypeColor(organization.type),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        organization.code,
                        style: GoogleFonts.sourceCodePro(fontWeight: FontWeight.w500, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSummary(int employeeCount, int assetCount) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Total Pegawai',
            value: '$employeeCount',
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Total Aset',
            value: '$assetCount',
            icon: Icons.inventory_2,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String label, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'dinas': return AppTheme.primary;
      case 'bidang': return Colors.blue[600]!;
      case 'seksi': return Colors.green[600]!;
      case 'upt': return Colors.orange[700]!;
      default: return Colors.grey;
    }
  }
}
