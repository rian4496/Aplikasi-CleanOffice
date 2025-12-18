import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../providers/transaction_providers.dart';
import '../../../../../models/transactions/transaction_models.dart';
import '../../../../../models/ticket.dart'; // For TicketType popup

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../providers/transaction_providers.dart';
import '../../../../../models/transactions/transaction_models.dart';
import 'maintenance_components.dart';

class MaintenanceListScreen extends HookConsumerWidget {
  const MaintenanceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Data & State
    final maintenanceAsync = ref.watch(maintenanceListProvider);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final selectedTicketId = useState<String?>(null); // For Split View
    
    // Triage Filters
    final filterMode = useState('all'); // 'all', 'urgent', 'unassigned'

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: maintenanceAsync.when(
        data: (allTickets) {
          // --- Logic ---
          // 1. Calculate Stats
          final openCount = allTickets.where((t) => t.status == 'open').length;
          final urgentCount = allTickets.where((t) => t.priority == 'high' || t.priority == 'urgent').length;
          final todayCount = allTickets.where((t) => t.status == 'completed' && _isToday(t.createdAt)).length;

          // 2. Filter List
          final filtered = allTickets.where((t) {
             final q = searchQuery.value.toLowerCase();
             final matchSearch = t.issueDescription!.toLowerCase().contains(q) || t.id.toLowerCase().contains(q);
             
             bool matchFilter = true;
             if (filterMode.value == 'urgent') matchFilter = t.priority == 'high' || t.priority == 'urgent';
             if (filterMode.value == 'unassigned') matchFilter = t.assignedTechnicianId == null;
             
             return matchSearch && matchFilter;
          }).toList();

          // 3. Group by Status (Kanban Columns)
          final todo = filtered.where((t) => t.status == 'open').toList();
          final doing = filtered.where((t) => t.status == 'in_progress' || t.status == 'assigned').toList();
          final done = filtered.where((t) => t.status == 'completed').toList();

          return Column(
            children: [
              // Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text('Maintenance Command Center', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                         // Dropdown Button
                         PopupMenuButton<TicketType>(
                            tooltip: 'Buat Tiket',
                            offset: const Offset(0, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onSelected: (type) => context.push('/ticket/new', extra: type),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: TicketType.kerusakan,
                                child: Row(
                                  children: [
                                    Icon(Icons.build_circle_outlined, color: Colors.blue[700]),
                                    const SizedBox(width: 12),
                                    const Text('Lapor Kerusakan'),
                                  ],
                                ),
                              ),
                               PopupMenuItem(
                                value: TicketType.kebersihan,
                                child: Row(
                                  children: [
                                    Icon(Icons.cleaning_services_outlined, color: Colors.green[700]),
                                    const SizedBox(width: 12),
                                    const Text('Lapor Kebersihan'),
                                  ],
                                ),
                              ),
                               PopupMenuItem(
                                value: TicketType.stockRequest,
                                child: Row(
                                  children: [
                                    Icon(Icons.inventory_2_outlined, color: Colors.orange[700]),
                                    const SizedBox(width: 12),
                                    const Text('Request Stok'),
                                  ],
                                ),
                              ),
                            ],
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(100), // Capsule shape
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Buat Tiket',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    MaintenanceStatsHeader(openCount: openCount, urgentCount: urgentCount, completedToday: todayCount),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Body (Split View)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT: Kanban Board
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Filter Bar
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.search),
                                      hintText: 'Cari tiket...',
                                      filled: true, fillColor: Colors.white,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                                    ),
                                    onChanged: (val) => searchQuery.value = val,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const SizedBox(width: 12),
                                // Filter Dropdown Icon
                                PopupMenuButton<String>(
                                  tooltip: 'Filter Tiket',
                                  onSelected: (val) => filterMode.value = val,
                                  itemBuilder: (context) => [
                                     PopupMenuItem(
                                       value: 'all', 
                                       child: _buildMenuItemContent('Semua Tiket', Icons.grid_view, filterMode.value == 'all')
                                     ),
                                     PopupMenuItem(
                                       value: 'urgent', 
                                       child: _buildMenuItemContent('Prioritas Tinggi', Icons.warning_amber_rounded, filterMode.value == 'urgent')
                                     ),
                                     PopupMenuItem(
                                       value: 'unassigned', 
                                       child: _buildMenuItemContent('Belum Ditugaskan', Icons.person_off_outlined, filterMode.value == 'unassigned')
                                     ),
                                  ],
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: filterMode.value == 'all' ? Colors.white : AppTheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Icon(
                                      Icons.filter_list_rounded, 
                                      color: filterMode.value == 'all' ? Colors.grey[700] : AppTheme.primary
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Columns
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildColumn('OPEN / TO DO', todo, Colors.red, selectedTicketId),
                                  const SizedBox(width: 16),
                                  _buildColumn('IN PROGRESS', doing, Colors.blue, selectedTicketId),
                                  const SizedBox(width: 16),
                                  _buildColumn('DONE', done, Colors.green, selectedTicketId),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // RIGHT: Detail Panel (Drawer)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: selectedTicketId.value != null ? 400 : 0,
                      child: selectedTicketId.value != null 
                        ? MaintenanceDetailPanel(
                            ticket: allTickets.firstWhere((t) => t.id == selectedTicketId.value), 
                            onClose: () => selectedTicketId.value = null
                          )
                        : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  bool _isToday(DateTime? dt) {
    if (dt == null) return false;
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  Widget _buildMenuItemContent(String label, IconData icon, bool isSelected) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isSelected ? AppTheme.primary : Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label, 
          style: TextStyle(
            color: isSelected ? AppTheme.primary : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
          )
        ),
      ],
    );
  }

  Widget _buildColumn(String title, List<MaintenanceRequest> tickets, Color color, ValueNotifier<String?> selectedId) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                const Spacer(),
                Text('${tickets.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: tickets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return MaintenanceTicketCard(
                    ticket: ticket,
                    isSelected: selectedId.value == ticket.id,
                    onTap: () => selectedId.value = ticket.id,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
