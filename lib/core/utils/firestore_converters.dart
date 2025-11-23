// lib/core/utils/firestore_converters.dart
// ✅ MIGRATED TO APPWRITE - No Firebase dependencies

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:freezed_annotation/freezed_annotation.dart';

/// Timestamp Converter untuk Freezed + Appwrite
///
/// Converts antara DateTime (Dart) dan ISO 8601 String (Appwrite)
/// Note: Appwrite uses ISO 8601 strings, not Firebase Timestamp
///
/// Usage dalam Freezed model:
/// ```dart
/// @freezed
/// class MyModel with _$MyModel {
///   const factory MyModel({
///     @TimestampConverter() required DateTime createdAt,
///     @NullableTimestampConverter() DateTime? updatedAt,
///   }) = _MyModel;
/// }
/// ```
class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json == null) return DateTime.now();

    // From ISO String (Appwrite format)
    if (json is String) {
      return DateTime.tryParse(json) ?? DateTime.now();
    }

    // From DateTime directly
    if (json is DateTime) {
      return json;
    }

    // From milliseconds since epoch
    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }

    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime object) {
    // Always convert to ISO 8601 String for Appwrite
    return object.toIso8601String();
  }
}

/// Nullable Timestamp Converter
///
/// Same as TimestampConverter but supports null values
class NullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;

    if (json is String) {
      return DateTime.tryParse(json);
    }

    if (json is DateTime) {
      return json;
    }

    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }

    return null;
  }

  @override
  dynamic toJson(DateTime? object) {
    if (object == null) return null;
    return object.toIso8601String();
  }
}

/// ISO DateTime Converter
///
/// Converts DateTime to/from ISO 8601 String (for models using ISO strings instead of Timestamp)
///
/// Usage:
/// ```dart
/// @freezed
/// class InventoryItem with _$InventoryItem {
///   const factory InventoryItem({
///     @ISODateTimeConverter() required DateTime createdAt,
///   }) = _InventoryItem;
/// }
/// ```
class ISODateTimeConverter implements JsonConverter<DateTime, String> {
  const ISODateTimeConverter();

  @override
  DateTime fromJson(String json) {
    return DateTime.tryParse(json) ?? DateTime.now();
  }

  @override
  String toJson(DateTime object) {
    return object.toIso8601String();
  }
}

/// Nullable ISO DateTime Converter
///
/// Same as ISODateTimeConverter but supports null values
class NullableISODateTimeConverter implements JsonConverter<DateTime?, String?> {
  const NullableISODateTimeConverter();

  @override
  DateTime? fromJson(String? json) {
    if (json == null) return null;
    return DateTime.tryParse(json);
  }

  @override
  String? toJson(DateTime? object) {
    if (object == null) return null;
    return object.toIso8601String();
  }
}

/// TimeOfDay Converter
///
/// Converts Flutter TimeOfDay to/from String (format: "HH:mm")
///
/// Usage:
/// ```dart
/// @freezed
/// class WorkSchedule with _$WorkSchedule {
///   const factory WorkSchedule({
///     @TimeOfDayConverter() required TimeOfDay shiftStart,
///   }) = _WorkSchedule;
/// }
/// ```
class TimeOfDayConverter implements JsonConverter<TimeOfDay, String> {
  const TimeOfDayConverter();

  @override
  TimeOfDay fromJson(String json) {
    final parts = json.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  @override
  String toJson(TimeOfDay object) {
    return '${object.hour}:${object.minute}';
  }
}

/// Report Status Converter
///
/// Converts ReportStatus enum untuk Database
class ReportStatusConverter implements JsonConverter<dynamic, String> {
  const ReportStatusConverter();

  @override
  dynamic fromJson(String json) {
    // This will be handled by enum's fromString method
    return json;
  }

  @override
  String toJson(dynamic object) {
    // Assume object has toDatabase() method
    if (object == null) return 'pending';
    return object.toString().split('.').last;
  }
}
