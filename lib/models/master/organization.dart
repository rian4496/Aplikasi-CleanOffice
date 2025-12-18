import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization.freezed.dart';
part 'organization.g.dart';

@freezed
abstract class Organization with _$Organization {
  const factory Organization({
    required String id,
    required String code,
    required String name,
    @JsonKey(name: 'parent_id') String? parentId,
    required String type, // 'dinas', 'bidang', 'seksi', 'upt'
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Organization;

  factory Organization.fromJson(Map<String, dynamic> json) => _$OrganizationFromJson(json);
}
