// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_freezed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Request {

 String get id;// ==================== REQUEST INFO ====================
 String get location;// "Parkiran Depan", "Pantry Lt 2", etc
 String get description;// Detail request
 bool get isUrgent;// Urgent flag
@NullableTimestampConverter() DateTime? get preferredDateTime;// When user wants service (optional)
// ==================== REQUESTER INFO ====================
 String get requestedBy;// userId (employee/admin)
 String get requestedByName;// User's name
 String get requestedByRole;// 'employee' (future: 'admin')
// ==================== ASSIGNMENT INFO ====================
 String? get assignedTo;// cleanerId (null if pending)
 String? get assignedToName;// Cleaner's name
@NullableTimestampConverter() DateTime? get assignedAt;// When assigned
 String? get assignedBy;// 'employee' | 'self' | 'admin' (tracking)
// ==================== STATUS & COMPLETION ====================
 RequestStatus get status;// Current status
 String? get imageUrl;// Initial photo (optional)
 String? get completionImageUrl;// Completion proof (optional)
 String? get completionNotes;// Notes from cleaner when completing
// ==================== TIMESTAMPS ====================
@TimestampConverter() DateTime get createdAt;// When request created
@NullableTimestampConverter() DateTime? get startedAt;// When cleaner started
@NullableTimestampConverter() DateTime? get completedAt;// When cleaner completed
// ==================== SOFT DELETE ====================
@NullableTimestampConverter() DateTime? get deletedAt;// Soft delete timestamp
 String? get deletedBy;
/// Create a copy of Request
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestCopyWith<Request> get copyWith => _$RequestCopyWithImpl<Request>(this as Request, _$identity);

  /// Serializes this Request to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Request&&(identical(other.id, id) || other.id == id)&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description)&&(identical(other.isUrgent, isUrgent) || other.isUrgent == isUrgent)&&(identical(other.preferredDateTime, preferredDateTime) || other.preferredDateTime == preferredDateTime)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy)&&(identical(other.requestedByName, requestedByName) || other.requestedByName == requestedByName)&&(identical(other.requestedByRole, requestedByRole) || other.requestedByRole == requestedByRole)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.assignedToName, assignedToName) || other.assignedToName == assignedToName)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.assignedBy, assignedBy) || other.assignedBy == assignedBy)&&(identical(other.status, status) || other.status == status)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.completionImageUrl, completionImageUrl) || other.completionImageUrl == completionImageUrl)&&(identical(other.completionNotes, completionNotes) || other.completionNotes == completionNotes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.deletedBy, deletedBy) || other.deletedBy == deletedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,location,description,isUrgent,preferredDateTime,requestedBy,requestedByName,requestedByRole,assignedTo,assignedToName,assignedAt,assignedBy,status,imageUrl,completionImageUrl,completionNotes,createdAt,startedAt,completedAt,deletedAt,deletedBy]);

@override
String toString() {
  return 'Request(id: $id, location: $location, description: $description, isUrgent: $isUrgent, preferredDateTime: $preferredDateTime, requestedBy: $requestedBy, requestedByName: $requestedByName, requestedByRole: $requestedByRole, assignedTo: $assignedTo, assignedToName: $assignedToName, assignedAt: $assignedAt, assignedBy: $assignedBy, status: $status, imageUrl: $imageUrl, completionImageUrl: $completionImageUrl, completionNotes: $completionNotes, createdAt: $createdAt, startedAt: $startedAt, completedAt: $completedAt, deletedAt: $deletedAt, deletedBy: $deletedBy)';
}


}

/// @nodoc
abstract mixin class $RequestCopyWith<$Res>  {
  factory $RequestCopyWith(Request value, $Res Function(Request) _then) = _$RequestCopyWithImpl;
@useResult
$Res call({
 String id, String location, String description, bool isUrgent,@NullableTimestampConverter() DateTime? preferredDateTime, String requestedBy, String requestedByName, String requestedByRole, String? assignedTo, String? assignedToName,@NullableTimestampConverter() DateTime? assignedAt, String? assignedBy, RequestStatus status, String? imageUrl, String? completionImageUrl, String? completionNotes,@TimestampConverter() DateTime createdAt,@NullableTimestampConverter() DateTime? startedAt,@NullableTimestampConverter() DateTime? completedAt,@NullableTimestampConverter() DateTime? deletedAt, String? deletedBy
});




}
/// @nodoc
class _$RequestCopyWithImpl<$Res>
    implements $RequestCopyWith<$Res> {
  _$RequestCopyWithImpl(this._self, this._then);

  final Request _self;
  final $Res Function(Request) _then;

/// Create a copy of Request
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? location = null,Object? description = null,Object? isUrgent = null,Object? preferredDateTime = freezed,Object? requestedBy = null,Object? requestedByName = null,Object? requestedByRole = null,Object? assignedTo = freezed,Object? assignedToName = freezed,Object? assignedAt = freezed,Object? assignedBy = freezed,Object? status = null,Object? imageUrl = freezed,Object? completionImageUrl = freezed,Object? completionNotes = freezed,Object? createdAt = null,Object? startedAt = freezed,Object? completedAt = freezed,Object? deletedAt = freezed,Object? deletedBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isUrgent: null == isUrgent ? _self.isUrgent : isUrgent // ignore: cast_nullable_to_non_nullable
as bool,preferredDateTime: freezed == preferredDateTime ? _self.preferredDateTime : preferredDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,requestedBy: null == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as String,requestedByName: null == requestedByName ? _self.requestedByName : requestedByName // ignore: cast_nullable_to_non_nullable
as String,requestedByRole: null == requestedByRole ? _self.requestedByRole : requestedByRole // ignore: cast_nullable_to_non_nullable
as String,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,assignedToName: freezed == assignedToName ? _self.assignedToName : assignedToName // ignore: cast_nullable_to_non_nullable
as String?,assignedAt: freezed == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,assignedBy: freezed == assignedBy ? _self.assignedBy : assignedBy // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequestStatus,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,completionImageUrl: freezed == completionImageUrl ? _self.completionImageUrl : completionImageUrl // ignore: cast_nullable_to_non_nullable
as String?,completionNotes: freezed == completionNotes ? _self.completionNotes : completionNotes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedBy: freezed == deletedBy ? _self.deletedBy : deletedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Request].
extension RequestPatterns on Request {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Request value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Request() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Request value)  $default,){
final _that = this;
switch (_that) {
case _Request():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Request value)?  $default,){
final _that = this;
switch (_that) {
case _Request() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String location,  String description,  bool isUrgent, @NullableTimestampConverter()  DateTime? preferredDateTime,  String requestedBy,  String requestedByName,  String requestedByRole,  String? assignedTo,  String? assignedToName, @NullableTimestampConverter()  DateTime? assignedAt,  String? assignedBy,  RequestStatus status,  String? imageUrl,  String? completionImageUrl,  String? completionNotes, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? startedAt, @NullableTimestampConverter()  DateTime? completedAt, @NullableTimestampConverter()  DateTime? deletedAt,  String? deletedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Request() when $default != null:
return $default(_that.id,_that.location,_that.description,_that.isUrgent,_that.preferredDateTime,_that.requestedBy,_that.requestedByName,_that.requestedByRole,_that.assignedTo,_that.assignedToName,_that.assignedAt,_that.assignedBy,_that.status,_that.imageUrl,_that.completionImageUrl,_that.completionNotes,_that.createdAt,_that.startedAt,_that.completedAt,_that.deletedAt,_that.deletedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String location,  String description,  bool isUrgent, @NullableTimestampConverter()  DateTime? preferredDateTime,  String requestedBy,  String requestedByName,  String requestedByRole,  String? assignedTo,  String? assignedToName, @NullableTimestampConverter()  DateTime? assignedAt,  String? assignedBy,  RequestStatus status,  String? imageUrl,  String? completionImageUrl,  String? completionNotes, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? startedAt, @NullableTimestampConverter()  DateTime? completedAt, @NullableTimestampConverter()  DateTime? deletedAt,  String? deletedBy)  $default,) {final _that = this;
switch (_that) {
case _Request():
return $default(_that.id,_that.location,_that.description,_that.isUrgent,_that.preferredDateTime,_that.requestedBy,_that.requestedByName,_that.requestedByRole,_that.assignedTo,_that.assignedToName,_that.assignedAt,_that.assignedBy,_that.status,_that.imageUrl,_that.completionImageUrl,_that.completionNotes,_that.createdAt,_that.startedAt,_that.completedAt,_that.deletedAt,_that.deletedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String location,  String description,  bool isUrgent, @NullableTimestampConverter()  DateTime? preferredDateTime,  String requestedBy,  String requestedByName,  String requestedByRole,  String? assignedTo,  String? assignedToName, @NullableTimestampConverter()  DateTime? assignedAt,  String? assignedBy,  RequestStatus status,  String? imageUrl,  String? completionImageUrl,  String? completionNotes, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? startedAt, @NullableTimestampConverter()  DateTime? completedAt, @NullableTimestampConverter()  DateTime? deletedAt,  String? deletedBy)?  $default,) {final _that = this;
switch (_that) {
case _Request() when $default != null:
return $default(_that.id,_that.location,_that.description,_that.isUrgent,_that.preferredDateTime,_that.requestedBy,_that.requestedByName,_that.requestedByRole,_that.assignedTo,_that.assignedToName,_that.assignedAt,_that.assignedBy,_that.status,_that.imageUrl,_that.completionImageUrl,_that.completionNotes,_that.createdAt,_that.startedAt,_that.completedAt,_that.deletedAt,_that.deletedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Request extends Request {
  const _Request({required this.id, required this.location, required this.description, this.isUrgent = false, @NullableTimestampConverter() this.preferredDateTime, required this.requestedBy, required this.requestedByName, required this.requestedByRole, this.assignedTo, this.assignedToName, @NullableTimestampConverter() this.assignedAt, this.assignedBy, required this.status, this.imageUrl, this.completionImageUrl, this.completionNotes, @TimestampConverter() required this.createdAt, @NullableTimestampConverter() this.startedAt, @NullableTimestampConverter() this.completedAt, @NullableTimestampConverter() this.deletedAt, this.deletedBy}): super._();
  factory _Request.fromJson(Map<String, dynamic> json) => _$RequestFromJson(json);

@override final  String id;
// ==================== REQUEST INFO ====================
@override final  String location;
// "Parkiran Depan", "Pantry Lt 2", etc
@override final  String description;
// Detail request
@override@JsonKey() final  bool isUrgent;
// Urgent flag
@override@NullableTimestampConverter() final  DateTime? preferredDateTime;
// When user wants service (optional)
// ==================== REQUESTER INFO ====================
@override final  String requestedBy;
// userId (employee/admin)
@override final  String requestedByName;
// User's name
@override final  String requestedByRole;
// 'employee' (future: 'admin')
// ==================== ASSIGNMENT INFO ====================
@override final  String? assignedTo;
// cleanerId (null if pending)
@override final  String? assignedToName;
// Cleaner's name
@override@NullableTimestampConverter() final  DateTime? assignedAt;
// When assigned
@override final  String? assignedBy;
// 'employee' | 'self' | 'admin' (tracking)
// ==================== STATUS & COMPLETION ====================
@override final  RequestStatus status;
// Current status
@override final  String? imageUrl;
// Initial photo (optional)
@override final  String? completionImageUrl;
// Completion proof (optional)
@override final  String? completionNotes;
// Notes from cleaner when completing
// ==================== TIMESTAMPS ====================
@override@TimestampConverter() final  DateTime createdAt;
// When request created
@override@NullableTimestampConverter() final  DateTime? startedAt;
// When cleaner started
@override@NullableTimestampConverter() final  DateTime? completedAt;
// When cleaner completed
// ==================== SOFT DELETE ====================
@override@NullableTimestampConverter() final  DateTime? deletedAt;
// Soft delete timestamp
@override final  String? deletedBy;

/// Create a copy of Request
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestCopyWith<_Request> get copyWith => __$RequestCopyWithImpl<_Request>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Request&&(identical(other.id, id) || other.id == id)&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description)&&(identical(other.isUrgent, isUrgent) || other.isUrgent == isUrgent)&&(identical(other.preferredDateTime, preferredDateTime) || other.preferredDateTime == preferredDateTime)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy)&&(identical(other.requestedByName, requestedByName) || other.requestedByName == requestedByName)&&(identical(other.requestedByRole, requestedByRole) || other.requestedByRole == requestedByRole)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.assignedToName, assignedToName) || other.assignedToName == assignedToName)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.assignedBy, assignedBy) || other.assignedBy == assignedBy)&&(identical(other.status, status) || other.status == status)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.completionImageUrl, completionImageUrl) || other.completionImageUrl == completionImageUrl)&&(identical(other.completionNotes, completionNotes) || other.completionNotes == completionNotes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.deletedBy, deletedBy) || other.deletedBy == deletedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,location,description,isUrgent,preferredDateTime,requestedBy,requestedByName,requestedByRole,assignedTo,assignedToName,assignedAt,assignedBy,status,imageUrl,completionImageUrl,completionNotes,createdAt,startedAt,completedAt,deletedAt,deletedBy]);

@override
String toString() {
  return 'Request(id: $id, location: $location, description: $description, isUrgent: $isUrgent, preferredDateTime: $preferredDateTime, requestedBy: $requestedBy, requestedByName: $requestedByName, requestedByRole: $requestedByRole, assignedTo: $assignedTo, assignedToName: $assignedToName, assignedAt: $assignedAt, assignedBy: $assignedBy, status: $status, imageUrl: $imageUrl, completionImageUrl: $completionImageUrl, completionNotes: $completionNotes, createdAt: $createdAt, startedAt: $startedAt, completedAt: $completedAt, deletedAt: $deletedAt, deletedBy: $deletedBy)';
}


}

/// @nodoc
abstract mixin class _$RequestCopyWith<$Res> implements $RequestCopyWith<$Res> {
  factory _$RequestCopyWith(_Request value, $Res Function(_Request) _then) = __$RequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String location, String description, bool isUrgent,@NullableTimestampConverter() DateTime? preferredDateTime, String requestedBy, String requestedByName, String requestedByRole, String? assignedTo, String? assignedToName,@NullableTimestampConverter() DateTime? assignedAt, String? assignedBy, RequestStatus status, String? imageUrl, String? completionImageUrl, String? completionNotes,@TimestampConverter() DateTime createdAt,@NullableTimestampConverter() DateTime? startedAt,@NullableTimestampConverter() DateTime? completedAt,@NullableTimestampConverter() DateTime? deletedAt, String? deletedBy
});




}
/// @nodoc
class __$RequestCopyWithImpl<$Res>
    implements _$RequestCopyWith<$Res> {
  __$RequestCopyWithImpl(this._self, this._then);

  final _Request _self;
  final $Res Function(_Request) _then;

/// Create a copy of Request
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? location = null,Object? description = null,Object? isUrgent = null,Object? preferredDateTime = freezed,Object? requestedBy = null,Object? requestedByName = null,Object? requestedByRole = null,Object? assignedTo = freezed,Object? assignedToName = freezed,Object? assignedAt = freezed,Object? assignedBy = freezed,Object? status = null,Object? imageUrl = freezed,Object? completionImageUrl = freezed,Object? completionNotes = freezed,Object? createdAt = null,Object? startedAt = freezed,Object? completedAt = freezed,Object? deletedAt = freezed,Object? deletedBy = freezed,}) {
  return _then(_Request(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isUrgent: null == isUrgent ? _self.isUrgent : isUrgent // ignore: cast_nullable_to_non_nullable
as bool,preferredDateTime: freezed == preferredDateTime ? _self.preferredDateTime : preferredDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,requestedBy: null == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as String,requestedByName: null == requestedByName ? _self.requestedByName : requestedByName // ignore: cast_nullable_to_non_nullable
as String,requestedByRole: null == requestedByRole ? _self.requestedByRole : requestedByRole // ignore: cast_nullable_to_non_nullable
as String,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,assignedToName: freezed == assignedToName ? _self.assignedToName : assignedToName // ignore: cast_nullable_to_non_nullable
as String?,assignedAt: freezed == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,assignedBy: freezed == assignedBy ? _self.assignedBy : assignedBy // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequestStatus,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,completionImageUrl: freezed == completionImageUrl ? _self.completionImageUrl : completionImageUrl // ignore: cast_nullable_to_non_nullable
as String?,completionNotes: freezed == completionNotes ? _self.completionNotes : completionNotes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedBy: freezed == deletedBy ? _self.deletedBy : deletedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
