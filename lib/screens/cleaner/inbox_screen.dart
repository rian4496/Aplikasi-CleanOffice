// lib/screens/cleaner/inbox_screen.dart
// ✅ UPDATED: Now uses tickets table via cleanerInboxProvider

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/ticket.dart';
import '../../riverpod/ticket_providers.dart';
import '../../riverpod/auth_providers.dart';
import '../../widgets/shared/empty_state_widget.dart';

enum SortOption { latest, oldest, urgent }

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortOption _sortOption = SortOption.latest;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }



  List<Ticket> _filterTickets(List<Ticket> tickets) {
    // 1. Filter by Search
    var filtered = tickets.where((t) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return t.title.toLowerCase().contains(q) || 
             (t.description?.toLowerCase().contains(q) ?? false) ||
             t.ticketNumber.toLowerCase().contains(q);
    }).toList();

    // 2. Sort
    filtered.sort((a, b) {
      switch (_sortOption) {
        case SortOption.latest:
          return b.createdAt.compareTo(a.createdAt);
        case SortOption.oldest:
          return a.createdAt.compareTo(b.createdAt);
        case SortOption.urgent:
          // Sort by priority index (High -> Low)
          // TicketPriority: urgent, high, medium, low
          // Assuming priority enum creates comparable order or manual check
          if (a.priority == b.priority) return b.createdAt.compareTo(a.createdAt);
          return (a.priority == TicketPriority.urgent ? 0 : 1).compareTo(b.priority == TicketPriority.urgent ? 0 : 1);
          // Simple urgent check first
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(cleanerInboxProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: ticketsAsync.when(
          data: (tickets) {
            final filteredTickets = _filterTickets(tickets);

            return Column(
              children: [
                _buildHeader(filteredTickets),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(cleanerInboxProvider);
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: filteredTickets.isEmpty
                        ? Stack(
                            children: [
                              ListView(physics: const AlwaysScrollableScrollPhysics()),
                              Positioned.fill(
                                child: _searchQuery.isNotEmpty 
                                  ? Center(child: Text('Tidak ditemukan hasil untuk "$_searchQuery"', style: GoogleFonts.inter(color: Colors.grey)))
                                  : EmptyStateWidget.noTasks(
                                      onCreateTask: () => ref.invalidate(cleanerInboxProvider),
                                    ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120), // ADD bottom padding for Floating Nav
                            itemCount: filteredTickets.length,
                            itemBuilder: (context, index) {
                              final ticket = filteredTickets[index];
                              return _TicketCard(
                                ticket: ticket,
                                onTap: () => _showTicketDetail(context, ref, ticket),
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(ref, error),
        ),
      ),
    );
  }

  Widget _buildHeader(List<Ticket> tickets) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Cari tiket...',
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.inter(color: Colors.grey),
                    ),
                    style: GoogleFonts.inter(fontSize: 18),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inbox',
                        style: GoogleFonts.inter(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) _searchController.clear();
                  });
                },
                icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded, color: const Color(0xFF4B5563)),
              ),
              PopupMenuButton<SortOption>(
                icon: const Icon(Icons.sort_rounded, color: Color(0xFF4B5563)),
                onSelected: (SortOption result) {
                  setState(() {
                    _sortOption = result;
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
                  const PopupMenuItem<SortOption>(
                    value: SortOption.latest,
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 20, color: Colors.black54),
                        SizedBox(width: 12),
                        Text('Terbaru'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<SortOption>(
                    value: SortOption.oldest,
                    child: Row(
                      children: [
                        Icon(Icons.history_rounded, size: 20, color: Colors.black54),
                        SizedBox(width: 12),
                        Text('Terlama'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<SortOption>(
                    value: SortOption.urgent,
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Prioritas (Urgent)'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _showTicketDetail(BuildContext context, WidgetRef ref, Ticket ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TicketDetailSheet(ticket: ticket, ref: ref),
    );
  }

  Widget _buildErrorState(WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          Text('Error: $error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(cleanerInboxProvider),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

// ==================== TICKET CARD ====================

class _TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const _TicketCard({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container( // Changed from Card to Container for custom shadow control
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ticket.priority == TicketPriority.urgent
              ? const Color(0xFFFECACA) // Red-200 for urgent
              : const Color(0xFFE2E8F0), // Slate-200
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Urgent Banner (if priority is urgent or high)
              if (ticket.priority == TicketPriority.urgent || ticket.priority == TicketPriority.high)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2), // Red-100
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFDC2626)),
                      const SizedBox(width: 6),
                      Text(
                        ticket.priority == TicketPriority.urgent ? 'URGENT' : 'HIGH PRIORITY',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFDC2626), // Red-600
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              // Header: Ticket Number + Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.type.displayName,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '#${ticket.ticketNumber}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(ticket.status),
                ],
              ),
              const SizedBox(height: 12),

              // Body: Title + Description
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    ticket.type == TicketType.kebersihan
                        ? Icons.cleaning_services_outlined
                        : Icons.build_outlined,
                    size: 16,
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ticket.title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF475569),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 12),

              // Footer: Location, Creator, Date
              Row(
                children: [
                  if (ticket.locationName != null) ...[
                    _buildFooterItem(Icons.location_on_outlined, ticket.locationName!),
                    const SizedBox(width: 16),
                  ],
                  if (ticket.createdByName != null)
                    _buildFooterItem(Icons.person_outline, ticket.createdByName!.split(' ')[0]),
                  const Spacer(),
                  Text(
                    DateFormatter.shortDate(ticket.createdAt),
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TicketStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case TicketStatus.open:
        bgColor = const Color(0xFFFEF3C7); // Amber-100
        textColor = const Color(0xFFD97706); // Amber-600
        break;
      case TicketStatus.claimed:
      case TicketStatus.inProgress:
        bgColor = const Color(0xFFDBEAFE); // Blue-100
        textColor = const Color(0xFF2563EB); // Blue-600
        break;
      case TicketStatus.completed:
        bgColor = const Color(0xFFD1FAE5); // Green-100
        textColor = const Color(0xFF059669); // Green-600
        break;
      default:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.displayName,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildFooterItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ==================== TICKET DETAIL SHEET ====================

class _TicketDetailSheet extends StatefulWidget {
  final Ticket ticket;
  final WidgetRef ref;

  const _TicketDetailSheet({required this.ticket, required this.ref});

  @override
  State<_TicketDetailSheet> createState() => _TicketDetailSheetState();
}

class _TicketDetailSheetState extends State<_TicketDetailSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TIKET #${widget.ticket.ticketNumber}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.ticket.title,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Status & Type
                  Row(
                    children: [
                      _buildInfoChip(widget.ticket.type.displayName, const Color(0xFF3B82F6)),
                      const SizedBox(width: 8),
                      _buildInfoChip(widget.ticket.status.displayName, _getStatusColor(widget.ticket.status)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  if (widget.ticket.description != null && widget.ticket.description!.isNotEmpty) ...[
                    Text(
                      'DESKRIPSI',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.ticket.description!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Image
                  if (widget.ticket.imageUrl != null && widget.ticket.imageUrl!.isNotEmpty) ...[
                    Text(
                      'FOTO LAMPIRAN',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.ticket.imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 100,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Location
                  if (widget.ticket.locationName != null) ...[
                    _buildDetailRow('LOKASI', widget.ticket.locationName!),
                    const SizedBox(height: 12),
                  ],

                  // Creator
                  if (widget.ticket.createdByName != null) ...[
                    _buildDetailRow('DIBUAT OLEH', widget.ticket.createdByName!),
                    const SizedBox(height: 12),
                  ],

                  // Date
                  _buildDetailRow('TANGGAL', DateFormatter.fullDateTime(widget.ticket.createdAt)),

                  // Activity Section (for claimed/in_progress tickets)
                  if (widget.ticket.assignedTo != null || widget.ticket.status != TicketStatus.open) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'AKTIVITAS',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActivitySection(),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Action Button
            if (widget.ticket.status == TicketStatus.open)
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleClaimTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Ambil Tiket',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleClaimTicket() async {
    setState(() => _isLoading = true);
    try {
      final repo = widget.ref.read(ticketRepositoryProvider);
      final userId = widget.ref.read(currentUserIdFromAuthProvider);
      
      if (userId != null) {
        await repo.claimTicket(widget.ticket.id, userId);
        widget.ref.invalidate(cleanerInboxProvider);
        widget.ref.invalidate(cleanerTasksProvider); // Refresh "Tugas Saya"
        widget.ref.invalidate(cleanerTicketStatsProvider); // Refresh stats
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tiket ${widget.ticket.ticketNumber} berhasil diambil!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil tiket: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF94A3B8),
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return const Color(0xFFD97706); // Amber
      case TicketStatus.claimed:
      case TicketStatus.inProgress:
        return const Color(0xFF2563EB); // Blue
      case TicketStatus.completed:
        return const Color(0xFF059669); // Green
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildActivitySection() {
    // Get users map from provider for name lookup
    final usersMapAsync = widget.ref.read(usersMapProvider);
    final usersMap = usersMapAsync.when(
      data: (data) => data,
      loading: () => <String, String>{},
      error: (_, __) => <String, String>{},
    );
    
    final assigneeName = widget.ticket.assignedTo != null 
      ? (usersMap[widget.ticket.assignedTo] ?? 'Petugas') 
      : 'Petugas';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Created activity
        _buildActivityItem(
          'System',
          'Tiket dibuat pada ${DateFormatter.fullDateTime(widget.ticket.createdAt)}',
        ),
        
        // Claimed activity
        if (widget.ticket.assignedTo != null && widget.ticket.claimedAt != null)
          _buildActivityItem(
            assigneeName,
            'Mengambil tiket pada ${DateFormatter.fullDateTime(widget.ticket.claimedAt!)}',
          ),
        
        // In Progress activity
        if (widget.ticket.status == TicketStatus.inProgress || widget.ticket.status == TicketStatus.completed)
          _buildActivityItem(
            assigneeName,
            'Mulai mengerjakan tiket',
          ),
        
        // Completed activity
        if (widget.ticket.status == TicketStatus.completed && widget.ticket.completedAt != null)
          _buildActivityItem(
            assigneeName,
            'Menyelesaikan tiket pada ${DateFormatter.fullDateTime(widget.ticket.completedAt!)}',
          ),
      ],
    );
  }

  Widget _buildActivityItem(String user, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: user == 'System' ? Colors.grey[300] : AppTheme.primary.withValues(alpha: 0.2),
            child: Text(
              user[0].toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: user == 'System' ? Colors.grey[600] : AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Provider to get current user ID from auth
final currentUserIdFromAuthProvider = Provider<String?>((ref) {
  // Import and use existing auth provider if available
  // For now, get from Supabase directly
  return Supabase.instance.client.auth.currentUser?.id;
});
