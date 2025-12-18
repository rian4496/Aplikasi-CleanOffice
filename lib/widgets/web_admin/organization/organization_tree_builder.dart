// lib/widgets/web_admin/organization/organization_tree_builder.dart

import '../../../models/master/organization.dart';

class OrganizationNode {
  final Organization data;
  final List<OrganizationNode> children;
  final int level;

  OrganizationNode({
    required this.data,
    this.children = const [],
    this.level = 0,
  });
}

class OrganizationTreeBuilder {
  /// Builds a list of root nodes with nested children from a flat list
  static List<OrganizationNode> buildTree(List<Organization> flatList) {
    if (flatList.isEmpty) return [];

    // 1. Sort by code first to ensure order
    flatList.sort((a, b) => a.code.compareTo(b.code));

    // 2. Map ID to Node for easy lookup
    final nodeMap = <String, OrganizationNode>{};
    final rootNodes = <OrganizationNode>[];

    // Create all nodes first (without children)
    for (var org in flatList) {
      // Temporary level 0
      nodeMap[org.id] = OrganizationNode(data: org, children: []); 
    }

    // 3. Link Parents and Children
    for (var org in flatList) {
      final node = nodeMap[org.id]!;
      
      if (org.parentId != null && nodeMap.containsKey(org.parentId)) {
        // Child: Add to parent's children list
        final parent = nodeMap[org.parentId]!;
        
        // Use a new Node instance to update level
        final updatedNode = OrganizationNode(
          data: node.data,
          children: node.children,
          level: parent.level + 1,
        );
        nodeMap[org.id] = updatedNode; // Update map reference
        
        // We have to mutate the parent's children list
        // Since OrganizationNode.children is final List, we need to make it mutable in implementation 
        // or just use a helper class that is mutable during build
        // Let's simpler approach: Use a mutable builder class internally
      } else {
        // Root: Add to root list
        rootNodes.add(node);
      }
    }
    
    // The above loop has issues with immutable classes and updating levels recursively.
    // Let's try a recursive build approach instead, which is cleaner.
    
    return _buildRecursive(flatList, null, 0);
  }

  static List<OrganizationNode> _buildRecursive(
    List<Organization> allItems,
    String? parentId,
    int level,
  ) {
    // Find all items that match this parentId
    final directChildren = allItems.where((item) => item.parentId == parentId).toList();
    
    // Sort them
    directChildren.sort((a, b) => a.code.compareTo(b.code));

    return directChildren.map((item) {
      final children = _buildRecursive(allItems, item.id, level + 1);
      return OrganizationNode(
        data: item,
        children: children,
        level: level,
      );
    }).toList();
  }
}
