// lib/screens/reporting_screen_hooks.dart
// ✅ MIGRATED TO HOOKS_RIVERPOD

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReportingScreen extends HookConsumerWidget {
  final String scannedData; // Data dari QR Code, misal: "Ruang Rapat A-101"

  const ReportingScreen({super.key, required this.scannedData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ HOOKS: Controllers and state
    final notesController = useTextEditingController();
    final isSelected = useState<List<bool>>([true, false]);
    final isLoading = useState(false);

    // ✅ HOOKS: Animation controller (replaces SingleTickerProviderStateMixin)
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    // ✅ HOOKS: Memoized animation
    final scaleAnimation = useMemoized(
      () => Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
      ),
      [animationController],
    );

    // ✅ HELPER: Submit report
    Future<void> submitReport() async {
      if (isLoading.value) return;

      isLoading.value = true; // ✅ Direct state update

      try {
        final status = isSelected.value[0] ? 'Bersih' : 'Perlu Dibersihkan';
        final notes = notesController.text;

        // Animasi tekan tombol
        animationController.forward();
        await Future.delayed(const Duration(milliseconds: 150));
        animationController.reverse();

        // ⚠️ REVIEW: Simulated submission (not connected to backend)
        // TODO: Integrate with actual reporting service
        await Future.delayed(const Duration(seconds: 1));

        // Log data (untuk development)
        debugPrint('Laporan Dikirim!');
        debugPrint('Lokasi: $scannedData');
        debugPrint('Status: $status');
        debugPrint('Catatan: $notes');

        if (!context.mounted) return;

        // Tampilkan notifikasi sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Laporan berhasil dikirim!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 2),
          ),
        );

        // TODO (Phase 5): Replace with go_router navigation
        Navigator.pop(context);
      } catch (e) {
        // Tampilkan error jika gagal
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Gagal mengirim laporan: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      } finally {
        if (context.mounted) {
          isLoading.value = false; // ✅ Direct state update
        }
      }
    }

    // ✅ BUILD UI
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Laporan Kebersihan'),
        backgroundColor: Colors.indigo[800],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.indigo[800]),
                        const SizedBox(width: 8),
                        const Text(
                          'Lokasi Pemeriksaan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      scannedData,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Status Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cleaning_services,
                          color: Colors.indigo[800],
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Status Kebersihan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ToggleButtons(
                      isSelected: isSelected.value,
                      onPressed: (int index) {
                        // ✅ Direct state update
                        final newSelection = List<bool>.filled(
                          isSelected.value.length,
                          false,
                        );
                        newSelection[index] = true;
                        isSelected.value = newSelection;
                      },
                      borderRadius: BorderRadius.circular(8.0),
                      selectedColor: Colors.white,
                      fillColor: Colors.indigo,
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Bersih'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Perlu Dibersihkan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notes Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note_add, color: Colors.indigo[800]),
                        const SizedBox(width: 8),
                        const Text(
                          'Catatan Tambahan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: notesController,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Tambahkan catatan jika diperlukan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.indigo[800]!),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button with Animation
            ScaleTransition(
              scale: scaleAnimation,
              child: ElevatedButton(
                onPressed: isLoading.value ? null : submitReport,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  backgroundColor: Colors.indigo[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: isLoading.value
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Kirim Laporan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

