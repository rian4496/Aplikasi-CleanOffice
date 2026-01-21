import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../riverpod/ticket_providers.dart';
import '../../../../../riverpod/auth_providers.dart';
import '../../../../../models/ticket.dart';
import '../../../../../services/chat_service.dart';
import '../../../../../screens/chat/chat_room_screen.dart';
import '../../../../../screens/chat/chat_dashboard_screen.dart';
import 'helpdesk_components.dart';
import 'assign_ticket_dialog.dart';
import 'resolve_ticket_dialog.dart';

class HelpdeskScreen extends HookConsumerWidget {
  final String? initialType;
  
  const HelpdeskScreen({super.key, this.initialType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Data & State
    final ticketsAsync = ref.watch(allTicketsProvider);
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    final filterMode = useState('all');
    
    // Category Filter (local state - not navigation)
    final categoryFilter = useState<TicketType?>(null);

    // Mobile Logic
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    // Tab Controller for Mobile Kanban
    final tabController = useTabController(initialLength: 3);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Modern BG
      appBar: isMobile ? AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin/dashboard'),
        ),
        titleSpacing: 0,
        title: Text('Helpdesk Command Center', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16)),
      ) : null,
      floatingActionButton: isMobile ? _ExpandableHelpFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: ticketsAsync.when(
        data: (allTickets) {
          // ... (Scope variables logic stays same) ...
          final statsTickets = categoryFilter.value != null ? allTickets.where((t) => t.type == categoryFilter.value).toList() : allTickets;
          final openCount = statsTickets.where((t) => t.status == TicketStatus.open).length;
          final urgentCount = statsTickets.where((t) => t.priority == TicketPriority.urgent || t.priority == TicketPriority.high).length;
          final todayCount = statsTickets.where((t) => t.status == TicketStatus.completed && _isToday(t.createdAt)).length;
          
          final completedWithTime = statsTickets.where((t) => t.status == TicketStatus.completed && t.completedAt != null).toList();
          String avgSla = '-';
          if (completedWithTime.isNotEmpty) {
             int totalMinutes = 0;
             for (final t in completedWithTime) {
               final duration = t.completedAt!.difference(t.createdAt);
               totalMinutes += duration.inMinutes;
             }
             final avgMinutes = totalMinutes ~/ completedWithTime.length;
             if (avgMinutes < 60) avgSla = '$avgMinutes Menit';
             else if (avgMinutes < 1440) avgSla = '${(avgMinutes / 60).toStringAsFixed(1)} Jam';
             else avgSla = '${(avgMinutes / 1440).toStringAsFixed(1)} Hari';
          }
          // ---------------------------

          final filtered = allTickets.where((t) {
             final q = searchQuery.value.toLowerCase();
             final matchSearch = t.title.toLowerCase().contains(q) || (t.description?.toLowerCase().contains(q) ?? false) || t.ticketNumber.toLowerCase().contains(q);
             bool matchCategory = categoryFilter.value == null || t.type == categoryFilter.value;
             bool matchFilter = true;
             if (filterMode.value == 'urgent') matchFilter = t.priority == TicketPriority.urgent || t.priority == TicketPriority.high;
             if (filterMode.value == 'unassigned') matchFilter = t.assignedTo == null;
             return matchSearch && matchCategory && matchFilter;
          }).toList();

          final todo = filtered.where((t) => t.status == TicketStatus.open).toList();
          final doing = filtered.where((t) => t.status == TicketStatus.inProgress || t.status == TicketStatus.claimed || t.status == TicketStatus.pendingApproval).toList();
          final done = filtered.where((t) => t.status == TicketStatus.completed || t.status == TicketStatus.cancelled).toList();

          return Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.only(
                  left: isMobile ? 16 : 24, 
                  right: isMobile ? 0 : 24, // Remove right padding on mobile for scrollable stats
                  top: 20, 
                  bottom: isMobile ? 12 : 20
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Row - Hidden on Mobile (shown in AppBar)
                    if (!isMobile)
                    Padding(
                      padding: EdgeInsets.only(right: isMobile ? 16 : 0), // Restore right padding for title only
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back Button (Only Desktop - Mobile has back in AppBar)
                          if (!isMobile && Navigator.canPop(context)) 
                             Padding(
                               padding: const EdgeInsets.only(right: 8.0),
                               child: IconButton(
                                 onPressed: () => Navigator.pop(context),
                                 icon: const Icon(Icons.arrow_back),
                                 color: Colors.black87,
                                 tooltip: 'Kembali',
                               ),
                             ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Helpdesk Command Center', style: GoogleFonts.inter(fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('Pusat Layanan Terpadu BRIDA Kalsel', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          // Chat Support Button (Separate from Buat Tiket)
                          if (!isMobile)
                            InkWell(
                              onTap: () => _openSupportChat(context),
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(color: Colors.teal.shade400),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.headset_mic_outlined, color: Colors.teal, size: 20),
                                    const SizedBox(width: 8),
                                    Text('Chat Support', style: GoogleFonts.inter(color: Colors.teal, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          if (!isMobile) const SizedBox(width: 12),
                          // Web Button (Hidden on Mobile)
                          if (!isMobile)
                            InkWell(
                              onTap: () => showCreateTicketDialogGlobal(context),
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.8)]),
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.note_add_outlined, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text('Buat Tiket', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    if (!isMobile) const SizedBox(height: 24),
                    
                    // Stats Header (Scrollable on Mobile)
                     HelpdeskStatsHeader(
                       openCount: openCount, 
                       urgentCount: urgentCount, 
                       completedToday: todayCount, 
                       avgSla: avgSla,
                       isMobile: isMobile, // Pass flag
                     ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Filter Tabs (Category)
              Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: isMobile 
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryFilterChip('Semua', null, categoryFilter),
                          const SizedBox(width: 16),
                          _buildCategoryFilterChip('Kerusakan', TicketType.kerusakan, categoryFilter),
                          const SizedBox(width: 16),
                          _buildCategoryFilterChip('Kebersihan', TicketType.kebersihan, categoryFilter),
                          const SizedBox(width: 16),
                          _buildCategoryFilterChip('Stok', TicketType.stockRequest, categoryFilter),
                        ],
                      ),
                    )
                  : Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildCategoryFilterChip('Semua', null, categoryFilter),
                          const SizedBox(width: 32),
                          _buildCategoryFilterChip('Kerusakan', TicketType.kerusakan, categoryFilter),
                          const SizedBox(width: 32),
                          _buildCategoryFilterChip('Kebersihan', TicketType.kebersihan, categoryFilter),
                          const SizedBox(width: 32),
                          _buildCategoryFilterChip('Stok', TicketType.stockRequest, categoryFilter),
                        ],
                      ),
                    ),
              ),
              const Divider(height: 1),

              // Search & Filter (Global)
              Container(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 16),
                  color: Colors.grey[50], // Background Match
                  child: Row(
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
                                color: filterMode.value == 'all' ? Colors.white : AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Icon(Icons.filter_list_rounded, color: filterMode.value == 'all' ? Colors.grey[700] : AppTheme.primary),
                            ),
                          ),
                      ],
                  ),
              ),

              // Mobile Tab Bar (Only if Mobile)
              if (isMobile)
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: tabController,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primary,
                    tabs: [
                      Tab(text: 'OPEN (${todo.length})'),
                      Tab(text: 'DOING (${doing.length})'),
                      Tab(text: 'DONE (${done.length})'),
                    ],
                  ),
                ),

              // Body (Split View or Tab View)
              Expanded(
                child: isMobile 
                ? TabBarView(
                    controller: tabController,
                    children: [
                       _buildMobileList(context, ref, todo, Colors.red),
                       _buildMobileList(context, ref, doing, Colors.blue),
                       _buildMobileList(context, ref, done, Colors.green),
                    ],
                  )
                : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0), // Padding reduced as search is moved up
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildColumn(context, ref, 'OPEN / TO DO', todo, Colors.red),
                            const SizedBox(width: 16),
                            _buildColumn(context, ref, 'IN PROGRESS', doing, Colors.blue),
                            const SizedBox(width: 16),
                            _buildColumn(context, ref, 'DONE', done, Colors.green),
                          ],
                        ),
                      ),
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
           BoxShadow(color: (colorOverride ?? AppTheme.primary).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
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

  Widget _buildMobileList(BuildContext context, WidgetRef ref, List<Ticket> tickets, Color color) {
    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text('Tidak ada tiket', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return HelpdeskTicketCard(
          ticket: ticket,
          isSelected: false,
          onTap: () => _showDetailDialog(context, ref, ticket),
        );
      },
    );
  }

  Widget _buildColumn(BuildContext context, WidgetRef ref, String title, List<Ticket> tickets, Color color) {
    return Expanded(
      child: Column(
        children: [
          // Column Header
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 3))],
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
                          onPressed: () => _showFullListDialog(context, ref, title, tickets),
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
                          const SizedBox(width: 8),
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
                    isSelected: false,
                    onTap: () => _showDetailDialog(context, ref, ticket),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext context, WidgetRef ref, Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Consumer(
            builder: (context, ref, child) {
              final usersMapAsync = ref.watch(usersMapProvider);
              final usersMap = usersMapAsync.maybeWhen(
                data: (data) => data,
                orElse: () => <String, String>{},
              );
              
              return HelpdeskDetailPanel(
                ticket: ticket, 
                usersMap: usersMap,
                onClose: () => Navigator.pop(context),
            onAssign: () async {
              // Close detail dialog first? No, open assign dialog ON TOP.
              // Logic: Open AssignDialog. If success, refresh list and close detail dialog.
              
              final result = await showDialog<bool>(
                context: context,
                builder: (c) => AssignTicketDialog(ticket: ticket),
              );

              if (result == true && context.mounted) {
                 // Refresh list (invalidate provider)
                 ref.invalidate(allTicketsProvider);
                 
                 // Close detail dialog
                 Navigator.pop(context);
                 
                 // Show success
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Tiket berhasil di-assign')),
                 );
              }
            },
            onResolve: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (c) => ResolveTicketDialog(ticket: ticket),
              );

              if (result == true && context.mounted) {
                 ref.invalidate(allTicketsProvider);
                 Navigator.pop(context); // Close detail dialog
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Tiket berhasil diselesaikan')),
                 );
              }
            },
            onDelete: () async {
              // Show confirmation dialog
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Hapus Tiket?'),
                  content: Text('Anda yakin ingin menghapus tiket #${ticket.ticketNumber}? Tindakan ini tidak dapat dibatalkan.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
                    TextButton(
                      onPressed: () => Navigator.pop(c, true), 
                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                try {
                  await ref.read(ticketRepositoryProvider).deleteTicket(ticket.id);
                  if (context.mounted) {
                    ref.invalidate(allTicketsProvider); // Refresh list
                    Navigator.pop(context); // Close detail dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tiket #${ticket.ticketNumber} berhasil dihapus')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menghapus tiket: $e')),
                    );
                  }
                }
              }
            },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showFullListDialog(BuildContext context, WidgetRef ref, String title, List<Ticket> tickets) {
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
                       isSelected: false, 
                       onTap: () {
                          Navigator.pop(context);
                          _showDetailDialog(context, ref, ticket);
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

// --- Category Filter Chip (Local State) ---
Widget _buildCategoryFilterChip(String label, TicketType? type, ValueNotifier<TicketType?> categoryFilter) {
  final isSelected = categoryFilter.value == type;
  return InkWell(
    onTap: () => categoryFilter.value = type,
    borderRadius: BorderRadius.circular(20),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blueGrey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? Colors.blueGrey.shade800 : Colors.grey.shade300),
        boxShadow: isSelected ? [BoxShadow(color: Colors.blueGrey.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))] : null,
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

// --- Create Ticket Dialog (Global) ---
void showCreateTicketDialogGlobal(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Buat Tiket Baru',
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih jenis tiket yang ingin dibuat:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            
            // Option 1: Laporan Kerusakan
            _buildTicketTypeOption(
              context,
              icon: Icons.build_circle_outlined,
              iconColor: Colors.blue,
              title: 'Laporan Kerusakan',
              subtitle: 'Laporkan aset yang rusak atau bermasalah',
              onTap: () {
                Navigator.pop(context);
                context.go('/admin/ticket/new', extra: TicketType.kerusakan);
              },
            ),
            const SizedBox(height: 12),
            
            // Option 2: Laporan Kebersihan
            _buildTicketTypeOption(
              context,
              icon: Icons.cleaning_services_outlined,
              iconColor: Colors.green,
              title: 'Laporan Masalah Kebersihan',
              subtitle: 'Laporkan area yang perlu dibersihkan',
              onTap: () {
                Navigator.pop(context);
                context.go('/admin/ticket/new', extra: TicketType.kebersihan);
              },
            ),
            const SizedBox(height: 12),
            
            // Option 3: Request Stok
            _buildTicketTypeOption(
              context,
              icon: Icons.inventory_2_outlined,
              iconColor: Colors.orange,
              title: 'Request Stok',
              subtitle: 'Ajukan permintaan barang/stok',
              onTap: () {
                Navigator.pop(context);
                context.go('/admin/ticket/new', extra: TicketType.stockRequest);
              },
            ),
            // Hubungi Support removed - now a separate button
          ],
        ),
      ),
    ),
  );
}

Widget _buildTicketTypeOption(
  BuildContext context, {
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    ),
  );
}

// --- Open Support Chat ---
void _openSupportChat(BuildContext context) {
  // Simply navigate to ChatDashboardScreen without auto-creating a conversation
  // User can start a new chat manually from the "Chat Baru" button
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const ChatDashboardScreen(),
    ),
  );
}

// --- Support Chat Room Wrapper ---
class _SupportChatRoomWrapper extends StatelessWidget {
  final String conversationId;
  final String supportName;
  
  const _SupportChatRoomWrapper({
    required this.conversationId,
    required this.supportName,
  });
  
  @override
  Widget build(BuildContext context) {
    return ChatRoomScreen(
      conversationId: conversationId,
      otherUserName: supportName,
    );
  }
}

// --- Expandable Help FAB for Mobile ---
class _ExpandableHelpFab extends StatefulWidget {
  @override
  State<_ExpandableHelpFab> createState() => _ExpandableHelpFabState();
}

class _ExpandableHelpFabState extends State<_ExpandableHelpFab> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const double buttonWidth = 160; // Fixed width for uniform buttons
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Expandable Options
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Option 1: Chat Support
                  _buildOptionButton(
                    icon: Icons.headset_mic_outlined,
                    label: 'Chat Support',
                    color: Colors.teal,
                    width: buttonWidth,
                    onTap: () {
                      _toggle();
                      _openSupportChat(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  // Option 2: Buat Tiket
                  _buildOptionButton(
                    icon: Icons.note_add_outlined,
                    label: 'Buat Tiket',
                    color: Colors.blue,
                    width: buttonWidth,
                    onTap: () {
                      _toggle();
                      showCreateTicketDialogGlobal(context);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Main FAB: Bantuan
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: buttonWidth,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isExpanded 
                    ? [Colors.grey.shade600, Colors.grey.shade700] 
                    : [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.9)],
                ),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: (_isExpanded ? Colors.grey : AppTheme.primary).withValues(alpha: 0.3), 
                    blurRadius: 10, 
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedRotation(
                    turns: _isExpanded ? 0.125 : 0, // 45 degrees
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _isExpanded ? Icons.close : Icons.headset_mic_outlined, 
                      color: Colors.white, 
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isExpanded ? 'Tutup' : 'Bantuan', 
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required double width,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: color.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
