// lib/screens/cleaner/cleaner_home_screen.dart
// ✅ RECREATED: Pixel-Perfect Match with referensi_tampilan_cleaner.html
// 🎨 Design System: Slate & Blue Palette (Tailwind-like)
// 🔤 Typography: Inter (Google Fonts)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui; // Needed for Web Mouse Scroll support
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../riverpod/auth_providers.dart';
import '../../riverpod/cleaner_providers.dart';
import '../../riverpod/ticket_providers.dart';
import '../../models/ticket.dart'; // For TicketStatus enum
import '../../widgets/chat/new_chat_dialog.dart';
import '../../riverpod/notification_providers.dart';

import './inbox_screen.dart';
import '../../widgets/cleaner/lapor_masalah_dialog.dart';
import '../../widgets/shared/realtime_notification_listener.dart';
import '../chat/conversation_list_screen.dart';
import '../chat/chat_room_screen.dart';
import '../shared/profile_screen.dart'; // Import ProfileScreen

class CleanerHomeScreen extends ConsumerStatefulWidget {
  const CleanerHomeScreen({super.key});

  @override
  ConsumerState<CleanerHomeScreen> createState() => _CleanerHomeScreenState();
}

class _CleanerHomeScreenState extends ConsumerState<CleanerHomeScreen> {
  int _currentNavIndex = 0;

  // Define pages for persistent navigation
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _DashboardContent(
        onTabChanged: (index) => setState(() => _currentNavIndex = index),
      ),
      const InboxScreen(), // Full screen widget
      const ConversationListScreen(showBottomNav: false), // Hide internal bottom nav
      const ProfileScreen(), // Full screen widget
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Color Palette from Reference
    final primaryBlue = const Color(0xFF3B82F6); // Blue-500
    final bgLight = const Color(0xFFF8FAFC); // Slate-50

    return RealtimeNotificationListener(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // Black icons
          statusBarBrightness: Brightness.light, // iOS light status bar (dark text)
        ),
        child: Container(
          color: const Color(0xFFF1F5F9), // Slate-100 (Very Light Gray)
          child: SafeArea(
            bottom: false,
            child: Scaffold(
              backgroundColor: bgLight,
              // Use Stack to overlay Bottom Nav on top of pages
              body: Stack(
          children: [
          // Persistent Pages
          IndexedStack(
            index: _currentNavIndex,
            children: _pages,
          ),

          // FAB (Lapor) - Only show on Dashboard (Index 0)
          if (_currentNavIndex == 0)
            Positioned(
              bottom: 96,
              right: 20,
              child: SizedBox(
                 height: 56,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const LaporMasalahDialog(),
                    );
                  },
                  backgroundColor: primaryBlue,
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  icon: const Icon(Icons.campaign_rounded, size: 24, color: Colors.white),
                  label: Text(
                    'Lapor',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            
          // FAB (New Chat) - Only show on Chat (Index 2)
          if (_currentNavIndex == 2)
             Positioned(
              bottom: 96,
              right: 20,
              child: SizedBox(
                width: 56,
                height: 56,
                child: FloatingActionButton(
                  onPressed: () async {
                      final currentUser = ref.read(currentUserProfileProvider).value;
                      if (currentUser != null) {
                        final selectedUser = await showDialog<dynamic>(
                          context: context,
                          builder: (context) => NewChatDialog(currentUserId: currentUser.uid),
                        );
                        
                        // If user selected, navigate to chat room
                        if (selectedUser != null && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatRoomScreen(
                                conversationId: 'new_${selectedUser.uid}',
                                otherUserName: selectedUser.displayName,
                              ),
                            ),
                          );
                        }
                      }
                  },
                  backgroundColor: const Color(0xFF2563EB), // Blue-600
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Squircle
                  child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 28),
                ),
              ),
             ),

          // Custom Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNav(primaryBlue),
          ),
        ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== BOTTOM NAV ====================
  Widget _buildBottomNav(Color primary) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))), // slate-200
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12), // Increased padding slightly (8 -> 12)
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(Icons.home_rounded, 'Beranda', 0, primary),
              _navItem(Icons.inbox_rounded, 'Inbox', 1, primary),
              _navItem(Icons.chat_bubble_rounded, 'Chat', 2, primary),
              _navItem(Icons.person_rounded, 'Profil', 3, primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, Color primary) {
    final isActive = _currentNavIndex == index;
    final color = isActive ? primary : const Color(0xFF64748B); // text-slate-500
    
    return InkWell(
      onTap: () {
        setState(() => _currentNavIndex = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26), // Increased size (24 -> 26)
          const SizedBox(height: 3), // Increased gap (2 -> 3)
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: color)), // Increased font (11 -> 12)
        ],
      ),
    );
  }
}

// ==================== DASHBOARD CONTENT (Extracted) ====================
class _DashboardContent extends ConsumerWidget {
  final Function(int)? onTabChanged;

  const _DashboardContent({this.onTabChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketStatsAsync = ref.watch(cleanerTicketStatsProvider);
    final primaryBlue = const Color(0xFF3B82F6); 

    // Get stats with default fallback using when pattern
    final cleanerStats = ticketStatsAsync.when(
      data: (stats) => stats,
      loading: () => <String, int>{
        'assigned': 0,
        'inProgress': 0,
        'completed': 0,
        'total': 0,
        'completedToday': 0,
        'avgWorkTimeMinutes': 0,
      },
      error: (_, __) => <String, int>{
        'assigned': 0,
        'inProgress': 0,
        'completed': 0,
        'total': 0,
        'completedToday': 0,
        'avgWorkTimeMinutes': 0,
      },
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(cleanerTicketStatsProvider);
        ref.invalidate(cleanerTasksProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120), // Extra space for Nav + Lapor FAB
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Section
            _buildHeader(context, ref),

            const SizedBox(height: 24),

            // 2. Horizontal Stat Cards
            _buildStatScroll(context, cleanerStats),

            const SizedBox(height: 24),

            // 3. Ringkasan Kinerja
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildPerformanceCard(cleanerStats, primaryBlue),
            ),

            const SizedBox(height: 24),

            // 4. Tugas Saya Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment_outlined, color: Color(0xFF94A3B8), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Tugas Saya',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.push('/cleaner/my-tasks'),
                    child: Text(
                      'Lihat Semua',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF3B82F6)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 5. Tugas Saya Content - Use Provider
            _buildMyTasksPreview(ref),

            const SizedBox(height: 24),

            // 6. Jadwal Kebersihan Section
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: Color(0xFF94A3B8), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Jadwal Kebersihan',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.push('/cleaner/schedule'),
                    child: Text(
                      'Lihat Semua',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF3B82F6)),
                    ),
                  ),
                ],
              ),
            ),
            
            // Jadwal Empty State
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                   children: [
                     Text(
                       'Tidak ada jadwal mendatang',
                       style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
                     ),
                   ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... helper methods copied from previous state ...
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Selamat Malam,',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  userProfileAsync.when(
                    data: (profile) => Text(
                      profile?.displayName ?? 'Hadianur',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    loading: () => Text('Hadianur...', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
                    error: (_,__) => Text('Cleaner', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Row(
                children: [
                   IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Color(0xFF94A3B8)),
                    onPressed: () => context.push('/admin/notifications'), // Update route
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 40,
                    width: 40,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF), // Blue-50/10
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF1F5F9), width: 2), // Slate-100
                    ),
                    child: ClipOval(
                      child: userProfileAsync.when(
                        data: (profile) {
                           return Center(
                             child: Text(
                               profile?.displayName?[0] ?? 'H', 
                               style: GoogleFonts.inter(color: const Color(0xFF3B82F6), fontWeight: FontWeight.bold)
                             )
                           );
                        },
                        loading: () => const SizedBox(),
                        error: (_,__) => const Icon(Icons.person, color: Color(0xFF3B82F6)),
                      ),
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi,';
    if (hour < 15) return 'Selamat Siang,';
    if (hour < 18) return 'Selamat Sore,';
    return 'Selamat Malam,';
  }

  Widget _buildStatScroll(BuildContext context, Map<String, int> stats) {
    final cards = [
      {'icon': Icons.send_rounded, 'val': '${stats['total']??0}', 'label': 'Total Tugas', 'sub': 'Semua laporan', 'c': Colors.blue, 'bg': const Color(0xFFEFF6FF)},
      {'icon': Icons.engineering_rounded, 'val': '${stats['inProgress']??3}', 'label': 'Dikerjakan', 'sub': 'Sedang aktif', 'c': Colors.orange, 'bg': const Color(0xFFFFF7ED)},
      {'icon': Icons.schedule_rounded, 'val': '${stats['assigned']??5}', 'label': 'Menunggu', 'sub': 'Belum dimulai', 'c': Colors.amber, 'bg': const Color(0xFFFEFCE8)},
      {'icon': Icons.check_circle_rounded, 'val': '${stats['completed']??3}', 'label': 'Selesai', 'sub': 'Hari ini', 'c': Colors.green, 'bg': const Color(0xFFF0FDF4)},
    ];

    return SizedBox(
      height: 140,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            ui.PointerDeviceKind.touch,
            ui.PointerDeviceKind.mouse,
          },
        ),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          scrollDirection: Axis.horizontal,
          itemCount: cards.length,
          separatorBuilder: (_,__) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
          final item = cards[index];
          return Container(
            width: 144,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item['bg'] as Color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item['icon'] as IconData, color: item['c'] as Color, size: 20),
                    ),
                    Text(
                      item['val'] as String,
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['label'] as String, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
                    Text(item['sub'] as String, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
          );
        },
        ),
      ),
    );
  }

  Widget _buildMyTasksPreview(WidgetRef ref) {
    final ticketsAsync = ref.watch(cleanerTasksProvider);

    return ticketsAsync.when(
      data: (tickets) {
        if (tickets.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Center(
              child: Text(
                'Tidak ada tugas aktif.',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
              ),
            ),
          );
        }

        // Show max 3 tickets as preview
        final previewTickets = tickets.take(3).toList();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: previewTickets.map((ticket) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ticket.status == TicketStatus.claimed ? Colors.orange.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.cleaning_services_rounded,
                      color: ticket.status == TicketStatus.claimed ? Colors.orange : Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.title,
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (ticket.locationName != null)
                          Text(
                            ticket.locationName!,
                            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ticket.status == TicketStatus.claimed ? Colors.orange.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ticket.status == TicketStatus.claimed ? 'Diambil' : 'Proses',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ticket.status == TicketStatus.claimed ? Colors.orange : Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text('Gagal memuat tugas', style: GoogleFonts.inter(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(Map<String, int> stats, Color primary) {
    // Calculate completion rate dynamically
    final total = stats['total'] ?? 0;
    final completed = stats['completed'] ?? 0;
    final completionRate = total > 0 ? (completed / total) : 0.0;
    final completionPercent = (completionRate * 100).round();
    
    // Get other stats
    final assigned = stats['assigned'] ?? 0;
    final inProgress = stats['inProgress'] ?? 0;
    final avgTimeMinutes = stats['avgWorkTimeMinutes'] ?? 0;
    final completedToday = stats['completedToday'] ?? 0;
    
    // Format avg time
    String avgTimeText;
    if (avgTimeMinutes >= 60) {
      final hours = avgTimeMinutes ~/ 60;
      final mins = avgTimeMinutes % 60;
      avgTimeText = mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    } else if (avgTimeMinutes > 0) {
      avgTimeText = '${avgTimeMinutes}m';
    } else {
      avgTimeText = '-';
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: primary),
              const SizedBox(width: 8),
              Text('Ringkasan Kinerja', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tingkat Penyelesaian', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF475569))),
              Text('$completionPercent%', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: primary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: completionRate,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation(primary),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Col 1: Status Tugas
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('STATUS TUGAS', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: const Color(0xFF94A3B8))),
                    const SizedBox(height: 12),
                    _buildStatRow('Menunggu', '$assigned'),
                    const SizedBox(height: 12),
                    _buildStatRow('Dalam Proses', '$inProgress'),
                    const SizedBox(height: 12),
                    _buildStatRow('Selesai', '$completed'),
                  ],
                ),
              ),
              // Vertical Divider
              Container(width: 1, height: 100, color: const Color(0xFFF1F5F9), margin: const EdgeInsets.symmetric(horizontal: 24)),
              // Col 2: Metrik
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('METRIK', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: const Color(0xFF94A3B8))),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Waktu Rata²', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569))),
                        Text(avgTimeText, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1E293B))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Hari Ini', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569))),
                        Text('$completedToday selesai', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(count, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569))),
        ),
      ],
    );
  }
}
