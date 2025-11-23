// lib/scripts/setup_appwrite.dart
// Appwrite Database & Storage Setup Script
//
// Usage:
//   1. Set environment variable: $env:APPWRITE_API_KEY = "your-api-key"
//   2. Run: dart run lib/scripts/setup_appwrite.dart

import 'dart:io';
import 'package:appwrite/appwrite.dart';

// Configuration
const String endpoint = 'https://sgp.cloud.appwrite.io/v1';
const String projectId = '690dc074000d8971b247';
const String databaseId = 'cleanoffice_db';

void main() async {
  print('🚀 Starting Appwrite Setup...\n');

  // Get API key from environment variable
  final apiKey = Platform.environment['APPWRITE_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('❌ Error: APPWRITE_API_KEY environment variable not set!');
    print('\nPlease set it first:');
    print('  PowerShell: \$env:APPWRITE_API_KEY = "your-api-key"');
    print('  CMD: set APPWRITE_API_KEY=your-api-key');
    exit(1);
  }

  // Initialize Appwrite client
  final client = Client()
      .setEndpoint(endpoint)
      .setProject(projectId)
      .setKey(apiKey);

  final databases = Databases(client);
  final storage = Storage(client);

  try {
    // Verify database exists
    print('📊 Verifying database "$databaseId"...');
    try {
      await databases.get(databaseId: databaseId);
      print('✅ Database exists\n');
    } catch (e) {
      print('❌ Database not found. Please create it first in Appwrite Console.');
      exit(1);
    }

    // Create collections
    await _createUsersCollection(databases);
    await _createReportsCollection(databases);
    await _createInventoryCollection(databases);
    await _createRequestsCollection(databases);
    await _createNotificationsCollection(databases);
    await _createDepartmentsCollection(databases);
    await _createStockHistoryCollection(databases);

    // Create storage buckets
    await _createReportsBucket(storage);
    await _createProfilesBucket(storage);
    await _createInventoryBucket(storage);

    print('\n🎉 Setup completed successfully!');
    print('\nVerify in Appwrite Console:');
    print('  https://cloud.appwrite.io/console/project-$projectId');
  } catch (e) {
    print('\n❌ Setup failed: $e');
    exit(1);
  }
}

// ==================== COLLECTIONS ====================

Future<void> _createUsersCollection(Databases databases) async {
  const collectionId = 'users';
  print('📦 Creating collection: $collectionId');

  try {
    // Create collection
    await databases.createCollection(
      databaseId: databaseId,
      collectionId: collectionId,
      name: 'Users',
    );

    // Create attributes
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'userId',
      size: 36,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'email',
      size: 255,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'name',
      size: 255,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'role',
      size: 50,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'departmentId',
      size: 36,
      required: false,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'departmentName',
      size: 255,
      required: false,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'phoneNumber',
      size: 20,
      required: false,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'profileImageUrl',
      size: 2000,
      required: false,
    );
    await databases.createBooleanAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'isActive',
      required: true,
      xdefault: true,
    );
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'createdAt',
      required: true,
    );
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'updatedAt',
      required: false,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'location',
      size: 255,
      required: false,
    );

    // Wait for attributes to be ready
    await Future.delayed(Duration(seconds: 2));

    // Create indexes
    await databases.createIndex(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'email_idx',
      type: IndexType.unique,
      attributes: ['email'],
    );
    await databases.createIndex(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'role_idx',
      type: IndexType.key,
      attributes: ['role'],
    );
    await databases.createIndex(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'department_idx',
      type: IndexType.key,
      attributes: ['departmentId'],
    );

    print('✅ Users collection created\n');
  } catch (e) {
    print('⚠️  Users collection: $e\n');
  }
}

Future<void> _createReportsCollection(Databases databases) async {
  const collectionId = 'reports';
  print('📦 Creating collection: $collectionId');

  try {
    await databases.createCollection(
      databaseId: databaseId,
      collectionId: collectionId,
      name: 'Reports',
    );

    // Create string attributes
    final stringAttrs = {
      'reportId': 36,
      'userId': 36,
      'userName': 255,
      'userEmail': 255,
      'departmentId': 36,
      'departmentName': 255,
      'location': 255,
      'title': 255,
      'description': 5000,
      'imageUrl': 2000,
      'status': 50,
      'priority': 50,
      'cleanerId': 36,
      'cleanerName': 255,
      'completionImageUrl': 2000,
      'verifiedBy': 36,
      'verifiedByName': 255,
      'verificationNotes': 2000,
      'deletedBy': 36,
    };

    for (var entry in stringAttrs.entries) {
      final required = ['reportId', 'userId', 'userName', 'location', 'title', 'description', 'status']
          .contains(entry.key);
      await databases.createStringAttribute(
        databaseId: databaseId,
        collectionId: collectionId,
        key: entry.key,
        size: entry.value,
        required: required,
      );
    }

    // Boolean attribute
    await databases.createBooleanAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'isUrgent',
      required: false,
      xdefault: false,
    );

    // Datetime attributes
    final dateAttrs = ['date', 'assignedAt', 'startedAt', 'completedAt', 'verifiedAt', 'deletedAt'];
    for (var attr in dateAttrs) {
      await databases.createDatetimeAttribute(
        databaseId: databaseId,
        collectionId: collectionId,
        key: attr,
        required: attr == 'date',
      );
    }

    await Future.delayed(Duration(seconds: 2));

    // Create indexes
    await databases.createIndex(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'user_idx',
      type: IndexType.key,
      attributes: ['userId'],
    );
    await databases.createIndex(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'cleaner_idx',
      type: IndexType.key,
      attributes: ['cleanerId'],
    );
    await databases.createIndex(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'status_idx',
      type: IndexType.key,
      attributes: ['status'],
    );
    await databases.createIndex(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'date_idx',
      type: IndexType.key,
      attributes: ['date'],
      orders: ['DESC'],
    );

    print('✅ Reports collection created\n');
  } catch (e) {
    print('⚠️  Reports collection: $e\n');
  }
}

Future<void> _createInventoryCollection(Databases databases) async {
  const collectionId = 'inventory';
  print('📦 Creating collection: $collectionId');

  try {
    await databases.createCollection(
      databaseId: databaseId,
      collectionId: collectionId,
      name: 'Inventory',
    );

    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'itemId',
      size: 36,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'name',
      size: 255,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'category',
      size: 100,
      required: true,
    );
    await databases.createIntegerAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'quantity',
      required: true,
      min: 0,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'unit',
      size: 50,
      required: true,
    );
    await databases.createIntegerAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'minStock',
      required: true,
      min: 0,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'location',
      size: 255,
      required: false,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'imageUrl',
      size: 2000,
      required: false,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'description',
      size: 2000,
      required: false,
    );
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'lastRestocked',
      required: false,
    );
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'createdAt',
      required: true,
    );
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'updatedAt',
      required: false,
    );
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'deletedAt',
      required: false,
    );

    await Future.delayed(Duration(seconds: 2));

    await databases.createIndex(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'category_idx',
      type: IndexType.key,
      attributes: ['category'],
    );

    print('✅ Inventory collection created\n');
  } catch (e) {
    print('⚠️  Inventory collection: $e\n');
  }
}

Future<void> _createRequestsCollection(Databases databases) async {
  const collectionId = 'requests';
  print('📦 Creating collection: $collectionId');

  try {
    await databases.createCollection(
      databaseId: databaseId,
      collectionId: collectionId,
      name: 'Requests',
    );

    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'requestId',
      size: 36,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'itemId',
      size: 36,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'itemName',
      size: 255,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'requestedBy',
      size: 36,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'requestedByName',
      size: 255,
      required: true,
    );
    await databases.createIntegerAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'quantity',
      required: true,
      min: 1,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'reason',
      size: 2000,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'status',
      size: 50,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'approvedBy',
      size: 36,
      required: false,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'approvedByName',
      size: 255,
      required: false,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'approvalNotes',
      size: 2000,
      required: false,
    );
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'requestDate',
      required: true,
    );
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'approvedAt',
      required: false,
    );
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'fulfilledAt',
      required: false,
    );

    await Future.delayed(Duration(seconds: 2));

    await databases.createIndex(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'status_idx',
      type: IndexType.key,
      attributes: ['status'],
    );

    print('✅ Requests collection created\n');
  } catch (e) {
    print('⚠️  Requests collection: $e\n');
  }
}

Future<void> _createNotificationsCollection(Databases databases) async {
  const collectionId = 'notifications';
  print('📦 Creating collection: $collectionId');

  try {
    await databases.createCollection(
      databaseId: databaseId,
      collectionId: collectionId,
      name: 'Notifications',
    );

    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'notificationId',
      size: 36,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'userId',
      size: 36,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'title',
      size: 255,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'body',
      size: 2000,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'type',
      size: 50,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'data',
      size: 5000,
      required: false,
    );
    await databases.createBooleanAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'isRead',
      required: true,
      xdefault: false,
    );
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'createdAt',
      required: true,
    );

    await Future.delayed(Duration(seconds: 2));

    await databases.createIndex(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'user_idx',
      type: IndexType.key,
      attributes: ['userId'],
    );

    print('✅ Notifications collection created\n');
  } catch (e) {
    print('⚠️  Notifications collection: $e\n');
  }
}

Future<void> _createDepartmentsCollection(Databases databases) async {
  const collectionId = 'departments';
  print('📦 Creating collection: $collectionId');

  try {
    await databases.createCollection(
      databaseId: databaseId,
      collectionId: collectionId,
      name: 'Departments',
    );

    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'departmentId',
      size: 36,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'name',
      size: 255,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'description',
      size: 2000,
      required: false,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'headId',
      size: 36,
      required: false,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'headName',
      size: 255,
      required: false,
    );
    await databases.createBooleanAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'isActive',
      required: true,
      xdefault: true,
    );
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'createdAt',
      required: true,
    );

    await Future.delayed(Duration(seconds: 2));

    await databases.createIndex(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'name_idx',
      type: IndexType.unique,
      attributes: ['name'],
    );

    print('✅ Departments collection created\n');
  } catch (e) {
    print('⚠️  Departments collection: $e\n');
  }
}

Future<void> _createStockHistoryCollection(Databases databases) async {
  const collectionId = 'stock_history';
  print('📦 Creating collection: $collectionId');

  try {
    await databases.createCollection(
      databaseId: databaseId,
      collectionId: collectionId,
      name: 'Stock History',
    );

    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'historyId',
      size: 36,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'itemId',
      size: 36,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'itemName',
      size: 255,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'action',
      size: 50,
      required: true,
    );
    await databases.createIntegerAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'quantityChange',
      required: true,
    );
    await databases.createIntegerAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'quantityBefore',
      required: true,
    );
    await databases.createIntegerAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'quantityAfter',
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'userId',
      size: 36,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'userName',
      size: 255,
      required: true,
    );
    await databases.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'notes',
      size: 2000,
      required: false,
    );
    await databases.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'createdAt',
      required: true,
    );

    await Future.delayed(Duration(seconds: 2));

    await databases.createIndex(
      databaseId: databaseId,
      collectionId: collectionId,
      key: 'item_idx',
      type: IndexType.key,
      attributes: ['itemId'],
    );

    print('✅ Stock History collection created\n');
  } catch (e) {
    print('⚠️  Stock History collection: $e\n');
  }
}

// ==================== STORAGE BUCKETS ====================

Future<void> _createReportsBucket(Storage storage) async {
  const bucketId = 'reports';
  print('🗂️  Creating bucket: $bucketId');

  try {
    await storage.createBucket(
      bucketId: bucketId,
      name: 'Reports Images',
      permissions: [
        Permission.read(Role.users()),
        Permission.create(Role.users()),
      ],
      fileSecurity: true,
      enabled: true,
      maximumFileSize: 5242880, // 5MB
      allowedFileExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      compression: Compression.gzip,
      encryption: true,
      antivirus: true,
    );

    print('✅ Reports bucket created\n');
  } catch (e) {
    print('⚠️  Reports bucket: $e\n');
  }
}

Future<void> _createProfilesBucket(Storage storage) async {
  const bucketId = 'profiles';
  print('🗂️  Creating bucket: $bucketId');

  try {
    await storage.createBucket(
      bucketId: bucketId,
      name: 'Profile Pictures',
      permissions: [
        Permission.read(Role.users()),
        Permission.create(Role.users()),
      ],
      fileSecurity: true,
      enabled: true,
      maximumFileSize: 2097152, // 2MB
      allowedFileExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      compression: Compression.gzip,
      encryption: true,
      antivirus: true,
    );

    print('✅ Profiles bucket created\n');
  } catch (e) {
    print('⚠️  Profiles bucket: $e\n');
  }
}

Future<void> _createInventoryBucket(Storage storage) async {
  const bucketId = 'inventory';
  print('🗂️  Creating bucket: $bucketId');

  try {
    await storage.createBucket(
      bucketId: bucketId,
      name: 'Inventory Images',
      permissions: [
        Permission.read(Role.users()),
        Permission.create(Role.users()),
      ],
      fileSecurity: true,
      enabled: true,
      maximumFileSize: 5242880, // 5MB
      allowedFileExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      compression: Compression.gzip,
      encryption: true,
      antivirus: true,
    );

    print('✅ Inventory bucket created\n');
  } catch (e) {
    print('⚠️  Inventory bucket: $e\n');
  }
}
