// lib/core/config/appwrite_config.dart

import 'package:logging/logging.dart';

/// Appwrite Configuration
///
/// This class contains all Appwrite-related configuration
/// including endpoint, project ID, and collection/bucket IDs
class AppwriteConfig {
  // Private constructor to prevent instantiation
  AppwriteConfig._();

  // ==================== CORE CONFIG ====================

  /// Appwrite endpoint URL
  /// Singapore region: https://sgp.cloud.appwrite.io/v1
  static String get endpoint => 'https://sgp.cloud.appwrite.io/v1';

  /// Appwrite Project ID
  static String get projectId => '690dc074000d8971b247';

  // ==================== DATABASE CONFIG ====================

  /// Main database ID
  /// Note: This must match the actual Database ID in Appwrite Console
  /// (not the display name, but the ID shown in the URL)
  static const String databaseId = '691868630007af45a94b';

  // Collection IDs
  static const String usersCollectionId = 'users';
  static const String reportsCollectionId = 'reports';
  static const String inventoryCollectionId = 'inventory';
  static const String stockRequestsCollectionId = 'stock_requests';
  static const String serviceRequestsCollectionId = 'service_requests';
  static const String notificationsCollectionId = 'notifications';
  static const String departmentsCollectionId = 'departments';
  static const String stockHistoryCollectionId = 'stock_history';

  // Chat Collection IDs
  static const String conversationsCollectionId = 'conversations';
  static const String messagesCollectionId = 'messages';
  static const String typingIndicatorsCollectionId = 'typing_indicators';
  static const String userPresenceCollectionId = 'user_presence';

  // ==================== STORAGE CONFIG ====================

  /// Storage bucket ID (Free tier: only 1 bucket allowed)
  /// We use folder structure to organize files:
  /// - reports/ for report images
  /// - profiles/ for profile pictures
  /// - inventory/ for inventory images
  static const String mainBucketId = 'cleanoffice_storage';

  // Folder paths within bucket
  static const String reportsFolder = 'reports';
  static const String profilesFolder = 'profiles';
  static const String inventoryFolder = 'inventory';
  static const String chatFolder = 'chat';

  // ==================== REALTIME CONFIG ====================

  /// Realtime channels for subscriptions
  static String get reportsChannel =>
      'databases.$databaseId.collections.$reportsCollectionId.documents';

  static String get notificationsChannel =>
      'databases.$databaseId.collections.$notificationsCollectionId.documents';

  static String get inventoryChannel =>
      'databases.$databaseId.collections.$inventoryCollectionId.documents';

  static String get stockRequestsChannel =>
      'databases.$databaseId.collections.$stockRequestsCollectionId.documents';

  static String get serviceRequestsChannel =>
      'databases.$databaseId.collections.$serviceRequestsCollectionId.documents';

  // Chat channels
  static String get conversationsChannel =>
      'databases.$databaseId.collections.$conversationsCollectionId.documents';

  static String get messagesChannel =>
      'databases.$databaseId.collections.$messagesCollectionId.documents';

  static String get typingIndicatorsChannel =>
      'databases.$databaseId.collections.$typingIndicatorsCollectionId.documents';

  static String get userPresenceChannel =>
      'databases.$databaseId.collections.$userPresenceCollectionId.documents';

  // ==================== HELPER METHODS ====================

  /// Get document channel for specific document
  static String getDocumentChannel(String collectionId, String documentId) {
    return 'databases.$databaseId.collections.$collectionId.documents.$documentId';
  }

  /// Validate configuration
  static bool isConfigured() {
    return endpoint.isNotEmpty && projectId.isNotEmpty;
  }

  /// Print configuration (for debugging)
  static void printConfig() {
    final logger = Logger('AppwriteConfig');
    logger.info('=== Appwrite Configuration ===');
    logger.info('Endpoint: $endpoint');
    logger.info('Project ID: $projectId');
    logger.info('Database ID: $databaseId');
    logger.info('Configured: ${isConfigured()}');
    logger.info('==============================');
  }
}
