// lib/services/barcode_lookup_service.dart
// Service for looking up product information by barcode

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Product information returned from barcode lookup
class ProductInfo {
  final String barcode;
  final String? brand;
  final String? name;
  final String? description;
  final String? category;
  final String? imageUrl;

  ProductInfo({
    required this.barcode,
    this.brand,
    this.name,
    this.description,
    this.category,
    this.imageUrl,
  });

  /// Get display name (brand + name or just name)
  String get displayName {
    if (brand != null && name != null) {
      return '$brand $name';
    }
    return name ?? barcode;
  }

  factory ProductInfo.fromUpcItemDb(Map<String, dynamic> json) {
    final items = json['items'] as List?;
    if (items == null || items.isEmpty) {
      return ProductInfo(barcode: json['code'] ?? '');
    }
    
    final item = items.first as Map<String, dynamic>;
    return ProductInfo(
      barcode: item['upc'] ?? item['ean'] ?? '',
      brand: item['brand'],
      name: item['title'],
      description: item['description'],
      category: item['category'],
      imageUrl: (item['images'] as List?)?.firstOrNull as String?,
    );
  }
}

/// Service for looking up product information by barcode
class BarcodeLookupService {
  // UPC Item DB API (Free tier: 100 lookups/day)
  static const String _baseUrl = 'https://api.upcitemdb.com/prod/trial/lookup';

  /// Lookup product by barcode
  /// Returns ProductInfo if found, null if not found or error
  static Future<ProductInfo?> lookup(String barcode) async {
    try {
      final uri = Uri.parse('$_baseUrl?upc=$barcode');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Check if product found
        if (data['code'] == 'OK' && data['total'] > 0) {
          return ProductInfo.fromUpcItemDb(data);
        }
        
        // Product not found in database
        return null;
      } else if (response.statusCode == 429) {
        // Rate limit exceeded
        debugPrint('Barcode API rate limit exceeded');
        return null;
      } else {
        debugPrint('Barcode API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Barcode lookup error: $e');
      return null;
    }
  }

  /// Map category from API to internal category code
  static String? mapToInternalCategory(String? apiCategory) {
    if (apiCategory == null) return null;
    
    final lower = apiCategory.toLowerCase();
    
    // Electronics
    if (lower.contains('computer') || lower.contains('laptop') || 
        lower.contains('electronic') || lower.contains('phone')) {
      return 'elektronik';
    }
    
    // Office Supplies
    if (lower.contains('office') || lower.contains('paper') || 
        lower.contains('stationery')) {
      return 'alat_kantor';
    }
    
    // Cleaning
    if (lower.contains('clean') || lower.contains('soap') || 
        lower.contains('sanitizer')) {
      return 'kebersihan';
    }
    
    // Furniture
    if (lower.contains('furniture') || lower.contains('chair') || 
        lower.contains('desk') || lower.contains('table')) {
      return 'furniture';
    }
    
    return null;
  }
}
