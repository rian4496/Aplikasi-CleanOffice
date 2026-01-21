import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../models/maintenance_log.dart';
import '../../riverpod/auth_providers.dart';
import '../../riverpod/maintenance_providers.dart';

class MaintenanceDetailScreen extends ConsumerStatefulWidget {
  final MaintenanceLog log;

  const MaintenanceDetailScreen({super.key, required this.log});

  @override
  ConsumerState<MaintenanceDetailScreen> createState() => _MaintenanceDetailScreenState();
}

class _MaintenanceDetailScreenState extends ConsumerState<MaintenanceDetailScreen> {
  final _supabase = Supabase.instance.client;
  late MaintenanceLog _log;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _log = widget.log;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.modernBg,
      child: Column(
        children: [
          // Custom Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Detail Maintenance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                if (_log.status == MaintenanceStatus.pending)
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppTheme.primary),
                    onPressed: () => _navigateToEdit(context),
                    tooltip: 'Edit',
                  ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Status banner
                  _buildStatusBanner(),

                  // Content Body
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Main info card
                        _buildInfoCard(
                          title: 'Informasi Request',
                          icon: Icons.info_outline,
                          children: [
                            _infoRow('Tipe', _log.type.displayName),
                            _infoRow('Status', _log.status.displayName),
                            _infoRow('Prioritas', _log.isUrgent ? '🔴 URGENT' : 'Normal'),
                            _infoRow('Tanggal Request', _formatDate(_log.createdAt)),
                            if (_log.scheduledDate != null)
                              _infoRow('Jadwal', _formatDate(_log.scheduledDate!)),
                            if (_log.completedDate != null)
                              _infoRow('Selesai', _formatDate(_log.completedDate!)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Asset info
                        if (_log.assetName != null)
                          _buildInfoCard(
                            title: 'Aset',
                            icon: Icons.inventory_2,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.inventory_2, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _log.assetName!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (_log.assetId.isNotEmpty)
                                          Text(
                                            'ID: ${_log.assetId}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),

                        // Description
                        _buildInfoCard(
                          title: 'Deskripsi Masalah',
                          icon: Icons.description,
                          children: [
                            Text(
                              _log.description ?? _log.title,
                              style: const TextStyle(fontSize: 15),
                            ),
                            if (_log.notes != null && _log.notes!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 8),
                              Text(
                                'Catatan:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(_log.notes!),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Assignment info
                        if (_log.assignedToName != null)
                          _buildInfoCard(
                            title: 'Penugasan',
                            icon: Icons.person,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                                    child: const Icon(Icons.person, color: AppTheme.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _log.assignedToName!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Text(
                                          'Teknisi',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),

                        // Cost info (if completed)
                        if (_log.cost != null && _log.cost! > 0)
                          _buildInfoCard(
                            title: 'Biaya',
                            icon: Icons.attach_money,
                            children: [
                              Text(
                                'Rp ${_log.cost!.toStringAsFixed(0).replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (m) => '${m[1]}.',
                                )}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Actions
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: _log.status.color.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: _log.status.color.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Icon(_log.status.icon, color: _log.status.color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _log.status.displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _log.status.color,
                  ),
                ),
                Text(
                  _getStatusDescription(),
                  style: TextStyle(
                    color: _log.status.color.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (_log.isUrgent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'URGENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getStatusDescription() {
    switch (_log.status) {
      case MaintenanceStatus.pending:
        return 'Menunggu persetujuan admin';
      case MaintenanceStatus.approved:
        return 'Disetujui, menunggu penugasan teknisi';
      case MaintenanceStatus.inProgress:
        return 'Sedang dikerjakan oleh teknisi';
      case MaintenanceStatus.completed:
        return 'Pekerjaan telah selesai';
      case MaintenanceStatus.rejected:
        return 'Request ditolak';
      case MaintenanceStatus.cancelled:
        return 'Request dibatalkan';
    }
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
       shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final userAsync = ref.watch(currentUserProvider);
    final isAdmin = userAsync.value?.role == 'admin';

    // If no actions available, return empty
    if (_log.status == MaintenanceStatus.cancelled || _log.status == MaintenanceStatus.rejected) {
       return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status update buttons based on current status and role
          if (isAdmin && _log.status == MaintenanceStatus.pending) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _updateStatus(MaintenanceStatus.rejected),
                icon: const Icon(Icons.close, color: Colors.red),
                label: const Text('Tolak'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _updateStatus(MaintenanceStatus.approved),
                icon: const Icon(Icons.check),
                label: const Text('Setujui'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ] else if (isAdmin && _log.status == MaintenanceStatus.approved) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _updateStatus(MaintenanceStatus.inProgress),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Mulai Pengerjaan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ] else if (_log.status == MaintenanceStatus.inProgress) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showCompleteDialog(),
                icon: const Icon(Icons.check_circle),
                label: const Text('Tandai Selesai'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ] else if (_log.status == MaintenanceStatus.completed) ...[
            const Expanded(
              child: Center(
                child: Text(
                  '✓ Pekerjaan telah selesai',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _updateStatus(MaintenanceStatus newStatus) async {
    setState(() => _isUpdating = true);
    
    try {
      final data = {'status': newStatus.toDatabase()};
      
      if (newStatus == MaintenanceStatus.completed) {
        data['completed_date'] = DateTime.now().toIso8601String();
      }
      
      // Update DB
      await _supabase
          .from('maintenance_logs')
          .update(data)
          .eq('id', _log.id);
          
      // Refresh Riverpod provider
       ref.invalidate(allMaintenanceLogsProvider);
      
      if (mounted) {
        setState(() {
          _log = _log.copyWith(status: newStatus);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status diupdate ke ${newStatus.displayName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  void _showCompleteDialog() {
    final costController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Pekerjaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Apakah pekerjaan maintenance sudah selesai?'),
            const SizedBox(height: 16),
            TextField(
              controller: costController,
              decoration: const InputDecoration(
                labelText: 'Biaya (Rp) - Opsional',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _completeWithCost(
                double.tryParse(costController.text) ?? 0,
              );
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeWithCost(double cost) async {
    setState(() => _isUpdating = true);
    
    try {
      await _supabase.from('maintenance_logs').update({
        'status': MaintenanceStatus.completed.toDatabase(),
        'completed_date': DateTime.now().toIso8601String(),
        'cost': cost,
      }).eq('id', _log.id);
      
      ref.invalidate(allMaintenanceLogsProvider);
      
      if (mounted) {
        setState(() {
          _log = _log.copyWith(
            status: MaintenanceStatus.completed,
            completedAt: DateTime.now(),
            cost: cost,
          );
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pekerjaan ditandai selesai'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
         setState(() => _isUpdating = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToEdit(BuildContext context) {
    context.go('/admin/maintenance/edit/${_log.id}', extra: _log);
  }
}

