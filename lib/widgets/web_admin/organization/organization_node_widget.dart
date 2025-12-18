// lib/widgets/web_admin/organization/organization_node_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/master/organization.dart';
import '../../../providers/riverpod/organization_stats_provider.dart';
import 'organization_tree_builder.dart';

class OrganizationNodeWidget extends ConsumerStatefulWidget {
  final OrganizationNode node;
  final Function(Organization) onEdit;
  final Function(Organization) onDelete;
  final Function(Organization) onTap;
  final bool isSelected;

  const OrganizationNodeWidget({
    super.key,
    required this.node,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  ConsumerState<OrganizationNodeWidget> createState() => _OrganizationNodeWidgetState();
}

class _OrganizationNodeWidgetState extends ConsumerState<OrganizationNodeWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final org = node.data;
    final hasChildren = node.children.isNotEmpty;

    // Get Stats
    final statsAsync = ref.watch(statsForOrganizationProvider(org.id));
    final stats = statsAsync.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Node Card
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
               // Connector for child nodes (if depth > 0)
              if (node.level > 0) ...[
                 SizedBox(
                  width: 24.0,
                  height: 1.0,
                  child: Container(color: Colors.grey[300]),
                ),
              ],
              
              // Actual Card (Taken Full Width minus connector)
              Expanded(
                child: InkWell(
                  onTap: () => widget.onTap(org),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isSelected ? AppTheme.primary.withOpacity(0.05) : Colors.white,
                      border: Border.all(
                        color: widget.isSelected ? AppTheme.primary : Colors.grey[200]!,
                        width: widget.isSelected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      // Left border accent based on type
                      boxShadow: [
                         if (widget.isSelected)
                           BoxShadow(color: AppTheme.primary.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          // Left Accent Bar
                          Container(
                            width: 4,
                            decoration: BoxDecoration(
                              color: _getTypeColor(org.type),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                          ),
                          
                          // Toggle Button (Moved Inside)
                          if (hasChildren)
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: IconButton(
                                icon: Icon(
                                  _isExpanded ? Icons.expand_less : Icons.expand_more, // Use chevron for cleaner inside-look
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                              ),
                            )
                          else
                            const SizedBox(width: 16), // Spacer inside

                          // Icon (Only if no children? Or keeps icon?)
                          // Maybe remove the big icon if we have chevron? No, keep it for type.
                          Icon(_getTypeIcon(org.type), color: _getTypeColor(org.type), size: 20),
                          const SizedBox(width: 12),
                          
                          // Content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    org.name,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _buildBadge(org.type.toUpperCase(), Colors.grey[200]!, Colors.grey[700]!),
                                      const SizedBox(width: 8),
                                      Text(
                                        org.code,
                                        style: GoogleFonts.sourceCodePro(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Stats Badges
                          if (stats != null) ...[
                            _buildStatBadge(Icons.people_outline, '${stats.employeeCount}', Colors.blue),
                            const SizedBox(width: 8),
                            _buildStatBadge(Icons.inventory_2_outlined, '${stats.assetCount}', Colors.orange),
                            const SizedBox(width: 16),
                          ],
                          
                          // Actions (only show on hover ideally, but for now always)
                          // Only if needed immediately, but context menu might be cleaner
                          // Let's rely on Drawer for detailed actions, but keep basic edit here
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                            onPressed: () => widget.onEdit(org),
                            tooltip: 'Edit Unit',
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Children (if expanded)
        if (_isExpanded && hasChildren)
          Padding(
            padding: EdgeInsets.only(left: hasChildren ? 12.0 : 0), // Indent for children
            child: Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey[300]!, width: 1)),
              ),
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                children: node.children
                    .map((childNode) => OrganizationNodeWidget(
                          node: childNode,
                          onEdit: widget.onEdit,
                          onDelete: widget.onDelete,
                          onTap: widget.onTap,
                          isSelected: widget.isSelected, // Only parent is selected in this logic, update if needed
                        ))
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  Widget _buildStatBadge(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'dinas': return AppTheme.primary;
      case 'bidang': return Colors.blue[600]!;
      case 'seksi': return Colors.green[600]!;
      case 'upt': return Colors.orange[700]!;
      default: return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'dinas': return Icons.account_balance;
      case 'bidang': return Icons.business;
      case 'seksi': return Icons.groups;
      case 'upt': return Icons.store;
      default: return Icons.domain;
    }
  }
}
