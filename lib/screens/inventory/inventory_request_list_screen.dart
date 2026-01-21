import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/stock_request.dart';
import '../../riverpod/inventory_providers.dart';
import '../../riverpod/auth_providers.dart';
import '../../core/utils/responsive_helper.dart';

class InventoryRequestListScreen extends ConsumerStatefulWidget {
  const InventoryRequestListScreen({super.key});

  @override
  ConsumerState<InventoryRequestListScreen> createState() => _InventoryRequestListScreenState();
}

class _InventoryRequestListScreenState extends ConsumerState<InventoryRequestListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      appBar: AppBar(
        title: const Text(
          'Permintaan Stok',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(pendingStockRequestsProvider);
              ref.invalidate(completedStockRequestsProvider);
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Pending', icon: Icon(Icons.pending_actions, size: 18)),
            Tab(text: 'Riwayat', icon: Icon(Icons.history, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PendingTab(),
          _HistoryTab(),
        ],
      ),
    );
  }
}

// ==================== PENDING TAB ====================
class _PendingTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(pendingStockRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildKPIHeader(requests),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _RequestCard(
                    request: request,
                    onApprove: () => _approveRequest(context, ref, request),
                    onReject: () => _showRejectDialog(context, ref, request),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppTheme.shadowSm,
            ),
            child: Icon(Icons.inbox_rounded, 
              size: 64, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak ada permintaan pending',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Semua permintaan stok aman terkendali',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIHeader(List<StockRequest> requests) {
    final urgentCount = requests.where((r) => 
      DateTime.now().difference(r.createdAt).inDays > 2
    ).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildKPICard(
              'Pending',
              requests.length.toString(),
              Icons.pending_actions,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildKPICard(
              'Perlu Perhatian',
              urgentCount.toString(),
              Icons.warning_amber_rounded,
              Colors.orange,
              isUrgent: urgentCount > 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon, Color color, {bool isUrgent = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isUrgent ? Border.all(color: Colors.red.withValues(alpha: 0.5)) : null,
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _approveRequest(BuildContext context, WidgetRef ref, StockRequest request) async {
    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) return;

      await ref.read(inventoryServiceProvider).fulfillRequest(
        requestId: request.id,
        fulfilledBy: user.uid,
        fulfilledByName: user.displayName ?? 'Admin',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permintaan ${request.itemName} disetujui & stok dikurangi'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(pendingStockRequestsProvider);
        ref.invalidate(completedStockRequestsProvider);
        ref.invalidate(allInventoryItemsProvider); 
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyetujui: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref, StockRequest request) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Permintaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Berikan alasan penolakan:'),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                hintText: 'Misal: Stok dialokasikan untuk divisi lain...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(inventoryServiceProvider).rejectRequest(
                  request.id,
                  noteController.text.isEmpty ? 'Ditolak Admin' : noteController.text,
                );
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Permintaan ditolak'), backgroundColor: Colors.orange),
                  );
                  ref.invalidate(pendingStockRequestsProvider);
                  ref.invalidate(completedStockRequestsProvider);
                }
              } catch (e) {
                // handle error
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Tolak Permintaan'),
          ),
        ],
      ),
    );
  }
}

// ==================== HISTORY TAB ====================
class _HistoryTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(completedStockRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'Belum ada riwayat permintaan',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final request = requests[index];
            return _HistoryCard(request: request);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final StockRequest request;

  const _HistoryCard({required this.request});

  @override
  Widget build(BuildContext context) {
    Color statusColor = AppTheme.getStatusColor(request.status);
    String statusLabel = request.status.toUpperCase();
    if (request.status == 'fulfilled') statusLabel = 'SELESAI';
    if (request.status == 'rejected') statusLabel = 'DITOLAK';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.shadowSm,
        border: Border(left: BorderSide(color: statusColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                request.itemName ?? 'Unknown Item',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Qty: ${request.requestedQuantity}',
                style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(request.createdAt),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ),
          if (request.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Alasan penolakan: ${request.rejectionReason}',
                style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  final StockRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _RequestCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: _isHovered 
              ? Border.all(color: AppTheme.primary.withValues(alpha: 0.5), width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
          boxShadow: _isHovered ? AppTheme.shadowMd : AppTheme.shadowSm,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2, color: AppTheme.primary),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.request.itemName ?? 'Unknown Item',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'x${widget.request.requestedQuantity} ${widget.request.itemName?.contains('Liter') == true ? 'L' : 'pcs'}', 
                            // Simple heuristic for unit, ideally passed in model
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Diminta oleh: ${widget.request.requesterName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStepper(widget.request),
                    
                    if (widget.request.notes != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        '"${widget.request.notes}"',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Actions (Always visible on mobile, hover on desktop)
              if (!isDesktop || _isHovered) 
                Row(
                  children: [
                    IconButton(
                        onPressed: widget.onReject,
                        icon: const Icon(Icons.close, color: Colors.red),
                        tooltip: 'Tolak',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: widget.onApprove,
                        icon: const Icon(Icons.check, color: Colors.green),
                        tooltip: 'Setujui',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green.withValues(alpha: 0.1),
                        ),
                      ),
                  ],
                )
              else 
                 Padding(
                   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                   child: Text(
                     DateFormat('HH:mm').format(widget.request.createdAt),
                     style: TextStyle(color: Colors.grey.shade400),
                   ),
                 ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper(StockRequest request) {
    // Determine current step index
    // 0: Pending, 1: Approved, 2: Fulfilled
    // Since this list only shows Pending, it's always step 1 active.
    // But we visualize the flow.
    
    return Row(
      children: [
        _buildStepDot(isActive: true, label: 'Pending'),
        _buildStepLine(isActive: false),
        _buildStepDot(isActive: false, label: 'Approved'),
        _buildStepLine(isActive: false),
        _buildStepDot(isActive: false, label: 'Fulfilled'),
      ],
    );
  }

  Widget _buildStepDot({required bool isActive, required String label}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.blue : Colors.grey.shade400,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isActive}) {
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isActive ? Colors.blue : Colors.grey.shade200,
    );
  }
}
