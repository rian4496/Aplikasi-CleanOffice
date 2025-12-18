import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/transactions/booking_model.dart';
import '../../providers/transactions/booking_provider.dart';

class BookingListScreen extends HookConsumerWidget {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingListProvider);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final activeTab = useState(0); // 0: Upcoming, 1: History, 2: Pending Approval

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Booking & Jadwal Aset', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          FilledButton.icon(
            onPressed: () {
               context.push('/admin/bookings/new');
            }, 
            icon: const Icon(Icons.add), 
            label: const Text('Booking Baru'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: bookingAsync.when(
        data: (bookings) {
          // Filtering
          final filtered = bookings.where((b) {
            final q = searchQuery.value.toLowerCase();
            final matchSearch = b.assetName.toLowerCase().contains(q) || 
                                b.employeeName.toLowerCase().contains(q) ||
                                b.department.toLowerCase().contains(q);
            
            bool matchTab = true;
            final now = DateTime.now();
            if (activeTab.value == 0) { // Upcoming / Active
              matchTab = ['approved', 'active'].contains(b.status) && b.endTime.isAfter(now);
            } else if (activeTab.value == 1) { // History
              matchTab = ['completed', 'rejected', 'cancelled'].contains(b.status) || (b.endTime.isBefore(now) && b.status != 'pending');
            } else if (activeTab.value == 2) { // Pending
              matchTab = b.status == 'pending';
            }
            
            return matchSearch && matchTab;
          }).toList();
          
          // Sort by Date
          filtered.sort((a, b) => a.startTime.compareTo(b.startTime));

          return Column(
            children: [
              // Search & Tabs
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                     Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari Aset atau Peminjam...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          filled: true, fillColor: Colors.grey[50],
                        ),
                        onChanged: (val) => searchQuery.value = val,
                      ),
                    ),
                    Row(
                      children: [
                        _buildTabItem('Jadwal Aktif', 0, activeTab),
                        _buildTabItem('Menunggu Approval', 2, activeTab),
                        _buildTabItem('Riwayat', 1, activeTab),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // List Content
              Expanded(
                child: filtered.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return _buildBookingCard(context, filtered[index]);
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
        Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('Tidak ada jadwal booking ditemukan', style: TextStyle(color: Colors.grey[500])),
      ],
    ));
  }

  Widget _buildTabItem(String label, int index, ValueNotifier<int> activeTab) {
    final isActive = activeTab.value == index;
    return InkWell(
      onTap: () => activeTab.value = index,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isActive ? AppTheme.primary : Colors.transparent, width: 2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.primary : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingRequest item) {
    final isPending = item.status == 'pending';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Time Column
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            width: 80,
            decoration: BoxDecoration(
              color: isPending ? Colors.orange.shade50 : Colors.blue.shade50,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat('dd MMM').format(item.startTime), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey[800], fontSize: 13)),
                const SizedBox(height: 4),
                Text(DateFormat('HH:mm').format(item.startTime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('s/d', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text(DateFormat('HH:mm').format(item.endTime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          
          // Right: Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Expanded(child: Text(item.assetName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1)),
                       _buildStatusBadge(item.status),
                     ],
                   ),
                   const SizedBox(height: 4),
                   Row(
                     children: [
                        Icon(getAssetIcon(item.assetType), size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(item.assetType.toUpperCase(), style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                     ],
                   ),
                   const SizedBox(height: 12),
                   Row(
                     children: [
                        CircleAvatar(
                          radius: 12, 
                          backgroundColor: Colors.grey[200],
                          child: Text(item.employeeName.substring(0,1), style: const TextStyle(fontSize: 10)),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.employeeName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(item.department, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                          ],
                        )
                     ],
                   ),
                   const SizedBox(height: 12),
                   Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(6)),
                     child: Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                         const SizedBox(width: 6),
                         Expanded(child: Text(item.purpose, style: TextStyle(color: Colors.grey[800], fontSize: 13, fontStyle: FontStyle.italic))),
                       ],
                     )
                   ),
                   
                   if (isPending) ...[
                     const SizedBox(height: 12),
                     const Divider(),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                         OutlinedButton(onPressed: (){}, child: const Text('Tolak')),
                         const SizedBox(width: 8),
                         FilledButton(
                           onPressed: (){}, 
                           style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
                           child: const Text('Setujui'),
                         ),
                       ],
                     )
                   ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  IconData getAssetIcon(String type) {
    switch(type) {
      case 'vehicle': return Icons.directions_car;
      case 'room': return Icons.meeting_room;
      case 'equipment': return Icons.camera_alt;
      default: return Icons.category;
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch(status) {
      case 'pending': color = Colors.orange; label = 'Menunggu'; break;
      case 'approved': color = Colors.blue; label = 'Disetujui'; break;
      case 'active': color = Colors.green; label = 'Digunakan'; break;
      case 'completed': color = Colors.grey; label = 'Selesai'; break;
      case 'rejected': color = Colors.red; label = 'Ditolak'; break;
      default: color = Colors.grey; label = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
