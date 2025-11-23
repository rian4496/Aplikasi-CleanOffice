// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model_freezed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppNotification {

 String get id; String get userId;// Who receives this notification
 NotificationType get type; String get title; String get message; Map<String, dynamic>? get data;// Extra data (reportId, etc.)
 bool get read;@ISODateTimeConverter() DateTime get createdAt;
/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppNotificationCopyWith<AppNotification> get copyWith => _$AppNotificationCopyWithImpl<AppNotification>(this as AppNotification, _$identity);

  /// Serializes this AppNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.read, read) || other.read == read)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,title,message,const DeepCollectionEquality().hash(data),read,createdAt);

@override
String toString() {
  return 'AppNotification(id: $id, userId: $userId, type: $type, title: $title, message: $message, data: $data, read: $read, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AppNotificationCopyWith<$Res>  {
  factory $AppNotificationCopyWith(AppNotification value, $Res Function(AppNotification) _then) = _$AppNotificationCopyWithImpl;
@useResult
$Res call({
 String id, String userId, NotificationType type, String title, String message, Map<String, dynamic>? data, bool read,@ISODateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class _$AppNotificationCopyWithImpl<$Res>
    implements $AppNotificationCopyWith<$Res> {
  _$AppNotificationCopyWithImpl(this._self, this._then);

  final AppNotification _self;
  final $Res Function(AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? title = null,Object? message = null,Object? data = freezed,Object? read = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AppNotification].
extension AppNotificationPatterns on AppNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppNotification value)  $default,){
final _that = this;
switch (_that) {
case _AppNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppNotification value)?  $default,){
final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  NotificationType type,  String title,  String message,  Map<String, dynamic>? data,  bool read, @ISODateTimeConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.title,_that.message,_that.data,_that.read,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  NotificationType type,  String title,  String message,  Map<String, dynamic>? data,  bool read, @ISODateTimeConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AppNotification():
return $default(_that.id,_that.userId,_that.type,_that.title,_that.message,_that.data,_that.read,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  NotificationType type,  String title,  String message,  Map<String, dynamic>? data,  bool read, @ISODateTimeConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.title,_that.message,_that.data,_that.read,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppNotification extends AppNotification {
  const _AppNotification({required this.id, required this.userId, required this.type, required this.title, required this.message, final  Map<String, dynamic>? data, this.read = false, @ISODateTimeConverter() required this.createdAt}): _data = data,super._();
  factory _AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);

@override final  String id;
@override final  String userId;
// Who receives this notification
@override final  NotificationType type;
@override final  String title;
@override final  String message;
 final  Map<String, dynamic>? _data;
@override Map<String, dynamic>? get data {
  final value = _data;
  if (value == null) return null;
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// Extra data (reportId, etc.)
@override@JsonKey() final  bool read;
@override@ISODateTimeConverter() final  DateTime createdAt;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppNotificationCopyWith<_AppNotification> get copyWith => __$AppNotificationCopyWithImpl<_AppNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.read, read) || other.read == read)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,title,message,const DeepCollectionEquality().hash(_data),read,createdAt);

@override
String toString() {
  return 'AppNotification(id: $id, userId: $userId, type: $type, title: $title, message: $message, data: $data, read: $read, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AppNotificationCopyWith<$Res> implements $AppNotificationCopyWith<$Res> {
  factory _$AppNotificationCopyWith(_AppNotification value, $Res Function(_AppNotification) _then) = __$AppNotificationCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, NotificationType type, String title, String message, Map<String, dynamic>? data, bool read,@ISODateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class __$AppNotificationCopyWithImpl<$Res>
    implements _$AppNotificationCopyWith<$Res> {
  __$AppNotificationCopyWithImpl(this._self, this._then);

  final _AppNotification _self;
  final $Res Function(_AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? title = null,Object? message = null,Object? data = freezed,Object? read = null,Object? createdAt = null,}) {
  return _then(_AppNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$NotificationSettings {

 String get userId; bool get enabled; bool get urgentReport; bool get reportAssigned; bool get reportCompleted; bool get reportOverdue; bool get reportRejected; bool get newComment; bool get sound; bool get vibration;
/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationSettingsCopyWith<NotificationSettings> get copyWith => _$NotificationSettingsCopyWithImpl<NotificationSettings>(this as NotificationSettings, _$identity);

  /// Serializes this NotificationSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationSettings&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.urgentReport, urgentReport) || other.urgentReport == urgentReport)&&(identical(other.reportAssigned, reportAssigned) || other.reportAssigned == reportAssigned)&&(identical(other.reportCompleted, reportCompleted) || other.reportCompleted == reportCompleted)&&(identical(other.reportOverdue, reportOverdue) || other.reportOverdue == reportOverdue)&&(identical(other.reportRejected, reportRejected) || other.reportRejected == reportRejected)&&(identical(other.newComment, newComment) || other.newComment == newComment)&&(identical(other.sound, sound) || other.sound == sound)&&(identical(other.vibration, vibration) || other.vibration == vibration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,enabled,urgentReport,reportAssigned,reportCompleted,reportOverdue,reportRejected,newComment,sound,vibration);

@override
String toString() {
  return 'NotificationSettings(userId: $userId, enabled: $enabled, urgentReport: $urgentReport, reportAssigned: $reportAssigned, reportCompleted: $reportCompleted, reportOverdue: $reportOverdue, reportRejected: $reportRejected, newComment: $newComment, sound: $sound, vibration: $vibration)';
}


}

/// @nodoc
abstract mixin class $NotificationSettingsCopyWith<$Res>  {
  factory $NotificationSettingsCopyWith(NotificationSettings value, $Res Function(NotificationSettings) _then) = _$NotificationSettingsCopyWithImpl;
@useResult
$Res call({
 String userId, bool enabled, bool urgentReport, bool reportAssigned, bool reportCompleted, bool reportOverdue, bool reportRejected, bool newComment, bool sound, bool vibration
});




}
/// @nodoc
class _$NotificationSettingsCopyWithImpl<$Res>
    implements $NotificationSettingsCopyWith<$Res> {
  _$NotificationSettingsCopyWithImpl(this._self, this._then);

  final NotificationSettings _self;
  final $Res Function(NotificationSettings) _then;

/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? enabled = null,Object? urgentReport = null,Object? reportAssigned = null,Object? reportCompleted = null,Object? reportOverdue = null,Object? reportRejected = null,Object? newComment = null,Object? sound = null,Object? vibration = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,urgentReport: null == urgentReport ? _self.urgentReport : urgentReport // ignore: cast_nullable_to_non_nullable
as bool,reportAssigned: null == reportAssigned ? _self.reportAssigned : reportAssigned // ignore: cast_nullable_to_non_nullable
as bool,reportCompleted: null == reportCompleted ? _self.reportCompleted : reportCompleted // ignore: cast_nullable_to_non_nullable
as bool,reportOverdue: null == reportOverdue ? _self.reportOverdue : reportOverdue // ignore: cast_nullable_to_non_nullable
as bool,reportRejected: null == reportRejected ? _self.reportRejected : reportRejected // ignore: cast_nullable_to_non_nullable
as bool,newComment: null == newComment ? _self.newComment : newComment // ignore: cast_nullable_to_non_nullable
as bool,sound: null == sound ? _self.sound : sound // ignore: cast_nullable_to_non_nullable
as bool,vibration: null == vibration ? _self.vibration : vibration // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationSettings].
extension NotificationSettingsPatterns on NotificationSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationSettings value)  $default,){
final _that = this;
switch (_that) {
case _NotificationSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationSettings value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  bool enabled,  bool urgentReport,  bool reportAssigned,  bool reportCompleted,  bool reportOverdue,  bool reportRejected,  bool newComment,  bool sound,  bool vibration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
return $default(_that.userId,_that.enabled,_that.urgentReport,_that.reportAssigned,_that.reportCompleted,_that.reportOverdue,_that.reportRejected,_that.newComment,_that.sound,_that.vibration);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  bool enabled,  bool urgentReport,  bool reportAssigned,  bool reportCompleted,  bool reportOverdue,  bool reportRejected,  bool newComment,  bool sound,  bool vibration)  $default,) {final _that = this;
switch (_that) {
case _NotificationSettings():
return $default(_that.userId,_that.enabled,_that.urgentReport,_that.reportAssigned,_that.reportCompleted,_that.reportOverdue,_that.reportRejected,_that.newComment,_that.sound,_that.vibration);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  bool enabled,  bool urgentReport,  bool reportAssigned,  bool reportCompleted,  bool reportOverdue,  bool reportRejected,  bool newComment,  bool sound,  bool vibration)?  $default,) {final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
return $default(_that.userId,_that.enabled,_that.urgentReport,_that.reportAssigned,_that.reportCompleted,_that.reportOverdue,_that.reportRejected,_that.newComment,_that.sound,_that.vibration);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationSettings extends NotificationSettings {
  const _NotificationSettings({required this.userId, this.enabled = true, this.urgentReport = true, this.reportAssigned = true, this.reportCompleted = true, this.reportOverdue = true, this.reportRejected = true, this.newComment = true, this.sound = true, this.vibration = true}): super._();
  factory _NotificationSettings.fromJson(Map<String, dynamic> json) => _$NotificationSettingsFromJson(json);

@override final  String userId;
@override@JsonKey() final  bool enabled;
@override@JsonKey() final  bool urgentReport;
@override@JsonKey() final  bool reportAssigned;
@override@JsonKey() final  bool reportCompleted;
@override@JsonKey() final  bool reportOverdue;
@override@JsonKey() final  bool reportRejected;
@override@JsonKey() final  bool newComment;
@override@JsonKey() final  bool sound;
@override@JsonKey() final  bool vibration;

/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationSettingsCopyWith<_NotificationSettings> get copyWith => __$NotificationSettingsCopyWithImpl<_NotificationSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationSettings&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.urgentReport, urgentReport) || other.urgentReport == urgentReport)&&(identical(other.reportAssigned, reportAssigned) || other.reportAssigned == reportAssigned)&&(identical(other.reportCompleted, reportCompleted) || other.reportCompleted == reportCompleted)&&(identical(other.reportOverdue, reportOverdue) || other.reportOverdue == reportOverdue)&&(identical(other.reportRejected, reportRejected) || other.reportRejected == reportRejected)&&(identical(other.newComment, newComment) || other.newComment == newComment)&&(identical(other.sound, sound) || other.sound == sound)&&(identical(other.vibration, vibration) || other.vibration == vibration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,enabled,urgentReport,reportAssigned,reportCompleted,reportOverdue,reportRejected,newComment,sound,vibration);

@override
String toString() {
  return 'NotificationSettings(userId: $userId, enabled: $enabled, urgentReport: $urgentReport, reportAssigned: $reportAssigned, reportCompleted: $reportCompleted, reportOverdue: $reportOverdue, reportRejected: $reportRejected, newComment: $newComment, sound: $sound, vibration: $vibration)';
}


}

/// @nodoc
abstract mixin class _$NotificationSettingsCopyWith<$Res> implements $NotificationSettingsCopyWith<$Res> {
  factory _$NotificationSettingsCopyWith(_NotificationSettings value, $Res Function(_NotificationSettings) _then) = __$NotificationSettingsCopyWithImpl;
@override @useResult
$Res call({
 String userId, bool enabled, bool urgentReport, bool reportAssigned, bool reportCompleted, bool reportOverdue, bool reportRejected, bool newComment, bool sound, bool vibration
});




}
/// @nodoc
class __$NotificationSettingsCopyWithImpl<$Res>
    implements _$NotificationSettingsCopyWith<$Res> {
  __$NotificationSettingsCopyWithImpl(this._self, this._then);

  final _NotificationSettings _self;
  final $Res Function(_NotificationSettings) _then;

/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? enabled = null,Object? urgentReport = null,Object? reportAssigned = null,Object? reportCompleted = null,Object? reportOverdue = null,Object? reportRejected = null,Object? newComment = null,Object? sound = null,Object? vibration = null,}) {
  return _then(_NotificationSettings(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,urgentReport: null == urgentReport ? _self.urgentReport : urgentReport // ignore: cast_nullable_to_non_nullable
as bool,reportAssigned: null == reportAssigned ? _self.reportAssigned : reportAssigned // ignore: cast_nullable_to_non_nullable
as bool,reportCompleted: null == reportCompleted ? _self.reportCompleted : reportCompleted // ignore: cast_nullable_to_non_nullable
as bool,reportOverdue: null == reportOverdue ? _self.reportOverdue : reportOverdue // ignore: cast_nullable_to_non_nullable
as bool,reportRejected: null == reportRejected ? _self.reportRejected : reportRejected // ignore: cast_nullable_to_non_nullable
as bool,newComment: null == newComment ? _self.newComment : newComment // ignore: cast_nullable_to_non_nullable
as bool,sound: null == sound ? _self.sound : sound // ignore: cast_nullable_to_non_nullable
as bool,vibration: null == vibration ? _self.vibration : vibration // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
