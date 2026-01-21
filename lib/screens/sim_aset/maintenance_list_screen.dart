import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/maintenance_log.dart';
import '../../riverpod/maintenance_providers.dart';

class MaintenanceListScreen extends ConsumerStatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  ConsumerState<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends ConsumerState<MaintenanceListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  final _tabs = const [
    Tab(text: 'Semua'),
    Tab(text: 'Pending'),
    Tab(text: 'In Progress'),
    Tab(text: 'Completed'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maintenanceAsync = ref.watch(allMaintenanceLogsProvider);

    return Container(
      color: AppTheme.modernBg,
      child: Column(
        children: [
          // Header
          _buildHeader(context),
          
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primary,
              tabs: _tabs,
            ),
          ),
          
          // Search bar
          _buildSearchBar(),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(maintenanceAsync, null),
                _buildList(maintenanceAsync, MaintenanceStatus.pending),
                _buildList(maintenanceAsync, MaintenanceStatus.inProgress),
                _buildList(maintenanceAsync, MaintenanceStatus.completed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          const Icon(Icons.build, color: AppTheme.primary, size: 28),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Maintenance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'Kelola permintaan pemeliharaan aset',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          
          // Stats
          _buildStatChip('Pending', ref.watch(pendingMaintenanceProvider).value?.length ?? 0, Colors.orange),
          const SizedBox(width: 8),
          _buildStatChip('In Progress', ref.watch(maintenanceByStatusProvider(MaintenanceStatus.inProgress)).value?.length ?? 0, Colors.blue),
          
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => context.go('/admin/maintenance/new'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Request Baru'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari maintenance request...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildList(AsyncValue<List<MaintenanceLog>> logsAsync, MaintenanceStatus? filterStatus) {
    return logsAsync.when(
      data: (logs) {
        var filtered = logs;
        
        // Filter by status (mock implementation if not handled by provider filtering yet)
        if (filterStatus != null) {
          filtered = filtered.where((l) => l.status == filterStatus).toList();
        }
        
        // Filter by search
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          filtered = filtered.where((l) =>
            (l.description ?? l.title).toLowerCase().contains(query) ||
            (l.notes?.toLowerCase().contains(query) ?? false) ||
            (l.assetName?.toLowerCase().contains(query) ?? false)
          ).toList();
        }
        
        // Sort by urgent first, then by created date
        filtered.sort((a, b) {
          if (a.isUrgent && !b.isUrgent) return -1;
          if (!a.isUrgent && b.isUrgent) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });
        
        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.build_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada request maintenance',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) => _buildRequestCard(filtered[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildRequestCard(MaintenanceLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.go('/admin/maintenance/detail/${log.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Urgent badge
                  if (log.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'URGENT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: log.type == MaintenanceType.corrective 
                          ? Colors.orange.withValues(alpha: 0.2)
                          : Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      log.type.displayName,
                      style: TextStyle(
                        color: log.type == MaintenanceType.corrective 
                            ? Colors.orange[700]
                            : Colors.blue[700],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Status
                  _buildStatusBadge(log.status),
                ],
              ),
              const SizedBox(height: 12),
              
              // Description
              Text(
                log.description ?? log.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Asset info (if available)
              if (log.assetName != null)
                Row(
                  children: [
                    Icon(Icons.inventory_2, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        log.assetName!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              
              // Date and assignee
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(log.createdAt),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  if (log.assignedToName != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.person, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      log.assignedToName!,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MaintenanceStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: status.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

