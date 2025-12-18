// lib/models/master/organization_stats.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization_stats.freezed.dart';
part 'organization_stats.g.dart';

@freezed
abstract class OrganizationStats with _$OrganizationStats {
  const factory OrganizationStats({
    @Default(0) int employeeCount,
    @Default(0) int assetCount,
    @Default(0) int totalValue, // Optional: Total asset value
  }) = _OrganizationStats;

  factory OrganizationStats.fromJson(Map<String, dynamic> json) => _$OrganizationStatsFromJson(json);
}
