import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/transactions/disposal_model.dart';
import '../../../../providers/transactions/disposal_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/transactions/disposal_model.dart';
import '../../../../providers/transactions/disposal_provider.dart';

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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Penghapusan Aset (Disposal)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          FilledButton.icon(
            onPressed: () => context.push('/admin/disposal/new'),
            icon: const Icon(Icons.add),
            label: const Text('Buat Usulan'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red[700], // Red for disposal/danger actions
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    Row(
                      children: [
                        _buildTabItem('Usulan Baru', 0),
                        _buildTabItem('Sedang Proses', 1),
                        _buildTabItem('Selesai', 2),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Gallery Content
              Expanded(
                child: filtered.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        childAspectRatio: 0.9, // Taller cards to fit details
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return _buildDisposalCard(context, filtered[index]);
                      },
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

  Widget _buildDisposalCard(BuildContext context, DisposalRequest item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image Area (Mock)
          Container(
            height: 140,
            width: double.infinity,
            color: Colors.grey[200],
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                Positioned(
                  top: 8, right: 8,
                  child: _buildStatusBadge(item.status),
                ),
              ],
            ),
          ),
          
          // 2. Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.assetName ?? 'Unknown Asset', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(item.assetCode ?? '-', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 8),
                  
                  // Key Value
                  Row(
                    children: [
                       const Icon(Icons.money_off, size: 14, color: Colors.grey),
                       const SizedBox(width: 4),
                       Text('Nilai Perkiraan: Rp ${NumberFormat.decimalPattern('id').format(item.estimatedValue)}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                   const SizedBox(height: 4),
                   Row(
                    children: [
                       const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red),
                       const SizedBox(width: 4),
                       Expanded(child: Text(item.reason, style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold), maxLines: 1)),
                    ],
                  ),
                  
                  const Spacer(),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: (){}, child: const Text('Detail')),
                      if (item.status == 'proposed')
                        FilledButton(onPressed: (){}, style: FilledButton.styleFrom(visualDensity: VisualDensity.compact), child: const Text('Verifikasi')),
                    ],
                  )
                ],
              ),
            ),
          )
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}
