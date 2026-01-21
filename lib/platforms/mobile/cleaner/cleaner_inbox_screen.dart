// lib/platforms/mobile/cleaner/cleaner_inbox_screen.dart
// Inbox Screen untuk Cleaner - Menampung Laporan Masuk + Permintaan Layanan pending + Keluhan (Tickets)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; // Added
import 'package:intl/intl.dart'; // Added
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../riverpod/cleaner_providers.dart';
import '../../../riverpod/ticket_providers.dart'; // Added
import '../../../riverpod/auth_providers.dart';
import '../../../models/ticket.dart'; // Added
import '../../../widgets/shared/empty_state_widget.dart';
import '../../../widgets/cleaner/cleaner_report_card.dart';
import '../../../widgets/shared/request_card_widget.dart';
import '../navigation/cleaner_more_bottom_sheet.dart';
import '../../../widgets/shared/notification_bell.dart';
import '../../../widgets/shared/drawer_menu_widget.dart';
import './report_detail_cleaner_screen.dart';
import '../../shared/request_detail/request_detail_screen.dart';
import '../../chat/conversation_list_screen.dart';

class CleanerInboxScreen extends ConsumerStatefulWidget {
  const CleanerInboxScreen({super.key});

  @override
  ConsumerState<CleanerInboxScreen> createState() => _CleanerInboxScreenState();
}

class _CleanerInboxScreenState extends ConsumerState<CleanerInboxScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Changed to 3
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      endDrawer: _buildMobileDrawer(),
      appBar: AppBar(
        title: const Text(
          'Inbox',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          const NotificationBell(iconColor: Colors.white),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(
              icon: Icon(Icons.assignment_outlined),
              text: 'Laporan',
            ),
            Tab(
              icon: Icon(Icons.warning_amber_rounded), // Icon for complaints
              text: 'Keluhan',
            ),
            Tab(
              icon: Icon(Icons.room_service_outlined),
              text: 'Permintaan',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportsTab(),
          _buildComplaintsTab(), // Added
          _buildRequestsTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ... (Reports Tab and Requests Tab unchanged, but need to be careful with replace)
  // I will include them to be safe or use multiple chunks if I wasn't replacing the whole file logic.
  // Actually, I am replacing from line 1.

  Widget _buildReportsTab() {
    final pendingReportsAsync = ref.watch(pendingReportsProvider);

    return pendingReportsAsync.when(
      data: (reports) {
        if (reports.isEmpty) {
          return EmptyStateWidget.noReports();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(pendingReportsProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return CleanerReportCard(
                report: report,
                animationIndex: index,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CleanerReportDetailScreen(
                        reportId: report.id,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error, () {
        ref.invalidate(pendingReportsProvider);
      }),
    );
  }

  Widget _buildRequestsTab() {
    final availableRequestsAsync = ref.watch(availableRequestsProvider);

    return availableRequestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return EmptyStateWidget.noRequests();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(availableRequestsProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return RequestCardWidget(
                request: request,
                animationIndex: index,
                compact: false,
                showAssignee: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequestDetailScreen(
                        requestId: request.id,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error, () {
        ref.invalidate(availableRequestsProvider);
      }),
    );
  }

  // NEW: Complaints Tab (Tickets)
  Widget _buildComplaintsTab() {
    final ticketsAsync = ref.watch(cleanerInboxProvider);

    return ticketsAsync.when(
      data: (tickets) {
        if (tickets.isEmpty) {
           return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cleaning_services_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada keluhan baru',
                    style: GoogleFonts.inter(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(cleanerInboxProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return _CleanerTicketCard(
                ticket: ticket,
                onClaim: () => _claimTicket(context, ref, ticket),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error, () {
        ref.invalidate(cleanerInboxProvider);
      }),
    );
  }

  Future<void> _claimTicket(BuildContext context, WidgetRef ref, Ticket ticket) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final repo = ref.read(ticketRepositoryProvider);
      await repo.claimTicket(ticket.id, userId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Keluhan ${ticket.ticketNumber} berhasil diambil!')),
        );
        ref.invalidate(cleanerInboxProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildErrorState(Object error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  // ==================== BOTTOM NAVIGATION BAR ====================
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: false,
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppConstants.homeCleanerRoute,
                  (route) => false,
                ),
              ),
              _buildNavItem(
                icon: Icons.inbox_rounded,
                label: 'Inbox',
                isActive: true,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.chat_rounded,
                label: 'Chat',
                isActive: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConversationListScreen(),
                  ),
                ),
              ),
              _buildNavItem(
                icon: Icons.more_horiz_rounded,
                label: 'Lainnya',
                isActive: false,
                onTap: () {
                  CleanerMoreBottomSheet.show(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? AppTheme.primary : Colors.grey[600]!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DRAWER ====================
  Widget _buildMobileDrawer() {
    return DrawerMenuWidget(
      menuItems: [
        DrawerMenuItem(
          icon: Icons.inbox_rounded,
          title: 'Inbox',
          onTap: () => Navigator.pop(context),
        ),
        DrawerMenuItem(
          icon: Icons.person_outline,
          title: 'Profil',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, AppConstants.profileRoute);
          },
        ),
        DrawerMenuItem(
          icon: Icons.settings_outlined,
          title: 'Pengaturan',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
      onLogout: () => _handleLogout(),
      roleTitle: 'Petugas Kebersihan',
    );
  }

  Future<void> _handleLogout() async {
    await Supabase.instance.client.auth.signOut();
    // GoRouter will auto-redirect to /login
  }
}

// Internal Widget for Ticket Card (Copied/Adapted for Cleaner)
class _CleanerTicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onClaim;

  const _CleanerTicketCard({required this.ticket, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    final bool canClaim = ticket.status == TicketStatus.open;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to detail? OR just expand
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Ticket Number + Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(ticket.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getPriorityColor(ticket.priority).withOpacity(0.3)),
                    ),
                    child: Text(
                      ticket.priority.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getPriorityColor(ticket.priority),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ticket.ticketNumber,
                    style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  _StatusBadge(status: ticket.status),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                ticket.title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Description
              if (ticket.description != null && ticket.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  ticket.description!,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Footer: Date + Claim Button
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM, HH:mm').format(ticket.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const Spacer(),
                  if (canClaim)
                    ElevatedButton.icon(
                      onPressed: onClaim,
                      icon: const Icon(Icons.assignment_turned_in, size: 16),
                      label: const Text('Ambil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    )
                  else
                     Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Sudah Diambil',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low: return Colors.grey;
      case TicketPriority.normal: return Colors.blue;
      case TicketPriority.high: return Colors.orange;
      case TicketPriority.urgent: return Colors.red;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final TicketStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case TicketStatus.open:
        color = Colors.blue;
        break;
      case TicketStatus.claimed:
      case TicketStatus.inProgress:
        color = Colors.orange;
        break;
      case TicketStatus.completed:
      case TicketStatus.approved:
        color = Colors.green;
        break;
      case TicketStatus.rejected:
      case TicketStatus.cancelled:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
