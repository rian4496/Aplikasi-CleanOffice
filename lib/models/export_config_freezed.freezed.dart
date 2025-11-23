// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'export_config_freezed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExportConfig {

 ExportFormat get format; ReportType get reportType; DateTime? get startDate; DateTime? get endDate; bool get includeCharts; bool get includePhotos; bool get includeStatistics; String? get cleanerId; String? get location;
/// Create a copy of ExportConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportConfigCopyWith<ExportConfig> get copyWith => _$ExportConfigCopyWithImpl<ExportConfig>(this as ExportConfig, _$identity);

  /// Serializes this ExportConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportConfig&&(identical(other.format, format) || other.format == format)&&(identical(other.reportType, reportType) || other.reportType == reportType)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.includeCharts, includeCharts) || other.includeCharts == includeCharts)&&(identical(other.includePhotos, includePhotos) || other.includePhotos == includePhotos)&&(identical(other.includeStatistics, includeStatistics) || other.includeStatistics == includeStatistics)&&(identical(other.cleanerId, cleanerId) || other.cleanerId == cleanerId)&&(identical(other.location, location) || other.location == location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,format,reportType,startDate,endDate,includeCharts,includePhotos,includeStatistics,cleanerId,location);

@override
String toString() {
  return 'ExportConfig(format: $format, reportType: $reportType, startDate: $startDate, endDate: $endDate, includeCharts: $includeCharts, includePhotos: $includePhotos, includeStatistics: $includeStatistics, cleanerId: $cleanerId, location: $location)';
}


}

/// @nodoc
abstract mixin class $ExportConfigCopyWith<$Res>  {
  factory $ExportConfigCopyWith(ExportConfig value, $Res Function(ExportConfig) _then) = _$ExportConfigCopyWithImpl;
@useResult
$Res call({
 ExportFormat format, ReportType reportType, DateTime? startDate, DateTime? endDate, bool includeCharts, bool includePhotos, bool includeStatistics, String? cleanerId, String? location
});




}
/// @nodoc
class _$ExportConfigCopyWithImpl<$Res>
    implements $ExportConfigCopyWith<$Res> {
  _$ExportConfigCopyWithImpl(this._self, this._then);

  final ExportConfig _self;
  final $Res Function(ExportConfig) _then;

/// Create a copy of ExportConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? format = null,Object? reportType = null,Object? startDate = freezed,Object? endDate = freezed,Object? includeCharts = null,Object? includePhotos = null,Object? includeStatistics = null,Object? cleanerId = freezed,Object? location = freezed,}) {
  return _then(_self.copyWith(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExportFormat,reportType: null == reportType ? _self.reportType : reportType // ignore: cast_nullable_to_non_nullable
as ReportType,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,includeCharts: null == includeCharts ? _self.includeCharts : includeCharts // ignore: cast_nullable_to_non_nullable
as bool,includePhotos: null == includePhotos ? _self.includePhotos : includePhotos // ignore: cast_nullable_to_non_nullable
as bool,includeStatistics: null == includeStatistics ? _self.includeStatistics : includeStatistics // ignore: cast_nullable_to_non_nullable
as bool,cleanerId: freezed == cleanerId ? _self.cleanerId : cleanerId // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExportConfig].
extension ExportConfigPatterns on ExportConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportConfig value)  $default,){
final _that = this;
switch (_that) {
case _ExportConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ExportConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ExportFormat format,  ReportType reportType,  DateTime? startDate,  DateTime? endDate,  bool includeCharts,  bool includePhotos,  bool includeStatistics,  String? cleanerId,  String? location)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportConfig() when $default != null:
return $default(_that.format,_that.reportType,_that.startDate,_that.endDate,_that.includeCharts,_that.includePhotos,_that.includeStatistics,_that.cleanerId,_that.location);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ExportFormat format,  ReportType reportType,  DateTime? startDate,  DateTime? endDate,  bool includeCharts,  bool includePhotos,  bool includeStatistics,  String? cleanerId,  String? location)  $default,) {final _that = this;
switch (_that) {
case _ExportConfig():
return $default(_that.format,_that.reportType,_that.startDate,_that.endDate,_that.includeCharts,_that.includePhotos,_that.includeStatistics,_that.cleanerId,_that.location);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ExportFormat format,  ReportType reportType,  DateTime? startDate,  DateTime? endDate,  bool includeCharts,  bool includePhotos,  bool includeStatistics,  String? cleanerId,  String? location)?  $default,) {final _that = this;
switch (_that) {
case _ExportConfig() when $default != null:
return $default(_that.format,_that.reportType,_that.startDate,_that.endDate,_that.includeCharts,_that.includePhotos,_that.includeStatistics,_that.cleanerId,_that.location);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExportConfig extends ExportConfig {
  const _ExportConfig({required this.format, required this.reportType, this.startDate, this.endDate, this.includeCharts = true, this.includePhotos = false, this.includeStatistics = true, this.cleanerId, this.location}): super._();
  factory _ExportConfig.fromJson(Map<String, dynamic> json) => _$ExportConfigFromJson(json);

@override final  ExportFormat format;
@override final  ReportType reportType;
@override final  DateTime? startDate;
@override final  DateTime? endDate;
@override@JsonKey() final  bool includeCharts;
@override@JsonKey() final  bool includePhotos;
@override@JsonKey() final  bool includeStatistics;
@override final  String? cleanerId;
@override final  String? location;

/// Create a copy of ExportConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportConfigCopyWith<_ExportConfig> get copyWith => __$ExportConfigCopyWithImpl<_ExportConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExportConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportConfig&&(identical(other.format, format) || other.format == format)&&(identical(other.reportType, reportType) || other.reportType == reportType)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.includeCharts, includeCharts) || other.includeCharts == includeCharts)&&(identical(other.includePhotos, includePhotos) || other.includePhotos == includePhotos)&&(identical(other.includeStatistics, includeStatistics) || other.includeStatistics == includeStatistics)&&(identical(other.cleanerId, cleanerId) || other.cleanerId == cleanerId)&&(identical(other.location, location) || other.location == location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,format,reportType,startDate,endDate,includeCharts,includePhotos,includeStatistics,cleanerId,location);

@override
String toString() {
  return 'ExportConfig(format: $format, reportType: $reportType, startDate: $startDate, endDate: $endDate, includeCharts: $includeCharts, includePhotos: $includePhotos, includeStatistics: $includeStatistics, cleanerId: $cleanerId, location: $location)';
}


}

/// @nodoc
abstract mixin class _$ExportConfigCopyWith<$Res> implements $ExportConfigCopyWith<$Res> {
  factory _$ExportConfigCopyWith(_ExportConfig value, $Res Function(_ExportConfig) _then) = __$ExportConfigCopyWithImpl;
@override @useResult
$Res call({
 ExportFormat format, ReportType reportType, DateTime? startDate, DateTime? endDate, bool includeCharts, bool includePhotos, bool includeStatistics, String? cleanerId, String? location
});




}
/// @nodoc
class __$ExportConfigCopyWithImpl<$Res>
    implements _$ExportConfigCopyWith<$Res> {
  __$ExportConfigCopyWithImpl(this._self, this._then);

  final _ExportConfig _self;
  final $Res Function(_ExportConfig) _then;

/// Create a copy of ExportConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? format = null,Object? reportType = null,Object? startDate = freezed,Object? endDate = freezed,Object? includeCharts = null,Object? includePhotos = null,Object? includeStatistics = null,Object? cleanerId = freezed,Object? location = freezed,}) {
  return _then(_ExportConfig(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExportFormat,reportType: null == reportType ? _self.reportType : reportType // ignore: cast_nullable_to_non_nullable
as ReportType,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,includeCharts: null == includeCharts ? _self.includeCharts : includeCharts // ignore: cast_nullable_to_non_nullable
as bool,includePhotos: null == includePhotos ? _self.includePhotos : includePhotos // ignore: cast_nullable_to_non_nullable
as bool,includeStatistics: null == includeStatistics ? _self.includeStatistics : includeStatistics // ignore: cast_nullable_to_non_nullable
as bool,cleanerId: freezed == cleanerId ? _self.cleanerId : cleanerId // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ExportResult {

 bool get success; String? get filePath; String? get fileName; int? get fileSize; String? get error; DateTime get exportedAt;
/// Create a copy of ExportResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportResultCopyWith<ExportResult> get copyWith => _$ExportResultCopyWithImpl<ExportResult>(this as ExportResult, _$identity);

  /// Serializes this ExportResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportResult&&(identical(other.success, success) || other.success == success)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.error, error) || other.error == error)&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,filePath,fileName,fileSize,error,exportedAt);

@override
String toString() {
  return 'ExportResult(success: $success, filePath: $filePath, fileName: $fileName, fileSize: $fileSize, error: $error, exportedAt: $exportedAt)';
}


}

/// @nodoc
abstract mixin class $ExportResultCopyWith<$Res>  {
  factory $ExportResultCopyWith(ExportResult value, $Res Function(ExportResult) _then) = _$ExportResultCopyWithImpl;
@useResult
$Res call({
 bool success, String? filePath, String? fileName, int? fileSize, String? error, DateTime exportedAt
});




}
/// @nodoc
class _$ExportResultCopyWithImpl<$Res>
    implements $ExportResultCopyWith<$Res> {
  _$ExportResultCopyWithImpl(this._self, this._then);

  final ExportResult _self;
  final $Res Function(ExportResult) _then;

/// Create a copy of ExportResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? filePath = freezed,Object? fileName = freezed,Object? fileSize = freezed,Object? error = freezed,Object? exportedAt = null,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ExportResult].
extension ExportResultPatterns on ExportResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportResult value)  $default,){
final _that = this;
switch (_that) {
case _ExportResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportResult value)?  $default,){
final _that = this;
switch (_that) {
case _ExportResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  String? filePath,  String? fileName,  int? fileSize,  String? error,  DateTime exportedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportResult() when $default != null:
return $default(_that.success,_that.filePath,_that.fileName,_that.fileSize,_that.error,_that.exportedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  String? filePath,  String? fileName,  int? fileSize,  String? error,  DateTime exportedAt)  $default,) {final _that = this;
switch (_that) {
case _ExportResult():
return $default(_that.success,_that.filePath,_that.fileName,_that.fileSize,_that.error,_that.exportedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  String? filePath,  String? fileName,  int? fileSize,  String? error,  DateTime exportedAt)?  $default,) {final _that = this;
switch (_that) {
case _ExportResult() when $default != null:
return $default(_that.success,_that.filePath,_that.fileName,_that.fileSize,_that.error,_that.exportedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExportResult extends ExportResult {
  const _ExportResult({required this.success, this.filePath, this.fileName, this.fileSize, this.error, required this.exportedAt}): super._();
  factory _ExportResult.fromJson(Map<String, dynamic> json) => _$ExportResultFromJson(json);

@override final  bool success;
@override final  String? filePath;
@override final  String? fileName;
@override final  int? fileSize;
@override final  String? error;
@override final  DateTime exportedAt;

/// Create a copy of ExportResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportResultCopyWith<_ExportResult> get copyWith => __$ExportResultCopyWithImpl<_ExportResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExportResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportResult&&(identical(other.success, success) || other.success == success)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.error, error) || other.error == error)&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,filePath,fileName,fileSize,error,exportedAt);

@override
String toString() {
  return 'ExportResult(success: $success, filePath: $filePath, fileName: $fileName, fileSize: $fileSize, error: $error, exportedAt: $exportedAt)';
}


}

/// @nodoc
abstract mixin class _$ExportResultCopyWith<$Res> implements $ExportResultCopyWith<$Res> {
  factory _$ExportResultCopyWith(_ExportResult value, $Res Function(_ExportResult) _then) = __$ExportResultCopyWithImpl;
@override @useResult
$Res call({
 bool success, String? filePath, String? fileName, int? fileSize, String? error, DateTime exportedAt
});




}
/// @nodoc
class __$ExportResultCopyWithImpl<$Res>
    implements _$ExportResultCopyWith<$Res> {
  __$ExportResultCopyWithImpl(this._self, this._then);

  final _ExportResult _self;
  final $Res Function(_ExportResult) _then;

/// Create a copy of ExportResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? filePath = freezed,Object? fileName = freezed,Object? fileSize = freezed,Object? error = freezed,Object? exportedAt = null,}) {
  return _then(_ExportResult(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ReportData {

 String get title; String get subtitle; DateTime get generatedAt; DateTime? get startDate; DateTime? get endDate; Map<String, dynamic> get summary; List<Map<String, dynamic>> get items;
/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportDataCopyWith<ReportData> get copyWith => _$ReportDataCopyWithImpl<ReportData>(this as ReportData, _$identity);

  /// Serializes this ReportData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportData&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.summary, summary)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,subtitle,generatedAt,startDate,endDate,const DeepCollectionEquality().hash(summary),const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'ReportData(title: $title, subtitle: $subtitle, generatedAt: $generatedAt, startDate: $startDate, endDate: $endDate, summary: $summary, items: $items)';
}


}

/// @nodoc
abstract mixin class $ReportDataCopyWith<$Res>  {
  factory $ReportDataCopyWith(ReportData value, $Res Function(ReportData) _then) = _$ReportDataCopyWithImpl;
@useResult
$Res call({
 String title, String subtitle, DateTime generatedAt, DateTime? startDate, DateTime? endDate, Map<String, dynamic> summary, List<Map<String, dynamic>> items
});




}
/// @nodoc
class _$ReportDataCopyWithImpl<$Res>
    implements $ReportDataCopyWith<$Res> {
  _$ReportDataCopyWithImpl(this._self, this._then);

  final ReportData _self;
  final $Res Function(ReportData) _then;

/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? subtitle = null,Object? generatedAt = null,Object? startDate = freezed,Object? endDate = freezed,Object? summary = null,Object? items = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportData].
extension ReportDataPatterns on ReportData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportData value)  $default,){
final _that = this;
switch (_that) {
case _ReportData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportData value)?  $default,){
final _that = this;
switch (_that) {
case _ReportData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String subtitle,  DateTime generatedAt,  DateTime? startDate,  DateTime? endDate,  Map<String, dynamic> summary,  List<Map<String, dynamic>> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportData() when $default != null:
return $default(_that.title,_that.subtitle,_that.generatedAt,_that.startDate,_that.endDate,_that.summary,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String subtitle,  DateTime generatedAt,  DateTime? startDate,  DateTime? endDate,  Map<String, dynamic> summary,  List<Map<String, dynamic>> items)  $default,) {final _that = this;
switch (_that) {
case _ReportData():
return $default(_that.title,_that.subtitle,_that.generatedAt,_that.startDate,_that.endDate,_that.summary,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String subtitle,  DateTime generatedAt,  DateTime? startDate,  DateTime? endDate,  Map<String, dynamic> summary,  List<Map<String, dynamic>> items)?  $default,) {final _that = this;
switch (_that) {
case _ReportData() when $default != null:
return $default(_that.title,_that.subtitle,_that.generatedAt,_that.startDate,_that.endDate,_that.summary,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportData extends ReportData {
  const _ReportData({required this.title, required this.subtitle, required this.generatedAt, this.startDate, this.endDate, required final  Map<String, dynamic> summary, required final  List<Map<String, dynamic>> items}): _summary = summary,_items = items,super._();
  factory _ReportData.fromJson(Map<String, dynamic> json) => _$ReportDataFromJson(json);

@override final  String title;
@override final  String subtitle;
@override final  DateTime generatedAt;
@override final  DateTime? startDate;
@override final  DateTime? endDate;
 final  Map<String, dynamic> _summary;
@override Map<String, dynamic> get summary {
  if (_summary is EqualUnmodifiableMapView) return _summary;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_summary);
}

 final  List<Map<String, dynamic>> _items;
@override List<Map<String, dynamic>> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportDataCopyWith<_ReportData> get copyWith => __$ReportDataCopyWithImpl<_ReportData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportData&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._summary, _summary)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,subtitle,generatedAt,startDate,endDate,const DeepCollectionEquality().hash(_summary),const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ReportData(title: $title, subtitle: $subtitle, generatedAt: $generatedAt, startDate: $startDate, endDate: $endDate, summary: $summary, items: $items)';
}


}

/// @nodoc
abstract mixin class _$ReportDataCopyWith<$Res> implements $ReportDataCopyWith<$Res> {
  factory _$ReportDataCopyWith(_ReportData value, $Res Function(_ReportData) _then) = __$ReportDataCopyWithImpl;
@override @useResult
$Res call({
 String title, String subtitle, DateTime generatedAt, DateTime? startDate, DateTime? endDate, Map<String, dynamic> summary, List<Map<String, dynamic>> items
});




}
/// @nodoc
class __$ReportDataCopyWithImpl<$Res>
    implements _$ReportDataCopyWith<$Res> {
  __$ReportDataCopyWithImpl(this._self, this._then);

  final _ReportData _self;
  final $Res Function(_ReportData) _then;

/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? subtitle = null,Object? generatedAt = null,Object? startDate = freezed,Object? endDate = freezed,Object? summary = null,Object? items = null,}) {
  return _then(_ReportData(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,summary: null == summary ? _self._summary : summary // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}


}

// dart format on
