// lib/screens/inventory/stock_requests_screen.dart
// Stock requests management screen for Admin and Cleaner

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/inventory_item.dart';
import '../../models/user_role.dart';
import '../../services/inventory_service.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../widgets/inventory/request_stock_dialog.dart';

class StockRequestsScreen extends ConsumerStatefulWidget {
  const StockRequestsScreen({super.key});

  @override
  ConsumerState<StockRequestsScreen> createState() => _StockRequestsScreenState();
}

class _StockRequestsScreenState extends ConsumerState<StockRequestsScreen> with SingleTickerProviderStateMixin {
  final _inventoryService = InventoryService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(currentUserProfileProvider).value;
    final isAdmin = userProfile?.role == UserRole.admin;

    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      appBar: _buildAppBar(isAdmin),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPendingTab(isAdmin, userProfile?.uid ?? ''),
                _buildApprovedTab(isAdmin, userProfile?.uid ?? ''),
                _buildRejectedTab(isAdmin, userProfile?.uid ?? ''),
                _buildFulfilledTab(isAdmin, userProfile?.uid ?? ''),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: !isAdmin ? _buildFAB() : null,
    );
  }

  // ==================== APP BAR ====================
  AppBar _buildAppBar(bool isAdmin) {
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
        isAdmin ? 'Kelola Permintaan Stok' : 'Permintaan Stok Saya',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ==================== TAB BAR ====================
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppTheme.primary,
        isScrollable: true,
        tabs: const [
          Tab(text: 'Pending'),
          Tab(text: 'Disetujui'),
          Tab(text: 'Ditolak'),
          Tab(text: 'Selesai'),
        ],
      ),
    );
  }

  // ==================== PENDING TAB ====================
  Widget _buildPendingTab(bool isAdmin, String userId) {
    return StreamBuilder<List<StockRequest>>(
      stream: isAdmin
          ? _inventoryService.streamPendingRequests()
          : _inventoryService.streamUserRequests(userId),
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

        return _buildRequestList(requests, isAdmin);
      },
    );
  }

  // ==================== APPROVED TAB ====================
  Widget _buildApprovedTab(bool isAdmin, String userId) {
    return StreamBuilder<List<StockRequest>>(
      stream: isAdmin
          ? _inventoryService.streamPendingRequests() // TODO: Change to streamAllRequests
          : _inventoryService.streamUserRequests(userId),
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

        return _buildRequestList(requests, isAdmin);
      },
    );
  }

  // ==================== REJECTED TAB ====================
  Widget _buildRejectedTab(bool isAdmin, String userId) {
    return StreamBuilder<List<StockRequest>>(
      stream: isAdmin
          ? _inventoryService.streamPendingRequests() // TODO: Change to streamAllRequests
          : _inventoryService.streamUserRequests(userId),
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

        return _buildRequestList(requests, isAdmin);
      },
    );
  }

  // ==================== FULFILLED TAB ====================
  Widget _buildFulfilledTab(bool isAdmin, String userId) {
    return StreamBuilder<List<StockRequest>>(
      stream: isAdmin
          ? _inventoryService.streamPendingRequests() // TODO: Change to streamAllRequests
          : _inventoryService.streamUserRequests(userId),
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

        return _buildRequestList(requests, isAdmin);
      },
    );
  }

  // ==================== REQUEST LIST ====================
  Widget _buildRequestList(List<StockRequest> requests, bool isAdmin) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh handled by stream
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: EdgeInsets.all(ResponsiveHelper.padding(context)),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return _buildRequestCard(requests[index], isAdmin);
        },
      ),
    );
  }

  // ==================== REQUEST CARD ====================
  Widget _buildRequestCard(StockRequest request, bool isAdmin) {
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
                          onPressed: () => _rejectRequest(request),
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
                          onPressed: () => _approveRequest(request),
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
                      onPressed: () => _fulfillRequest(request),
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
  Widget _buildEmptyState({
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
  Widget _buildError(String error) {
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
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _createNewRequest,
      backgroundColor: AppTheme.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Permintaan Baru',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // ==================== METHODS ====================

  Future<void> _approveRequest(StockRequest request) async {
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
      await _inventoryService.approveRequest(
        request.id,
        userProfile.uid,
        userProfile.displayName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permintaan berhasil disetujui'),
            backgroundColor: AppTheme.success,
          ),
        );
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
    }
  }

  Future<void> _rejectRequest(StockRequest request) async {
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
      await _inventoryService.rejectRequest(
        request.id,
        reasonController.text.trim().isEmpty
            ? 'Tidak ada alasan'
            : reasonController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permintaan berhasil ditolak'),
            backgroundColor: Colors.orange,
          ),
        );
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
    }
  }

  Future<void> _fulfillRequest(StockRequest request) async {
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
      await _inventoryService.fulfillRequest(
        requestId: request.id,
        fulfilledBy: userProfile.uid,
        fulfilledByName: userProfile.displayName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permintaan berhasil dipenuhi dan stok telah dikurangi'),
            backgroundColor: AppTheme.success,
          ),
        );
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
    }
  }

  Future<void> _createNewRequest() async {
    await showDialog(
      context: context,
      builder: (context) => const RequestStockDialog(),
    );
  }
}
