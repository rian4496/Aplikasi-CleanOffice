import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset_category.freezed.dart';
part 'asset_category.g.dart';

@freezed
abstract class AssetCategory with _$AssetCategory {
  const factory AssetCategory({
    required String id,
    required String code,
    required String name,
    String? description,
  }) = _AssetCategory;

  factory AssetCategory.fromJson(Map<String, dynamic> json) => _$AssetCategoryFromJson(json);
}
