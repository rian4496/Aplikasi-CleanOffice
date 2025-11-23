// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'work_schedule_freezed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkSchedule {

 String get id; String get userId; String get shift;// 'morning', 'afternoon', 'night'
 List<String> get workDays;// ['monday', 'tuesday', etc.]
@TimeOfDayConverter() TimeOfDay get shiftStart;@TimeOfDayConverter() TimeOfDay get shiftEnd; String get location; String get assignedBy;@TimestampConverter() DateTime get createdAt;@NullableTimestampConverter() DateTime? get updatedAt;
/// Create a copy of WorkSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkScheduleCopyWith<WorkSchedule> get copyWith => _$WorkScheduleCopyWithImpl<WorkSchedule>(this as WorkSchedule, _$identity);

  /// Serializes this WorkSchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkSchedule&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.shift, shift) || other.shift == shift)&&const DeepCollectionEquality().equals(other.workDays, workDays)&&(identical(other.shiftStart, shiftStart) || other.shiftStart == shiftStart)&&(identical(other.shiftEnd, shiftEnd) || other.shiftEnd == shiftEnd)&&(identical(other.location, location) || other.location == location)&&(identical(other.assignedBy, assignedBy) || other.assignedBy == assignedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,shift,const DeepCollectionEquality().hash(workDays),shiftStart,shiftEnd,location,assignedBy,createdAt,updatedAt);

@override
String toString() {
  return 'WorkSchedule(id: $id, userId: $userId, shift: $shift, workDays: $workDays, shiftStart: $shiftStart, shiftEnd: $shiftEnd, location: $location, assignedBy: $assignedBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $WorkScheduleCopyWith<$Res>  {
  factory $WorkScheduleCopyWith(WorkSchedule value, $Res Function(WorkSchedule) _then) = _$WorkScheduleCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String shift, List<String> workDays,@TimeOfDayConverter() TimeOfDay shiftStart,@TimeOfDayConverter() TimeOfDay shiftEnd, String location, String assignedBy,@TimestampConverter() DateTime createdAt,@NullableTimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$WorkScheduleCopyWithImpl<$Res>
    implements $WorkScheduleCopyWith<$Res> {
  _$WorkScheduleCopyWithImpl(this._self, this._then);

  final WorkSchedule _self;
  final $Res Function(WorkSchedule) _then;

/// Create a copy of WorkSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? shift = null,Object? workDays = null,Object? shiftStart = null,Object? shiftEnd = null,Object? location = null,Object? assignedBy = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,shift: null == shift ? _self.shift : shift // ignore: cast_nullable_to_non_nullable
as String,workDays: null == workDays ? _self.workDays : workDays // ignore: cast_nullable_to_non_nullable
as List<String>,shiftStart: null == shiftStart ? _self.shiftStart : shiftStart // ignore: cast_nullable_to_non_nullable
as TimeOfDay,shiftEnd: null == shiftEnd ? _self.shiftEnd : shiftEnd // ignore: cast_nullable_to_non_nullable
as TimeOfDay,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,assignedBy: null == assignedBy ? _self.assignedBy : assignedBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkSchedule].
extension WorkSchedulePatterns on WorkSchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkSchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkSchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkSchedule value)  $default,){
final _that = this;
switch (_that) {
case _WorkSchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkSchedule value)?  $default,){
final _that = this;
switch (_that) {
case _WorkSchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String shift,  List<String> workDays, @TimeOfDayConverter()  TimeOfDay shiftStart, @TimeOfDayConverter()  TimeOfDay shiftEnd,  String location,  String assignedBy, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkSchedule() when $default != null:
return $default(_that.id,_that.userId,_that.shift,_that.workDays,_that.shiftStart,_that.shiftEnd,_that.location,_that.assignedBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String shift,  List<String> workDays, @TimeOfDayConverter()  TimeOfDay shiftStart, @TimeOfDayConverter()  TimeOfDay shiftEnd,  String location,  String assignedBy, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _WorkSchedule():
return $default(_that.id,_that.userId,_that.shift,_that.workDays,_that.shiftStart,_that.shiftEnd,_that.location,_that.assignedBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String shift,  List<String> workDays, @TimeOfDayConverter()  TimeOfDay shiftStart, @TimeOfDayConverter()  TimeOfDay shiftEnd,  String location,  String assignedBy, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _WorkSchedule() when $default != null:
return $default(_that.id,_that.userId,_that.shift,_that.workDays,_that.shiftStart,_that.shiftEnd,_that.location,_that.assignedBy,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkSchedule extends WorkSchedule {
  const _WorkSchedule({required this.id, required this.userId, required this.shift, required final  List<String> workDays, @TimeOfDayConverter() required this.shiftStart, @TimeOfDayConverter() required this.shiftEnd, required this.location, required this.assignedBy, @TimestampConverter() required this.createdAt, @NullableTimestampConverter() this.updatedAt}): _workDays = workDays,super._();
  factory _WorkSchedule.fromJson(Map<String, dynamic> json) => _$WorkScheduleFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String shift;
// 'morning', 'afternoon', 'night'
 final  List<String> _workDays;
// 'morning', 'afternoon', 'night'
@override List<String> get workDays {
  if (_workDays is EqualUnmodifiableListView) return _workDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workDays);
}

// ['monday', 'tuesday', etc.]
@override@TimeOfDayConverter() final  TimeOfDay shiftStart;
@override@TimeOfDayConverter() final  TimeOfDay shiftEnd;
@override final  String location;
@override final  String assignedBy;
@override@TimestampConverter() final  DateTime createdAt;
@override@NullableTimestampConverter() final  DateTime? updatedAt;

/// Create a copy of WorkSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkScheduleCopyWith<_WorkSchedule> get copyWith => __$WorkScheduleCopyWithImpl<_WorkSchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkSchedule&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.shift, shift) || other.shift == shift)&&const DeepCollectionEquality().equals(other._workDays, _workDays)&&(identical(other.shiftStart, shiftStart) || other.shiftStart == shiftStart)&&(identical(other.shiftEnd, shiftEnd) || other.shiftEnd == shiftEnd)&&(identical(other.location, location) || other.location == location)&&(identical(other.assignedBy, assignedBy) || other.assignedBy == assignedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,shift,const DeepCollectionEquality().hash(_workDays),shiftStart,shiftEnd,location,assignedBy,createdAt,updatedAt);

@override
String toString() {
  return 'WorkSchedule(id: $id, userId: $userId, shift: $shift, workDays: $workDays, shiftStart: $shiftStart, shiftEnd: $shiftEnd, location: $location, assignedBy: $assignedBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$WorkScheduleCopyWith<$Res> implements $WorkScheduleCopyWith<$Res> {
  factory _$WorkScheduleCopyWith(_WorkSchedule value, $Res Function(_WorkSchedule) _then) = __$WorkScheduleCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String shift, List<String> workDays,@TimeOfDayConverter() TimeOfDay shiftStart,@TimeOfDayConverter() TimeOfDay shiftEnd, String location, String assignedBy,@TimestampConverter() DateTime createdAt,@NullableTimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$WorkScheduleCopyWithImpl<$Res>
    implements _$WorkScheduleCopyWith<$Res> {
  __$WorkScheduleCopyWithImpl(this._self, this._then);

  final _WorkSchedule _self;
  final $Res Function(_WorkSchedule) _then;

/// Create a copy of WorkSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? shift = null,Object? workDays = null,Object? shiftStart = null,Object? shiftEnd = null,Object? location = null,Object? assignedBy = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_WorkSchedule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,shift: null == shift ? _self.shift : shift // ignore: cast_nullable_to_non_nullable
as String,workDays: null == workDays ? _self._workDays : workDays // ignore: cast_nullable_to_non_nullable
as List<String>,shiftStart: null == shiftStart ? _self.shiftStart : shiftStart // ignore: cast_nullable_to_non_nullable
as TimeOfDay,shiftEnd: null == shiftEnd ? _self.shiftEnd : shiftEnd // ignore: cast_nullable_to_non_nullable
as TimeOfDay,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,assignedBy: null == assignedBy ? _self.assignedBy : assignedBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
