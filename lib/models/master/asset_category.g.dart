// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssetCategory _$AssetCategoryFromJson(Map json) =>
    $checkedCreate('_AssetCategory', json, ($checkedConvert) {
      final val = _AssetCategory(
        id: $checkedConvert('id', (v) => v as String),
        code: $checkedConvert('code', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$AssetCategoryToJson(_AssetCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'description': ?instance.description,
    };
