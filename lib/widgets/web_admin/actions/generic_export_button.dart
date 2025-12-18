import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/export_config.dart';
import '../../../services/export_service.dart';

class GenericExportButton<T> extends ConsumerStatefulWidget {
  final String title;
  final List<String> headers;
  final List<T> data;
  final List<dynamic> Function(T item) rowBuilder;
  final bool isLoading;

  const GenericExportButton({
    super.key,
    required this.title,
    required this.headers,
    required this.data,
    required this.rowBuilder,
    this.isLoading = false,
  });

  @override
  ConsumerState<GenericExportButton<T>> createState() => _GenericExportButtonState<T>();
}

class _GenericExportButtonState<T> extends ConsumerState<GenericExportButton<T>> {
  bool _isExporting = false;

  Future<void> _handleExport(ExportFormat format) async {
    setState(() => _isExporting = true);
    
    // Prepare data
    final rows = widget.data.map((item) => widget.rowBuilder(item)).toList();
    
    final result = await ref.read(exportServiceProvider).exportGenericData(
      title: widget.title,
      headers: widget.headers,
      data: rows,
      format: format,
    );

    if (!mounted) return;
    setState(() => _isExporting = false);

    if (result.success) {
      final message = result.fileName != null && result.fileName!.contains('Print Dialog')
          ? result.fileName!
          : 'Export berhasil: ${result.fileName}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export gagal: ${result.error}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ExportFormat>(
      icon: _isExporting 
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
        : const Icon(Icons.download, color: Colors.grey),
      tooltip: 'Export Data',
      enabled: !widget.isLoading && !_isExporting && widget.data.isNotEmpty,
      onSelected: _handleExport,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: ExportFormat.excel,
          child: Row(
            children: [
              Icon(Icons.table_chart, color: Colors.green),
              SizedBox(width: 8),
              Text('Export Excel (.xlsx)'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: ExportFormat.pdf,
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red),
              SizedBox(width: 8),
              Text('Export PDF (.pdf)'),
            ],
          ),
        ),
      ],
    );
  }
}
