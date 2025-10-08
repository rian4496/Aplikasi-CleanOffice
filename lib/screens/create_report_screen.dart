import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  // Daftar lokasi yang sudah ditentukan untuk saran Autocomplete
  static const List<String> _locationOptions = <String>[
    'Toilet Lantai 1',
    'Toilet Lantai 2',
    'Area Lobby',
    'Dapur Karyawan',
    'Ruang Rapat A-101',
    'Halaman Depan',
    'Halaman Belakang',
    'Ruang Server',
    'Pantry',
    'Area Parkir',
  ];

  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    if (pickedImage == null) return;

    setState(() {
      _selectedImage = File(pickedImage.path);
    });
  }

  void _resetForm() {
    setState(() {
      _locationController.clear();
      _notesController.clear();
      _selectedImage = null;
    });
  }

  Future<void> _kirimLaporan() async {
    if (!_formKey.currentState!.validate()) return;

    final location = _locationController.text;
    final notes = _notesController.text;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon ambil foto terlebih dahulu.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulasi pengiriman data ke server
      await Future.delayed(const Duration(seconds: 2));
      
      // Log data yang akan dikirim (simulasi)
      debugPrint('Mengirim laporan dengan data:');
      debugPrint('Lokasi: $location');
      debugPrint('Deskripsi: $notes');
      debugPrint('Foto Path: ${_selectedImage!.path}');
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil dikirim!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _resetForm();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim laporan: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporkan Masalah Kebersihan'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Foto Masalah',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400, width: 2),
                      ),
                child: _selectedImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(_selectedImage!, fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withAlpha(128),
                              child: IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.white),
                                onPressed: _takePicture,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 60, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Ketuk untuk mengambil foto',
                              style: TextStyle(color: Colors.grey)),
                          Text('masalah kebersihan',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Widget LOKASI sekarang menggunakan Autocomplete ---
            Autocomplete<String>(
              // Memberitahu Autocomplete untuk menggunakan controller ini
              fieldViewBuilder: (BuildContext context, TextEditingController fieldController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                // Kita assign controller kita di sini agar bisa mengambil nilainya nanti
                _locationController.text = fieldController.text;
                return TextFormField(
                  controller: fieldController,
                  focusNode: fieldFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Ketik atau Pilih Lokasi',
                    hintText: 'Contoh: Halaman Belakang',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                );
              },
              // Logika untuk menampilkan opsi/saran
              optionsBuilder: (TextEditingValue textEditingValue) {
                // Jika kolom teks kosong, jangan tampilkan saran apa-apa
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                // Tampilkan opsi yang mengandung teks yang diketik oleh user
                return _locationOptions.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              // Aksi saat user meng-klik salah satu saran
              onSelected: (String selection) {
                _locationController.text = selection;
                debugPrint('You just selected $selection');
              },
            ),
            const SizedBox(height: 20),

            // Deskripsi & Tombol Kirim (tidak ada perubahan)
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Tambahan',
                hintText: 'Jelaskan masalah singkat...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Mohon isi deskripsi masalah';
                }
                if (value.trim().length < 10) {
                  return 'Deskripsi terlalu singkat (min. 10 karakter)';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _kirimLaporan,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send),
                        SizedBox(width: 8),
                        Text('Kirim Laporan'),
                      ],
                    ),
            ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(128),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}