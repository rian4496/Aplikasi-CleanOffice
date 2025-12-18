// lib/screens/employee/request_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
class RequestHistoryScreen extends ConsumerStatefulWidget {
  const RequestHistoryScreen({super.key});

  @override
  ConsumerState<RequestHistoryScreen> createState() =>
      _RequestHistoryScreenState();
}

class _RequestHistoryScreenState extends ConsumerState<RequestHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              _buildSearchBar(),
              
              // Tab bar
              TabBar(
                controller: _tabController,
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
        controller: _tabController,
        children: [
          _buildRequestList(RequestHistoryFilter.all),
          _buildRequestList(RequestHistoryFilter.active),
          _buildRequestList(RequestHistoryFilter.completed),
          _buildRequestList(RequestHistoryFilter.cancelled),
        ],
      ),
    );
  }

  /// Build search bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari lokasi atau deskripsi...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
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
          setState(() => _searchQuery = value.toLowerCase());
        },
      ),
    );
  }

  /// Build request list dengan filter
  Widget _buildRequestList(RequestHistoryFilter filter) {
    final requestsAsync = ref.watch(myRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        // Filter berdasarkan tab
        final filteredRequests = _applyFilters(requests, filter);

        if (filteredRequests.isEmpty) {
          return _buildEmptyState(filter);
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
                onTap: () => _navigateToDetail(request.id),
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
  List<Request> _applyFilters(
    List<Request> requests,
    RequestHistoryFilter filter,
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
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((request) {
        final location = request.location.toLowerCase();
        final description = request.description.toLowerCase();
        return location.contains(_searchQuery) ||
            description.contains(_searchQuery);
      }).toList();
    }

    // Sort by created date (latest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  /// Build empty state berdasarkan filter
  Widget _buildEmptyState(RequestHistoryFilter filter) {
    String message;
    IconData icon;

    if (_searchQuery.isNotEmpty) {
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
  void _navigateToDetail(String requestId) {
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
