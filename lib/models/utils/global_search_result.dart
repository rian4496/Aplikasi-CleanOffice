import 'package:flutter/material.dart';

enum SearchResultType {
  asset,
  budget,
  procurement,
  employee,
  inventory,
}

class GlobalSearchResult {
  final String id;
  final String title;
  final String subtitle;
  final SearchResultType type;
  final String route;
  final Map<String, dynamic>? metadata;

  const GlobalSearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.route,
    this.metadata,
  });

  IconData get icon {
    switch (type) {
      case SearchResultType.asset:
        return Icons.inventory_2_outlined;
      case SearchResultType.budget:
        return Icons.account_balance_wallet_outlined;
      case SearchResultType.procurement:
        return Icons.shopping_cart_outlined;
      case SearchResultType.employee:
        return Icons.person_outline;
      case SearchResultType.inventory:
        return Icons.category_outlined;
    }
  }

  Color get color {
    switch (type) {
      case SearchResultType.asset:
        return Colors.blue;
      case SearchResultType.budget:
        return Colors.green;
      case SearchResultType.procurement:
        return Colors.orange;
      case SearchResultType.employee:
        return Colors.purple;
      case SearchResultType.inventory:
        return Colors.teal;
    }
  }
}
