// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrganizationStats _$OrganizationStatsFromJson(
  Map json,
) => $checkedCreate('_OrganizationStats', json, ($checkedConvert) {
  final val = _OrganizationStats(
    employeeCount: $checkedConvert(
      'employeeCount',
      (v) => (v as num?)?.toInt() ?? 0,
    ),
    assetCount: $checkedConvert('assetCount', (v) => (v as num?)?.toInt() ?? 0),
    totalValue: $checkedConvert('totalValue', (v) => (v as num?)?.toInt() ?? 0),
  );
  return val;
});

Map<String, dynamic> _$OrganizationStatsToJson(_OrganizationStats instance) =>
    <String, dynamic>{
      'employeeCount': instance.employeeCount,
      'assetCount': instance.assetCount,
      'totalValue': instance.totalValue,
    };
