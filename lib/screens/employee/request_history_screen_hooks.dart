// lib/screens/employee/request_history_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../models/request.dart';
import '../../providers/riverpod/request_providers.dart';
import '../../widgets/shared/request_card_widget.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../shared/request_detail/request_detail_screen.dart';
import '../../core/theme/app_theme.dart';

/// Request History Screen untuk Employee
///
/// Screen ini menampilkan semua request yang pernah dibuat oleh employee
/// dengan fitur:
/// - Filter by status (All, Active, Completed, Cancelled)
/// - Search by location atau description
/// - Pull to refresh
/// - Empty state untuk each filter
/// - Tap card untuk lihat detail
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const RequestHistoryScreen(),
///   ),
/// );
/// ```
///
/// ✅ MIGRATED: ConsumerStatefulWidget → HookConsumerWidget
class RequestHistoryScreen extends HookConsumerWidget {
  const RequestHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: TabController (auto-disposed)
    final tabController = useTabController(initialLength: 4);

    // ✅ HOOKS: Auto-disposed controller
    final searchController = useTextEditingController();

    // ✅ HOOKS: State management
    final searchQuery = useState('');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Riwayat Request'),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search bar
              _buildSearchBar(searchController, searchQuery),

              // Tab bar
              TabBar(
                controller: tabController,
                isScrollable: false,
                labelColor: AppTheme.primary,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: AppTheme.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'Semua'),
                  Tab(text: 'Aktif'),
                  Tab(text: 'Selesai'),
                  Tab(text: 'Batal'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildRequestList(context, ref, RequestHistoryFilter.all, searchQuery.value),
          _buildRequestList(context, ref, RequestHistoryFilter.active, searchQuery.value),
          _buildRequestList(context, ref, RequestHistoryFilter.completed, searchQuery.value),
          _buildRequestList(context, ref, RequestHistoryFilter.cancelled, searchQuery.value),
        ],
      ),
    );
  }

  // ==================== STATIC HELPERS ====================

  /// Build search bar
  static Widget _buildSearchBar(
    TextEditingController searchController,
    ValueNotifier<String> searchQuery,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Cari lokasi atau deskripsi...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
          suffixIcon: searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                  onPressed: () {
                    searchController.clear();
                    searchQuery.value = '';
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          searchQuery.value = value.toLowerCase();
        },
      ),
    );
  }

  /// Build request list dengan filter
  static Widget _buildRequestList(
    BuildContext context,
    WidgetRef ref,
    RequestHistoryFilter filter,
    String searchQuery,
  ) {
    final requestsAsync = ref.watch(myRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        // Filter berdasarkan tab
        final filteredRequests = _applyFilters(requests, filter, searchQuery);

        if (filteredRequests.isEmpty) {
          return _buildEmptyState(filter, searchQuery);
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Riverpod auto-refresh stream
            ref.invalidate(myRequestsProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredRequests.length,
            itemBuilder: (context, index) {
              final request = filteredRequests[index];
              return RequestCardWidget(
                request: request,
                onTap: () => _navigateToDetail(context, request.id),
                showAssignee: true,
                animationIndex: index,
              );
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(myRequestsProvider),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  /// Apply filter berdasarkan status dan search query
  static List<Request> _applyFilters(
    List<Request> requests,
    RequestHistoryFilter filter,
    String searchQuery,
  ) {
    // Filter by status
    List<Request> filtered;
    switch (filter) {
      case RequestHistoryFilter.all:
        filtered = requests;
        break;
      case RequestHistoryFilter.active:
        filtered = requests.where((r) => r.isActive).toList();
        break;
      case RequestHistoryFilter.completed:
        filtered = requests
            .where((r) => r.status == RequestStatus.completed)
            .toList();
        break;
      case RequestHistoryFilter.cancelled:
        filtered = requests
            .where((r) => r.status == RequestStatus.cancelled)
            .toList();
        break;
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((request) {
        final location = request.location.toLowerCase();
        final description = request.description.toLowerCase();
        return location.contains(searchQuery) ||
            description.contains(searchQuery);
      }).toList();
    }

    // Sort by created date (latest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  /// Build empty state berdasarkan filter
  static Widget _buildEmptyState(RequestHistoryFilter filter, String searchQuery) {
    String message;
    IconData icon;

    if (searchQuery.isNotEmpty) {
      message = 'Tidak ada request yang sesuai dengan pencarian';
      icon = Icons.search_off;
    } else {
      switch (filter) {
        case RequestHistoryFilter.all:
          message = 'Belum ada request yang dibuat';
          icon = Icons.inbox;
          break;
        case RequestHistoryFilter.active:
          message = 'Tidak ada request aktif';
          icon = Icons.check_circle_outline;
          break;
        case RequestHistoryFilter.completed:
          message = 'Belum ada request yang selesai';
          icon = Icons.done_all;
          break;
        case RequestHistoryFilter.cancelled:
          message = 'Tidak ada request yang dibatalkan';
          icon = Icons.cancel_outlined;
          break;
      }
    }

    return EmptyStateWidget(
      icon: icon,
      title: message,
      subtitle: 'Coba buat request baru atau ubah filter',
    );
  }

  /// Navigate to request detail
  static void _navigateToDetail(BuildContext context, String requestId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailScreen(requestId: requestId),
      ),
    );
  }
}

/// Enum untuk filter history
enum RequestHistoryFilter {
  all,
  active,
  completed,
  cancelled,
}
