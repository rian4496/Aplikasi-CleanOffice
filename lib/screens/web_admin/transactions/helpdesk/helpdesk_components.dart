import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../models/ticket.dart';

// --- 1. KPI Header ---
class HelpdeskStatsHeader extends StatelessWidget {
  final int openCount;
  final int urgentCount;
  final int completedToday;
  
  const HelpdeskStatsHeader({
    super.key, 
    required this.openCount, 
    required this.urgentCount, 
    required this.completedToday
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatCard('Total Open', openCount.toString(), Colors.blue, Icons.confirmation_number_outlined),
        const SizedBox(width: 12),
        _buildStatCard('Urgent / High', urgentCount.toString(), Colors.red, Icons.warning_amber_rounded),
        const SizedBox(width: 12),
        _buildStatCard('Selesai Hari Ini', completedToday.toString(), Colors.green, Icons.check_circle_outline),
        const SizedBox(width: 12),
        Expanded(child: _buildSlaCard('Avg SLA', '2.5 Jam', Colors.purple)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            )
          ],
        ),
      ),
    );
  }
  
  Widget _buildSlaCard(String label, String value, Color color) {
     return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, offset: const Offset(0,2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const Icon(Icons.timer_outlined, color: Colors.white, size: 32),
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
            color: isSelected ? Colors.blue : (isUrgent ? Colors.red.withOpacity(0.3) : Colors.transparent), 
            width: isSelected ? 2 : 1
          ),
          boxShadow: [
             if(!isSelected) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
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
                   decoration: BoxDecoration(color: _getTypeColor(ticket.type).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
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
            const SizedBox(height: 12),
            Row(
              children: [
                 CircleAvatar(
                   radius: 10,
                   backgroundColor: _getAvatarColor(ticket.assignedTo),
                   child: Text((ticket.assignedTo != null && ticket.assignedTo!.isNotEmpty ? ticket.assignedTo![0] : '?').toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                 ),
                 const SizedBox(width: 8),
                 Expanded(
                   child: Text(
                     ticket.assignedTo == null ? 'Unassigned' : 'Staff ${ticket.assignedTo!.substring(0,3)}', 
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

  const HelpdeskDetailPanel({super.key, required this.ticket, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(-2, 0))],
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
                IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
              ],
            ),
          ),
          
          // Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Actions
                Row(
                  children: [
                    Expanded(child: OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.person_add), label: const Text('Assign'))),
                    const SizedBox(width: 12),
                    Expanded(child: FilledButton.icon(onPressed: (){}, icon: const Icon(Icons.check), label: const Text('Resolve'), style: FilledButton.styleFrom(backgroundColor: Colors.green))),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildDetailGroup('JENIS TIKET', ticket.type.displayName),
                _buildDetailGroup('JUDUL', ticket.title),
                _buildDetailGroup('DESKRIPSI', ticket.description ?? '-'),
                
                if (ticket.type == TicketType.kerusakan && ticket.assetId != null)
                   _buildDetailGroup('ASET ID', ticket.assetId!),
                
                if (ticket.type == TicketType.kebersihan && ticket.locationId != null)
                   _buildDetailGroup('LOKASI ID', ticket.locationId!),

                _buildDetailGroup('DIBUAT OLEH', ticket.createdBy),
                
                const Divider(height: 32),
                
                const Text('Aktivitas', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildActivityItem('System', 'Tiket dibuat pada ${DateFormat('dd MMM HH:mm').format(ticket.createdAt)}'),
                if(ticket.priority == TicketPriority.urgent || ticket.priority == TicketPriority.high) 
                  _buildActivityItem('System', 'Ditandai sebagai URGENT/HIGH'),
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
}
