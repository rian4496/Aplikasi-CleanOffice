// lib/models/work_schedule.dart
// ✅ MIGRATED TO APPWRITE - No Firebase dependencies

import 'package:flutter/material.dart' show TimeOfDay;

class WorkSchedule {
  final String id;
  final String userId;
  final String shift; // 'morning', 'afternoon', 'night'
  final List<String> workDays; // ['monday', 'tuesday', etc.]
  final TimeOfDay shiftStart;
  final TimeOfDay shiftEnd;
  final String location;
  final String assignedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WorkSchedule({
    required this.id,
    required this.userId,
    required this.shift,
    required this.workDays,
    required this.shiftStart,
    required this.shiftEnd,
    required this.location,
    required this.assignedBy,
    required this.createdAt,
    this.updatedAt,
  });

  // Helper to parse dates from various formats
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'shift': shift,
      'workDays': workDays,
      'shiftStart': '${shiftStart.hour}:${shiftStart.minute}',
      'shiftEnd': '${shiftEnd.hour}:${shiftEnd.minute}',
      'location': location,
      'assignedBy': assignedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to Appwrite document format
  Map<String, dynamic> toAppwrite() => toMap();

  factory WorkSchedule.fromMap(String id, Map<String, dynamic> map) {
    final startTime = map['shiftStart'].toString().split(':');
    final endTime = map['shiftEnd'].toString().split(':');

    return WorkSchedule(
      id: id,
      userId: map['userId'] ?? '',
      shift: map['shift'] ?? '',
      workDays: List<String>.from(map['workDays'] ?? []),
      shiftStart: TimeOfDay(
        hour: int.parse(startTime[0]),
        minute: int.parse(startTime[1]),
      ),
      shiftEnd: TimeOfDay(
        hour: int.parse(endTime[0]),
        minute: int.parse(endTime[1]),
      ),
      location: map['location'] ?? '',
      assignedBy: map['assignedBy'] ?? '',
      createdAt: _parseDate(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  /// Factory from Appwrite document
  factory WorkSchedule.fromAppwrite(Map<String, dynamic> data) {
    final startTime = data['shiftStart'].toString().split(':');
    final endTime = data['shiftEnd'].toString().split(':');

    return WorkSchedule(
      id: data['\$id'] ?? data['id'] ?? '',
      userId: data['userId'] ?? '',
      shift: data['shift'] ?? '',
      workDays: List<String>.from(data['workDays'] ?? []),
      shiftStart: TimeOfDay(
        hour: int.parse(startTime[0]),
        minute: int.parse(startTime[1]),
      ),
      shiftEnd: TimeOfDay(
        hour: int.parse(endTime[0]),
        minute: int.parse(endTime[1]),
      ),
      location: data['location'] ?? '',
      assignedBy: data['assignedBy'] ?? '',
      createdAt: _parseDate(data['\$createdAt']) ?? _parseDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(data['\$updatedAt']) ?? _parseDate(data['updatedAt']),
    );
  }

  WorkSchedule copyWith({
    String? shift,
    List<String>? workDays,
    TimeOfDay? shiftStart,
    TimeOfDay? shiftEnd,
    String? location,
  }) {
    return WorkSchedule(
      id: id,
      userId: userId,
      shift: shift ?? this.shift,
      workDays: workDays ?? this.workDays,
      shiftStart: shiftStart ?? this.shiftStart,
      shiftEnd: shiftEnd ?? this.shiftEnd,
      location: location ?? this.location,
      assignedBy: assignedBy,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

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
