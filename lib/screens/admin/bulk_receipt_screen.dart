import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

// 1. State Definition
enum BulkReceiptStatus {
  idle,
  uploading,
  processing,
  success,
  error,
}

@immutable
class BulkReceiptState {
  final BulkReceiptStatus status;
  final String? message;
  final String? downloadUrl;
  final String? fileName;

  const BulkReceiptState({
    this.status = BulkReceiptStatus.idle,
    this.message,
    this.downloadUrl,
    this.fileName,
  });

  BulkReceiptState copyWith({
    BulkReceiptStatus? status,
    String? message,
    String? downloadUrl,
    String? fileName,
  }) {
    return BulkReceiptState(
      status: status ?? this.status,
      message: message ?? this.message,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      fileName: fileName ?? this.fileName,
    );
  }
}

// 2. Notifier (Riverpod 2.4+)
class BulkReceiptNotifier extends Notifier<BulkReceiptState> {
  late final FirebaseStorage _storage;
  late final FirebaseFunctions _functions;
  late final FirebaseAuth _auth;

  @override
  BulkReceiptState build() {
    _storage = FirebaseStorage.instance;
    _functions = FirebaseFunctions.instanceFor(region: 'asia-southeast2');
    _auth = FirebaseAuth.instance;
    return const BulkReceiptState();
  }

  Future<void> pickAndUploadFile() async {
    state = state.copyWith(status: BulkReceiptStatus.idle, message: 'Membuka pemilih file...');

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null || result.files.isEmpty) {
        state = state.copyWith(status: BulkReceiptStatus.idle, message: 'Pemilihan file dibatalkan.');
        return;
      }

      final platformFile = result.files.single;
      final fileName = platformFile.name;
      final ext = fileName.split('.').last.toLowerCase();
      if (ext != 'xlsx' && ext != 'xls') {
        state = state.copyWith(status: BulkReceiptStatus.error, message: 'Format file tidak didukung.');
        return;
      }

      state = state.copyWith(
        status: BulkReceiptStatus.uploading,
        fileName: fileName,
        message: 'Mengunggah file: $fileName',
      );

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in.");
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'uploads/${user.uid}-$timestamp.$ext';

      if (kIsWeb) {
        final bytes = platformFile.bytes;
        if (bytes == null) throw Exception("File bytes tidak tersedia.");
        await _storage.ref(storagePath).putData(bytes);
      } else {
        final path = platformFile.path;
        if (path == null) throw Exception("Path file tidak tersedia.");
        final file = File(path);
        await _storage.ref(storagePath).putFile(file);
      }

      state = state.copyWith(
        status: BulkReceiptStatus.processing,
        message: 'File berhasil diunggah. Memproses di backend...',
      );

      await _callProcessingFunction(storagePath);
    } catch (e) {
      state = state.copyWith(
        status: BulkReceiptStatus.error,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<void> _callProcessingFunction(String filePath) async {
    try {
      final callable = _functions.httpsCallable('processExcelAndGeneratePdf');
      final result = await callable.call<Map<String, dynamic>>({
        'filePath': filePath,
      });

      // ✅ Perbaikan: hapus ? karena result.data tidak null
      final url = result.data['downloadUrl'] as String?;
      if (url != null) {
        state = state.copyWith(
          status: BulkReceiptStatus.success,
          downloadUrl: url,
          message: 'Proses berhasil! Kwitansi siap diunduh.',
        );
      } else {
        final errorMsg = result.data['error'] as String? ?? 'URL unduhan tidak ditemukan.';
        throw Exception(errorMsg);
      }
    } on FirebaseFunctionsException catch (e) {
      state = state.copyWith(
        status: BulkReceiptStatus.error,
        message: 'Error Cloud Function: [${e.code}] ${e.message}',
      );
    } catch (e) {
      state = state.copyWith(
        status: BulkReceiptStatus.error,
        message: 'Gagal memanggil backend: ${e.toString()}',
      );
    }
  }

  void reset() {
    state = const BulkReceiptState();
  }
}

// 3. Provider
final bulkReceiptProvider = NotifierProvider<BulkReceiptNotifier, BulkReceiptState>(
  BulkReceiptNotifier.new,
);

// 4. UI
class BulkReceiptScreen extends ConsumerWidget {
  const BulkReceiptScreen({super.key});

  // ✅ Perbaikan: _downloadFile sekarang menerima BuildContext
  Future<void> _downloadFile(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat membuka: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bulkReceiptProvider);
    final notifier = ref.read(bulkReceiptProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Kwitansi Massal'),
        actions: [
          if (state.status != BulkReceiptStatus.idle &&
              state.status != BulkReceiptStatus.uploading &&
              state.status != BulkReceiptStatus.processing)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: notifier.reset,
              tooltip: 'Mulai Ulang',
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.receipt_long, size: 80, color: Colors.blueGrey),
              const SizedBox(height: 24),
              _buildStatusWidget(context, state),
              const SizedBox(height: 32),
              _buildButtonWidget(context, state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusWidget(BuildContext context, BulkReceiptState state) {
    final textTheme = Theme.of(context).textTheme;
    switch (state.status) {
      case BulkReceiptStatus.idle:
        return Text(
          state.message ?? 'Silakan unggah file Excel untuk memulai.',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium,
        );
      case BulkReceiptStatus.uploading:
      case BulkReceiptStatus.processing:
        return Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              state.message ?? 'Mohon tunggu...',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            if (state.fileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  state.fileName!,
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      case BulkReceiptStatus.success:
        return Text(
          state.message ?? 'Berhasil!',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(color: Colors.green[700]),
        );
      case BulkReceiptStatus.error:
        return Text(
          state.message ?? 'Terjadi kesalahan.',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(color: Colors.red[700]),
        );
    }
  }

  Widget _buildButtonWidget(BuildContext context, BulkReceiptState state, BulkReceiptNotifier notifier) {
    final isProcessing = state.status == BulkReceiptStatus.uploading ||
        state.status == BulkReceiptStatus.processing;

    if (state.status == BulkReceiptStatus.success) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.download),
        label: const Text('Download Kwitansi'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.green,
        ),
        onPressed: state.downloadUrl != null
            ? () => _downloadFile(context, state.downloadUrl!) // ✅ kirim context
            : null,
      );
    }

    return ElevatedButton.icon(
      icon: const Icon(Icons.upload_file),
      label: const Text('Upload File Excel'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: isProcessing ? null : notifier.pickAndUploadFile,
    );
  }
}