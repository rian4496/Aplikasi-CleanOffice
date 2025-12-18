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
import '../../../providers/riverpod/user_providers.dart';
import '../../../providers/riverpod/supabase_service_providers.dart';
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

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Cari User (Nama / NIP / Email)',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  await showDialog(
                    context: context, 
                    builder: (c) => const UserFormDialog() // Add Mode
                  );
                  // No refresh needed strictly as Add is manual instructions
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

          // Table Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 0),
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
                       case 0: // Daftar User (Active/Inactive but not deleted, and verified)
                         return u.status != 'deleted' && u.verificationStatus != 'pending';
                       case 1: // Perlu Approval (Pending verification)
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
                          const Icon(Icons.person_off, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(tabIndex.value == 1 ? 'Tidak ada user perlu approval.' : 'Tidak ada user ditemukan.'),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 8),
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                      columns: const [
                         DataColumn(label: Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold))),
                         DataColumn(label: Text('Email / NIP', style: TextStyle(fontWeight: FontWeight.bold))),
                         DataColumn(label: Text('Peran', style: TextStyle(fontWeight: FontWeight.bold))),
                         DataColumn(label: Text('Unit Kerja', style: TextStyle(fontWeight: FontWeight.bold))),
                         DataColumn(label: Text('Status Ver.', style: TextStyle(fontWeight: FontWeight.bold))),
                         DataColumn(label: Text('Status Akun', style: TextStyle(fontWeight: FontWeight.bold))),
                         DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: filtered.map((user) => _buildUserRow(context, ref, user, _refresh, _handleDelete, _handleApprove)).toList(),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
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
              backgroundColor: AdminColors.primary.withOpacity(0.1),
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
    Color color;
    String label;
    switch (role) {
      case 'admin':
        color = Colors.purple;
        label = 'Administrator';
        break;
      case 'employee': // UserRole.employee
        color = Colors.blue;
        label = 'Pengurus';
        break;
      case 'cleaner':
        color = Colors.orange;
        label = 'Teknisi';
        break;
      default:
        color = Colors.grey;
        label = role;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
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
