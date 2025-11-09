// lib/data/sample_inventory.dart
// Sample inventory data

import '../models/inventory_item.dart';
import '../services/inventory_service.dart';

class SampleInventory {
  static List<InventoryItem> getSampleItems() {
    final now = DateTime.now();
    
    return [
      // ALAT KEBERSIHAN
      InventoryItem(
        id: 'inv_001',
        name: 'Sapu',
        category: 'alat',
        currentStock: 15,
        maxStock: 20,
        minStock: 5,
        unit: 'pcs',
        description: 'Sapu lantai standar',
        createdAt: now,
        updatedAt: now,
      ),
      InventoryItem(
        id: 'inv_002',
        name: 'Pel',
        category: 'alat',
        currentStock: 8,
        maxStock: 10,
        minStock: 3,
        unit: 'pcs',
        description: 'Pel basah untuk lantai',
        createdAt: now,
        updatedAt: now,
      ),
      InventoryItem(
        id: 'inv_003',
        name: 'Kain Lap',
        category: 'alat',
        currentStock: 25,
        maxStock: 30,
        minStock: 10,
        unit: 'pcs',
        description: 'Kain lap microfiber',
        createdAt: now,
        updatedAt: now,
      ),
      InventoryItem(
        id: 'inv_004',
        name: 'Ember',
        category: 'alat',
        currentStock: 6,
        maxStock: 10,
        minStock: 3,
        unit: 'pcs',
        description: 'Ember plastik 10L',
        createdAt: now,
        updatedAt: now,
      ),
      InventoryItem(
        id: 'inv_005',
        name: 'Sikat Toilet',
        category: 'alat',
        currentStock: 4,
        maxStock: 10,
        minStock: 3,
        unit: 'pcs',
        description: 'Sikat pembersih toilet',
        createdAt: now,
        updatedAt: now,
      ),
      
      // BAHAN HABIS PAKAI
      InventoryItem(
        id: 'inv_006',
        name: 'Sabun Cuci',
        category: 'consumable',
        currentStock: 2,
        maxStock: 20,
        minStock: 5,
        unit: 'botol',
        description: 'Sabun cuci piring dan lantai',
        createdAt: now,
        updatedAt: now,
      ),
      InventoryItem(
        id: 'inv_007',
        name: 'Disinfektan',
        category: 'consumable',
        currentStock: 0,
        maxStock: 15,
        minStock: 3,
        unit: 'botol',
        description: 'Disinfektan spray',
        createdAt: now,
        updatedAt: now,
      ),
      InventoryItem(
        id: 'inv_008',
        name: 'Pembersih Lantai',
        category: 'consumable',
        currentStock: 8,
        maxStock: 15,
        minStock: 4,
        unit: 'botol',
        description: 'Cairan pembersih lantai',
        createdAt: now,
        updatedAt: now,
      ),
      InventoryItem(
        id: 'inv_009',
        name: 'Pewangi Ruangan',
        category: 'consumable',
        currentStock: 12,
        maxStock: 20,
        minStock: 5,
        unit: 'botol',
        description: 'Spray pewangi ruangan',
        createdAt: now,
        updatedAt: now,
      ),
      InventoryItem(
        id: 'inv_010',
        name: 'Tisu',
        category: 'consumable',
        currentStock: 18,
        maxStock: 30,
        minStock: 10,
        unit: 'box',
        description: 'Tisu toilet dan tangan',
        createdAt: now,
        updatedAt: now,
      ),
      
      // ALAT PELINDUNG DIRI
      InventoryItem(
        id: 'inv_011',
        name: 'Sarung Tangan',
        category: 'ppe',
        currentStock: 15,
        maxStock: 25,
        minStock: 8,
        unit: 'pasang',
        description: 'Sarung tangan karet',
        createdAt: now,
        updatedAt: now,
      ),
      InventoryItem(
        id: 'inv_012',
        name: 'Masker',
        category: 'ppe',
        currentStock: 35,
        maxStock: 50,
        minStock: 15,
        unit: 'pcs',
        description: 'Masker medis sekali pakai',
        createdAt: now,
        updatedAt: now,
      ),
      InventoryItem(
        id: 'inv_013',
        name: 'Apron',
        category: 'ppe',
        currentStock: 7,
        maxStock: 10,
        minStock: 3,
        unit: 'pcs',
        description: 'Apron plastik waterproof',
        createdAt: now,
        updatedAt: now,
      ),
      InventoryItem(
        id: 'inv_014',
        name: 'Sepatu Boots',
        category: 'ppe',
        currentStock: 5,
        maxStock: 8,
        minStock: 2,
        unit: 'pasang',
        description: 'Sepatu boots anti slip',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Populate Firestore with sample data
  static Future<void> populateFirestore() async {
    final service = InventoryService();
    final items = getSampleItems();
    
    for (final item in items) {
      await service.addItem(item);
    }
  }
}
