// lib/services/seed_data_service.dart
// Service untuk generate sample data inventory - Using Appwrite

import 'package:flutter/foundation.dart';
import '../services/appwrite_database_service.dart';
import '../models/inventory_item.dart';

class SeedDataService {
  final AppwriteDatabaseService _dbService = AppwriteDatabaseService();

  /// Generate sample inventory items
  Future<void> generateSampleInventory({
    required String userId,
    required String userName,
  }) async {
    try {
      final now = DateTime.now();

      // Sample data dengan berbagai status stok
      final sampleItems = [
        InventoryItem(
          id: 'item_${now.millisecondsSinceEpoch}_001',
          name: 'Sapu Ijuk',
          category: 'alat',
          description: 'Sapu untuk membersihkan lantai ruangan',
          unit: 'pcs',
          currentStock: 25,
          minStock: 5,
          maxStock: 100,
          imageUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
        InventoryItem(
          id: 'item_${now.millisecondsSinceEpoch}_002',
          name: 'Kain Pel Microfiber',
          category: 'alat',
          description: 'Kain pel untuk mengepel lantai',
          unit: 'pcs',
          currentStock: 15,
          minStock: 8,
          maxStock: 50,
          imageUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
        InventoryItem(
          id: 'item_${now.millisecondsSinceEpoch}_003',
          name: 'Sabun Cuci Piring',
          category: 'consumable',
          description: 'Sabun cuci untuk dapur kantor',
          unit: 'botol',
          currentStock: 3, // LOW STOCK - untuk testing alert
          minStock: 10,
          maxStock: 100,
          imageUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
        InventoryItem(
          id: 'item_${now.millisecondsSinceEpoch}_004',
          name: 'Pewangi Ruangan',
          category: 'consumable',
          description: 'Spray pewangi untuk ruangan kantor',
          unit: 'kaleng',
          currentStock: 0, // OUT OF STOCK - untuk testing alert
          minStock: 5,
          maxStock: 50,
          imageUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
        InventoryItem(
          id: 'item_${now.millisecondsSinceEpoch}_005',
          name: 'Masker N95',
          category: 'ppe',
          description: 'Masker pelindung untuk petugas kebersihan',
          unit: 'box',
          currentStock: 8, // MEDIUM STOCK
          minStock: 10,
          maxStock: 100,
          imageUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
        InventoryItem(
          id: 'item_${now.millisecondsSinceEpoch}_006',
          name: 'Sarung Tangan Karet',
          category: 'ppe',
          description: 'Sarung tangan untuk petugas cleaning',
          unit: 'pasang',
          currentStock: 45, // HIGH STOCK
          minStock: 20,
          maxStock: 200,
          imageUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
        InventoryItem(
          id: 'item_${now.millisecondsSinceEpoch}_007',
          name: 'Cairan Pembersih Lantai',
          category: 'consumable',
          description: 'Cairan pembersih untuk lantai keramik',
          unit: 'liter',
          currentStock: 12, // MEDIUM STOCK
          minStock: 15,
          maxStock: 100,
          imageUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
        InventoryItem(
          id: 'item_${now.millisecondsSinceEpoch}_008',
          name: 'Tissue Gulung',
          category: 'consumable',
          description: 'Tissue untuk toilet kantor',
          unit: 'roll',
          currentStock: 120, // HIGH STOCK
          minStock: 50,
          maxStock: 500,
          imageUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Add each item using Appwrite
      for (final item in sampleItems) {
        await _dbService.createInventoryItem(item);
      }

      debugPrint('Generated ${sampleItems.length} sample inventory items');
    } catch (e) {
      debugPrint('Error generating sample data: $e');
      rethrow;
    }
  }

  /// Clear all inventory data (untuk reset)
  Future<void> clearAllInventory() async {
    try {
      // Get all inventory items
      final items = await _dbService.getAllInventoryItems().first;

      // Soft delete each item
      for (final item in items) {
        await _dbService.softDeleteInventoryItem(item.id);
      }

      debugPrint('Cleared all inventory data');
    } catch (e) {
      debugPrint('Error clearing inventory: $e');
      rethrow;
    }
  }

  /// Get count of inventory items
  Future<int> getInventoryCount() async {
    try {
      final items = await _dbService.getAllInventoryItems().first;
      return items.length;
    } catch (e) {
      debugPrint('Error getting count: $e');
      return 0;
    }
  }
}
