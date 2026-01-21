import 'package:flutter/material.dart';
import '../../../models/master/vendor.dart';
import '../../../core/theme/app_theme.dart';

class MobileVendorCard extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MobileVendorCard({
    super.key,
    required this.vendor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isBlacklisted = vendor.status == 'blacklisted';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isBlacklisted ? Colors.red[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isBlacklisted ? Border.all(color: Colors.red.shade200) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name & Status
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isBlacklisted ? Colors.red[100] : Colors.blue[50],
                  child: Text(
                    vendor.name[0],
                    style: TextStyle(
                      color: isBlacklisted ? Colors.red : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Name & Cat
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13, // Reduced from 14
                          color: isBlacklisted ? Colors.red[900] : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey[300]!)
                        ),
                        child: Text(
                          vendor.category, 
                          style: const TextStyle(fontSize: 10, color: Colors.grey)
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Chip
                _buildStatusChip(vendor.status),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                _buildInfoRow(Icons.person, vendor.contactPerson ?? '-'),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.phone, vendor.phone ?? '-'),
              ],
            ),
          ),

          const Divider(height: 1),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 14), // Reduced size
                  label: const Text('Edit', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 14), // Reduced size
                  label: const Text('Hapus', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey[600]), // Reduced size
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, color: Colors.grey[800]), // Reduced from 12
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    if (status == 'active') {
       color = Colors.green;
       label = 'Verified';
    } else if (status == 'blacklisted') {
       color = Colors.red;
       label = 'Blacklisted';
    } else {
       color = Colors.orange;
       label = 'Unverified';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color), // Reduced from 10
      ),
    );
  }
}
