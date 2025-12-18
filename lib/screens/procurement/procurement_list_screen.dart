import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/procurement.dart';

// Dummy provider until backend is ready
final procurementRequestsProvider = FutureProvider<List<ProcurementRequest>>((ref) async {
  await Future.delayed(const Duration(seconds: 1)); // Mock latency
  return [
    ProcurementRequest(
      id: '1',
      title: 'Pengadaan Laptop Staff',
      description: 'Kebutuhan laptop untuk 3 staff baru bidang IT',
      departmentId: 'dept-1',
      departmentName: 'Bidang IT',
      fiscalYear: 2024,
      status: ProcurementStatus.submitted,
      totalEstimatedCost: 45000000,
      createdBy: 'user-1',
      createdByName: 'Budi Santoso',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
    ),
    ProcurementRequest(
      id: '2',
      title: 'Meja Rapat Utama',
      description: 'Penggantian meja rapat ruang utama yang rusak',
      departmentId: 'dept-2',
      departmentName: 'Umum',
      fiscalYear: 2024,
      status: ProcurementStatus.draft,
      totalEstimatedCost: 15000000,
      createdBy: 'user-2',
      createdByName: 'Siti Aminah',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
     ProcurementRequest(
      id: '3',
      title: 'AC Ruang Server',
      description: 'Penambahan AC 2PK untuk ruang server',
      departmentId: 'dept-1',
      departmentName: 'Bidang IT',
      fiscalYear: 2024,
      status: ProcurementStatus.approvedKasubbag,
      totalEstimatedCost: 8000000,
      createdBy: 'user-1',
      createdByName: 'Budi Santoso',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
  ];
});

class ProcurementListScreen extends HookConsumerWidget {
  const ProcurementListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(procurementRequestsProvider);
    final searchQuery = useState('');
    final selectedYear = useState(2024);

    return Container(
      color: AppTheme.modernBg,
      child: Column(
        children: [
          // Header
          _buildHeader(context),

          // Filters Toolbar
          _buildToolbar(context, searchQuery, selectedYear),

          // Content
          Expanded(
            child: requestsAsync.when(
              data: (requests) {
                // Filter Logic
                final filtered = requests.where((req) {
                  final q = searchQuery.value.toLowerCase();
                  final matchSearch = req.title.toLowerCase().contains(q) ||
                                      req.departmentName.toLowerCase().contains(q) ||
                                      (req.description?.toLowerCase().contains(q) ?? false);
                  final matchYear = req.fiscalYear == selectedYear.value;
                  return matchSearch && matchYear;
                }).toList();

                return _buildList(context, filtered);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, stack) => Center(child: Text('Error: $e')),
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
          const Icon(Icons.shopping_cart_outlined, color: AppTheme.primary, size: 28),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Perencanaan Pengadaan (RKBMD)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'Kelola usulan pengadaan barang & jasa',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => context.go('/admin/procurement/new'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Buat Usulan Baru'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ValueNotifier<String> searchQuery, ValueNotifier<int> selectedYear) {
    // Basic filter UI
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari usulan (judul, bidang, deskripsi)...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) => searchQuery.value = val,
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<int>(
            value: selectedYear.value,
            hint: const Text('Tahun'),
            items: const [DropdownMenuItem(value: 2024, child: Text("2024"))],
            onChanged: (val) {
               if (val != null) selectedYear.value = val;
            },
            underline: const SizedBox(),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
            tooltip: 'Filter Status',
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<ProcurementRequest> requests) {
    if (requests.isEmpty) {
      return const Center(child: Text("Tidak ada usulan pengadaan yang sesuai filter"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final item = requests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => context.go('/admin/procurement/detail/${item.id}'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Status Indicator
                  Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      color: item.status.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.departmentName} • TA ${item.fiscalYear}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cost
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp ${item.totalEstimatedCost.toStringAsFixed(0)}', // Use formatter later
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.status.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.status.displayName,
                          style: TextStyle(
                            color: item.status.color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

