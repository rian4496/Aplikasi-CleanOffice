// lib/core/services/appwrite_client.dart

import 'package:appwrite/appwrite.dart';
import 'package:logging/logging.dart';
import '../config/appwrite_config.dart';

/// Appwrite Client Singleton
///
/// This class provides a singleton instance of Appwrite client
/// with pre-configured endpoint and project ID
class AppwriteClient {
  static final AppwriteClient _instance = AppwriteClient._internal();
  factory AppwriteClient() => _instance;
  AppwriteClient._internal();

  final Logger _logger = Logger('AppwriteClient');

  late final Client _client;
  late final Account _account;
  late final Databases _databases;
  late final Storage _storage;
  late final Realtime _realtime;

  // ==================== GETTERS ====================

  /// Get Appwrite client instance
  Client get client => _client;

  /// Get Account service (for authentication)
  Account get account => _account;

  /// Get Databases service (for database operations)
  Databases get databases => _databases;

  /// Get Storage service (for file operations)
  Storage get storage => _storage;

  /// Get Realtime service (for realtime subscriptions)
  Realtime get realtime => _realtime;

  // ==================== INITIALIZATION ====================

  /// Initialize Appwrite client
  ///
  /// This should be called once during app initialization (in main.dart)
  Future<void> initialize() async {
    try {
      _logger.info('Initializing Appwrite client...');

      // Validate configuration
      if (!AppwriteConfig.isConfigured()) {
        throw Exception('Appwrite configuration is missing');
      }

      // Initialize client
      _client = Client()
          .setEndpoint(AppwriteConfig.endpoint)
          .setProject(AppwriteConfig.projectId)
          .setSelfSigned(status: false); // Set to true for local development

      // Initialize services
      _account = Account(_client);
      _databases = Databases(_client);
      _storage = Storage(_client);
      _realtime = Realtime(_client);

      _logger.info('✅ Appwrite client initialized successfully');
      AppwriteConfig.printConfig();
    } catch (e, stackTrace) {
      _logger.severe('❌ Failed to initialize Appwrite client', e, stackTrace);
      rethrow;
    }
  }

  /// Check if client is initialized
  bool get isInitialized {
    try {
      // Try to access client, will throw if not initialized
      _client.config;
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== SESSION MANAGEMENT ====================

  /// Get current user session
  Future<bool> hasActiveSession() async {
    try {
      await _account.get();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear client cache (for logout)
  void clearCache() {
    _logger.info('Clearing Appwrite client cache');
    // Appwrite SDK handles session clearing automatically
  }
}
