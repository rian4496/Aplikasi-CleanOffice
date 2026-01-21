// lib/screens/console/cleaner/web_cleaner_dashboard.dart
// 🖥️ Web Cleaner Dashboard - Responsive view for Cleaner role

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../services/web_notification_service_interface.dart';

import '../../../core/theme/app_theme.dart';
import 'dart:ui' as ui;
import '../../../riverpod/cleaner_providers.dart';
import '../../../riverpod/auth_providers.dart';
import '../../../riverpod/supabase_service_providers.dart';
import '../../../riverpod/notification_providers.dart';
import '../../../models/report.dart';
import '../../../models/user_profile.dart'; // ✅ Added correct import
import '../../chat/conversation_list_screen.dart';
import '../../../widgets/web_admin/layout/admin_sidebar.dart';
import '../../../widgets/web_admin/cards/compact_stat_card.dart'; // Added CompactStatCard
import '../../cleaner/cleaner_home_screen.dart'; // Import Native Mobile Screen

class WebCleanerDashboard extends HookConsumerWidget {
  const WebCleanerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(0); // 0: Home, 1: Inbox, 2: Chat, 3: Profile
    final stats = ref.watch(cleanerStatsProvider);
    final activeReportsAsync = ref.watch(cleanerActiveReportsProvider);
    final pendingReportsAsync = ref.watch(pendingReportsProvider);
    final userProfile = ref.watch(currentUserProfileProvider).value;

    // Notification Service State
    final notificationService = useMemoized(() => WebNotificationService());
    final notificationEnabled = useState(notificationService.isEnabled);
    final permissionStatus = useState(notificationService.permissionStatus);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        // ================= DESKTOP VIEW =================
        if (!isMobile) {
          return Scaffold(
            backgroundColor: AppTheme.modernBg,
             body: RefreshIndicator(
              onRefresh: () async {
                 ref.invalidate(cleanerActiveReportsProvider);
                 ref.invalidate(pendingReportsProvider);
                 ref.invalidate(cleanerStatsProvider);
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDesktopHeader(userProfile?.displayName ?? 'Cleaner'),
                    _buildDesktopSplitView(context, ref, stats, activeReportsAsync, pendingReportsAsync),
                     const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        }

        // ================= MOBILE VIEW (Synced with Native) =================
        return const CleanerHomeScreen();
      },
    );
  }



  // ==================== DESKTOP & DIALOG METHODS ====================

  Widget _buildDesktopHeader(String name) {
    // Determine greeting
    final hour = DateTime.now().hour;
    String greeting = 'Selamat Pagi';
    if (hour >= 11) greeting = 'Selamat Siang';
    if (hour >= 15) greeting = 'Selamat Sore';
    if (hour >= 19) greeting = 'Selamat Malam';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      margin: const EdgeInsets.only(top: 24, bottom: 24), // Add margin
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  painter: HeaderWavePainter(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/vector_greeting.png',
                    height: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.account_circle, size: 80, color: Colors.white),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      _formatIndonesianDate(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSplitView(
    BuildContext context, 
    WidgetRef ref, 
    Map<String, int> stats, 
    AsyncValue<List<Report>> activeReportsAsync, 
    AsyncValue<List<Report>> pendingReportsAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel: Ringkasan Kinerja (Flex 2)
          Expanded(
            flex: 2,
            child: _buildDesktopPerformanceCard(stats),
          ),
          const SizedBox(width: 24),
          // Right Panel: Inbox Tiket (Flex 1)
          Expanded(
            flex: 1,
            child: _buildDesktopInboxList(context, ref, activeReportsAsync, pendingReportsAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopPerformanceCard(Map<String, int> stats) {
    // Calculate Completion Rate logic
    final total = (stats['assigned'] ?? 0) + (stats['inProgress'] ?? 0) + (stats['completedToday'] ?? 0) + (stats['pending'] ?? 0);
    final completed = stats['completedToday'] ?? 0;
    final double completionRate = total == 0 ? 0 : (completed / total);
    final percent = (completionRate * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(width: 12),
              Text('Ringkasan Kinerja', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 24),
          
          // Progress Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tingkat Penyelesaian', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF64748B))),
              Text('$percent%', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: completionRate, backgroundColor: const Color(0xFFF1F5F9), color: const Color(0xFF3B82F6), minHeight: 12),
          ),
          const SizedBox(height: 32),

          // Split Status & Metrik
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Tugas
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status Tugas', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                    const SizedBox(height: 16),
                    _perfRow('Menunggu', stats['pending'] ?? 0),
                    const SizedBox(height: 12),
                    _perfRow('Dalam Proses', stats['inProgress'] ?? 0),
                    const SizedBox(height: 12),
                    _perfRow('Selesai', stats['completedToday'] ?? 0),
                  ],
                ),
              ),
              Container(width: 1, height: 120, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 24)),
              // Metrik
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Metrik', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                    const SizedBox(height: 16),
                    _perfRowMetric('Waktu Rata-rata', '45 menit'),
                    const SizedBox(height: 12),
                    _perfRowMetric('Hari Ini', '${stats['completedToday'] ?? 0} selesai', isGreen: true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopInboxList(
    BuildContext context, 
    WidgetRef ref, 
    AsyncValue<List<Report>> activeReportsAsync, 
    AsyncValue<List<Report>> pendingReportsAsync,
  ) {
    // Combine lists safely
    final active = activeReportsAsync.asData?.value ?? [];
    final pending = pendingReportsAsync.asData?.value ?? [];
    final allReports = [...active, ...pending];
    // Sort by date desc
    allReports.sort((a, b) => b.date.compareTo(a.date));

    return Container(
      constraints: const BoxConstraints(minHeight: 400),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(16),
         boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               const Icon(Icons.inbox_rounded, color: Color(0xFF64748B)),
               const SizedBox(width: 12),
               Text('Inbox Tiket', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 24),
          if (allReports.isEmpty) 
             const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Tidak ada tiket masuk'))),
          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allReports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final report = allReports[index];
              return _buildDesktopTaskCard(context, ref, report);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTaskCard(BuildContext context, WidgetRef ref, Report report) {
     final isPending = report.status == ReportStatus.pending;
     final isUrgent = report.isUrgent;

     return Container(
       decoration: BoxDecoration(
         border: Border.all(color: Colors.grey.shade200),
         borderRadius: BorderRadius.circular(12),
       ),
       padding: const EdgeInsets.all(16),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           // Row 1: Title and Status Chip
           Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Expanded(
                 child: Text(
                   report.title,
                   style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                   maxLines: 2, overflow: TextOverflow.ellipsis,
                 ),
               ),
               const SizedBox(width: 8),
               _buildStatusChip(report.status),
             ],
           ),
           const SizedBox(height: 8),
           
           // Row 2: Location
           Row(
             children: [
               Icon(Icons.place_outlined, size: 14, color: Colors.grey.shade500),
               const SizedBox(width: 4),
               Expanded(
                 child: Text(
                   report.location, 
                   style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500),
                   maxLines: 1, overflow: TextOverflow.ellipsis,
                 ),
               ),
             ],
           ),
           const SizedBox(height: 12),

           // Row 3: User and Priority
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text(report.userName, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
               // Priority Chip
               _buildSimplePriorityChip(isUrgent),
             ],
           ),
           
           // Hidden Action for tapping
           if (isPending)
             Padding(
               padding: const EdgeInsets.only(top: 12),
               child: SizedBox(
                 width: double.infinity,
                 child: OutlinedButton(
                    onPressed: () => _handleCardAction(context, ref, report, true),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF3B82F6)),
                      padding: const EdgeInsets.symmetric(vertical: 0), // Small height
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Ambil Tugas', style: TextStyle(fontSize: 12)),
                 ),
               ),
             ),
             
           if (!isPending && report.status == ReportStatus.inProgress)
             Padding(
               padding: const EdgeInsets.only(top: 12),
               child: SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                    onPressed: () => _handleCardAction(context, ref, report, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Selesaikan', style: TextStyle(fontSize: 12, color: Colors.white)),
                 ),
               ),
             ),
         ],
       ),
     );
  }

  Widget _buildSimplePriorityChip(bool isUrgent) {
    if (isUrgent) {
       return Container(
         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
         decoration: BoxDecoration(
           color: const Color(0xFFFEF2F2),
           border: Border.all(color: const Color(0xFFFECACA)),
           borderRadius: BorderRadius.circular(4),
         ),
         child: Text('Urgent', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFFB91C1C))),
       );
    } else {
       return Container(
         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
         decoration: BoxDecoration(
           color: const Color(0xFFFFF7ED),
           border: Border.all(color: const Color(0xFFFFEDD5)),
           borderRadius: BorderRadius.circular(4),
         ),
         child: Text('Biasa', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFFC2410C))),
       );
    }
  }



  String _formatIndonesianDate(DateTime date) {
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final List<String> days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _perfRow(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
          child: Text(value.toString(), style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569))),
        ),
      ],
    );
  }

  Widget _perfRowMetric(String label, String value, {IconData? icon, Color? iconColor, bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569))),
        Row(
          children: [
            if (icon != null) Icon(icon, size: 14, color: iconColor),
            if (icon != null) const SizedBox(width: 2),
            Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: isGreen ? Colors.green : const Color(0xFF1E293B))),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(ReportStatus status) {
    Color bg, text;
    String label;
    switch(status) {
      case ReportStatus.pending: bg = Colors.purple[50]!; text = Colors.purple[700]!; label = 'Pending'; break;
      case ReportStatus.assigned: bg = Colors.blue[50]!; text = Colors.blue[700]!; label = 'Assigned'; break;
      case ReportStatus.inProgress: bg = Colors.blue[100]!; text = Colors.blue[800]!; label = 'In Progress'; break;
      case ReportStatus.completed: bg = Colors.green[100]!; text = Colors.green[800]!; label = 'Completed'; break;
      default: bg = Colors.grey[100]!; text = Colors.grey[700]!; label = status.name;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: text)),
    );
  }

  Future<void> _confirmAction(BuildContext context, String title, Function() onConfirm) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: const Text('Apakah anda yakin?'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')), TextButton(onPressed: () { Navigator.pop(ctx); onConfirm(); }, child: const Text('Ya'))],
      ),
    );
  }

  void _handleCardAction(BuildContext context, WidgetRef ref, Report report, bool isPending) {
     final actions = ref.read(cleanerActionsProvider.notifier);
     if (isPending || report.status == ReportStatus.pending) {
       _confirmAction(context, 'Ambil Tugas?', () async {
          await actions.acceptReport(report.id);
          ref.invalidate(cleanerActiveReportsProvider);
          ref.invalidate(pendingReportsProvider);
          ref.invalidate(cleanerStatsProvider);
       });
     } else if (report.status == ReportStatus.assigned) {
       _confirmAction(context, 'Mulai Tugas?', () async {
          await actions.startReport(report.id);
          ref.invalidate(cleanerActiveReportsProvider);
          ref.invalidate(cleanerStatsProvider);
       });
     } else if (report.status == ReportStatus.inProgress) {
        _showCompleteDialog(context, ref, report);
     }
  }

  void _showCompleteDialog(BuildContext context, WidgetRef ref, Report report) {
    XFile? selectedImage;
    bool isUploading = false;
    final picker = ImagePicker();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Selesaikan Tugas'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Konfirmasi: ${report.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Lokasi: ${report.location}'),
                  const SizedBox(height: 16),
                  const Text('Bukti Pekerjaan (Wajib)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: isUploading ? null : () async {
                      try {
                        final XFile? image = await picker.pickImage(source: ImageSource.camera, maxWidth: 800, imageQuality: 70);
                        if (image != null) setState(() => selectedImage = image);
                      } catch (e) {
                         final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
                         if (image != null) setState(() => selectedImage = image);
                      }
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey[100], border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                      child: selectedImage != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(selectedImage!.path, fit: BoxFit.cover))
                          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, color: Colors.grey[400]), Text('Ambil Foto', style: TextStyle(color: Colors.grey[600]))]),
                    ),
                  ),
                  if (isUploading) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
                ],
              ),
              actions: [
                if (!isUploading) TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: (selectedImage == null || isUploading) ? null : () async {
                    setState(() => isUploading = true);
                    try {
                      final storageService = ref.read(supabaseStorageServiceProvider);
                      final actions = ref.read(cleanerActionsProvider.notifier);
                      final user = ref.read(currentUserProfileProvider).value;
                      if (user == null) throw Exception('User not logged in');
                      final imageUrl = await storageService.uploadReportImage(selectedImage!, user.uid);
                      await actions.completeReportWithProof(report.id, imageUrl);
                      ref.invalidate(cleanerActiveReportsProvider);
                      ref.invalidate(cleanerStatsProvider);
                      if (context.mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tugas selesai! ✅'), backgroundColor: Colors.green));
                      }
                    } catch (e) {
                      setState(() => isUploading = false);
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                    }
                  },
                  child: Text(isUploading ? 'Mengirim...' : 'Selesai'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showQuickReportDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final descController = TextEditingController();
    XFile? selectedImage;
    bool isUploading = false;
    final picker = ImagePicker();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF), // blue-50
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.campaign_rounded, color: Color(0xFF3B82F6), size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lapor Masalah',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Laporkan temuan baru di lapangan',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Form Content
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title Input
                            Text('Judul Laporan', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                            const SizedBox(height: 6),
                            TextField(
                              controller: titleController,
                              style: GoogleFonts.inter(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Contoh: Lantai licin di Lobby',
                                hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                                prefixIcon: const Icon(Icons.edit_note_rounded, size: 20, color: Colors.grey),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Location Input
                            Text('Lokasi', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                            const SizedBox(height: 6),
                            TextField(
                              controller: locationController,
                              style: GoogleFonts.inter(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Contoh: Gedung A, Lt 1',
                                hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                                prefixIcon: const Icon(Icons.place_outlined, size: 20, color: Colors.grey),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Image Picker
                            Text('Foto Bukti (Opsional)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: isUploading ? null : () async {
                                final XFile? image = await picker.pickImage(source: ImageSource.camera, maxWidth: 800, imageQuality: 70);
                                if (image != null) setState(() => selectedImage = image);
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid), // Dashed border implementation requires custom painter, solid is fine for now
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: selectedImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(selectedImage!.path, fit: BoxFit.cover),
                                            Positioned(
                                              right: 8,
                                              top: 8,
                                              child: InkWell(
                                                onTap: () => setState(() => selectedImage = null),
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50), border: Border.all(color: Colors.grey[200]!)),
                                            child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF3B82F6), size: 24),
                                          ),
                                          const SizedBox(height: 8),
                                          Text('Tap untuk ambil foto', style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
                                        ],
                                      ),
                              ),
                            ),
                            
                            if (isUploading) 
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Column(
                                  children: [
                                    const LinearProgressIndicator(backgroundColor: Color(0xFFEFF6FF), color: Color(0xFF3B82F6)),
                                    const SizedBox(height: 4),
                                    Text('Mengirim laporan...', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[600])),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isUploading ? null : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text('Batal', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey[600])),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isUploading ? null : () async {
                              if (titleController.text.isEmpty || locationController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul dan Lokasi wajib diisi!'), backgroundColor: Colors.red));
                                return;
                              }
                              setState(() => isUploading = true);
                              try {
                                String? imageUrl;
                                final storageService = ref.read(supabaseStorageServiceProvider);
                                final actions = ref.read(cleanerActionsProvider.notifier);
                                final user = ref.read(currentUserProfileProvider).value;
                                if (user != null && selectedImage != null) {
                                  imageUrl = await storageService.uploadReportImage(selectedImage!, user.uid);
                                }
                                await actions.createCleaningReport(title: titleController.text, location: locationController.text, description: descController.text, imageUrl: imageUrl);
                                ref.invalidate(cleanerActiveReportsProvider);
                                ref.invalidate(cleanerStatsProvider);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan terkirim! ✅'), backgroundColor: Colors.green));
                                }
                              } catch (e) {
                                setState(() => isUploading = false);
                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: Text(isUploading ? 'Mengirim...' : 'Kirim Laporan', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}



class HeaderWavePainter extends CustomPainter {
  final Color color;
  HeaderWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.6,
      size.width * 0.5, size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 1.0,
      size.width, size.height * 0.9,
    );
    
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.5);
    path2.quadraticBezierTo(
       size.width * 0.3, size.height * 0.2,
       size.width * 0.6, size.height * 0.6
    );
    path2.quadraticBezierTo(
       size.width * 0.85, size.height * 0.9,
       size.width, size.height * 0.7
    );
    path2.lineTo(size.width, 0);
    path2.lineTo(0, 0);
    path2.close();
    
    canvas.drawPath(path2, paint..color = color.withValues(alpha: 0.5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
