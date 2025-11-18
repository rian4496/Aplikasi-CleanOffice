// lib/core/utils/firestore_converters.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Timestamp Converter untuk Freezed + Firestore
///
/// Converts antara DateTime (Dart) dan Timestamp (Firestore)
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

    // From Firestore Timestamp
    if (json is Timestamp) {
      return json.toDate();
    }

    // From ISO String (for cache/JSON)
    if (json is String) {
      return DateTime.parse(json);
    }

    // From milliseconds since epoch
    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }

    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime object) {
    // Always convert to Timestamp for Firestore
    return Timestamp.fromDate(object);
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

    if (json is Timestamp) {
      return json.toDate();
    }

    if (json is String) {
      return DateTime.parse(json);
    }

    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }

    return null;
  }

  @override
  dynamic toJson(DateTime? object) {
    if (object == null) return null;
    return Timestamp.fromDate(object);
  }
}

/// Report Status Converter
///
/// Converts ReportStatus enum untuk Firestore
class ReportStatusConverter implements JsonConverter<dynamic, String> {
  const ReportStatusConverter();

  @override
  dynamic fromJson(String json) {
    // This will be handled by enum's fromString method
    return json;
  }

  @override
  String toJson(dynamic object) {
    // Assume object has toFirestore() method
    if (object == null) return 'pending';
    return object.toString().split('.').last;
  }
}
