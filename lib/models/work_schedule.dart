// lib/models/work_schedule.dart
// WorkSchedule Model for Supabase

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

  // Helper to parse TimeOfDay from string
  static TimeOfDay _parseTime(String? value) {
    if (value == null || value.isEmpty) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );
  }

  factory WorkSchedule.fromMap(String id, Map<String, dynamic> map) {
    return WorkSchedule(
      id: id,
      userId: map['userId'] ?? map['user_id'] ?? '',
      shift: map['shift'] ?? '',
      workDays: List<String>.from(map['workDays'] ?? map['work_days'] ?? []),
      shiftStart: _parseTime(map['shiftStart'] ?? map['shift_start']),
      shiftEnd: _parseTime(map['shiftEnd'] ?? map['shift_end']),
      location: map['location'] ?? '',
      assignedBy: map['assignedBy'] ?? map['assigned_by'] ?? '',
      createdAt: _parseDate(map['createdAt']) ?? _parseDate(map['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(map['updatedAt']) ?? _parseDate(map['updated_at']),
    );
  }

  /// Create from Supabase (snake_case)
  factory WorkSchedule.fromSupabase(Map<String, dynamic> data) {
    return WorkSchedule(
      id: data['id']?.toString() ?? '',
      userId: data['user_id'] ?? '',
      shift: data['shift'] ?? '',
      workDays: List<String>.from(data['work_days'] ?? []),
      shiftStart: _parseTime(data['shift_start']),
      shiftEnd: _parseTime(data['shift_end']),
      location: data['location'] ?? '',
      assignedBy: data['assigned_by'] ?? '',
      createdAt: _parseDate(data['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(data['updated_at']),
    );
  }

  /// Convert to Supabase document format (snake_case)
  Map<String, dynamic> toSupabase() {
    return {
      'user_id': userId,
      'shift': shift,
      'work_days': workDays,
      'shift_start': formatTimeOfDay(shiftStart),
      'shift_end': formatTimeOfDay(shiftEnd),
      'location': location,
      'assigned_by': assignedBy,
    };
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

