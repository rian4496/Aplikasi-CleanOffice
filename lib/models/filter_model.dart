// lib/models/filter_model.dart
// Filter model for advanced filtering functionality

import 'package:equatable/equatable.dart';

/// Filter model for reports
class ReportFilter extends Equatable {
  final String? searchQuery;
  final List<String>? statuses;
  final List<String>? locations;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isUrgent;
  final String? assignedTo;
  
  const ReportFilter({
    this.searchQuery,
    this.statuses,
    this.locations,
    this.startDate,
    this.endDate,
    this.isUrgent,
    this.assignedTo,
  });
  
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
  
  /// Create a copy with updated fields
  ReportFilter copyWith({
    String? searchQuery,
    List<String>? statuses,
    List<String>? locations,
    DateTime? startDate,
    DateTime? endDate,
    bool? isUrgent,
    String? assignedTo,
    bool clearSearch = false,
    bool clearStatuses = false,
    bool clearLocations = false,
    bool clearDateRange = false,
    bool clearUrgent = false,
    bool clearAssignedTo = false,
  }) {
    return ReportFilter(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      statuses: clearStatuses ? null : (statuses ?? this.statuses),
      locations: clearLocations ? null : (locations ?? this.locations),
      startDate: clearDateRange ? null : (startDate ?? this.startDate),
      endDate: clearDateRange ? null : (endDate ?? this.endDate),
      isUrgent: clearUrgent ? null : (isUrgent ?? this.isUrgent),
      assignedTo: clearAssignedTo ? null : (assignedTo ?? this.assignedTo),
    );
  }
  
  /// Clear all filters
  ReportFilter clear() => const ReportFilter();
  
  @override
  List<Object?> get props => [
        searchQuery,
        statuses,
        locations,
        startDate,
        endDate,
        isUrgent,
        assignedTo,
      ];
}

/// Quick filter options
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

/// Saved filter model (for future: save common filters)
class SavedFilter extends Equatable {
  final String id;
  final String name;
  final ReportFilter filter;
  final DateTime createdAt;
  
  const SavedFilter({
    required this.id,
    required this.name,
    required this.filter,
    required this.createdAt,
  });
  
  @override
  List<Object?> get props => [id, name, filter, createdAt];
  
  Map<String, dynamic> toJson() {
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
  
  factory SavedFilter.fromJson(Map<String, dynamic> json) {
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

