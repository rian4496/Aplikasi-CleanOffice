import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';
import '../../../models/user_profile.dart';
import '../../../models/user_role.dart';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../models/user_profile.dart';
import '../../../riverpod/user_providers.dart';
import '../../../riverpod/supabase_service_providers.dart';
import 'user_form_dialog.dart';

class UserManagementTab extends HookConsumerWidget {
  const UserManagementTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(userListProvider);
    final searchCtrl = useTextEditingController();
    final searchQuery = useState('');
    
    // Tab Controller state handled by DefaultTabController in parent or implicitly here?
    // Let's use internal state for filter mode if we don't want real tabs
    // Or simpler: use Tabs for: "Aktif", "Perlu Approval", "Semua"
    final tabIndex = useState(0); // 0: Aktif, 1: Pending, 2: Deleted

    useEffect(() {
      searchCtrl.addListener(() {
        searchQuery.value = searchCtrl.text;
      });
      return null;
    }, [searchCtrl]);

    // Handle Actions
    Future<void> _refresh() async {
      await ref.read(userListProvider.notifier).refresh();
    }

    Future<void> _handleDelete(UserProfile user) async {
       final confirm = await showDialog<bool>(
         context: context,
         builder: (c) => AlertDialog(
           title: const Text('Hapus User?'),
           content: Text('Anda yakin ingin menghapus user ${user.displayName}? User tidak akan bisa login lagi.'),
           actions: [
             TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
             TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
           ],
         ),
       );

       if (confirm == true) {
         try {
           final auth = ref.read(supabaseAuthServiceProvider);
           await auth.updateUserStatus(userId: user.uid, status: 'deleted');
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User dihapus')));
           _refresh();
         } catch(e) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
         }
       }
    }

    Future<void> _handleApprove(UserProfile user) async {
      try {
         final auth = ref.read(supabaseAuthServiceProvider);
         await auth.updateUserVerificationStatus(userId: user.uid, status: 'approved');
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User disetujui & diaktifkan')));
         _refresh();
      } catch(e) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        // Content Widget
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toolbar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Cari User (Nama / NIP / Email)',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Total User Count
                usersAsync.maybeWhen(
                  data: (users) => Text(
                    isMobile ? '${users.length}' : 'Total User: ${users.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
                // Desktop Add Button
                if (!isMobile) ...[
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final success = await showDialog<bool>(
                        context: context, 
                        builder: (c) => const UserFormDialog() // Add Mode
                      );
                      if (success == true) {
                        _refresh();
                      }
                    },
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    label: const Text('Tambah User'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      backgroundColor: AdminColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            
            // Tabs
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
              ),
              child: TabBar(
                onTap: (index) => tabIndex.value = index,
                labelColor: AdminColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AdminColors.primary,
                tabs: const [
                  Tab(text: 'Daftar User'),
                  Tab(text: 'Perlu Approval'),
                  Tab(text: 'Dihapus'),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Responsive Content
            Expanded(
              child: usersAsync.when(
                data: (users) {
                  // Filter logic
                  final filtered = users.where((u) {
                     // 1. Text Search
                     final matchesSearch = u.displayName.toLowerCase().contains(searchQuery.value.toLowerCase()) || 
                                           u.email.toLowerCase().contains(searchQuery.value.toLowerCase());
                     if (!matchesSearch) return false;

                     // 2. Tab Filter
                     switch (tabIndex.value) {
                       case 0: // Daftar User
                         return u.status != 'deleted' && u.verificationStatus != 'pending';
                       case 1: // Perlu Approval
                         return u.verificationStatus == 'pending';
                       case 2: // Deleted
                         return u.status == 'deleted';
                       default:
                         return true;
                     }
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(tabIndex.value == 1 ? 'Tidak ada user perlu approval.' : 'Tidak ada user ditemukan.',
                            style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    );
                  }

                  if (isMobile) {
                    return ListView.separated(
                      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80), // Extra bottom padding for FAB
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final user = filtered[index];
                        return _MobileUserCard(
                           user: user,
                           onEdit: () async {
                              final success = await showDialog<bool>(
                                context: context, 
                                builder: (c) => UserFormDialog(user: user),
                              );
                              if (success == true) _refresh();
                           },
                           onDelete: () => _handleDelete(user),
                           onApprove: () => _handleApprove(user),
                        );
                      },
                    );
                  }

                  // Desktop Table View
                  return Column(
                    children: [
                      // Header Row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AdminColors.primary.withValues(alpha: 0.05),
                          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 40), // Expand icon space
                            const SizedBox(width: 40), // Avatar space
                            const SizedBox(width: 16),
                            Expanded(flex: 3, child: Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]))),
                            Expanded(flex: 2, child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]))),
                            Expanded(flex: 2, child: Text('Peran', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]))),
                            Expanded(flex: 2, child: Text('No HP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]))),
                            SizedBox(width: 70, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]))),
                            const SizedBox(width: 80), // Actions
                          ],
                        ),
                      ),
                      
                      // List Content
                      Expanded(
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final user = filtered[index];
                            return _UserListTile(
                              user: user,
                              onEdit: () async {
                                final success = await showDialog<bool>(
                                  context: context, 
                                  builder: (c) => UserFormDialog(user: user),
                                );
                                if (success == true) _refresh();
                              },
                              onDelete: () => _handleDelete(user),
                              onApprove: () => _handleApprove(user),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        );

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.transparent, // Maintain existing bg
            body: content,
            floatingActionButton: isMobile ? FloatingActionButton(
              onPressed: () async {
                final success = await showDialog<bool>(
                  context: context, 
                  builder: (c) => const UserFormDialog() // Add Mode
                );
                if (success == true) {
                  _refresh();
                }
              },
              backgroundColor: AdminColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ) : null,
          ),
        );
      },
    );
  }

  DataRow _buildUserRow(
    BuildContext context, 
    WidgetRef ref,
    UserProfile user, 
    VoidCallback onRefresh,
    Function(UserProfile) onDelete,
    Function(UserProfile) onApprove,
  ) {
    return DataRow(
      cells: [
        DataCell(Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AdminColors.primary.withValues(alpha: 0.1),
              child: Text(user.displayName.isNotEmpty ? user.displayName[0] : '?', style: TextStyle(color: AdminColors.primary)),
            ),
            const SizedBox(width: 12),
            Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        )),
        DataCell(Text(user.email)),
        DataCell(_buildRoleBadge(user.role)),
        DataCell(Text(user.departmentId ?? '-')),
        DataCell(_buildVerificationBadge(user.verificationStatus)),
        DataCell(_buildStatusBadge(user.status)),
        DataCell(Row(
          children: [
            if (user.verificationStatus == 'pending')
               ElevatedButton(
                 onPressed: () => onApprove(user), 
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.green, 
                   foregroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                   textStyle: const TextStyle(fontSize: 12),
                 ),
                 child: const Text('Approve'),
               )
            else ...[
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final success = await showDialog<bool>(
                    context: context, 
                    builder: (c) => UserFormDialog(user: user),
                  );
                  if (success == true) onRefresh();
                },
                tooltip: 'Edit',
              ),
              if (user.status != 'deleted')
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(user),
                  tooltip: 'Hapus',
                ),
            ],
          ],
        )),
      ],
    );
  }

  Widget _buildRoleBadge(String role) {
    String label;
    switch (role) {
      case 'admin':
        label = 'Administrator';
        break;
      case 'kasubbag_umpeg':
        label = 'Kasubag Umpeg';
        break;
      case 'teknisi':
        label = 'Teknisi Aset';
        break;
      case 'cleaner':
        label = 'Petugas Kebersihan';
        break;
      case 'employee':
        label = 'Pegawai Umum';
        break;
      default:
        label = role;
    }
    return Text(label);
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    switch (status) {
      case 'active':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case 'inactive':
        color = Colors.grey;
        icon = Icons.pause_circle_outline;
        break;
      case 'deleted':
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildVerificationBadge(String status) {
    Color color;
    switch (status) {
      case 'approved': color = Colors.green; break;
      case 'pending': color = Colors.orange; break;
      case 'rejected': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11));
  }
}

// ==================== USER LIST TILE (Expandable Row) ====================
class _UserListTile extends StatefulWidget {
  final UserProfile user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onApprove;

  const _UserListTile({
    required this.user,
    required this.onEdit,
    required this.onDelete,
    required this.onApprove,
  });

  @override
  State<_UserListTile> createState() => _UserListTileState();
}

class _UserListTileState extends State<_UserListTile> {
  bool _expanded = false;

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin': return 'Administrator';
      case 'kasubbag_umpeg': return 'Kasubag Umpeg';
      case 'teknisi': return 'Teknisi Aset';
      case 'cleaner': return 'Petugas Kebersihan';
      case 'employee': return 'Pegawai Umum';
      default: return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    
    return Column(
      children: [
        // Main Row
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _expanded ? Colors.grey[50] : Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                // Expand Icon
                Icon(
                  _expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 8),
                // Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[200],
                  child: Text(
                    user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                // Name
                Expanded(
                  flex: 3,
                  child: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                // Email
                Expanded(
                  flex: 2,
                  child: Text(user.email, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                ),
                // Role
                Expanded(flex: 2, child: Text(_getRoleDisplayName(user.role))),
                // Phone
                Expanded(flex: 2, child: Text(user.phoneNumber ?? '-')),
                // Status Badge
                SizedBox(
                  width: 70,
                  child: _buildStatusPill(user.status),
                ),
                // Actions
                SizedBox(
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (user.verificationStatus == 'pending')
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: widget.onApprove,
                          tooltip: 'Approve',
                          iconSize: 20,
                        )
                      else ...[
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: widget.onEdit,
                          tooltip: 'Edit',
                          iconSize: 20,
                        ),
                        if (user.status != 'deleted')
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: widget.onDelete,
                            tooltip: 'Hapus',
                            iconSize: 20,
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Expanded Details
        if (_expanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.grey[50],
            child: Wrap(
              spacing: 48,
              runSpacing: 16,
              children: [
                _buildDetailItem('Email', user.email),
                _buildDetailItem('No. HP', user.phoneNumber ?? '-'),
                _buildDetailItem('Role', _getRoleDisplayName(user.role)),
                _buildDetailItem('Status Akun', user.status.toUpperCase()),
                _buildDetailItem('Status Verifikasi', user.verificationStatus.toUpperCase()),
                _buildDetailItem('Lokasi', user.location ?? '-'),
                _buildDetailItem('Tanggal Bergabung', _formatDate(user.joinDate)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatusPill(String status) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'active':
        bgColor = Colors.green;
        textColor = Colors.white;
        break;
      case 'inactive':
        bgColor = Colors.grey;
        textColor = Colors.white;
        break;
      case 'deleted':
        bgColor = Colors.red;
        textColor = Colors.white;
        break;
      default:
        bgColor = Colors.grey;
        textColor = Colors.white;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: textColor, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _MobileUserCard extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onApprove;

  const _MobileUserCard({
    required this.user,
    required this.onEdit,
    required this.onDelete,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: AdminColors.primary.withValues(alpha: 0.1),
                child: Text(
                  user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                  style: TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              // Name & Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName.isNotEmpty ? user.displayName : (user.email.split('@').first),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email, 
                      style: TextStyle(color: Colors.grey[600], fontSize: 12), 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis
                    ),
                  ],
                ),
              ),
              // Actions
              if (user.status == 'active' || user.status == 'inactive')
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                     _showActionSheet(context, user);
                  },
                )
              else if (user.verificationStatus == 'pending')
                 IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: onApprove, // Use passed callback
                  tooltip: 'Approve',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusPill(user.status),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _getRoleDisplayName(user.role),
                  style: const TextStyle(color: Colors.blue, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
  
  Widget _buildStatusPill(String status) {
     Color color;
     switch (status) {
       case 'active': color = Colors.green; break;
       case 'inactive': color = Colors.grey; break;
       case 'deleted': color = Colors.red; break;
       default: color = Colors.blue;
     }
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
       decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
       child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
     );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin': return 'Administrator';
      case 'kasubbag_umpeg': return 'Kasubag Umpeg';
      case 'teknisi': return 'Teknisi';
      case 'cleaner': return 'Petugas Kebersihan';
      default: return 'Pegawai';
    }
  }

  void _showActionSheet(BuildContext context, UserProfile user) {
     showModalBottomSheet(
       context: context,
       builder: (c) => Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           ListTile(
             leading: const Icon(Icons.edit, color: Colors.blue),
             title: const Text('Edit User'),
             onTap: () { Navigator.pop(c); onEdit(); },
           ),
           if (user.status != 'deleted')
             ListTile(
               leading: const Icon(Icons.delete, color: Colors.red),
               title: const Text('Hapus User'),
               onTap: () { Navigator.pop(c); onDelete(); },
             ),
         ],
       ),
     );
  }
}
