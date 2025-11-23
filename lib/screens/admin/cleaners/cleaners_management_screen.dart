// lib/screens/admin/cleaners/cleaners_management_screen.dart
// 👥 Cleaners Management Screen
// Manage cleaning staff with performance tracking

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_constants.dart';
import '../../../widgets/admin/layout/mobile_admin_app_bar.dart';
import '../../../widgets/admin/layout/admin_bottom_nav.dart';
import '../../../widgets/admin/search/search_bar_widget.dart';
import '../../../widgets/admin/filters/horizontal_filter_chips.dart';
import '../../../widgets/admin/cards/cleaner_card.dart';
import '../../../providers/riverpod/cleaner_providers.dart';

class CleanersManagementScreen extends ConsumerWidget {
  const CleanersManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cleanersAsync = ref.watch(allCleanersProvider);

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: const MobileAdminAppBar(
        title: 'Kelola Petugas',
      ),
      body: Column(
        children: [
          // Search Bar
          SearchBarWidget(
            hintText: 'Cari petugas...',
            onChanged: (value) {
              // TODO: Implement search
            },
          ),

          // Filter Chips
          HorizontalFilterChips(
            chips: const [
              FilterChipData(id: 'all', label: 'Semua'),
              FilterChipData(id: 'available', label: 'Available'),
              FilterChipData(id: 'busy', label: 'Busy'),
              FilterChipData(id: 'top', label: 'Top Rated'),
            ],
            selectedChipId: 'all',
            onSelected: (chipId) {
              // TODO: Apply filter
            },
          ),

          const SizedBox(height: AdminConstants.spaceSm),

          // Cleaners List
          Expanded(
            child: cleanersAsync.when(
              data: (cleaners) {
                if (cleaners.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allCleanersProvider);
                  },
                  child: ListView.builder(
                    itemCount: cleaners.length,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemBuilder: (context, index) {
                      final cleaner = cleaners[index];
                      // Mock data for demonstration
                      return CleanerCard(
                        cleanerId: cleaner.id,
                        cleanerName: cleaner.name ?? 'Unknown',
                        department: cleaner.department ?? 'General',
                        isAvailable: index % 3 != 0, // Mock availability
                        rating: 4.0 + (index % 10) / 10,
                        completedTasks: 50 + index * 5,
                        todayTasks: index % 8,
                        onTap: () {
                          // Navigate to cleaner detail
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(ref),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AdminConstants.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AdminColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AdminConstants.spaceMd),
            const Text(
              'Belum Ada Petugas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AdminConstants.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AdminColors.error.withOpacity(0.5),
            ),
            const SizedBox(height: AdminConstants.spaceMd),
            const Text(
              'Gagal Memuat Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AdminConstants.spaceMd),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(allCleanersProvider);
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
