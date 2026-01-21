// lib/screens/web_admin/transactions/mutation/mutation_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For User ID
import '../../../../core/theme/app_theme.dart';
import '../../../../models/asset.dart'; // For Asset picker
import '../../../../models/location.dart'; // For Location picker
import '../../../../models/transactions/asset_mutation.dart';
import '../../../../riverpod/mutation_providers.dart';
import '../../../../widgets/shared/custom_app_bar.dart';

// Needed for picking data
// Refactor: Should use proper providers, but using Supabase direct for speed in this iteration
// or reuse existing providers if available.
// Assume basic fetching or FutureBuilders for simplicity in form.

class MutationFormScreen extends ConsumerStatefulWidget {
  const MutationFormScreen({super.key});

  @override
  ConsumerState<MutationFormScreen> createState() => _MutationFormScreenState();
}

class _MutationFormScreenState extends ConsumerState<MutationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  
  Asset? _selectedAsset;
  Location? _selectedDestination;
  
  // Lists for dropdowns
  List<Asset> _assets = [];
  List<Location> _locations = [];
  bool _isLoadingData = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final client = Supabase.instance.client;
    
    try {
      // Fetch Assets (Active only)
      final assetsData = await client.from('assets').select('''
        *,
        locations:location_id(name)
      ''').eq('status', 'active');
      
      // Fetch Locations
      final locationsData = await client.from('locations').select();

      setState(() {
        _assets = (assetsData as List).map((e) => Asset.fromSupabase(e)).toList();
        _locations = (locationsData as List).map((e) => Location.fromJson(e)).toList();
        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAsset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih aset terlebih dahulu')),
      );
      return;
    }
    if (_selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih lokasi tujuan')),
      );
      return;
    }

    // Verify user
    // Verify user
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isSubmitting = true);

    final newMutation = AssetMutation(
      id: '', 
      mutationCode: 'MUT-${DateTime.now().millisecondsSinceEpoch}',
      assetId: _selectedAsset!.id,
      originLocationId: _selectedAsset!.locationId,
      destinationLocationId: _selectedDestination!.id,
      requesterId: userId,
      status: MutationStatus.pending,
      reason: _reasonController.text,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(mutationActionsProvider).createMutation(newMutation);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mutasi berhasil dibuat'), backgroundColor: Colors.green),
        );
        context.pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Buat Mutasi Baru',
          style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
      body: _isLoadingData 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: MaxWidthContainer(
              maxWidth: 800,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Asset Selection
                    _buildSectionHeader('1. Informasi Aset', Icons.inventory_2_outlined),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<Asset>(
                      decoration: _buildInputDecoration('Pilih Aset yang ingin dimutasi', Icons.search),
                      isExpanded: true,
                      hint: const Text('Cari Aset...'),
                      items: _assets.map((asset) => DropdownMenuItem(
                        value: asset,
                        child: Text(
                          '${asset.name} (${asset.qrCode})', 
                          overflow: TextOverflow.ellipsis
                        ),
                      )).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedAsset = val;
                        });
                      },
                      validator: (val) => val == null ? 'Aset wajib dipilih' : null,
                    ),

                    if (_selectedAsset != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 20),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Lokasi Saat Ini', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600])),
                                Text(
                                  _selectedAsset?.locationName ?? "Tidak diketahui", 
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87)
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Section 2: Destination
                    _buildSectionHeader('2. Tujuan Mutasi', Icons.near_me_outlined),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<Location>(
                      decoration: _buildInputDecoration('Pilih Lokasi Tujuan', Icons.place_outlined),
                      isExpanded: true,
                      hint: const Text('Pilih lokasi baru...'),
                      items: _locations
                          .where((loc) => loc.id != _selectedAsset?.locationId) // Exclude current
                          .map((loc) => DropdownMenuItem(
                        value: loc,
                        child: Text(loc.name),
                      )).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedDestination = val;
                        });
                      },
                      validator: (val) => val == null ? 'Lokasi tujuan wajib dipilih' : null,
                    ),

                    const SizedBox(height: 32),

                    // Section 3: Reason
                    _buildSectionHeader('3. Keterangan', Icons.description_outlined),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _reasonController,
                      maxLines: 4,
                      decoration: _buildInputDecoration('Alasan pemindahan aset...', Icons.edit_note),
                      validator: (val) => val == null || val.isEmpty ? 'Alasan wajib diisi' : null,
                    ),

                    const SizedBox(height: 48),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSubmitting 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Ajukan Mutasi', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.black87),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
      filled: true,
      fillColor: Colors.grey[50], // Very subtle grey
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

// Simple Helper for Max Width Constraint
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const MaxWidthContainer({super.key, required this.child, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
