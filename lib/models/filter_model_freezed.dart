// lib/models/filter_model_freezed.dart
// Filter model for advanced filtering functionality - Freezed Version

import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/firestore_converters.dart';

part 'filter_model_freezed.freezed.dart';
part 'filter_model_freezed.g.dart';

// ==================== QUICK FILTER ====================

enum QuickFilter {
  all('Semua', null),
  today('Hari Ini', 'Laporan hari ini'),
  thisWeek('Minggu Ini', 'Laporan minggu ini'),
  urgent('Urgent', 'Hanya laporan urgent'),
  overdue('Terlambat', 'Pending > 24 jam');

  final String label;
  final String? description;

  const QuickFilter(this.label, this.description);
}

// ==================== REPORT FILTER ====================

/// Filter model for reports
@freezed
class ReportFilter with _$ReportFilter {
  const ReportFilter._(); // Private constructor for custom methods

  const factory ReportFilter({
    String? searchQuery,
    List<String>? statuses,
    List<String>? locations,
    DateTime? startDate,
    DateTime? endDate,
    bool? isUrgent,
    String? assignedTo,
  }) = _ReportFilter;

  /// Convert dari JSON ke ReportFilter object
  factory ReportFilter.fromJson(Map<String, dynamic> json) => _$ReportFilterFromJson(json);
}

// ==================== REPORT FILTER EXTENSION ====================

extension ReportFilterExtension on ReportFilter {
  /// Check if filter is empty (no criteria set)
  bool get isEmpty =>
      searchQuery == null &&
      (statuses == null || statuses!.isEmpty) &&
      (locations == null || locations!.isEmpty) &&
      startDate == null &&
      endDate == null &&
      isUrgent == null &&
      assignedTo == null;

  /// Count active filters
  int get activeFilterCount {
    int count = 0;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (statuses != null && statuses!.isNotEmpty) count++;
    if (locations != null && locations!.isNotEmpty) count++;
    if (startDate != null || endDate != null) count++; // Count date range as one
    if (isUrgent != null) count++;
    if (assignedTo != null) count++;
    return count;
  }

  /// Clear all filters
  ReportFilter clear() => const ReportFilter();
}

// ==================== SAVED FILTER ====================

@freezed
class SavedFilter with _$SavedFilter {
  const SavedFilter._(); // Private constructor for custom methods

  const factory SavedFilter({
    required String id,
    required String name,
    required ReportFilter filter,
    @ISODateTimeConverter() required DateTime createdAt,
  }) = _SavedFilter;

  /// Convert dari JSON ke SavedFilter object
  factory SavedFilter.fromJson(Map<String, dynamic> json) => _$SavedFilterFromJson(json);

  /// Custom toJson for nested ReportFilter serialization
  Map<String, dynamic> toJsonCustom() {
    return {
      'id': id,
      'name': name,
      'filter': {
        'searchQuery': filter.searchQuery,
        'statuses': filter.statuses,
        'locations': filter.locations,
        'startDate': filter.startDate?.toIso8601String(),
        'endDate': filter.endDate?.toIso8601String(),
        'isUrgent': filter.isUrgent,
        'assignedTo': filter.assignedTo,
      },
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Custom fromJson for nested ReportFilter deserialization
  factory SavedFilter.fromJsonCustom(Map<String, dynamic> json) {
    final filterData = json['filter'] as Map<String, dynamic>;
    return SavedFilter(
      id: json['id'] as String,
      name: json['name'] as String,
      filter: ReportFilter(
        searchQuery: filterData['searchQuery'] as String?,
        statuses: (filterData['statuses'] as List?)?.cast<String>(),
        locations: (filterData['locations'] as List?)?.cast<String>(),
        startDate: filterData['startDate'] != null
            ? DateTime.parse(filterData['startDate'] as String)
            : null,
        endDate: filterData['endDate'] != null
            ? DateTime.parse(filterData['endDate'] as String)
            : null,
        isUrgent: filterData['isUrgent'] as bool?,
        assignedTo: filterData['assignedTo'] as String?,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
