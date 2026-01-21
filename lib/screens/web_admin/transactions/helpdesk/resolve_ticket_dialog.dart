import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../models/ticket.dart';
import '../../../../../riverpod/ticket_providers.dart';
import '../../../../../riverpod/auth_providers.dart';
import '../../../../../core/design/admin_colors.dart';

class ResolveTicketDialog extends ConsumerStatefulWidget {
  final Ticket ticket;

  const ResolveTicketDialog({super.key, required this.ticket});

  @override
  ConsumerState<ResolveTicketDialog> createState() => _ResolveTicketDialogState();
}

class _ResolveTicketDialogState extends ConsumerState<ResolveTicketDialog> {
  final _noteController = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageName;
  bool _isSubmitting = false;

  bool get isStockRequest => widget.ticket.type == TicketType.stockRequest;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _imageBytes = result.files.first.bytes;
        _imageName = result.files.first.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dialogTitle = isStockRequest ? 'Selesaikan Permintaan Stok' : 'Selesaikan Tiket';
    final confirmMessage = isStockRequest 
        ? 'Apakah permintaan stok #${widget.ticket.ticketNumber} sudah diserahkan?'
        : 'Apakah tiket #${widget.ticket.ticketNumber} sudah selesai dikerjakan?';

    return AlertDialog(
      title: Text(dialogTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(confirmMessage, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),

              // Stock Request Info
              if (isStockRequest) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.inventory_2_outlined, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text('Item Inventaris', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(widget.ticket.inventoryItemName ?? 'Item', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Jumlah: ${widget.ticket.requestedQuantity ?? 0} unit', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Stok inventaris akan otomatis berkurang ${widget.ticket.requestedQuantity ?? 0} unit setelah diselesaikan.',
                          style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Proof Image (Required for regular tickets, Optional for stock)
              Text(
                isStockRequest ? 'Bukti Foto (Opsional)' : 'Bukti Foto (Wajib)', 
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                    image: _imageBytes != null 
                      ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover) 
                      : null,
                  ),
                  child: _imageBytes == null 
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 28, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('Klik untuk upload foto', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        )
                      : Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const CircleAvatar(backgroundColor: Colors.white, radius: 12, child: Icon(Icons.close, size: 16, color: Colors.red)), 
                            onPressed: () => setState(() { _imageBytes = null; _imageName = null; }),
                          ),
                        ),
                ),
              ),
              if (_imageName != null) Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(_imageName!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ),
              const SizedBox(height: 16),

              // Note
              Text(
                isStockRequest ? 'Catatan Penyerahan' : 'Catatan Penyelesaian', 
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: isStockRequest 
                      ? 'Catatan penyerahan stok (opsional)...' 
                      : 'Jelaskan apa yang sudah dikerjakan...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context), 
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.green),
          // For stock request: allow without image. For others: require image
          onPressed: ((!isStockRequest && _imageBytes == null) || _isSubmitting) 
            ? null 
            : () async {
                setState(() => _isSubmitting = true);
                try {
                  final currentUser = ref.read(currentUserIdProvider);
                  if (currentUser == null) throw 'User session invalid';

                  await ref.read(ticketRepositoryProvider).resolveTicket(
                    ticketId: widget.ticket.id,
                    userId: currentUser,
                    note: _noteController.text.isNotEmpty ? _noteController.text : 'Selesai',
                    imageBytes: _imageBytes ?? Uint8List(0), // Empty bytes for stock request without image
                  );
                  
                  if (mounted) Navigator.pop(context, true); // Success
                } catch (e) {
                  setState(() => _isSubmitting = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                  }
                }
              },
          child: _isSubmitting 
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
            : Text(isStockRequest ? 'Resolve' : 'Selesaikan'),
        ),
      ],
    );
  }
}
