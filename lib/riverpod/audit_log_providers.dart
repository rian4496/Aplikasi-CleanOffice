// lib/riverpod/audit_log_providers.dart
// Audit Log Providers - using simple pattern matching existing codebase

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/audit_log.dart';
import 'supabase_service_providers.dart';

/// Filter state for audit logs
class AuditLogFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? userId;
  final String? action;
  final String? entityType;
  
  const AuditLogFilter({
    this.startDate,
    this.endDate,
    this.userId,
    this.action,
    this.entityType,
  });
  
  AuditLogFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    String? action,
    String? entityType,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearUserId = false,
    bool clearAction = false,
    bool clearEntityType = false,
  }) {
    return AuditLogFilter(
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      userId: clearUserId ? null : (userId ?? this.userId),
      action: clearAction ? null : (action ?? this.action),
      entityType: clearEntityType ? null : (entityType ?? this.entityType),
    );
  }
}

/// Notifier for audit log filter state
class AuditLogFilterNotifier extends Notifier<AuditLogFilter> {
  @override
  AuditLogFilter build() {
    return AuditLogFilter(
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now(),
    );
  }
  
  void updateFilter(AuditLogFilter newFilter) {
    state = newFilter;
  }
  
  void setDateRange(DateTime start, DateTime end) {
    state = state.copyWith(startDate: start, endDate: end);
  }
  
  void setAction(String? action) {
    state = action == null 
        ? state.copyWith(clearAction: true)
        : state.copyWith(action: action);
  }
  
  void setEntityType(String? entityType) {
    state = entityType == null 
        ? state.copyWith(clearEntityType: true)
        : state.copyWith(entityType: entityType);
  }
  
  void clearFilters() {
    state = AuditLogFilter(
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now(),
    );
  }
}

/// Provider for audit log filter state
final auditLogFilterProvider = NotifierProvider<AuditLogFilterNotifier, AuditLogFilter>(
  AuditLogFilterNotifier.new,
);

/// Provider for paginated audit logs
final auditLogListProvider = FutureProvider.autoDispose<List<AuditLog>>((ref) async {
  final filter = ref.watch(auditLogFilterProvider);
  final service = ref.read(supabaseDatabaseServiceProvider);
  
  return service.getAuditLogs(
    startDate: filter.startDate,
    endDate: filter.endDate,
    userId: filter.userId,
    action: filter.action,
    entityType: filter.entityType,
    limit: 100,
  );
});
