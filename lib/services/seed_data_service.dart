// lib/services/seed_data_service.dart
// Service untuk generate sample data inventory

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SeedDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate sample inventory items
  Future<void> generateSampleInventory({
    required String userId,
    required String userName,
  }) async {
    try {
      final now = DateTime.now();
      final batch = _firestore.batch();

      // Sample data dengan berbagai status stok
      final sampleItems = [
        {
          'id': 'item_${now.millisecondsSinceEpoch}_001',
          'name': 'Sapu Ijuk',
          'category': 'alat',
          'description': 'Sapu untuk membersihkan lantai ruangan',
          'unit': 'pcs',
          'currentStock': 25,
          'minStock': 5,
          'maxStock': 100,
          'location': 'Gudang A - Rak 1',
          'imageUrl': '',
        },
        {
          'id': 'item_${now.millisecondsSinceEpoch}_002',
          'name': 'Kain Pel Microfiber',
          'category': 'alat',
          'description': 'Kain pel untuk mengepel lantai',
          'unit': 'pcs',
          'currentStock': 15,
          'minStock': 8,
          'maxStock': 50,
          'location': 'Gudang A - Rak 2',
          'imageUrl': '',
        },
        {
          'id': 'item_${now.millisecondsSinceEpoch}_003',
          'name': 'Sabun Cuci Piring',
          'category': 'consumable',
          'description': 'Sabun cuci untuk dapur kantor',
          'unit': 'botol',
          'currentStock': 3, // LOW STOCK - untuk testing alert
          'minStock': 10,
          'maxStock': 100,
          'location': 'Gudang B - Rak 1',
          'imageUrl': '',
        },
        {
          'id': 'item_${now.millisecondsSinceEpoch}_004',
          'name': 'Pewangi Ruangan',
          'category': 'consumable',
          'description': 'Spray pewangi untuk ruangan kantor',
          'unit': 'kaleng',
          'currentStock': 0, // OUT OF STOCK - untuk testing alert
          'minStock': 5,
          'maxStock': 50,
          'location': 'Gudang B - Rak 2',
          'imageUrl': '',
        },
        {
          'id': 'item_${now.millisecondsSinceEpoch}_005',
          'name': 'Masker N95',
          'category': 'ppe',
          'description': 'Masker pelindung untuk petugas kebersihan',
          'unit': 'box',
          'currentStock': 8, // MEDIUM STOCK
          'minStock': 10,
          'maxStock': 100,
          'location': 'Gudang C - Rak 1',
          'imageUrl': '',
        },
        {
          'id': 'item_${now.millisecondsSinceEpoch}_006',
          'name': 'Sarung Tangan Karet',
          'category': 'ppe',
          'description': 'Sarung tangan untuk petugas cleaning',
          'unit': 'pasang',
          'currentStock': 45, // HIGH STOCK
          'minStock': 20,
          'maxStock': 200,
          'location': 'Gudang C - Rak 2',
          'imageUrl': '',
        },
        {
          'id': 'item_${now.millisecondsSinceEpoch}_007',
          'name': 'Cairan Pembersih Lantai',
          'category': 'consumable',
          'description': 'Cairan pembersih untuk lantai keramik',
          'unit': 'liter',
          'currentStock': 12, // MEDIUM STOCK
          'minStock': 15,
          'maxStock': 100,
          'location': 'Gudang B - Rak 3',
          'imageUrl': '',
        },
        {
          'id': 'item_${now.millisecondsSinceEpoch}_008',
          'name': 'Tissue Gulung',
          'category': 'consumable',
          'description': 'Tissue untuk toilet kantor',
          'unit': 'roll',
          'currentStock': 120, // HIGH STOCK
          'minStock': 50,
          'maxStock': 500,
          'location': 'Gudang A - Rak 5',
          'imageUrl': '',
        },
      ];

      // Add each item to batch
      for (final item in sampleItems) {
        final itemData = {
          ...item,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'createdBy': userId,
          'createdByName': userName,
        };

        final docRef = _firestore.collection('inventory').doc(item['id'] as String);
        batch.set(docRef, itemData);
      }

      // Commit batch
      await batch.commit();

      debugPrint('✅ Generated ${sampleItems.length} sample inventory items');
    } catch (e) {
      debugPrint('❌ Error generating sample data: $e');
      rethrow;
    }
  }

  /// Clear all inventory data (untuk reset)
  Future<void> clearAllInventory() async {
    try {
      final snapshot = await _firestore.collection('inventory').get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('✅ Cleared all inventory data');
    } catch (e) {
      debugPrint('❌ Error clearing inventory: $e');
      rethrow;
    }
  }

  /// Get count of inventory items
  Future<int> getInventoryCount() async {
    try {
      final snapshot = await _firestore.collection('inventory').get();
      return snapshot.size;
    } catch (e) {
      debugPrint('❌ Error getting count: $e');
      return 0;
    }
  }
}
