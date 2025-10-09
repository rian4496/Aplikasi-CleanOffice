import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Centralized logging system untuk aplikasi Clean Office
/// 
/// Usage:
/// ```dart
/// final logger = AppLogger('ScreenName');
/// logger.info('Something happened');
/// logger.error('Error occurred', error, stackTrace);
/// ```

class AppLogger {
  final Logger _logger;
  
  // Singleton instance untuk global configuration
  static bool _isConfigured = false;

  AppLogger(String name) : _logger = Logger(name) {
    if (!_isConfigured) {
      _configureLogging();
      _isConfigured = true;
    }
  }

  /// Configure logging untuk seluruh aplikasi
  static void _configureLogging() {
    Logger.root.level = kDebugMode ? Level.ALL : Level.WARNING;
    
    Logger.root.onRecord.listen((record) {
      final emoji = _getEmojiForLevel(record.level);
      final timestamp = _formatTimestamp(record.time);
      final loggerName = record.loggerName.padRight(20);
      
      // Format: [TIME] 🔵 [LOGGER_NAME] MESSAGE
      final logMessage = '[$timestamp] $emoji [$loggerName] ${record.message}';
      
      // Print ke console dengan warna (hanya di debug mode)
      if (kDebugMode) {
        debugPrint(logMessage);
        
        // Print error dan stackTrace jika ada
        if (record.error != null) {
          debugPrint('   ↳ Error: ${record.error}');
        }
        if (record.stackTrace != null) {
          debugPrint('   ↳ StackTrace:\n${record.stackTrace}');
        }
      }
      
      // TODO: Di production, send ke remote logging service (Crashlytics, Sentry, etc)
      // if (kReleaseMode && record.level >= Level.SEVERE) {
      //   _sendToRemoteLogging(record);
      // }
    });
  }

  /// Get emoji berdasarkan log level
  static String _getEmojiForLevel(Level level) {
    if (level >= Level.SEVERE) return '🔴'; // Error
    if (level >= Level.WARNING) return '🟡'; // Warning
    if (level >= Level.INFO) return '🔵'; // Info
    if (level >= Level.CONFIG) return '⚙️'; // Config
    return '⚪'; // Fine/Debug
  }

  /// Format timestamp ke readable format
  static String _formatTimestamp(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}:'
           '${time.second.toString().padLeft(2, '0')}';
  }

  // ==================== LOGGING METHODS ====================

  /// Log fine messages (very detailed debug info)
  void fine(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.fine(message, error, stackTrace);
  }

  /// Log config messages
  void config(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.config(message, error, stackTrace);
  }

  /// Log info messages (general information)
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.info(message, error, stackTrace);
  }

  /// Log warning messages
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.warning(message, error, stackTrace);
  }

  /// Log error messages
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }

  /// Log critical error messages
  void critical(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.shout(message, error, stackTrace);
  }

  // ==================== SPECIALIZED LOGGING ====================

  /// Log authentication events
  void logAuth(String event, {String? userId, Object? error}) {
    if (error != null) {
      error('Auth failed: $event', error);
    } else {
      info('Auth success: $event${userId != null ? " (userId: $userId)" : ""}');
    }
  }

  /// Log navigation events
  void logNavigation(String from, String to) {
    fine('Navigation: $from → $to');
  }

  /// Log API calls
  void logApiCall(String endpoint, {bool isSuccess = true, Object? error}) {
    if (isSuccess) {
      info('API call success: $endpoint');
    } else {
      error('API call failed: $endpoint', error);
    }
  }

  /// Log database operations
  void logDatabase(String operation, String collection, {bool isSuccess = true, Object? error}) {
    if (isSuccess) {
      info('DB $operation: $collection');
    } else {
      error('DB $operation failed: $collection', error);
    }
  }

  /// Log user actions untuk analytics
  void logUserAction(String action, {Map<String, dynamic>? params}) {
    final paramStr = params != null ? ' (${params.toString()})' : '';
    info('User action: $action$paramStr');
    
    // TODO: Send to analytics service
    // FirebaseAnalytics.instance.logEvent(name: action, parameters: params);
  }

  /// Log performance metrics
  void logPerformance(String operation, Duration duration) {
    final ms = duration.inMilliseconds;
    if (ms > 1000) {
      warning('Slow operation: $operation took ${ms}ms');
    } else {
      fine('Performance: $operation took ${ms}ms');
    }
  }

  // ==================== DEBUG HELPERS ====================

  /// Log object untuk debugging (pretty print)
  void debugObject(String label, Object? object) {
    if (kDebugMode) {
      fine('$label: ${object.toString()}');
    }
  }

  /// Log map dengan formatting
  void debugMap(String label, Map<String, dynamic> map) {
    if (kDebugMode) {
      fine('$label:');
      map.forEach((key, value) {
        fine('  $key: $value');
      });
    }
  }

  /// Log list dengan formatting
  void debugList(String label, List<dynamic> list) {
    if (kDebugMode) {
      fine('$label (${list.length} items):');
      for (var i = 0; i < list.length; i++) {
        fine('  [$i]: ${list[i]}');
      }
    }
  }
}

// ==================== GLOBAL LOGGER INSTANCES ====================

/// Pre-configured loggers untuk common use cases
class AppLoggers {
  static final auth = AppLogger('Auth');
  static final firestore = AppLogger('Firestore');
  static final storage = AppLogger('Storage');
  static final navigation = AppLogger('Navigation');
  static final ui = AppLogger('UI');
  static final service = AppLogger('Service');
  static final provider = AppLogger('Provider');
}

// ==================== LOG LEVEL EXTENSION ====================

extension LevelExtension on Level {
  bool get isError => this >= Level.SEVERE;
  bool get isWarning => this >= Level.WARNING;
  bool get isInfo => this >= Level.INFO;
}