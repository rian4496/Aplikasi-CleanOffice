import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/transactions/disposal_model.dart';
import '../../../../riverpod/transactions/disposal_provider.dart';
import '../../../../riverpod/auth_providers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/transactions/disposal_model.dart';
import '../../../../riverpod/transactions/disposal_provider.dart';

class DisposalListScreen extends ConsumerStatefulWidget {
  const DisposalListScreen({super.key});

  @override
  ConsumerState<DisposalListScreen> createState() => _DisposalListScreenState();
}

class _DisposalListScreenState extends ConsumerState<DisposalListScreen> {
  late TextEditingController _searchController;
  String _searchQuery = '';
  int _activeTab = 0; // 0: Usulan, 1: Proses, 2: Selesai

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disposalAsync = ref.watch(disposalListProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: isMobile ? Container(
         margin: const EdgeInsets.only(bottom: 16),
         child: InkWell(
            onTap: () => context.push('/admin/disposal/new'),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.red.shade700, Colors.red.shade500]),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [BoxShadow(color: Colors.red.shade700.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   const Icon(Icons.add, color: Colors.white, size: 20),
                   const SizedBox(width: 8),
                   Text('Buat Usulan', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
         ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        leading: isMobile ? IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin/dashboard'),
        ) : null,
        title: LayoutBuilder(
          builder: (context, constraints) {
            return Text(
              constraints.maxWidth < 600 ? 'Penghapusan Aset' : 'Penghapusan Aset (Disposal)',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
            );
          }
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!isMobile)
            FilledButton.icon(
              onPressed: () => context.push('/admin/disposal/new'),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Buat Usulan'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red[700], // Red for disposal/danger actions
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: disposalAsync.when(
        data: (requests) {
          final filtered = requests.where((r) {
            final q = _searchQuery.toLowerCase();
            final matchesSearch = (r.assetName?.toLowerCase().contains(q) ?? false) || r.code.toLowerCase().contains(q);
            
            bool matchesTab = true;
            if (_activeTab == 0) matchesTab = r.status == 'proposed' || r.status == 'draft';
            if (_activeTab == 1) matchesTab = r.status == 'verified' || r.status == 'approved';
            if (_activeTab == 2) matchesTab = r.status == 'executed' || r.status == 'disposed';
            
            return matchesSearch && matchesTab;
          }).toList();

          return Column(
            children: [
              // Filters
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                       decoration: InputDecoration(
                        hintText: 'Cari Aset atau No. SK...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        filled: true, fillColor: Colors.grey[50],
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTabItem('Usulan Baru', 0),
                          _buildTabItem('Sedang Proses', 1),
                          _buildTabItem('Selesai', 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Gallery Content
              Expanded(
                child: filtered.isEmpty
                  ? _buildEmptyState()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isMobile ? 2 : (constraints.maxWidth / 280).floor(),
                            childAspectRatio: isMobile ? 0.75 : 0.8, // Adjusted for balanced height
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return _buildDisposalCard(context, filtered[index]);
                          },
                        );
                      }
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

  Widget _buildEmptyState() {
     return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.delete_outline, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('Tidak ada data usulan penghapusan', style: TextStyle(color: Colors.grey[500])),
      ],
    ));
  }

  Widget _buildTabItem(String label, int index) {
    final isActive = _activeTab == index;
    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        margin: const EdgeInsets.only(right: 24),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isActive ? Colors.red.shade700 : Colors.transparent, width: 2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.red.shade700 : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ... (Keep existing helpers)

  Widget _buildDisposalCard(BuildContext context, DisposalRequest item) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200), // Subtle border like reference
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image Area with Badge (Expanded to fill top half)
          Expanded(
            flex: 4, // Adjust flex ratio to control image vs content height
            child: Container(
              width: double.infinity,
              color: Colors.grey[100],
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 48)),
                  Positioned(
                    top: 8, right: 8,
                    child: _buildStatusBadge(item.status),
                  ),
                ],
              ),
            ),
          ),
          
          // 2. Content Section
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (14px Bold - Matches Reference)
                  Text(
                    item.assetName ?? 'Unknown Asset',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 13, // Slightly smaller to prevent overflow
                      color: Colors.black87,
                    ),
                    maxLines: 2, // Allow 2 lines for title
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Code (11px Grey)
                  Text(
                    item.assetCode ?? '-',
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  
                  // Nilai Perkiraan Row
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Nilai Perkiraan: Rp ${NumberFormat.decimalPattern('id').format(item.estimatedValue)}',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Reason Row
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.reason,
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),
                  
                  // Divider before buttons
                  Divider(color: Colors.grey.shade200, height: 16),
                  
                  // Action Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spread out detail and action
                    children: [
                      // Detail Button
                      InkWell(
                        onTap: () => context.push('/admin/disposal/detail/${item.id}'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          child: Text(
                            'Detail',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      // Verifikasi Button - Role-based (Admin/Kasubbag UMPEG only)
                      if (item.status == 'proposed')
                        Builder(
                          builder: (context) {
                            final userRole = ref.watch(currentUserRoleProvider);
                            final canVerify = userRole == 'admin' || userRole == 'kasubbag_umpeg';
                            
                            if (canVerify) {
                              return SizedBox(
                                height: 30,
                                child: FilledButton(
                                  onPressed: () => context.push('/admin/disposal/detail/${item.id}'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  child: Text(
                                    'Verifikasi',
                                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Menunggu',
                                  style: TextStyle(fontSize: 10, color: Colors.orange.shade700, fontWeight: FontWeight.w600),
                                ),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusBadge(String status) {
    Color color;
    switch(status) {
      case 'proposed': color = Colors.orange; break;
      case 'verified': color = Colors.blue; break;
      case 'approved': color = Colors.purple; break;
      case 'executed': color = Colors.green; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
      ),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}
