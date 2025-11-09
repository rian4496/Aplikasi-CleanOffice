// lib/screens/dev/seed_data_screen.dart
// Screen untuk generate sample data (DEV ONLY)

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/seed_data_service.dart';
import '../../core/theme/app_theme.dart';

class SeedDataScreen extends StatefulWidget {
  const SeedDataScreen({super.key});

  @override
  State<SeedDataScreen> createState() => _SeedDataScreenState();
}

class _SeedDataScreenState extends State<SeedDataScreen> {
  final _seedService = SeedDataService();
  bool _isLoading = false;
  int _currentCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final count = await _seedService.getInventoryCount();
    setState(() {
      _currentCount = count;
    });
  }

  Future<void> _generateSampleData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError('User not logged in! Login dulu sebagai admin.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _seedService.generateSampleInventory(
        userId: user.uid,
        userName: user.displayName ?? 'Dev User',
      );

      await _loadCount();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sample data berhasil dibuat!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Konfirmasi'),
        content: const Text(
          'Hapus SEMUA data inventory?\nTindakan ini tidak bisa di-undo!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _seedService.clearAllInventory();
      await _loadCount();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Semua data berhasil dihapus'),
            backgroundColor: AppTheme.warning,
          ),
        );
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌱 Generate Sample Data'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Warning Card
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'DEV MODE ONLY\nJangan gunakan di production!',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Current Status
                  _buildStatusCard(),

                  const SizedBox(height: 24),

                  // Generate Button
                  _buildActionCard(
                    title: '🌱 Generate Sample Data',
                    description: 'Buat 8 item inventaris sample dengan berbagai status stok',
                    buttonText: 'Generate Data',
                    buttonColor: AppTheme.primary,
                    buttonIcon: Icons.add_circle,
                    onPressed: _generateSampleData,
                  ),

                  const SizedBox(height: 16),

                  // Clear Button
                  _buildActionCard(
                    title: '🗑️ Clear All Data',
                    description: 'Hapus semua data inventory dari database',
                    buttonText: 'Clear All',
                    buttonColor: AppTheme.error,
                    buttonIcon: Icons.delete_forever,
                    onPressed: _clearAllData,
                  ),

                  const SizedBox(height: 24),

                  // Sample Data Preview
                  _buildSamplePreview(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Current Inventory Count',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_currentCount',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'items',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadCount,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required String buttonText,
    required Color buttonColor,
    required IconData buttonIcon,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPressed,
                icon: Icon(buttonIcon),
                label: Text(buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSamplePreview() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📋 Sample Data Preview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPreviewItem('Sapu Ijuk', 'Alat', 'Stok: 25/100', AppTheme.success),
            _buildPreviewItem('Kain Pel', 'Alat', 'Stok: 15/50', AppTheme.success),
            _buildPreviewItem('Sabun Cuci', 'Consumable', 'Stok: 3/100 ⚠️', AppTheme.warning),
            _buildPreviewItem('Pewangi', 'Consumable', 'Stok: 0/50 ❌', AppTheme.error),
            _buildPreviewItem('Masker N95', 'PPE', 'Stok: 8/100', Colors.blue),
            _buildPreviewItem('Sarung Tangan', 'PPE', 'Stok: 45/200', AppTheme.success),
            _buildPreviewItem('Pembersih Lantai', 'Consumable', 'Stok: 12/100', Colors.blue),
            _buildPreviewItem('Tissue Gulung', 'Consumable', 'Stok: 120/500', AppTheme.success),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewItem(String name, String category, String stock, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$category • $stock',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
