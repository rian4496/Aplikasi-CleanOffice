import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design/employee_colors.dart';
import '../../core/design/shared_design_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../riverpod/auth_providers.dart';
import '../../riverpod/employee_providers.dart';
import '../../widgets/shared/cards/stat_card_base.dart';
import '../../widgets/shared/cards/performance_summary_card.dart';
import '../../widgets/shared/cards/action_card.dart';
import '../../widgets/shared/states/empty_state_widget.dart';
import '../../widgets/shared/states/error_state_widget.dart';
import 'package:go_router/go_router.dart';

class WebEmployeeDashboard extends ConsumerWidget {
  const WebEmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(employeeReportsProvider);
    final summary = ref.watch(employeeReportsSummaryProvider);
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: EmployeeColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
           ref.invalidate(employeeReportsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(SharedDesignConstants.spaceLg), // More padding for desktop
          child: Column(
            children: [
               // Greeting Section (Simplified for Web, as Header exists)
               // Actually Admin Header covers strict greeting, but we can have a Dashboard Title
               _buildWebWelcome(userProfileAsync),
               const SizedBox(height: SharedDesignConstants.spaceLg),
               
               reportsAsync.when(
                  loading: () => const SizedBox(
                    height: 300, 
                    child: Center(child: CircularProgressIndicator())
                  ),
                  error: (error, stack) => ErrorStateWidget.fetchFailed(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(employeeReportsProvider),
                  ),
                  data: (reports) => Column(
                    children: [
                       // Stats & Performance Row
                       LayoutBuilder(
                         builder: (context, constraints) {
                           if (constraints.maxWidth < 900) {
                             return Column(
                               children: [
                                 _buildStatCardsGrid(summary, 2), // 2 columns
                                 const SizedBox(height: 24),
                                 _buildPerformanceSummary(summary),
                               ],
                             );
                           }
                           return Row(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Expanded(flex: 3, child: _buildStatCardsGrid(summary, 2)), // Grid
                               const SizedBox(width: 24),
                               Expanded(flex: 2, child: _buildPerformanceSummary(summary)),
                             ],
                           );
                         }
                       ),
                       const SizedBox(height: 32),
                       
                       // Actions & Recent
                       _buildQuickActions(context),
                       const SizedBox(height: 32),
                       _buildRecentActivity(context, reports),
                       const SizedBox(height: 50),
                    ],
                  ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebWelcome(AsyncValue<dynamic> userProfileAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: SharedDesignConstants.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.waving_hand_rounded, color: EmployeeColors.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: userProfileAsync.when(
                  data: (profile) => Text(
                    'Selamat Datang, ${profile?.displayName ?? 'Employee'}!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: EmployeeColors.textPrimary),
                  ),
                  loading: () => const Text('Selamat Datang...', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  error: (_, __) => const Text('Selamat Datang', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ),
              Text(
                DateFormatter.fullDate(DateTime.now()),
                 style: const TextStyle(color: EmployeeColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Berikut adalah ringkasan aktivitas dan laporan anda hari ini.',
            style: TextStyle(color: EmployeeColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardsGrid(dynamic summary, int crossAxisCount) {    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5, // Wider cards
      children: [
        StatCardBase(
          label: 'Total Reports',
          value: summary.total.toString(),
          icon: Icons.assignment_rounded,
          colorIndex: 0,
          trend: '↑ 12%',
          trendUp: true,
          onTap: () {},
        ),
        StatCardBase(
          label: 'Pending',
          value: summary.pending.toString(),
          icon: Icons.schedule_rounded,
          colorIndex: 1,
        ),
        StatCardBase(
          label: 'Verified',
          value: summary.verified.toString(),
          icon: Icons.verified_rounded,
          colorIndex: 2,
        ),
        StatCardBase(
          label: 'Urgent',
          value: summary.urgent.toString(),
          icon: Icons.priority_high_rounded,
          colorIndex: 3,
        ),
      ],
    );
  }

  Widget _buildPerformanceSummary(dynamic summary) {
    final total = summary.total;
    final completed = summary.completed;
    final completionRate = total > 0 ? (completed / total * 100) : 0.0; // Dynamic implies int/double mix, careful. Assuming logic same as original.

    return PerformanceSummaryCard(
      completionRate: completionRate.toDouble(),
      primaryColor: EmployeeColors.primary,
      badge: completionRate >= 80 ? 'Maluk' : 'Baik',
      badgeColor: completionRate >= 80 
          ? EmployeeColors.performanceExcellent 
          : EmployeeColors.performanceGood,
      metrics: [
        MetricItem(label: 'Menunggu', value: summary.pending.toString(), color: EmployeeColors.warning),
        MetricItem(label: 'Dalam Proses', value: summary.inProgress.toString(), color: EmployeeColors.info),
        MetricItem(label: 'Selesai', value: summary.completed.toString(), color: EmployeeColors.success),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Menu Cepat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: EmployeeColors.textPrimary)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildQuickActionItem(
              context,
              title: 'Buat Laporan',
              icon: Icons.add_circle_outline_rounded,
              color: EmployeeColors.primary,
              onTap: () => context.push('/admin/reports/create'),
            ),
            const SizedBox(width: 24),
            _buildQuickActionItem(
              context,
              title: 'Request Layanan',
              icon: Icons.room_service_outlined,
              color: EmployeeColors.success,
              onTap: () {}, // context.push('/admin/services/create'),
            ),
             const SizedBox(width: 24),
            _buildQuickActionItem(
              context,
              title: 'Tiket Saya',
              icon: Icons.confirmation_number_outlined,
              color: EmployeeColors.warning,
              onTap: () => context.push('/admin/helpdesk'), // Or dedicated ticket list
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.w600,
            color: EmployeeColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, List reports) {
     if (reports.isEmpty) {
       return EmptyStateWidget.noReports(
         onCreateReport: () => context.push('/admin/reports/create'),
       );
     }
    final recentReports = reports.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: SharedDesignConstants.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: EmployeeColors.textPrimary)),
              TextButton(
                onPressed: () => context.push('/admin/reports'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentReports.length,
            separatorBuilder: (_, __) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final report = recentReports[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: EmployeeColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.assignment, color: EmployeeColors.primary),
                ),
                title: Text(report.description ?? 'No Description', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${report.location} • ${DateFormatter.shortDate(report.createdAt)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: EmployeeColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(report.status.displayName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: EmployeeColors.warning)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
