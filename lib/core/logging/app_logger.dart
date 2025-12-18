/// Centralized logging system untuk aplikasi Clean Office
///
/// Usage:
/// ```dart
/// final logger = AppLogger('ScreenName');
/// logger.info('Something happened');
/// logger.error('Error occurred', error, stackTrace);
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class AppLogger {
  final Logger _logger;

  static bool _isConfigured = false;

  AppLogger(String name) : _logger = Logger(name) {
    if (!_isConfigured) {
      _configureLogging();
      _isConfigured = true;
    }
  }

  // Filter patterns untuk skip logging (mengurangi noise)
  static final List<String> _skipPatterns = [
    'heartbeat',
    'Received heartbeat',
    'realtime server',
  ];

  static void _configureLogging() {
    Logger.root.level = kDebugMode ? Level.ALL : Level.WARNING;

    Logger.root.onRecord.listen((record) {
      // Skip noisy logs
      final message = record.message.toLowerCase();
      for (final pattern in _skipPatterns) {
        if (message.contains(pattern.toLowerCase())) {
          return; // Skip this log
        }
      }

      final emoji = _getEmojiForLevel(record.level);
      final timestamp = _formatTimestamp(record.time);
      final loggerName = record.loggerName.padRight(20);

      final logMessage = '[$timestamp] $emoji [$loggerName] ${record.message}';

      if (kDebugMode) {
        debugPrint(logMessage);

        if (record.error != null) {
          debugPrint('   ↳ Error: ${record.error}');
        }
        if (record.stackTrace != null) {
          debugPrint('   ↳ StackTrace:\n${record.stackTrace}');
        }
      }
    });
  }

  static String _getEmojiForLevel(Level level) {
    if (level >= Level.SEVERE) return '🔴';
    if (level >= Level.WARNING) return '🟡';
    if (level >= Level.INFO) return '🔵';
    if (level >= Level.CONFIG) return '⚙️';
    return '⚪';
  }

  static String _formatTimestamp(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }

  // ==================== LOGGING METHODS ====================

  void fine(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.fine(message, error, stackTrace);
  }

  void config(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.config(message, error, stackTrace);
  }

  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.info(message, error, stackTrace);
  }

  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.warning(message, error, stackTrace);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }

  void critical(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.shout(message, error, stackTrace);
  }

  // ==================== SPECIALIZED LOGGING ====================

  /// Log authentication events
  /// FIXED: Renamed parameter from 'error' to 'err' to avoid conflict with error() method
  void logAuth(String event, {String? userId, Object? err}) {
    if (err != null) {
      error('Auth failed: $event', err);
    } else {
      info('Auth success: $event${userId != null ? " (userId: $userId)" : ""}');
    }
  }

  void logNavigation(String from, String to) {
    fine('Navigation: $from → $to');
  }

  /// FIXED: Renamed parameter from 'error' to 'err'
  void logApiCall(String endpoint, {bool isSuccess = true, Object? err}) {
    if (isSuccess) {
      info('API call success: $endpoint');
    } else {
      error('API call failed: $endpoint', err);
    }
  }

  /// FIXED: Renamed parameter from 'error' to 'err'
  void logDatabase(
    String operation,
    String collection, {
    bool isSuccess = true,
    Object? err,
  }) {
    if (isSuccess) {
      info('DB $operation: $collection');
    } else {
      error('DB $operation failed: $collection', err);
    }
  }

  void logUserAction(String action, {Map<String, dynamic>? params}) {
    final paramStr = params != null ? ' (${params.toString()})' : '';
    info('User action: $action$paramStr');
  }

  void logPerformance(String operation, Duration duration) {
    final ms = duration.inMilliseconds;
    if (ms > 1000) {
      warning('Slow operation: $operation took ${ms}ms');
    } else {
      fine('Performance: $operation took ${ms}ms');
    }
  }

  // ==================== DEBUG HELPERS ====================

  void debugObject(String label, Object? object) {
    if (kDebugMode) {
      fine('$label: ${object.toString()}');
    }
  }

  void debugMap(String label, Map<String, dynamic> map) {
    if (kDebugMode) {
      fine('$label:');
      map.forEach((key, value) {
        fine('  $key: $value');
      });
    }
  }

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

