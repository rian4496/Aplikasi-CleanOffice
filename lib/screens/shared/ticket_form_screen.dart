import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/ticket.dart';
import '../../models/location.dart';
import '../../models/master/master_data_models.dart';
import '../../riverpod/ticket_providers.dart';
import '../../riverpod/supabase_service_providers.dart';
import '../../riverpod/dropdown_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/config/supabase_config.dart';
import '../../core/constants/app_constants.dart';
import '../web_admin/transactions/helpdesk/helpdesk_screen.dart';

class TicketFormScreen extends HookConsumerWidget {
  final TicketType? initialType;
  final String? initialAssetId;

  const TicketFormScreen({super.key, this.initialType, this.initialAssetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();
    
    // State
    final selectedType = useState<TicketType>(initialType ?? TicketType.kerusakan);
    final selectedPriority = useState<TicketPriority>(TicketPriority.normal);
    final selectedAsset = useState<MasterAset?>(null);
    final selectedLocation = useState<Location?>(null);
    final selectedInventory = useState<Map<String, dynamic>?>(null);
    final quantityController = useTextEditingController();
    final customLocationController = useTextEditingController();

    final isSubmitting = useState(false);
    final isUrgent = useState(false);
    
    // Image State
    final imageBytes = useState<Uint8List?>(null);

    // Watch Data
    final assetsAsync = ref.watch(assetListProvider);
    final locationsAsync = ref.watch(locationListProvider);
    final inventoryAsync = ref.watch(inventoryDropdownProvider);

    // Initial Asset Selection Logic
    useEffect(() {
      if (initialAssetId != null && assetsAsync.hasValue) {
        final assets = assetsAsync.value!;
        final foundAsset = assets.where((a) => a.id == initialAssetId).firstOrNull;
        if (foundAsset != null && selectedAsset.value == null) {
          selectedAsset.value = foundAsset;
        }
      }
      return null;
    }, [assetsAsync.value]);

    // Sync Urgent Toggle
    useEffect(() {
      if (isUrgent.value) {
        selectedPriority.value = TicketPriority.urgent;
      } else {
        if (selectedPriority.value == TicketPriority.urgent) {
          selectedPriority.value = TicketPriority.normal;
        }
      }
      return null;
    }, [isUrgent.value]);

    // Image Picker Function
    Future<void> pickImage(ImageSource source) async {
      try {
        final picker = ImagePicker();
        final picked = await picker.pickImage(
          source: source,
          maxWidth: 800,
          imageQuality: 70,
        );
        if (picked != null) {
          final bytes = await picked.readAsBytes();
          // Simple validation
          if (bytes.length > 5 * 1024 * 1024) { // 5MB limit
             if (context.mounted) {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ukuran gambar terlalu besar (Max 5MB)')));
             }
             return;
          }
          imageBytes.value = bytes;
        }
      } catch (e) {
        debugPrint('Error picking image: $e');
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengambil gambar: $e')));
        }
      }
    }

    void showImageSourceDialog() {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (ctx) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Ambil Foto (Kamera)'),
                onTap: () {
                  Navigator.pop(ctx);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(ctx);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      );
    }
    
    // ... (uploadImage remains same)

    // ... inside build ...
              // 3. Image Upload (Kebersihan Only - Android Style)

    Future<String?> uploadImage(String userId) async {
      if (imageBytes.value == null) return null;
      try {
        final storage = ref.read(supabaseStorageServiceProvider);
        final result = await storage.uploadImage(
          bytes: imageBytes.value!,
          bucket: SupabaseConfig.reportImagesBucket, // Ensure this bucket exists or use 'tickets'
          userId: userId,
        );
        if (result.isSuccess) {
          return result.data;
        } else {
          throw Exception(result.error ?? 'Upload failed');
        }
      } catch (e) {
        throw Exception('Image upload error: $e');
      }
    }

    Future<void> submitTicket() async {
      if (!formKey.currentState!.validate()) return;

      // Validation
      if (selectedType.value == TicketType.kerusakan && selectedAsset.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon pilih aset yang bermasalah')));
        return;
      }
      if (selectedType.value == TicketType.kebersihan) {
        if (selectedLocation.value == null && customLocationController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon isi lokasi masalah kebersihan')));
          return;
        }
      }
      if (selectedType.value == TicketType.stockRequest && (selectedInventory.value == null || quantityController.text.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon pilih item dan jumlah')));
        return;
      }

      isSubmitting.value = true;
      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) throw Exception('User tidak terautentikasi');

        String? uploadedImageUrl;
        if (imageBytes.value != null) {
          uploadedImageUrl = await uploadImage(userId);
        }

        final repo = ref.read(ticketRepositoryProvider);
        
        // Build description with custom location if provided
        String finalDescription = descriptionController.text.trim();
        if (customLocationController.text.trim().isNotEmpty && selectedLocation.value == null) {
          finalDescription = '[Lokasi: ${customLocationController.text.trim()}]\n$finalDescription';
        }
        
        final ticket = await repo.createTicket(
          type: selectedType.value,
          title: titleController.text.trim(),
          description: finalDescription,
          priority: selectedPriority.value,
          createdBy: userId,
          assetId: selectedAsset.value?.id,
          locationId: selectedLocation.value?.id,
          inventoryItemId: selectedInventory.value?['id'],
          requestedQuantity: int.tryParse(quantityController.text),
          imageUrl: uploadedImageUrl,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tiket ${ticket.ticketNumber} berhasil dibuat!'),
              backgroundColor: Colors.green,
            ),
          );
          
          
          // Refresh data so it appears immediately
          ref.read(ticketControllerProvider).refresh();

          // Explicitly go to helpdesk list to avoid pop errors and ensure correct flow
          context.go('/admin/helpdesk');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        isSubmitting.value = false;
      }
    }

    String getTitle() {
      switch (selectedType.value) {
        case TicketType.kerusakan: return 'Laporan Kerusakan';
        case TicketType.kebersihan: return 'Laporan Kebersihan';
        case TicketType.stockRequest: return 'Request Stok';
      }
    }

    Color getTypeColor(TicketType type) {
      switch (type) {
        case TicketType.kerusakan: return AppTheme.primary;
        case TicketType.kebersihan: return Colors.green[600]!;
        case TicketType.stockRequest: return Colors.orange[700]!;
      }
    }
    
    IconData getTypeIcon(TicketType type) {
      switch (type) {
         case TicketType.kerusakan: return Icons.build_circle_outlined;
         case TicketType.kebersihan: return Icons.cleaning_services_outlined;
         case TicketType.stockRequest: return Icons.inventory_2_outlined;
      }
    }

    Widget buildTypeSelector() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TicketType.values.map((type) {
            final isSelected = selectedType.value == type;
            final color = getTypeColor(type);
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Text(type.displayName),
                selected: isSelected,
                onSelected: (_) => selectedType.value = type,
                selectedColor: color,
                backgroundColor: Colors.grey[100],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                avatar: Icon(
                  getTypeIcon(type),
                  size: 18,
                  color: isSelected ? Colors.white : color,
                ),
                side: BorderSide(color: isSelected ? color : Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            );
          }).toList(),
        ),
      );
    }
    
    InputDecoration inputDecoration(String hint, IconData icon) {
        return InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), 
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent keyboard blank space issue on mobile web
      backgroundColor: Colors.white, // Match clean background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Custom Header (Matches Helpdesk Style) ---
              Row(
                children: [
                   InkWell(
                      onTap: () {
                        // Go back to helpdesk and show create ticket popup
                        context.go('/admin/helpdesk');
                        // Small delay to ensure navigation completed, then show popup
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (context.mounted) {
                            showCreateTicketDialogGlobal(context);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, size: 20),
                      ),
                   ),
                   const SizedBox(width: 16),
                   Text(
                      'Buat ${getTitle()}',
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                   ),
                ],
              ),
              const SizedBox(height: 32),
              // 1. Type Selector (Hidden if initialType exists)
              if (initialType == null) ...[
                Text('Jenis Tiket', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 8),
                buildTypeSelector(),
                const SizedBox(height: 24),
              ],

              // 2. Info Card (Kebersihan Only - Android Style)
              if (selectedType.value == TicketType.kebersihan)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Laporan untuk area yang perlu dibersihkan atau sudah dibersihkan.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

              // 3. Image Upload (For All Ticket Types)
              Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(12),
                       border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              'Foto (Opsional)',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                             SizedBox(width: 8),
                             Chip(
                               label: Text('Opsional', style: TextStyle(fontSize: 10)),
                               padding: EdgeInsets.zero,
                               visualDensity: VisualDensity.compact,
                             ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: GestureDetector(
                            onTap: isSubmitting.value ? null : showImageSourceDialog,
                            child: Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid, width: 2),
                              ),
                              child: imageBytes.value != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.memory(imageBytes.value!, fit: BoxFit.cover),
                                          Positioned(
                                            right: 8,
                                            top: 8,
                                            child: GestureDetector(
                                              onTap: showImageSourceDialog,
                                              child: CircleAvatar(
                                                backgroundColor: Colors.black.withValues(alpha: 0.5),
                                                child: const Icon(Icons.refresh, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('Ketuk untuk ambil foto', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

              // 4. Dynamic Fields
              if (selectedType.value == TicketType.kerusakan) ...[
                Text('Aset Bermasalah', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 8),
                assetsAsync.when(
                  data: (assets) => DropdownButtonFormField<MasterAset>(
                    value: selectedAsset.value,
                    decoration: inputDecoration('Pilih Aset', Icons.inventory_2_outlined),
                    items: assets.map((a) => DropdownMenuItem(
                      value: a, 
                      child: Text('${a.name} (${a.assetCode})', overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (val) => selectedAsset.value = val,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Gagal memuat aset: $e'),
                ),
                const SizedBox(height: 16),
                // Location Dropdown (Optional for Kerusakan)
                Text('Lokasi Aset (Opsional)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 8),
                locationsAsync.when(
                  data: (locations) => DropdownButtonFormField<Location>(
                    value: selectedLocation.value,
                    decoration: inputDecoration('Pilih Lokasi (jika ada)', Icons.place_outlined),
                    items: [
                      const DropdownMenuItem<Location>(value: null, child: Text('-- Lokasi Tidak Terdaftar --')),
                      ...locations.map((l) => DropdownMenuItem(
                        value: l, 
                        child: Text(l.name, overflow: TextOverflow.ellipsis),
                      )),
                    ],
                    onChanged: (val) => selectedLocation.value = val,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Gagal: $e'),
                ),
                // Custom Location Text Field when "Lokasi Tidak Terdaftar" is selected
                if (selectedLocation.value == null) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: customLocationController,
                    decoration: inputDecoration('Ketik lokasi jika tidak ada di daftar (opsional)', Icons.edit_location_alt).copyWith(
                      helperText: 'Contoh: Ruang Rapat Lt.2, Gudang Belakang',
                    ),
                  ),
                ],
              ] else if (selectedType.value == TicketType.kebersihan) ...[
                // Location Field (Required for Kebersihan)
                Text('Lokasi', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 8),
                locationsAsync.when(
                  data: (locations) => DropdownButtonFormField<Location>(
                    value: selectedLocation.value,
                    decoration: inputDecoration('Pilih Lokasi', Icons.place_outlined),
                    items: [
                      const DropdownMenuItem<Location>(value: null, child: Text('-- Lokasi Tidak Terdaftar --')),
                      ...locations.map((l) => DropdownMenuItem(
                        value: l, 
                        child: Text(l.name, overflow: TextOverflow.ellipsis),
                      )),
                    ],
                    onChanged: (val) => selectedLocation.value = val,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Gagal: $e'),
                ),
                // Custom Location Text Field when "Lokasi Tidak Terdaftar" is selected
                if (selectedLocation.value == null) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: customLocationController,
                    decoration: inputDecoration('Ketik lokasi jika tidak ada di daftar', Icons.edit_location_alt).copyWith(
                      helperText: 'Contoh: Ruang Rapat Lt.2, Gudang Belakang',
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Lokasi wajib diisi jika tidak memilih dari daftar' : null,
                  ),
                ],
              ] else if (selectedType.value == TicketType.stockRequest) ...[
                Text('Item Stok', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 8),
                inventoryAsync.when(
                  data: (items) => DropdownButtonFormField<Map<String, dynamic>>(
                    value: selectedInventory.value,
                    decoration: inputDecoration('Pilih Barang', Icons.shopping_cart_outlined),
                    items: items.map((i) => DropdownMenuItem(
                      value: i, 
                      child: Text('${i['name']} (Stok: ${i['current_stock']})', overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (val) => selectedInventory.value = val,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Gagal: $e'),
                ),
                const SizedBox(height: 16),
                Text('Jumlah', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 8),
                TextFormField(
                  controller: quantityController,
                   keyboardType: TextInputType.number,
                   decoration: inputDecoration('Masukkan jumlah', Icons.numbers),
                   validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                // Lokasi untuk Stock Request
                Text('Lokasi Pengiriman', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 8),
                locationsAsync.when(
                  data: (locations) => DropdownButtonFormField<Location>(
                    value: selectedLocation.value,
                    decoration: inputDecoration('Pilih Lokasi Tujuan', Icons.place_outlined),
                    items: [
                      const DropdownMenuItem<Location>(value: null, child: Text('-- Pilih Lokasi --')),
                      ...locations.map((l) => DropdownMenuItem(
                        value: l, 
                        child: Text(l.name, overflow: TextOverflow.ellipsis),
                      )),
                    ],
                    onChanged: (val) => selectedLocation.value = val,
                    validator: (v) => v == null ? 'Lokasi tujuan wajib dipilih' : null,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Gagal: $e'),
                ),
              ],
              
              const SizedBox(height: 24),

              // 5. Title & Desc
              Text('Judul / Subjek', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                decoration: inputDecoration(
                   selectedType.value == TicketType.stockRequest ? 'Keperluan' : 'Contoh: AC Bocor, Lantai Licin',
                   Icons.title
                ),
                validator: (v) => v == null || v.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              Text('Deskripsi Detail', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: inputDecoration('Jelaskan detailnya...', Icons.description_outlined).copyWith(alignLabelWithHint: true),
              ),
              const SizedBox(height: 24),

              // 6. Urgent (Not for Stock)
              if (selectedType.value != TicketType.stockRequest)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SwitchListTile(
                    title: Text('Mendesak / Urgent?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                    subtitle: Text('Aktifkan jika menghambat operasional utama.', style: TextStyle(color: Colors.grey[600])),
                    activeColor: Colors.red,
                    activeTrackColor: Colors.red[200],
                    inactiveThumbColor: Colors.grey[400],
                    inactiveTrackColor: Colors.grey[300],
                    secondary: Icon(Icons.warning_amber_rounded, color: isUrgent.value ? Colors.red : Colors.grey[400]),
                    value: isUrgent.value,
                    onChanged: (val) => isUrgent.value = val,
                  ),
                ),

              const SizedBox(height: 32),

              // Button
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                   width: 200, // Fixed reasonable width or remove for auto
                   height: 50,
                   child: OutlinedButton.icon(
                     onPressed: isSubmitting.value ? null : submitTicket,
                     icon: isSubmitting.value
                         ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green))
                         : const Icon(Icons.send_rounded, color: Colors.green),
                     label: Text(
                       isSubmitting.value ? 'Mengirim...' : 'Kirim Laporan',
                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                     ),
                     style: OutlinedButton.styleFrom(
                       foregroundColor: Colors.green,
                       side: const BorderSide(color: Colors.green, width: 2),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                       elevation: 0,
                     ),
                   ),
                 ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
