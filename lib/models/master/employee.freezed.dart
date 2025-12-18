// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employee.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Employee {

 String get id; String get nip;@JsonKey(name: 'full_name') String get fullName; String? get email; String? get phone; String? get position;@JsonKey(name: 'organization_id') String? get organizationId; String get status;@JsonKey(name: 'photo_url') String? get photoUrl;@JsonKey(name: 'department_name') String? get departmentName;
/// Create a copy of Employee
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmployeeCopyWith<Employee> get copyWith => _$EmployeeCopyWithImpl<Employee>(this as Employee, _$identity);

  /// Serializes this Employee to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Employee&&(identical(other.id, id) || other.id == id)&&(identical(other.nip, nip) || other.nip == nip)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.position, position) || other.position == position)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.status, status) || other.status == status)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.departmentName, departmentName) || other.departmentName == departmentName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nip,fullName,email,phone,position,organizationId,status,photoUrl,departmentName);

@override
String toString() {
  return 'Employee(id: $id, nip: $nip, fullName: $fullName, email: $email, phone: $phone, position: $position, organizationId: $organizationId, status: $status, photoUrl: $photoUrl, departmentName: $departmentName)';
}


}

/// @nodoc
abstract mixin class $EmployeeCopyWith<$Res>  {
  factory $EmployeeCopyWith(Employee value, $Res Function(Employee) _then) = _$EmployeeCopyWithImpl;
@useResult
$Res call({
 String id, String nip,@JsonKey(name: 'full_name') String fullName, String? email, String? phone, String? position,@JsonKey(name: 'organization_id') String? organizationId, String status,@JsonKey(name: 'photo_url') String? photoUrl,@JsonKey(name: 'department_name') String? departmentName
});




}
/// @nodoc
class _$EmployeeCopyWithImpl<$Res>
    implements $EmployeeCopyWith<$Res> {
  _$EmployeeCopyWithImpl(this._self, this._then);

  final Employee _self;
  final $Res Function(Employee) _then;

/// Create a copy of Employee
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nip = null,Object? fullName = null,Object? email = freezed,Object? phone = freezed,Object? position = freezed,Object? organizationId = freezed,Object? status = null,Object? photoUrl = freezed,Object? departmentName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nip: null == nip ? _self.nip : nip // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String?,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,departmentName: freezed == departmentName ? _self.departmentName : departmentName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Employee].
extension EmployeePatterns on Employee {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Employee value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Employee() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Employee value)  $default,){
final _that = this;
switch (_that) {
case _Employee():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Employee value)?  $default,){
final _that = this;
switch (_that) {
case _Employee() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nip, @JsonKey(name: 'full_name')  String fullName,  String? email,  String? phone,  String? position, @JsonKey(name: 'organization_id')  String? organizationId,  String status, @JsonKey(name: 'photo_url')  String? photoUrl, @JsonKey(name: 'department_name')  String? departmentName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Employee() when $default != null:
return $default(_that.id,_that.nip,_that.fullName,_that.email,_that.phone,_that.position,_that.organizationId,_that.status,_that.photoUrl,_that.departmentName);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nip, @JsonKey(name: 'full_name')  String fullName,  String? email,  String? phone,  String? position, @JsonKey(name: 'organization_id')  String? organizationId,  String status, @JsonKey(name: 'photo_url')  String? photoUrl, @JsonKey(name: 'department_name')  String? departmentName)  $default,) {final _that = this;
switch (_that) {
case _Employee():
return $default(_that.id,_that.nip,_that.fullName,_that.email,_that.phone,_that.position,_that.organizationId,_that.status,_that.photoUrl,_that.departmentName);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nip, @JsonKey(name: 'full_name')  String fullName,  String? email,  String? phone,  String? position, @JsonKey(name: 'organization_id')  String? organizationId,  String status, @JsonKey(name: 'photo_url')  String? photoUrl, @JsonKey(name: 'department_name')  String? departmentName)?  $default,) {final _that = this;
switch (_that) {
case _Employee() when $default != null:
return $default(_that.id,_that.nip,_that.fullName,_that.email,_that.phone,_that.position,_that.organizationId,_that.status,_that.photoUrl,_that.departmentName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Employee implements Employee {
  const _Employee({required this.id, required this.nip, @JsonKey(name: 'full_name') required this.fullName, this.email, this.phone, this.position, @JsonKey(name: 'organization_id') this.organizationId, this.status = 'active', @JsonKey(name: 'photo_url') this.photoUrl, @JsonKey(name: 'department_name') this.departmentName});
  factory _Employee.fromJson(Map<String, dynamic> json) => _$EmployeeFromJson(json);

@override final  String id;
@override final  String nip;
@override@JsonKey(name: 'full_name') final  String fullName;
@override final  String? email;
@override final  String? phone;
@override final  String? position;
@override@JsonKey(name: 'organization_id') final  String? organizationId;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'photo_url') final  String? photoUrl;
@override@JsonKey(name: 'department_name') final  String? departmentName;

/// Create a copy of Employee
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmployeeCopyWith<_Employee> get copyWith => __$EmployeeCopyWithImpl<_Employee>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmployeeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Employee&&(identical(other.id, id) || other.id == id)&&(identical(other.nip, nip) || other.nip == nip)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.position, position) || other.position == position)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.status, status) || other.status == status)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.departmentName, departmentName) || other.departmentName == departmentName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nip,fullName,email,phone,position,organizationId,status,photoUrl,departmentName);

@override
String toString() {
  return 'Employee(id: $id, nip: $nip, fullName: $fullName, email: $email, phone: $phone, position: $position, organizationId: $organizationId, status: $status, photoUrl: $photoUrl, departmentName: $departmentName)';
}


}

/// @nodoc
abstract mixin class _$EmployeeCopyWith<$Res> implements $EmployeeCopyWith<$Res> {
  factory _$EmployeeCopyWith(_Employee value, $Res Function(_Employee) _then) = __$EmployeeCopyWithImpl;
@override @useResult
$Res call({
 String id, String nip,@JsonKey(name: 'full_name') String fullName, String? email, String? phone, String? position,@JsonKey(name: 'organization_id') String? organizationId, String status,@JsonKey(name: 'photo_url') String? photoUrl,@JsonKey(name: 'department_name') String? departmentName
});




}
/// @nodoc
class __$EmployeeCopyWithImpl<$Res>
    implements _$EmployeeCopyWith<$Res> {
  __$EmployeeCopyWithImpl(this._self, this._then);

  final _Employee _self;
  final $Res Function(_Employee) _then;

/// Create a copy of Employee
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nip = null,Object? fullName = null,Object? email = freezed,Object? phone = freezed,Object? position = freezed,Object? organizationId = freezed,Object? status = null,Object? photoUrl = freezed,Object? departmentName = freezed,}) {
  return _then(_Employee(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nip: null == nip ? _self.nip : nip // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String?,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,departmentName: freezed == departmentName ? _self.departmentName : departmentName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
