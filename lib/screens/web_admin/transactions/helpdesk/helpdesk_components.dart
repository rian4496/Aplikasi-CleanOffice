import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../models/ticket.dart';
import '../../../../../widgets/shared/responsive_stats_grid.dart'; // Responsive Grid

// --- 1. KPI Header ---
class HelpdeskStatsHeader extends StatelessWidget {
  final int openCount;
  final int urgentCount;
  final int completedToday;
  final String avgSla;
  final bool isMobile; // Added isMobile flag
  
  const HelpdeskStatsHeader({
    super.key, 
    required this.openCount, 
    required this.urgentCount, 
    required this.completedToday,
    this.avgSla = '-', 
    this.isMobile = false, // Default false
  });

  @override
  Widget build(BuildContext context) {
    // 1. Mobile Layout: Horizontal Scrollable Row
    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatCard('Total Open', openCount.toString(), Colors.blue, Icons.confirmation_number_outlined),
            const SizedBox(width: 12),
            _buildStatCard('Urgent / High', urgentCount.toString(), Colors.red, Icons.warning_amber_rounded),
            const SizedBox(width: 12),
            _buildStatCard('Selesai Hari Ini', completedToday.toString(), Colors.green, Icons.check_circle_outline),
            const SizedBox(width: 12),
            _buildSlaCard('Rata-rata Penyelesaian', avgSla, Colors.purple),
          ],
        ),
      );
    }
    
    // 2. Desktop/Tablet Layout: Responsive Grid
    return ResponsiveStatsGrid(
      children: [
        _buildStatCard('Total Open', openCount.toString(), Colors.blue, Icons.confirmation_number_outlined),
        _buildStatCard('Urgent / High', urgentCount.toString(), Colors.red, Icons.warning_amber_rounded),
        _buildStatCard('Selesai Hari Ini', completedToday.toString(), Colors.green, Icons.check_circle_outline),
        _buildSlaCard('Rata-rata Penyelesaian', avgSla, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    // Compact styling for mobile
    final double width = isMobile ? 150 : double.infinity; // Fixed width for mobile items
    final double padding = isMobile ? 12 : 16;
    final double iconSize = isMobile ? 16 : 20;
    final double valueSize = isMobile ? 20 : 24;
    final double labelSize = isMobile ? 11 : 12;

    return Container(
      width: isMobile ? width : null,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isMobile ? Border.all(color: Colors.grey.shade200) : Border(left: BorderSide(color: color, width: 4)), // Minimalist border for mobile
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: labelSize, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.inter(fontSize: valueSize, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ),
          if (!isMobile) // Hide icon on mobile if space is tight, or keep it if it fits. Keeping it small.
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: iconSize),
            )
          else 
             Align(
               alignment: Alignment.topRight,
               child: Icon(icon, color: color.withValues(alpha: 0.7), size: iconSize),
             )
        ],
      ),
    );
  }
  
  Widget _buildSlaCard(String label, String value, Color color) {
     final double width = isMobile ? 160 : double.infinity;
     final double padding = isMobile ? 12 : 16;
     final double valueSize = isMobile ? 18 : 24;
     final double labelSize = isMobile ? 11 : 12;
     
     return Container(
        width: isMobile ? width : null,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Expanded(
               child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: TextStyle(color: Colors.grey[600], fontSize: labelSize, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(value, style: GoogleFonts.inter(fontSize: valueSize, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
            ),
          ),
          if (!isMobile) 
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
              child: Icon(Icons.timer_outlined, color: Colors.grey[600], size: 20),
            )
          else 
             Align(
               alignment: Alignment.topRight,
               child: Icon(Icons.timer_outlined, color: Colors.grey[400], size: 16),
             )
         ],
       ),
     );
  }
}

// --- 2. Enhanced Ticket Card ---
class HelpdeskTicketCard extends StatelessWidget {
  final Ticket ticket;
  final bool isSelected;
  final VoidCallback onTap;

  const HelpdeskTicketCard({super.key, required this.ticket, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUrgent = ticket.priority == TicketPriority.urgent || ticket.priority == TicketPriority.high;
    final now = DateTime.now();
    final elapsed = now.difference(ticket.createdAt);
    
    String timeString = '';
    if (elapsed.inDays > 0) timeString = '${elapsed.inDays}h lalu';
    else if (elapsed.inHours > 0) timeString = '${elapsed.inHours}j lalu';
    else timeString = '${elapsed.inMinutes}m lalu';

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : (isUrgent ? Colors.red.withValues(alpha: 0.3) : Colors.transparent), 
            width: isSelected ? 2 : 1
          ),
          boxShadow: [
             if(!isSelected) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                   decoration: BoxDecoration(color: _getTypeColor(ticket.type).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                   child: Text(
                     '#${ticket.ticketNumber} • ${ticket.type.displayName}', 
                     style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getTypeColor(ticket.type))
                   ),
                 ),
                 if (isUrgent)
                   const Icon(Icons.warning_rounded, color: Colors.red, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket.title,
              style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, fontSize: 13),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            if (ticket.description != null && ticket.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  ticket.description!,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]), 
                  maxLines: 1, overflow: TextOverflow.ellipsis
                ),
              ),
            // Show location for kebersihan tickets
            if (ticket.locationId != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ticket.locationName ?? ticket.locationId!,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            // Show asset for kerusakan tickets
            if (ticket.assetId != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.devices, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ticket.assetName ?? ticket.assetId!,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                 CircleAvatar(
                   radius: 10,
                   backgroundColor: _getAvatarColor(ticket.createdBy),
                   child: Text((ticket.createdByName != null && ticket.createdByName!.isNotEmpty ? ticket.createdByName![0] : '?').toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                 ),
                 const SizedBox(width: 8),
                   Expanded(
                     child: Text(
                       ticket.createdByName ?? 'Unknown', 
                       style: TextStyle(fontSize: 11, color: Colors.grey[600]), overflow: TextOverflow.ellipsis
                     ),
                   ),
                 Icon(Icons.access_time, size: 12, color: isUrgent ? Colors.red[300] : Colors.grey[400]),
                 const SizedBox(width: 4),
                 Text(timeString, style: TextStyle(fontSize: 11, color: isUrgent ? Colors.red : Colors.grey[500], fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(String? id) {
    if (id == null) return Colors.grey;
    return Colors.primaries[id.hashCode % Colors.primaries.length];
  }

  Color _getTypeColor(TicketType type) {
    switch(type) {
      case TicketType.kerusakan: return Colors.blue;
      case TicketType.kebersihan: return Colors.green;
      case TicketType.stockRequest: return Colors.orange;
    }
  }
}

// --- 3. Detail Panel (Right Drawer) ---
class HelpdeskDetailPanel extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onClose;
  final VoidCallback? onDelete;
  final VoidCallback? onAssign;
  final VoidCallback? onResolve;
  final Map<String, String>? usersMap; // For assignee name lookup

  const HelpdeskDetailPanel({
    super.key, 
    required this.ticket, 
    required this.onClose, 
    this.onDelete,
    this.onAssign,
    this.onResolve,
    this.usersMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(-2, 0))],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TIKET #${ticket.ticketNumber}', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                       Row(
                        children: [
                          Icon(Icons.circle, size: 10, color: _getStatusColor(ticket.status)),
                          const SizedBox(width: 8),
                          Text(ticket.status.displayName.toUpperCase(), style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete, 
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Hapus Tiket',
                  ),
                IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
              ],
            ),
          ),
          
          // Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Actions - Hide if ticket is already completed
                if (ticket.status == TicketStatus.completed) ...[ 
                  // Show "Resolved" label instead of buttons
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Tiket Sudah Diselesaikan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Show action buttons for non-completed tickets
                  Row(
                    mainAxisAlignment: ticket.type == TicketType.stockRequest 
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      // Only show Assign for non-stockRequest tickets
                      if (ticket.type != TicketType.stockRequest) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onAssign, 
                            icon: const Icon(Icons.person_add), 
                            label: const Text('Assign')
                          )
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: onResolve, 
                            icon: const Icon(Icons.check), 
                            label: const Text('Resolve'), 
                            style: FilledButton.styleFrom(backgroundColor: Colors.green)
                          )
                        ),
                      ] else ...[
                        // Compact Resolve button for stock request
                        FilledButton.icon(
                          onPressed: onResolve, 
                          icon: const Icon(Icons.check), 
                          label: const Text('Resolve & Kurangi Stok'), 
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          )
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                
                _buildDetailGroup('JENIS TIKET', ticket.type.displayName),
                _buildDetailGroup('JUDUL', ticket.title),
                _buildDetailGroup('DESKRIPSI', ticket.description ?? '-'),
                
                // Image Viewer (if image exists)
                if (ticket.imageUrl != null && ticket.imageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FOTO LAMPIRAN', style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showFullscreenImage(context, ticket.imageUrl!),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  ticket.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                  ),
                                  loadingBuilder: (_, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      color: Colors.grey[100],
                                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                    );
                                  },
                                ),
                                Positioned(
                                  right: 4,
                                  bottom: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.fullscreen, color: Colors.white, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                
                if (ticket.type == TicketType.kerusakan && ticket.assetId != null)
                   _buildDetailGroup('ASET', ticket.assetName ?? ticket.assetId!),
                
                if (ticket.type == TicketType.kebersihan && ticket.locationId != null)
                   _buildDetailGroup('LOKASI', ticket.locationName ?? ticket.locationId!),

                // Stock Request specific fields
                if (ticket.type == TicketType.stockRequest) ...[
                  if (ticket.inventoryItemId != null)
                    _buildDetailGroup('ITEM INVENTARIS', ticket.inventoryItemName ?? ticket.inventoryItemId!),
                  if (ticket.requestedQuantity != null)
                    _buildDetailGroup('JUMLAH DIMINTA', '${ticket.requestedQuantity} unit'),
                  if (ticket.locationId != null)
                    _buildDetailGroup('LOKASI PENGIRIMAN', ticket.locationName ?? ticket.locationId!),
                ],

                _buildDetailGroup('DIBUAT OLEH', ticket.createdByName ?? ticket.createdBy),
                
                const Divider(height: 32),
                
                const Text('Aktivitas', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildActivityItem('System', 'Tiket dibuat pada ${DateFormat('dd MMM HH:mm').format(ticket.createdAt)}'),
                if(ticket.priority == TicketPriority.urgent || ticket.priority == TicketPriority.high) 
                  _buildActivityItem('System', 'Ditandai sebagai URGENT/HIGH'),
                if(ticket.assignedTo != null && ticket.claimedAt != null)
                  _buildActivityItem(usersMap?[ticket.assignedTo] ?? 'Petugas', 'Mengambil tiket pada ${DateFormat('dd MMM HH:mm').format(ticket.claimedAt!)}'),
                if(ticket.status == TicketStatus.inProgress || ticket.status == TicketStatus.completed)
                  _buildActivityItem(usersMap?[ticket.assignedTo] ?? 'Petugas', 'Mulai mengerjakan tiket'),
                if(ticket.status == TicketStatus.completed && ticket.completedAt != null)
                  _buildActivityItem(usersMap?[ticket.assignedTo] ?? 'Petugas', 'Menyelesaikan tiket pada ${DateFormat('dd MMM HH:mm').format(ticket.completedAt!)}'),
              ],
            ),
          ),
          
          // Chat Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50], border: Border(top: BorderSide(color: Colors.grey.shade200))),
            child: Row(
              children: [
                Expanded(child: TextField(decoration: InputDecoration(hintText: 'Tulis komentar...', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)))),
                const SizedBox(width: 8),
                IconButton(onPressed: (){}, icon: const Icon(Icons.send, color: AppTheme.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailGroup(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
  
  Widget _buildActivityItem(String user, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 10, backgroundColor: Colors.grey[300], child: Text(user[0], style: const TextStyle(fontSize: 10))),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch(status) {
      case TicketStatus.open: return Colors.red;
      case TicketStatus.claimed: return Colors.blue;
      case TicketStatus.inProgress: return Colors.blue[700]!;
      case TicketStatus.pendingApproval: return Colors.orange;
      case TicketStatus.completed: return Colors.green;
      default: return Colors.grey;
    }
  }
  
  void _showFullscreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Image
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[800],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.white, size: 64),
                        SizedBox(height: 16),
                        Text('Gagal memuat gambar', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Close Button
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
