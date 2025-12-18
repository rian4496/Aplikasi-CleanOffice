import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee.freezed.dart';
part 'employee.g.dart';

@freezed
abstract class Employee with _$Employee {
  const factory Employee({
    required String id,
    required String nip,
    @JsonKey(name: 'full_name') required String fullName,
    String? email,
    String? phone,
    String? position,
    @JsonKey(name: 'organization_id') String? organizationId,
    @Default('active') String status,
    @JsonKey(name: 'photo_url') String? photoUrl,
    @JsonKey(name: 'department_name') String? departmentName, // For convenience in UI, joined query
  }) = _Employee;

  factory Employee.fromJson(Map<String, dynamic> json) => _$EmployeeFromJson(json);
}
