// lib/screens/inventory/stock_requests_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD
// Stock requests management screen for Admin and Cleaner

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/inventory_item.dart';
import '../../models/user_role.dart';
import '../../services/inventory_service.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../widgets/inventory/request_stock_dialog.dart';

/// Stock Requests Screen - Manage stock requests with tabs (Pending/Approved/Rejected/Fulfilled)
/// ✅ MIGRATED: ConsumerStatefulWidget → HookConsumerWidget
class StockRequestsScreen extends HookConsumerWidget {
  const StockRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: TabController (auto-disposed)
    final tabController = useTabController(initialLength: 4);

    // ✅ HOOKS: Service memoization
    final inventoryService = useMemoized(() => InventoryService());

    final userProfile = ref.watch(currentUserProfileProvider).value;
    final isAdmin = userProfile?.role == UserRole.admin;
    final userId = userProfile?.uid ?? '';

    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      appBar: _buildAppBar(context, isAdmin),
      body: Column(
        children: [
          _buildTabBar(tabController),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _buildPendingTab(context, ref, isAdmin, userId, inventoryService),
                _buildApprovedTab(context, ref, isAdmin, userId, inventoryService),
                _buildRejectedTab(context, ref, isAdmin, userId, inventoryService),
                _buildFulfilledTab(context, ref, isAdmin, userId, inventoryService),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: !isAdmin ? _buildFAB(context) : null,
    );
  }

  // ==================== STATIC HELPERS: UI BUILDERS ====================

  /// Build app bar
  static AppBar _buildAppBar(BuildContext context, bool isAdmin) {
    // Cek apakah dalam dialog atau tidak
    final isInDialog = ResponsiveHelper.isDesktop(context);

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
      // Sembunyikan back button jika di web/dialog
      automaticallyImplyLeading: !isInDialog,
      leading: isInDialog
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.request_page,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isAdmin ? 'Kelola Permintaan Stok' : 'Permintaan Stok Saya',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  isAdmin
                      ? 'Setujui atau tolak permintaan'
                      : 'Lihat status permintaan Anda',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: isInDialog
          ? [
              // Tambahkan tombol close untuk dialog
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Tutup',
              ),
            ]
          : null,
    );
  }

  /// Build tab bar
  static Widget _buildTabBar(TabController tabController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDark],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        isScrollable: true,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        tabs: const [
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hourglass_empty, size: 18),
                  SizedBox(width: 8),
                  Text('Pending'),
                ],
              ),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 18),
                  SizedBox(width: 8),
                  Text('Disetujui'),
                ],
              ),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Ditolak'),
                ],
              ),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.done_all, size: 18),
                  SizedBox(width: 8),
                  Text('Selesai'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB CONTENT BUILDERS ====================

  /// Build pending tab
  static Widget _buildPendingTab(
    BuildContext context,
    WidgetRef ref,
    bool isAdmin,
    String userId,
    InventoryService inventoryService,
  ) {
    return StreamBuilder<List<StockRequest>>(
      stream: isAdmin
          ? inventoryService.streamPendingRequests()
          : inventoryService.streamUserRequests(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }

        final requests = (snapshot.data ?? [])
            .where((r) => r.status == RequestStatus.pending)
            .toList();

        if (requests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.pending_actions,
            title: 'Tidak ada permintaan pending',
            subtitle: isAdmin
                ? 'Semua permintaan telah diproses'
                : 'Anda belum memiliki permintaan pending',
          );
        }

        return _buildRequestList(context, ref, requests, isAdmin, inventoryService);
      },
    );
  }

  /// Build approved tab
  static Widget _buildApprovedTab(
    BuildContext context,
    WidgetRef ref,
    bool isAdmin,
    String userId,
    InventoryService inventoryService,
  ) {
    return StreamBuilder<List<StockRequest>>(
      stream: isAdmin
          ? inventoryService.streamPendingRequests() // TODO: Change to streamAllRequests
          : inventoryService.streamUserRequests(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = (snapshot.data ?? [])
            .where((r) => r.status == RequestStatus.approved)
            .toList();

        if (requests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.check_circle_outline,
            title: 'Tidak ada permintaan disetujui',
            subtitle: '',
          );
        }

        return _buildRequestList(context, ref, requests, isAdmin, inventoryService);
      },
    );
  }

  /// Build rejected tab
  static Widget _buildRejectedTab(
    BuildContext context,
    WidgetRef ref,
    bool isAdmin,
    String userId,
    InventoryService inventoryService,
  ) {
    return StreamBuilder<List<StockRequest>>(
      stream: isAdmin
          ? inventoryService.streamPendingRequests() // TODO: Change to streamAllRequests
          : inventoryService.streamUserRequests(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = (snapshot.data ?? [])
            .where((r) => r.status == RequestStatus.rejected)
            .toList();

        if (requests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.cancel_outlined,
            title: 'Tidak ada permintaan ditolak',
            subtitle: '',
          );
        }

        return _buildRequestList(context, ref, requests, isAdmin, inventoryService);
      },
    );
  }

  /// Build fulfilled tab
  static Widget _buildFulfilledTab(
    BuildContext context,
    WidgetRef ref,
    bool isAdmin,
    String userId,
    InventoryService inventoryService,
  ) {
    return StreamBuilder<List<StockRequest>>(
      stream: isAdmin
          ? inventoryService.streamPendingRequests() // TODO: Change to streamAllRequests
          : inventoryService.streamUserRequests(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = (snapshot.data ?? [])
            .where((r) => r.status == RequestStatus.fulfilled)
            .toList();

        if (requests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.done_all,
            title: 'Tidak ada permintaan selesai',
            subtitle: '',
          );
        }

        return _buildRequestList(context, ref, requests, isAdmin, inventoryService);
      },
    );
  }

  // ==================== REQUEST LIST ====================

  static Widget _buildRequestList(
    BuildContext context,
    WidgetRef ref,
    List<StockRequest> requests,
    bool isAdmin,
    InventoryService inventoryService,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh handled by stream
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: EdgeInsets.all(ResponsiveHelper.padding(context)),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return _buildRequestCard(
            context,
            ref,
            requests[index],
            isAdmin,
            inventoryService,
          );
        },
      ),
    );
  }

  // ==================== REQUEST CARD ====================

  static Widget _buildRequestCard(
    BuildContext context,
    WidgetRef ref,
    StockRequest request,
    bool isAdmin,
    InventoryService inventoryService,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: request.statusColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: request.statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request.statusLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd MMM yyyy', 'id_ID').format(request.requestedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Name
                Text(
                  request.itemName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Quantity
                Row(
                  children: [
                    const Icon(Icons.inventory_2, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Jumlah: ${request.requestedQuantity}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Requester
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      isAdmin ? 'Oleh: ${request.requesterName}' : 'Anda',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),

                // Notes
                if (request.notes != null && request.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note_outlined, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            request.notes!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Rejection Reason
                if (request.status == RequestStatus.rejected &&
                    request.rejectionReason != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Alasan Penolakan:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                request.rejectionReason!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Approved Info
                if (request.status == RequestStatus.approved ||
                    request.status == RequestStatus.fulfilled) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Disetujui oleh ${request.approvedByName ?? 'Admin'} pada ${request.approvedAt != null ? DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(request.approvedAt!) : '-'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Admin Actions
                if (isAdmin && request.status == RequestStatus.pending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Tolak'),
                          onPressed: () => _rejectRequest(
                            context,
                            request,
                            inventoryService,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Setujui'),
                          onPressed: () => _approveRequest(
                            context,
                            ref,
                            request,
                            inventoryService,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.success,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Fulfill Action for Approved Requests
                if (isAdmin && request.status == RequestStatus.approved) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.inventory, size: 18),
                      label: const Text('Penuhi Permintaan'),
                      onPressed: () => _fulfillRequest(
                        context,
                        ref,
                        request,
                        inventoryService,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EMPTY STATE ====================

  static Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  // ==================== ERROR ====================

  static Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
        ],
      ),
    );
  }

  // ==================== FAB ====================

  static Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _createNewRequest(context),
      backgroundColor: AppTheme.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Permintaan Baru',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // ==================== ACTION HANDLERS ====================

  /// Approve request (admin only)
  static Future<void> _approveRequest(
    BuildContext context,
    WidgetRef ref,
    StockRequest request,
    InventoryService inventoryService,
  ) async {
    final userProfile = ref.read(currentUserProfileProvider).value;
    if (userProfile == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setujui Permintaan'),
        content: Text(
          'Setujui permintaan ${request.requestedQuantity} ${request.itemName} dari ${request.requesterName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('SETUJUI'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await inventoryService.approveRequest(
        request.id,
        userProfile.uid,
        userProfile.displayName,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan berhasil disetujui'),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Reject request (admin only)
  static Future<void> _rejectRequest(
    BuildContext context,
    StockRequest request,
    InventoryService inventoryService,
  ) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Permintaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tolak permintaan dari ${request.requesterName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan Penolakan',
                border: OutlineInputBorder(),
                hintText: 'Berikan alasan penolakan...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('TOLAK'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await inventoryService.rejectRequest(
        request.id,
        reasonController.text.trim().isEmpty
            ? 'Tidak ada alasan'
            : reasonController.text.trim(),
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan berhasil ditolak'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Fulfill request (admin only)
  static Future<void> _fulfillRequest(
    BuildContext context,
    WidgetRef ref,
    StockRequest request,
    InventoryService inventoryService,
  ) async {
    final userProfile = ref.read(currentUserProfileProvider).value;
    if (userProfile == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Penuhi Permintaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Penuhi permintaan ${request.requestedQuantity} ${request.itemName} dari ${request.requesterName}?',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Stok akan otomatis dikurangi sebanyak ${request.requestedQuantity} unit',
                      style: const TextStyle(fontSize: 13, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('PENUHI'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await inventoryService.fulfillRequest(
        requestId: request.id,
        fulfilledBy: userProfile.uid,
        fulfilledByName: userProfile.displayName,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan berhasil dipenuhi dan stok telah dikurangi'),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Create new request (cleaner only)
  static Future<void> _createNewRequest(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const RequestStockDialog(),
    );
  }
}
