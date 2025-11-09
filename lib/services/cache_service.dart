// lib/services/cache_service.dart
// Simple cache service for offline viewing

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/report.dart';

class CacheService {
  static const String _reportsKey = 'cached_reports';
  static const String _lastSyncKey = 'last_sync_time';
  static const Duration _cacheExpiry = Duration(hours: 24);

  /// Cache reports locally
  Future<void> cacheReports(List<Report> reports) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert reports to JSON
      final jsonList = reports.map((r) => r.toMap()).toList();
      final jsonString = jsonEncode(jsonList);
      
      // Save to cache
      await prefs.setString(_reportsKey, jsonString);
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      // Silent fail - cache is optional
      debugPrint('Cache error: $e');
    }
  }

  /// Get cached reports
  Future<List<Report>?> getCachedReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if cache exists
      final jsonString = prefs.getString(_reportsKey);
      if (jsonString == null) return null;
      
      // Check if cache is expired
      if (await isCacheExpired()) {
        await clearCache();
        return null;
      }
      
      // Parse JSON
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) {
        final map = json as Map<String, dynamic>;
        final id = map['id'] as String;
        return Report.fromMap(id, map);
      }).toList();
    } catch (e) {
      debugPrint('Cache read error: $e');
      return null;
    }
  }

  /// Check if cache is expired
  Future<bool> isCacheExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncStr = prefs.getString(_lastSyncKey);
      
      if (lastSyncStr == null) return true;
      
      final lastSync = DateTime.parse(lastSyncStr);
      final now = DateTime.now();
      
      return now.difference(lastSync) > _cacheExpiry;
    } catch (e) {
      return true;
    }
  }

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncStr = prefs.getString(_lastSyncKey);
      
      if (lastSyncStr == null) return null;
      return DateTime.parse(lastSyncStr);
    } catch (e) {
      return null;
    }
  }

  /// Clear cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_reportsKey);
      await prefs.remove(_lastSyncKey);
    } catch (e) {
      debugPrint('Clear cache error: $e');
    }
  }

  /// Get cache size (estimated)
  Future<int> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_reportsKey);
      
      if (jsonString == null) return 0;
      return jsonString.length; // Approximate size in bytes
    } catch (e) {
      return 0;
    }
  }
}
