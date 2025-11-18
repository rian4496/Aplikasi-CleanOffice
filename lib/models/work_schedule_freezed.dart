// lib/models/work_schedule_freezed.dart
// Work Schedule model - Freezed Version

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/firestore_converters.dart';

part 'work_schedule_freezed.freezed.dart';
part 'work_schedule_freezed.g.dart';

@freezed
class WorkSchedule with _$WorkSchedule {
  const WorkSchedule._(); // Private constructor for custom methods

  const factory WorkSchedule({
    required String id,
    required String userId,
    required String shift, // 'morning', 'afternoon', 'night'
    required List<String> workDays, // ['monday', 'tuesday', etc.]
    @TimeOfDayConverter() required TimeOfDay shiftStart,
    @TimeOfDayConverter() required TimeOfDay shiftEnd,
    required String location,
    required String assignedBy,
    @TimestampConverter() required DateTime createdAt,
    @NullableTimestampConverter() DateTime? updatedAt,
  }) = _WorkSchedule;

  /// Convert dari JSON ke WorkSchedule object
  factory WorkSchedule.fromJson(Map<String, dynamic> json) => _$WorkScheduleFromJson(json);

  /// Convert dari Map ke WorkSchedule object (backward compatibility)
  factory WorkSchedule.fromMap(String id, Map<String, dynamic> map) {
    final startTime = map['shiftStart'].toString().split(':');
    final endTime = map['shiftEnd'].toString().split(':');

    return WorkSchedule.fromJson({
      'id': id,
      'userId': map['userId'] ?? '',
      'shift': map['shift'] ?? '',
      'workDays': map['workDays'] ?? [],
      'shiftStart': map['shiftStart'], // TimeOfDayConverter handles this
      'shiftEnd': map['shiftEnd'], // TimeOfDayConverter handles this
      'location': map['location'] ?? '',
      'assignedBy': map['assignedBy'] ?? '',
      'createdAt': map['createdAt'], // TimestampConverter handles this
      'updatedAt': map['updatedAt'],
    });
  }

  /// Convert WorkSchedule object ke Map (backward compatibility)
  Map<String, dynamic> toMap() {
    final json = toJson();
    // Remove 'id' from map for Firestore
    json.remove('id');
    return json;
  }

  /// Static helper methods
  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static List<String> get allShifts => ['morning', 'afternoon', 'night'];

  static String getShiftDisplayName(String shift) {
    switch (shift) {
      case 'morning':
        return 'Pagi';
      case 'afternoon':
        return 'Siang';
      case 'night':
        return 'Malam';
      default:
        return shift;
    }
  }

  static List<String> get allWorkDays => [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  static String getWorkDayDisplayName(String day) {
    switch (day) {
      case 'monday':
        return 'Senin';
      case 'tuesday':
        return 'Selasa';
      case 'wednesday':
        return 'Rabu';
      case 'thursday':
        return 'Kamis';
      case 'friday':
        return 'Jumat';
      case 'saturday':
        return 'Sabtu';
      case 'sunday':
        return 'Minggu';
      default:
        return day;
    }
  }
}
