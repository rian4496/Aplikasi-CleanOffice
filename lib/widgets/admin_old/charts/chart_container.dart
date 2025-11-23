// lib/widgets/admin/charts/chart_container.dart
// Container widget for consistent chart styling

import 'package:flutter/material.dart';

class ChartContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final double height;
  final VoidCallback? onExport;
  final Widget? trailing;

  const ChartContainer({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.height = 400,
    this.onExport,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: height,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (trailing != null) trailing!,
        if (onExport != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Chart',
            onPressed: onExport,
            iconSize: 20,
          ),
        ],
      ],
    );
  }
}
