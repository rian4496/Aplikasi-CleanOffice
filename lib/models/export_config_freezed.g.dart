// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_config_freezed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExportConfig _$ExportConfigFromJson(
  Map json,
) => $checkedCreate('_ExportConfig', json, ($checkedConvert) {
  final val = _ExportConfig(
    format: $checkedConvert(
      'format',
      (v) => $enumDecode(_$ExportFormatEnumMap, v),
    ),
    reportType: $checkedConvert(
      'reportType',
      (v) => $enumDecode(_$ReportTypeEnumMap, v),
    ),
    startDate: $checkedConvert(
      'startDate',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    endDate: $checkedConvert(
      'endDate',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    includeCharts: $checkedConvert('includeCharts', (v) => v as bool? ?? true),
    includePhotos: $checkedConvert('includePhotos', (v) => v as bool? ?? false),
    includeStatistics: $checkedConvert(
      'includeStatistics',
      (v) => v as bool? ?? true,
    ),
    cleanerId: $checkedConvert('cleanerId', (v) => v as String?),
    location: $checkedConvert('location', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$ExportConfigToJson(_ExportConfig instance) =>
    <String, dynamic>{
      'format': _$ExportFormatEnumMap[instance.format]!,
      'reportType': _$ReportTypeEnumMap[instance.reportType]!,
      'startDate': ?instance.startDate?.toIso8601String(),
      'endDate': ?instance.endDate?.toIso8601String(),
      'includeCharts': instance.includeCharts,
      'includePhotos': instance.includePhotos,
      'includeStatistics': instance.includeStatistics,
      'cleanerId': ?instance.cleanerId,
      'location': ?instance.location,
    };

const _$ExportFormatEnumMap = {
  ExportFormat.pdf: 'pdf',
  ExportFormat.excel: 'excel',
  ExportFormat.csv: 'csv',
};

const _$ReportTypeEnumMap = {
  ReportType.daily: 'daily',
  ReportType.weekly: 'weekly',
  ReportType.monthly: 'monthly',
  ReportType.custom: 'custom',
  ReportType.allReports: 'allReports',
  ReportType.cleanerPerformance: 'cleanerPerformance',
};

_ExportResult _$ExportResultFromJson(Map json) =>
    $checkedCreate('_ExportResult', json, ($checkedConvert) {
      final val = _ExportResult(
        success: $checkedConvert('success', (v) => v as bool),
        filePath: $checkedConvert('filePath', (v) => v as String?),
        fileName: $checkedConvert('fileName', (v) => v as String?),
        fileSize: $checkedConvert('fileSize', (v) => (v as num?)?.toInt()),
        error: $checkedConvert('error', (v) => v as String?),
        exportedAt: $checkedConvert(
          'exportedAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ExportResultToJson(_ExportResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'filePath': ?instance.filePath,
      'fileName': ?instance.fileName,
      'fileSize': ?instance.fileSize,
      'error': ?instance.error,
      'exportedAt': instance.exportedAt.toIso8601String(),
    };

_ReportData _$ReportDataFromJson(Map json) =>
    $checkedCreate('_ReportData', json, ($checkedConvert) {
      final val = _ReportData(
        title: $checkedConvert('title', (v) => v as String),
        subtitle: $checkedConvert('subtitle', (v) => v as String),
        generatedAt: $checkedConvert(
          'generatedAt',
          (v) => DateTime.parse(v as String),
        ),
        startDate: $checkedConvert(
          'startDate',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        endDate: $checkedConvert(
          'endDate',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        summary: $checkedConvert(
          'summary',
          (v) => Map<String, dynamic>.from(v as Map),
        ),
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ReportDataToJson(_ReportData instance) =>
    <String, dynamic>{
      'title': instance.title,
      'subtitle': instance.subtitle,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'startDate': ?instance.startDate?.toIso8601String(),
      'endDate': ?instance.endDate?.toIso8601String(),
      'summary': instance.summary,
      'items': instance.items,
    };
