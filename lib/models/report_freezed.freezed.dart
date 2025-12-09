// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_freezed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Report {

 String get id; String get title; String get location;@TimestampConverter() DateTime get date; ReportStatus get status; String get userId; String get userName; String? get userEmail; String? get cleanerId; String? get cleanerName; String? get verifiedBy; String? get verifiedByName;@NullableTimestampConverter() DateTime? get verifiedAt; String? get verificationNotes; String? get imageUrl; String? get completionImageUrl; String? get description; bool get isUrgent;@NullableTimestampConverter() DateTime? get assignedAt;@NullableTimestampConverter() DateTime? get startedAt;@NullableTimestampConverter() DateTime? get completedAt; String? get departmentId;@NullableTimestampConverter() DateTime? get deletedAt; String? get deletedBy;
/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportCopyWith<Report> get copyWith => _$ReportCopyWithImpl<Report>(this as Report, _$identity);

  /// Serializes this Report to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Report&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.location, location) || other.location == location)&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.cleanerId, cleanerId) || other.cleanerId == cleanerId)&&(identical(other.cleanerName, cleanerName) || other.cleanerName == cleanerName)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.verifiedByName, verifiedByName) || other.verifiedByName == verifiedByName)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.verificationNotes, verificationNotes) || other.verificationNotes == verificationNotes)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.completionImageUrl, completionImageUrl) || other.completionImageUrl == completionImageUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.isUrgent, isUrgent) || other.isUrgent == isUrgent)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.departmentId, departmentId) || other.departmentId == departmentId)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.deletedBy, deletedBy) || other.deletedBy == deletedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,location,date,status,userId,userName,userEmail,cleanerId,cleanerName,verifiedBy,verifiedByName,verifiedAt,verificationNotes,imageUrl,completionImageUrl,description,isUrgent,assignedAt,startedAt,completedAt,departmentId,deletedAt,deletedBy]);

@override
String toString() {
  return 'Report(id: $id, title: $title, location: $location, date: $date, status: $status, userId: $userId, userName: $userName, userEmail: $userEmail, cleanerId: $cleanerId, cleanerName: $cleanerName, verifiedBy: $verifiedBy, verifiedByName: $verifiedByName, verifiedAt: $verifiedAt, verificationNotes: $verificationNotes, imageUrl: $imageUrl, completionImageUrl: $completionImageUrl, description: $description, isUrgent: $isUrgent, assignedAt: $assignedAt, startedAt: $startedAt, completedAt: $completedAt, departmentId: $departmentId, deletedAt: $deletedAt, deletedBy: $deletedBy)';
}


}

/// @nodoc
abstract mixin class $ReportCopyWith<$Res>  {
  factory $ReportCopyWith(Report value, $Res Function(Report) _then) = _$ReportCopyWithImpl;
@useResult
$Res call({
 String id, String title, String location,@TimestampConverter() DateTime date, ReportStatus status, String userId, String userName, String? userEmail, String? cleanerId, String? cleanerName, String? verifiedBy, String? verifiedByName,@NullableTimestampConverter() DateTime? verifiedAt, String? verificationNotes, String? imageUrl, String? completionImageUrl, String? description, bool isUrgent,@NullableTimestampConverter() DateTime? assignedAt,@NullableTimestampConverter() DateTime? startedAt,@NullableTimestampConverter() DateTime? completedAt, String? departmentId,@NullableTimestampConverter() DateTime? deletedAt, String? deletedBy
});




}
/// @nodoc
class _$ReportCopyWithImpl<$Res>
    implements $ReportCopyWith<$Res> {
  _$ReportCopyWithImpl(this._self, this._then);

  final Report _self;
  final $Res Function(Report) _then;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? location = null,Object? date = null,Object? status = null,Object? userId = null,Object? userName = null,Object? userEmail = freezed,Object? cleanerId = freezed,Object? cleanerName = freezed,Object? verifiedBy = freezed,Object? verifiedByName = freezed,Object? verifiedAt = freezed,Object? verificationNotes = freezed,Object? imageUrl = freezed,Object? completionImageUrl = freezed,Object? description = freezed,Object? isUrgent = null,Object? assignedAt = freezed,Object? startedAt = freezed,Object? completedAt = freezed,Object? departmentId = freezed,Object? deletedAt = freezed,Object? deletedBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userEmail: freezed == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String?,cleanerId: freezed == cleanerId ? _self.cleanerId : cleanerId // ignore: cast_nullable_to_non_nullable
as String?,cleanerName: freezed == cleanerName ? _self.cleanerName : cleanerName // ignore: cast_nullable_to_non_nullable
as String?,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as String?,verifiedByName: freezed == verifiedByName ? _self.verifiedByName : verifiedByName // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,verificationNotes: freezed == verificationNotes ? _self.verificationNotes : verificationNotes // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,completionImageUrl: freezed == completionImageUrl ? _self.completionImageUrl : completionImageUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isUrgent: null == isUrgent ? _self.isUrgent : isUrgent // ignore: cast_nullable_to_non_nullable
as bool,assignedAt: freezed == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,departmentId: freezed == departmentId ? _self.departmentId : departmentId // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedBy: freezed == deletedBy ? _self.deletedBy : deletedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Report].
extension ReportPatterns on Report {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Report value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Report() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Report value)  $default,){
final _that = this;
switch (_that) {
case _Report():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Report value)?  $default,){
final _that = this;
switch (_that) {
case _Report() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String location, @TimestampConverter()  DateTime date,  ReportStatus status,  String userId,  String userName,  String? userEmail,  String? cleanerId,  String? cleanerName,  String? verifiedBy,  String? verifiedByName, @NullableTimestampConverter()  DateTime? verifiedAt,  String? verificationNotes,  String? imageUrl,  String? completionImageUrl,  String? description,  bool isUrgent, @NullableTimestampConverter()  DateTime? assignedAt, @NullableTimestampConverter()  DateTime? startedAt, @NullableTimestampConverter()  DateTime? completedAt,  String? departmentId, @NullableTimestampConverter()  DateTime? deletedAt,  String? deletedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.id,_that.title,_that.location,_that.date,_that.status,_that.userId,_that.userName,_that.userEmail,_that.cleanerId,_that.cleanerName,_that.verifiedBy,_that.verifiedByName,_that.verifiedAt,_that.verificationNotes,_that.imageUrl,_that.completionImageUrl,_that.description,_that.isUrgent,_that.assignedAt,_that.startedAt,_that.completedAt,_that.departmentId,_that.deletedAt,_that.deletedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String location, @TimestampConverter()  DateTime date,  ReportStatus status,  String userId,  String userName,  String? userEmail,  String? cleanerId,  String? cleanerName,  String? verifiedBy,  String? verifiedByName, @NullableTimestampConverter()  DateTime? verifiedAt,  String? verificationNotes,  String? imageUrl,  String? completionImageUrl,  String? description,  bool isUrgent, @NullableTimestampConverter()  DateTime? assignedAt, @NullableTimestampConverter()  DateTime? startedAt, @NullableTimestampConverter()  DateTime? completedAt,  String? departmentId, @NullableTimestampConverter()  DateTime? deletedAt,  String? deletedBy)  $default,) {final _that = this;
switch (_that) {
case _Report():
return $default(_that.id,_that.title,_that.location,_that.date,_that.status,_that.userId,_that.userName,_that.userEmail,_that.cleanerId,_that.cleanerName,_that.verifiedBy,_that.verifiedByName,_that.verifiedAt,_that.verificationNotes,_that.imageUrl,_that.completionImageUrl,_that.description,_that.isUrgent,_that.assignedAt,_that.startedAt,_that.completedAt,_that.departmentId,_that.deletedAt,_that.deletedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String location, @TimestampConverter()  DateTime date,  ReportStatus status,  String userId,  String userName,  String? userEmail,  String? cleanerId,  String? cleanerName,  String? verifiedBy,  String? verifiedByName, @NullableTimestampConverter()  DateTime? verifiedAt,  String? verificationNotes,  String? imageUrl,  String? completionImageUrl,  String? description,  bool isUrgent, @NullableTimestampConverter()  DateTime? assignedAt, @NullableTimestampConverter()  DateTime? startedAt, @NullableTimestampConverter()  DateTime? completedAt,  String? departmentId, @NullableTimestampConverter()  DateTime? deletedAt,  String? deletedBy)?  $default,) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.id,_that.title,_that.location,_that.date,_that.status,_that.userId,_that.userName,_that.userEmail,_that.cleanerId,_that.cleanerName,_that.verifiedBy,_that.verifiedByName,_that.verifiedAt,_that.verificationNotes,_that.imageUrl,_that.completionImageUrl,_that.description,_that.isUrgent,_that.assignedAt,_that.startedAt,_that.completedAt,_that.departmentId,_that.deletedAt,_that.deletedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Report extends Report {
  const _Report({required this.id, required this.title, required this.location, @TimestampConverter() required this.date, required this.status, required this.userId, required this.userName, this.userEmail, this.cleanerId, this.cleanerName, this.verifiedBy, this.verifiedByName, @NullableTimestampConverter() this.verifiedAt, this.verificationNotes, this.imageUrl, this.completionImageUrl, this.description, this.isUrgent = false, @NullableTimestampConverter() this.assignedAt, @NullableTimestampConverter() this.startedAt, @NullableTimestampConverter() this.completedAt, this.departmentId, @NullableTimestampConverter() this.deletedAt, this.deletedBy}): super._();
  factory _Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

@override final  String id;
@override final  String title;
@override final  String location;
@override@TimestampConverter() final  DateTime date;
@override final  ReportStatus status;
@override final  String userId;
@override final  String userName;
@override final  String? userEmail;
@override final  String? cleanerId;
@override final  String? cleanerName;
@override final  String? verifiedBy;
@override final  String? verifiedByName;
@override@NullableTimestampConverter() final  DateTime? verifiedAt;
@override final  String? verificationNotes;
@override final  String? imageUrl;
@override final  String? completionImageUrl;
@override final  String? description;
@override@JsonKey() final  bool isUrgent;
@override@NullableTimestampConverter() final  DateTime? assignedAt;
@override@NullableTimestampConverter() final  DateTime? startedAt;
@override@NullableTimestampConverter() final  DateTime? completedAt;
@override final  String? departmentId;
@override@NullableTimestampConverter() final  DateTime? deletedAt;
@override final  String? deletedBy;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportCopyWith<_Report> get copyWith => __$ReportCopyWithImpl<_Report>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Report&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.location, location) || other.location == location)&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.cleanerId, cleanerId) || other.cleanerId == cleanerId)&&(identical(other.cleanerName, cleanerName) || other.cleanerName == cleanerName)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.verifiedByName, verifiedByName) || other.verifiedByName == verifiedByName)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.verificationNotes, verificationNotes) || other.verificationNotes == verificationNotes)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.completionImageUrl, completionImageUrl) || other.completionImageUrl == completionImageUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.isUrgent, isUrgent) || other.isUrgent == isUrgent)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.departmentId, departmentId) || other.departmentId == departmentId)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.deletedBy, deletedBy) || other.deletedBy == deletedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,location,date,status,userId,userName,userEmail,cleanerId,cleanerName,verifiedBy,verifiedByName,verifiedAt,verificationNotes,imageUrl,completionImageUrl,description,isUrgent,assignedAt,startedAt,completedAt,departmentId,deletedAt,deletedBy]);

@override
String toString() {
  return 'Report(id: $id, title: $title, location: $location, date: $date, status: $status, userId: $userId, userName: $userName, userEmail: $userEmail, cleanerId: $cleanerId, cleanerName: $cleanerName, verifiedBy: $verifiedBy, verifiedByName: $verifiedByName, verifiedAt: $verifiedAt, verificationNotes: $verificationNotes, imageUrl: $imageUrl, completionImageUrl: $completionImageUrl, description: $description, isUrgent: $isUrgent, assignedAt: $assignedAt, startedAt: $startedAt, completedAt: $completedAt, departmentId: $departmentId, deletedAt: $deletedAt, deletedBy: $deletedBy)';
}


}

/// @nodoc
abstract mixin class _$ReportCopyWith<$Res> implements $ReportCopyWith<$Res> {
  factory _$ReportCopyWith(_Report value, $Res Function(_Report) _then) = __$ReportCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String location,@TimestampConverter() DateTime date, ReportStatus status, String userId, String userName, String? userEmail, String? cleanerId, String? cleanerName, String? verifiedBy, String? verifiedByName,@NullableTimestampConverter() DateTime? verifiedAt, String? verificationNotes, String? imageUrl, String? completionImageUrl, String? description, bool isUrgent,@NullableTimestampConverter() DateTime? assignedAt,@NullableTimestampConverter() DateTime? startedAt,@NullableTimestampConverter() DateTime? completedAt, String? departmentId,@NullableTimestampConverter() DateTime? deletedAt, String? deletedBy
});




}
/// @nodoc
class __$ReportCopyWithImpl<$Res>
    implements _$ReportCopyWith<$Res> {
  __$ReportCopyWithImpl(this._self, this._then);

  final _Report _self;
  final $Res Function(_Report) _then;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? location = null,Object? date = null,Object? status = null,Object? userId = null,Object? userName = null,Object? userEmail = freezed,Object? cleanerId = freezed,Object? cleanerName = freezed,Object? verifiedBy = freezed,Object? verifiedByName = freezed,Object? verifiedAt = freezed,Object? verificationNotes = freezed,Object? imageUrl = freezed,Object? completionImageUrl = freezed,Object? description = freezed,Object? isUrgent = null,Object? assignedAt = freezed,Object? startedAt = freezed,Object? completedAt = freezed,Object? departmentId = freezed,Object? deletedAt = freezed,Object? deletedBy = freezed,}) {
  return _then(_Report(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userEmail: freezed == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String?,cleanerId: freezed == cleanerId ? _self.cleanerId : cleanerId // ignore: cast_nullable_to_non_nullable
as String?,cleanerName: freezed == cleanerName ? _self.cleanerName : cleanerName // ignore: cast_nullable_to_non_nullable
as String?,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as String?,verifiedByName: freezed == verifiedByName ? _self.verifiedByName : verifiedByName // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,verificationNotes: freezed == verificationNotes ? _self.verificationNotes : verificationNotes // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,completionImageUrl: freezed == completionImageUrl ? _self.completionImageUrl : completionImageUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isUrgent: null == isUrgent ? _self.isUrgent : isUrgent // ignore: cast_nullable_to_non_nullable
as bool,assignedAt: freezed == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,departmentId: freezed == departmentId ? _self.departmentId : departmentId // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedBy: freezed == deletedBy ? _self.deletedBy : deletedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
