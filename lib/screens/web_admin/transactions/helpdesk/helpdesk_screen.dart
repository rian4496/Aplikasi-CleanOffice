import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../providers/riverpod/ticket_providers.dart';
import '../../../../../models/ticket.dart';
import 'helpdesk_components.dart';

class HelpdeskScreen extends HookConsumerWidget {
  final String? initialType;
  
  const HelpdeskScreen({super.key, this.initialType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Data & State
    final ticketsAsync = ref.watch(allTicketsProvider);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final selectedTicketId = useState<String?>(null);
    final filterMode = useState('all');

    // Determine TicketType from URL param
    TicketType? getTicketTypeFromParam() {
      if (initialType == 'kerusakan') return TicketType.kerusakan;
      if (initialType == 'kebersihan') return TicketType.kebersihan;
      if (initialType == 'stock_request') return TicketType.stockRequest;
      return null;
    }
    
    final activeType = getTicketTypeFromParam();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: ticketsAsync.when(
        data: (allTickets) {
          // --- Logic ---
          // 1. Calculate Stats (Contextual)
          final statsTickets = activeType != null 
              ? allTickets.where((t) => t.type == activeType).toList()
              : allTickets;

          final openCount = statsTickets.where((t) => t.status == TicketStatus.open).length;
          final urgentCount = statsTickets.where((t) => t.priority == TicketPriority.urgent || t.priority == TicketPriority.high).length;
          final todayCount = statsTickets.where((t) => t.status == TicketStatus.completed && _isToday(t.createdAt)).length;

          // 2. Filter List
          final filtered = allTickets.where((t) {
             // Search
             final q = searchQuery.value.toLowerCase();
             final matchSearch = t.title.toLowerCase().contains(q) || (t.description?.toLowerCase().contains(q) ?? false) || t.ticketNumber.toLowerCase().contains(q);
             
             // Category Filter (FROM URL PARAM)
             bool matchCategory = true;
             if (activeType != null) {
               matchCategory = t.type == activeType;
             }

             // Status/Priority Filter
             bool matchFilter = true;
             if (filterMode.value == 'urgent') matchFilter = t.priority == TicketPriority.urgent || t.priority == TicketPriority.high;
             if (filterMode.value == 'unassigned') matchFilter = t.assignedTo == null;
             
             return matchSearch && matchCategory && matchFilter;
          }).toList();

          // 3. Group by Status (Kanban Columns)
          final todo = filtered.where((t) => t.status == TicketStatus.open).toList();
          final doing = filtered.where((t) => t.status == TicketStatus.inProgress || t.status == TicketStatus.claimed || t.status == TicketStatus.pendingApproval).toList();
          final done = filtered.where((t) => t.status == TicketStatus.completed || t.status == TicketStatus.cancelled).toList();

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
                        // LEFT SIDE: Back Button + Title
                        Expanded(
                          child: Row(
                            children: [
                               // Back Button (If Sub-route)
                               if (activeType != null)
                                 Padding(
                                   padding: const EdgeInsets.only(right: 16),
                                   child: InkWell(
                                     onTap: () => context.go('/admin/helpdesk'),
                                     borderRadius: BorderRadius.circular(50),
                                     child: Container(
                                       padding: const EdgeInsets.all(8),
                                       decoration: BoxDecoration(
                                         border: Border.all(color: Colors.grey.shade300),
                                         shape: BoxShape.circle,
                                       ),
                                       child: const Icon(Icons.arrow_back, size: 20),
                                     ),
                                   ),
                                 ),
                               Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text(
                                     activeType == TicketType.kerusakan ? 'Pusat Laporan Kerusakan' :
                                     activeType == TicketType.kebersihan ? 'Pusat Laporan Kebersihan' :
                                     activeType == TicketType.stockRequest ? 'Pusat Permintaan Stok' :
                                     'Helpdesk Command Center', 
                                     style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)
                                   ),
                                   const SizedBox(height: 4),
                                   Text(
                                     activeType == TicketType.kerusakan ? 'Monitoring dan perbaikan aset fisik' :
                                     activeType == TicketType.kebersihan ? 'Monitoring kebersihan dan housekeeping' :
                                     activeType == TicketType.stockRequest ? 'Manajemen permintaan barang habis pakai' :
                                     'Pusat Layanan Terpadu BRIDA Kalsel', 
                                     style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)
                                   ),
                                 ],
                               ),
                            ],
                          ),
                        ),

                         // Contextual Create Button (Only in Child Screens)
                         if (activeType != null)
                            InkWell(
                              onTap: () => context.push('/admin/ticket/new', extra: activeType),
                              borderRadius: BorderRadius.circular(100),
                              child: _buildCreateButton(
                                label: 'Buat Tiket',
                                isPrimary: true,
                                colorOverride: AppTheme.primary
                              ),
                            ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    HelpdeskStatsHeader(openCount: openCount, urgentCount: urgentCount, completedToday: todayCount),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Filter Tabs (Category) - ONLY SHOW IN MAIN DASHBOARD (Semua)
              if (activeType == null) ...[
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                     children: [
                       _CategoryNavigationChip(context, 'Semua', null, activeType),
                       const SizedBox(width: 12),
                       _CategoryNavigationChip(context, 'Kerusakan', TicketType.kerusakan, activeType),
                       const SizedBox(width: 12),
                       _CategoryNavigationChip(context, 'Kebersihan', TicketType.kebersihan, activeType),
                       const SizedBox(width: 12),
                       _CategoryNavigationChip(context, 'Stok', TicketType.stockRequest, activeType),
                     ],
                  ),
                ),
                const Divider(height: 1),
              ],

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
                                // Filter Dropdown Icon
                                PopupMenuButton<String>(
                                  tooltip: 'Filter Status',
                                  onSelected: (val) => filterMode.value = val,
                                  itemBuilder: (context) => [
                                     PopupMenuItem(value: 'all', child: _buildMenuItemContent('Semua Status', Icons.grid_view, filterMode.value == 'all')),
                                     PopupMenuItem(value: 'urgent', child: _buildMenuItemContent('Prioritas Tinggi', Icons.warning_amber_rounded, filterMode.value == 'urgent')),
                                     PopupMenuItem(value: 'unassigned', child: _buildMenuItemContent('Belum Ditugaskan', Icons.person_off_outlined, filterMode.value == 'unassigned')),
                                  ],
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: filterMode.value == 'all' ? Colors.white : AppTheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Icon(Icons.filter_list_rounded, color: filterMode.value == 'all' ? Colors.grey[700] : AppTheme.primary),
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
                                  _buildColumn(context, 'OPEN / TO DO', todo, Colors.red, selectedTicketId),
                                  const SizedBox(width: 16),
                                  _buildColumn(context, 'IN PROGRESS', doing, Colors.blue, selectedTicketId),
                                  const SizedBox(width: 16),
                                  _buildColumn(context, 'DONE', done, Colors.green, selectedTicketId),
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
                        ? HelpdeskDetailPanel(
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

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  // Refactored Button Builder
  Widget _buildCreateButton({String label = 'Buat Tiket', bool isPrimary = false, Color? colorOverride}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: colorOverride ?? AppTheme.primary,
        borderRadius: BorderRadius.circular(100),
        boxShadow: isPrimary ? [
           BoxShadow(color: (colorOverride ?? AppTheme.primary).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.note_add_outlined, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMenuItemContent(String label, IconData icon, bool isSelected) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isSelected ? AppTheme.primary : Colors.grey[600]),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: isSelected ? AppTheme.primary : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildColumn(BuildContext context, String title, List<Ticket> tickets, Color color, ValueNotifier<String?> selectedId) {
    return Expanded(
      child: Column(
        children: [
          // Column Header
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Column(
                children: [
                  // Content
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                              child: Text('${tickets.length}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey[700])),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.open_in_full, size: 16, color: Colors.grey[400]),
                          tooltip: 'Lihat Selengkapnya',
                          onPressed: () => _showFullListDialog(context, title, tickets, selectedId),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Column Body
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: tickets.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Text('No Tickets', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        ],
                      ),
                    )
                  : ListView.separated(
                itemCount: tickets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return HelpdeskTicketCard(
                    ticket: ticket,
                    isSelected: selectedId.value == ticket.id,
                    onTap: () => selectedId.value = ticket.id,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullListDialog(BuildContext context, String title, List<Ticket> tickets, ValueNotifier<String?> selectedId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: tickets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                     final ticket = tickets[index];
                     return HelpdeskTicketCard(
                       ticket: ticket,
                       isSelected: false, // In dialog, simpler interaction
                       onTap: () {
                          Navigator.pop(context);
                          selectedId.value = ticket.id; // Select in main view
                       },
                     );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryNavigationChip extends StatelessWidget {
  final BuildContext context;
  final String label;
  final TicketType? type;
  final TicketType? activeType;

  const _CategoryNavigationChip(this.context, this.label, this.type, this.activeType);

  @override
  Widget build(BuildContext context) {
    final isSelected = activeType == type;
    return InkWell(
      onTap: () {
         if (type == null) {
           context.go('/admin/helpdesk');
         } else {
           if (type == TicketType.kerusakan) context.go('/admin/helpdesk/kerusakan');
           else if (type == TicketType.kebersihan) context.go('/admin/helpdesk/kebersihan');
           else if (type == TicketType.stockRequest) context.go('/admin/helpdesk/stok');
         }
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueGrey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.blueGrey.shade800 : Colors.grey.shade300),
          boxShadow: isSelected ? [BoxShadow(color: Colors.blueGrey.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

