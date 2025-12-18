// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrganizationStats {

 int get employeeCount; int get assetCount; int get totalValue;
/// Create a copy of OrganizationStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationStatsCopyWith<OrganizationStats> get copyWith => _$OrganizationStatsCopyWithImpl<OrganizationStats>(this as OrganizationStats, _$identity);

  /// Serializes this OrganizationStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganizationStats&&(identical(other.employeeCount, employeeCount) || other.employeeCount == employeeCount)&&(identical(other.assetCount, assetCount) || other.assetCount == assetCount)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,employeeCount,assetCount,totalValue);

@override
String toString() {
  return 'OrganizationStats(employeeCount: $employeeCount, assetCount: $assetCount, totalValue: $totalValue)';
}


}

/// @nodoc
abstract mixin class $OrganizationStatsCopyWith<$Res>  {
  factory $OrganizationStatsCopyWith(OrganizationStats value, $Res Function(OrganizationStats) _then) = _$OrganizationStatsCopyWithImpl;
@useResult
$Res call({
 int employeeCount, int assetCount, int totalValue
});




}
/// @nodoc
class _$OrganizationStatsCopyWithImpl<$Res>
    implements $OrganizationStatsCopyWith<$Res> {
  _$OrganizationStatsCopyWithImpl(this._self, this._then);

  final OrganizationStats _self;
  final $Res Function(OrganizationStats) _then;

/// Create a copy of OrganizationStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? employeeCount = null,Object? assetCount = null,Object? totalValue = null,}) {
  return _then(_self.copyWith(
employeeCount: null == employeeCount ? _self.employeeCount : employeeCount // ignore: cast_nullable_to_non_nullable
as int,assetCount: null == assetCount ? _self.assetCount : assetCount // ignore: cast_nullable_to_non_nullable
as int,totalValue: null == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OrganizationStats].
extension OrganizationStatsPatterns on OrganizationStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrganizationStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrganizationStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrganizationStats value)  $default,){
final _that = this;
switch (_that) {
case _OrganizationStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrganizationStats value)?  $default,){
final _that = this;
switch (_that) {
case _OrganizationStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int employeeCount,  int assetCount,  int totalValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrganizationStats() when $default != null:
return $default(_that.employeeCount,_that.assetCount,_that.totalValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int employeeCount,  int assetCount,  int totalValue)  $default,) {final _that = this;
switch (_that) {
case _OrganizationStats():
return $default(_that.employeeCount,_that.assetCount,_that.totalValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int employeeCount,  int assetCount,  int totalValue)?  $default,) {final _that = this;
switch (_that) {
case _OrganizationStats() when $default != null:
return $default(_that.employeeCount,_that.assetCount,_that.totalValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrganizationStats implements OrganizationStats {
  const _OrganizationStats({this.employeeCount = 0, this.assetCount = 0, this.totalValue = 0});
  factory _OrganizationStats.fromJson(Map<String, dynamic> json) => _$OrganizationStatsFromJson(json);

@override@JsonKey() final  int employeeCount;
@override@JsonKey() final  int assetCount;
@override@JsonKey() final  int totalValue;

/// Create a copy of OrganizationStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizationStatsCopyWith<_OrganizationStats> get copyWith => __$OrganizationStatsCopyWithImpl<_OrganizationStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizationStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrganizationStats&&(identical(other.employeeCount, employeeCount) || other.employeeCount == employeeCount)&&(identical(other.assetCount, assetCount) || other.assetCount == assetCount)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,employeeCount,assetCount,totalValue);

@override
String toString() {
  return 'OrganizationStats(employeeCount: $employeeCount, assetCount: $assetCount, totalValue: $totalValue)';
}


}

/// @nodoc
abstract mixin class _$OrganizationStatsCopyWith<$Res> implements $OrganizationStatsCopyWith<$Res> {
  factory _$OrganizationStatsCopyWith(_OrganizationStats value, $Res Function(_OrganizationStats) _then) = __$OrganizationStatsCopyWithImpl;
@override @useResult
$Res call({
 int employeeCount, int assetCount, int totalValue
});




}
/// @nodoc
class __$OrganizationStatsCopyWithImpl<$Res>
    implements _$OrganizationStatsCopyWith<$Res> {
  __$OrganizationStatsCopyWithImpl(this._self, this._then);

  final _OrganizationStats _self;
  final $Res Function(_OrganizationStats) _then;

/// Create a copy of OrganizationStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? employeeCount = null,Object? assetCount = null,Object? totalValue = null,}) {
  return _then(_OrganizationStats(
employeeCount: null == employeeCount ? _self.employeeCount : employeeCount // ignore: cast_nullable_to_non_nullable
as int,assetCount: null == assetCount ? _self.assetCount : assetCount // ignore: cast_nullable_to_non_nullable
as int,totalValue: null == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
