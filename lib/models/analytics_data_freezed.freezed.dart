// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_data_freezed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$KPIData {

 String get title; String get value; String? get subtitle; IconData get icon; Color get color; double? get trendPercentage;// Positive = up, Negative = down
 String? get comparisonText;
/// Create a copy of KPIData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KPIDataCopyWith<KPIData> get copyWith => _$KPIDataCopyWithImpl<KPIData>(this as KPIData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KPIData&&(identical(other.title, title) || other.title == title)&&(identical(other.value, value) || other.value == value)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.trendPercentage, trendPercentage) || other.trendPercentage == trendPercentage)&&(identical(other.comparisonText, comparisonText) || other.comparisonText == comparisonText));
}


@override
int get hashCode => Object.hash(runtimeType,title,value,subtitle,icon,color,trendPercentage,comparisonText);

@override
String toString() {
  return 'KPIData(title: $title, value: $value, subtitle: $subtitle, icon: $icon, color: $color, trendPercentage: $trendPercentage, comparisonText: $comparisonText)';
}


}

/// @nodoc
abstract mixin class $KPIDataCopyWith<$Res>  {
  factory $KPIDataCopyWith(KPIData value, $Res Function(KPIData) _then) = _$KPIDataCopyWithImpl;
@useResult
$Res call({
 String title, String value, String? subtitle, IconData icon, Color color, double? trendPercentage, String? comparisonText
});




}
/// @nodoc
class _$KPIDataCopyWithImpl<$Res>
    implements $KPIDataCopyWith<$Res> {
  _$KPIDataCopyWithImpl(this._self, this._then);

  final KPIData _self;
  final $Res Function(KPIData) _then;

/// Create a copy of KPIData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? value = null,Object? subtitle = freezed,Object? icon = null,Object? color = null,Object? trendPercentage = freezed,Object? comparisonText = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,trendPercentage: freezed == trendPercentage ? _self.trendPercentage : trendPercentage // ignore: cast_nullable_to_non_nullable
as double?,comparisonText: freezed == comparisonText ? _self.comparisonText : comparisonText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [KPIData].
extension KPIDataPatterns on KPIData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KPIData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KPIData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KPIData value)  $default,){
final _that = this;
switch (_that) {
case _KPIData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KPIData value)?  $default,){
final _that = this;
switch (_that) {
case _KPIData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String value,  String? subtitle,  IconData icon,  Color color,  double? trendPercentage,  String? comparisonText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KPIData() when $default != null:
return $default(_that.title,_that.value,_that.subtitle,_that.icon,_that.color,_that.trendPercentage,_that.comparisonText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String value,  String? subtitle,  IconData icon,  Color color,  double? trendPercentage,  String? comparisonText)  $default,) {final _that = this;
switch (_that) {
case _KPIData():
return $default(_that.title,_that.value,_that.subtitle,_that.icon,_that.color,_that.trendPercentage,_that.comparisonText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String value,  String? subtitle,  IconData icon,  Color color,  double? trendPercentage,  String? comparisonText)?  $default,) {final _that = this;
switch (_that) {
case _KPIData() when $default != null:
return $default(_that.title,_that.value,_that.subtitle,_that.icon,_that.color,_that.trendPercentage,_that.comparisonText);case _:
  return null;

}
}

}

/// @nodoc


class _KPIData extends KPIData {
  const _KPIData({required this.title, required this.value, this.subtitle, required this.icon, required this.color, this.trendPercentage, this.comparisonText}): super._();
  

@override final  String title;
@override final  String value;
@override final  String? subtitle;
@override final  IconData icon;
@override final  Color color;
@override final  double? trendPercentage;
// Positive = up, Negative = down
@override final  String? comparisonText;

/// Create a copy of KPIData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KPIDataCopyWith<_KPIData> get copyWith => __$KPIDataCopyWithImpl<_KPIData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KPIData&&(identical(other.title, title) || other.title == title)&&(identical(other.value, value) || other.value == value)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.trendPercentage, trendPercentage) || other.trendPercentage == trendPercentage)&&(identical(other.comparisonText, comparisonText) || other.comparisonText == comparisonText));
}


@override
int get hashCode => Object.hash(runtimeType,title,value,subtitle,icon,color,trendPercentage,comparisonText);

@override
String toString() {
  return 'KPIData(title: $title, value: $value, subtitle: $subtitle, icon: $icon, color: $color, trendPercentage: $trendPercentage, comparisonText: $comparisonText)';
}


}

/// @nodoc
abstract mixin class _$KPIDataCopyWith<$Res> implements $KPIDataCopyWith<$Res> {
  factory _$KPIDataCopyWith(_KPIData value, $Res Function(_KPIData) _then) = __$KPIDataCopyWithImpl;
@override @useResult
$Res call({
 String title, String value, String? subtitle, IconData icon, Color color, double? trendPercentage, String? comparisonText
});




}
/// @nodoc
class __$KPIDataCopyWithImpl<$Res>
    implements _$KPIDataCopyWith<$Res> {
  __$KPIDataCopyWithImpl(this._self, this._then);

  final _KPIData _self;
  final $Res Function(_KPIData) _then;

/// Create a copy of KPIData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? value = null,Object? subtitle = freezed,Object? icon = null,Object? color = null,Object? trendPercentage = freezed,Object? comparisonText = freezed,}) {
  return _then(_KPIData(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,trendPercentage: freezed == trendPercentage ? _self.trendPercentage : trendPercentage // ignore: cast_nullable_to_non_nullable
as double?,comparisonText: freezed == comparisonText ? _self.comparisonText : comparisonText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$TrendDataPoint {

 DateTime get date; double get value; String get label;
/// Create a copy of TrendDataPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrendDataPointCopyWith<TrendDataPoint> get copyWith => _$TrendDataPointCopyWithImpl<TrendDataPoint>(this as TrendDataPoint, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrendDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,date,value,label);

@override
String toString() {
  return 'TrendDataPoint(date: $date, value: $value, label: $label)';
}


}

/// @nodoc
abstract mixin class $TrendDataPointCopyWith<$Res>  {
  factory $TrendDataPointCopyWith(TrendDataPoint value, $Res Function(TrendDataPoint) _then) = _$TrendDataPointCopyWithImpl;
@useResult
$Res call({
 DateTime date, double value, String label
});




}
/// @nodoc
class _$TrendDataPointCopyWithImpl<$Res>
    implements $TrendDataPointCopyWith<$Res> {
  _$TrendDataPointCopyWithImpl(this._self, this._then);

  final TrendDataPoint _self;
  final $Res Function(TrendDataPoint) _then;

/// Create a copy of TrendDataPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? value = null,Object? label = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TrendDataPoint].
extension TrendDataPointPatterns on TrendDataPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrendDataPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrendDataPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrendDataPoint value)  $default,){
final _that = this;
switch (_that) {
case _TrendDataPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrendDataPoint value)?  $default,){
final _that = this;
switch (_that) {
case _TrendDataPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double value,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrendDataPoint() when $default != null:
return $default(_that.date,_that.value,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double value,  String label)  $default,) {final _that = this;
switch (_that) {
case _TrendDataPoint():
return $default(_that.date,_that.value,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double value,  String label)?  $default,) {final _that = this;
switch (_that) {
case _TrendDataPoint() when $default != null:
return $default(_that.date,_that.value,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _TrendDataPoint implements TrendDataPoint {
  const _TrendDataPoint({required this.date, required this.value, required this.label});
  

@override final  DateTime date;
@override final  double value;
@override final  String label;

/// Create a copy of TrendDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrendDataPointCopyWith<_TrendDataPoint> get copyWith => __$TrendDataPointCopyWithImpl<_TrendDataPoint>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrendDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,date,value,label);

@override
String toString() {
  return 'TrendDataPoint(date: $date, value: $value, label: $label)';
}


}

/// @nodoc
abstract mixin class _$TrendDataPointCopyWith<$Res> implements $TrendDataPointCopyWith<$Res> {
  factory _$TrendDataPointCopyWith(_TrendDataPoint value, $Res Function(_TrendDataPoint) _then) = __$TrendDataPointCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double value, String label
});




}
/// @nodoc
class __$TrendDataPointCopyWithImpl<$Res>
    implements _$TrendDataPointCopyWith<$Res> {
  __$TrendDataPointCopyWithImpl(this._self, this._then);

  final _TrendDataPoint _self;
  final $Res Function(_TrendDataPoint) _then;

/// Create a copy of TrendDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? value = null,Object? label = null,}) {
  return _then(_TrendDataPoint(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$DepartmentAnalytics {

 String get departmentId; String get departmentName; int get totalReports; int get completedReports; int get pendingReports; double get completionRate; Duration get averageResponseTime;
/// Create a copy of DepartmentAnalytics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DepartmentAnalyticsCopyWith<DepartmentAnalytics> get copyWith => _$DepartmentAnalyticsCopyWithImpl<DepartmentAnalytics>(this as DepartmentAnalytics, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DepartmentAnalytics&&(identical(other.departmentId, departmentId) || other.departmentId == departmentId)&&(identical(other.departmentName, departmentName) || other.departmentName == departmentName)&&(identical(other.totalReports, totalReports) || other.totalReports == totalReports)&&(identical(other.completedReports, completedReports) || other.completedReports == completedReports)&&(identical(other.pendingReports, pendingReports) || other.pendingReports == pendingReports)&&(identical(other.completionRate, completionRate) || other.completionRate == completionRate)&&(identical(other.averageResponseTime, averageResponseTime) || other.averageResponseTime == averageResponseTime));
}


@override
int get hashCode => Object.hash(runtimeType,departmentId,departmentName,totalReports,completedReports,pendingReports,completionRate,averageResponseTime);

@override
String toString() {
  return 'DepartmentAnalytics(departmentId: $departmentId, departmentName: $departmentName, totalReports: $totalReports, completedReports: $completedReports, pendingReports: $pendingReports, completionRate: $completionRate, averageResponseTime: $averageResponseTime)';
}


}

/// @nodoc
abstract mixin class $DepartmentAnalyticsCopyWith<$Res>  {
  factory $DepartmentAnalyticsCopyWith(DepartmentAnalytics value, $Res Function(DepartmentAnalytics) _then) = _$DepartmentAnalyticsCopyWithImpl;
@useResult
$Res call({
 String departmentId, String departmentName, int totalReports, int completedReports, int pendingReports, double completionRate, Duration averageResponseTime
});




}
/// @nodoc
class _$DepartmentAnalyticsCopyWithImpl<$Res>
    implements $DepartmentAnalyticsCopyWith<$Res> {
  _$DepartmentAnalyticsCopyWithImpl(this._self, this._then);

  final DepartmentAnalytics _self;
  final $Res Function(DepartmentAnalytics) _then;

/// Create a copy of DepartmentAnalytics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? departmentId = null,Object? departmentName = null,Object? totalReports = null,Object? completedReports = null,Object? pendingReports = null,Object? completionRate = null,Object? averageResponseTime = null,}) {
  return _then(_self.copyWith(
departmentId: null == departmentId ? _self.departmentId : departmentId // ignore: cast_nullable_to_non_nullable
as String,departmentName: null == departmentName ? _self.departmentName : departmentName // ignore: cast_nullable_to_non_nullable
as String,totalReports: null == totalReports ? _self.totalReports : totalReports // ignore: cast_nullable_to_non_nullable
as int,completedReports: null == completedReports ? _self.completedReports : completedReports // ignore: cast_nullable_to_non_nullable
as int,pendingReports: null == pendingReports ? _self.pendingReports : pendingReports // ignore: cast_nullable_to_non_nullable
as int,completionRate: null == completionRate ? _self.completionRate : completionRate // ignore: cast_nullable_to_non_nullable
as double,averageResponseTime: null == averageResponseTime ? _self.averageResponseTime : averageResponseTime // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}

}


/// Adds pattern-matching-related methods to [DepartmentAnalytics].
extension DepartmentAnalyticsPatterns on DepartmentAnalytics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DepartmentAnalytics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DepartmentAnalytics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DepartmentAnalytics value)  $default,){
final _that = this;
switch (_that) {
case _DepartmentAnalytics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DepartmentAnalytics value)?  $default,){
final _that = this;
switch (_that) {
case _DepartmentAnalytics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String departmentId,  String departmentName,  int totalReports,  int completedReports,  int pendingReports,  double completionRate,  Duration averageResponseTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DepartmentAnalytics() when $default != null:
return $default(_that.departmentId,_that.departmentName,_that.totalReports,_that.completedReports,_that.pendingReports,_that.completionRate,_that.averageResponseTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String departmentId,  String departmentName,  int totalReports,  int completedReports,  int pendingReports,  double completionRate,  Duration averageResponseTime)  $default,) {final _that = this;
switch (_that) {
case _DepartmentAnalytics():
return $default(_that.departmentId,_that.departmentName,_that.totalReports,_that.completedReports,_that.pendingReports,_that.completionRate,_that.averageResponseTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String departmentId,  String departmentName,  int totalReports,  int completedReports,  int pendingReports,  double completionRate,  Duration averageResponseTime)?  $default,) {final _that = this;
switch (_that) {
case _DepartmentAnalytics() when $default != null:
return $default(_that.departmentId,_that.departmentName,_that.totalReports,_that.completedReports,_that.pendingReports,_that.completionRate,_that.averageResponseTime);case _:
  return null;

}
}

}

/// @nodoc


class _DepartmentAnalytics implements DepartmentAnalytics {
  const _DepartmentAnalytics({required this.departmentId, required this.departmentName, required this.totalReports, required this.completedReports, required this.pendingReports, required this.completionRate, required this.averageResponseTime});
  

@override final  String departmentId;
@override final  String departmentName;
@override final  int totalReports;
@override final  int completedReports;
@override final  int pendingReports;
@override final  double completionRate;
@override final  Duration averageResponseTime;

/// Create a copy of DepartmentAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DepartmentAnalyticsCopyWith<_DepartmentAnalytics> get copyWith => __$DepartmentAnalyticsCopyWithImpl<_DepartmentAnalytics>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DepartmentAnalytics&&(identical(other.departmentId, departmentId) || other.departmentId == departmentId)&&(identical(other.departmentName, departmentName) || other.departmentName == departmentName)&&(identical(other.totalReports, totalReports) || other.totalReports == totalReports)&&(identical(other.completedReports, completedReports) || other.completedReports == completedReports)&&(identical(other.pendingReports, pendingReports) || other.pendingReports == pendingReports)&&(identical(other.completionRate, completionRate) || other.completionRate == completionRate)&&(identical(other.averageResponseTime, averageResponseTime) || other.averageResponseTime == averageResponseTime));
}


@override
int get hashCode => Object.hash(runtimeType,departmentId,departmentName,totalReports,completedReports,pendingReports,completionRate,averageResponseTime);

@override
String toString() {
  return 'DepartmentAnalytics(departmentId: $departmentId, departmentName: $departmentName, totalReports: $totalReports, completedReports: $completedReports, pendingReports: $pendingReports, completionRate: $completionRate, averageResponseTime: $averageResponseTime)';
}


}

/// @nodoc
abstract mixin class _$DepartmentAnalyticsCopyWith<$Res> implements $DepartmentAnalyticsCopyWith<$Res> {
  factory _$DepartmentAnalyticsCopyWith(_DepartmentAnalytics value, $Res Function(_DepartmentAnalytics) _then) = __$DepartmentAnalyticsCopyWithImpl;
@override @useResult
$Res call({
 String departmentId, String departmentName, int totalReports, int completedReports, int pendingReports, double completionRate, Duration averageResponseTime
});




}
/// @nodoc
class __$DepartmentAnalyticsCopyWithImpl<$Res>
    implements _$DepartmentAnalyticsCopyWith<$Res> {
  __$DepartmentAnalyticsCopyWithImpl(this._self, this._then);

  final _DepartmentAnalytics _self;
  final $Res Function(_DepartmentAnalytics) _then;

/// Create a copy of DepartmentAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? departmentId = null,Object? departmentName = null,Object? totalReports = null,Object? completedReports = null,Object? pendingReports = null,Object? completionRate = null,Object? averageResponseTime = null,}) {
  return _then(_DepartmentAnalytics(
departmentId: null == departmentId ? _self.departmentId : departmentId // ignore: cast_nullable_to_non_nullable
as String,departmentName: null == departmentName ? _self.departmentName : departmentName // ignore: cast_nullable_to_non_nullable
as String,totalReports: null == totalReports ? _self.totalReports : totalReports // ignore: cast_nullable_to_non_nullable
as int,completedReports: null == completedReports ? _self.completedReports : completedReports // ignore: cast_nullable_to_non_nullable
as int,pendingReports: null == pendingReports ? _self.pendingReports : pendingReports // ignore: cast_nullable_to_non_nullable
as int,completionRate: null == completionRate ? _self.completionRate : completionRate // ignore: cast_nullable_to_non_nullable
as double,averageResponseTime: null == averageResponseTime ? _self.averageResponseTime : averageResponseTime // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

/// @nodoc
mixin _$CleanerPerformanceAnalytics {

 String get cleanerId; String get cleanerName; String? get photoUrl; int get totalTasksCompleted; int get totalTasksAssigned; double get completionRate; Duration get averageCompletionTime; double get rating; int get rank;
/// Create a copy of CleanerPerformanceAnalytics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CleanerPerformanceAnalyticsCopyWith<CleanerPerformanceAnalytics> get copyWith => _$CleanerPerformanceAnalyticsCopyWithImpl<CleanerPerformanceAnalytics>(this as CleanerPerformanceAnalytics, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CleanerPerformanceAnalytics&&(identical(other.cleanerId, cleanerId) || other.cleanerId == cleanerId)&&(identical(other.cleanerName, cleanerName) || other.cleanerName == cleanerName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.totalTasksCompleted, totalTasksCompleted) || other.totalTasksCompleted == totalTasksCompleted)&&(identical(other.totalTasksAssigned, totalTasksAssigned) || other.totalTasksAssigned == totalTasksAssigned)&&(identical(other.completionRate, completionRate) || other.completionRate == completionRate)&&(identical(other.averageCompletionTime, averageCompletionTime) || other.averageCompletionTime == averageCompletionTime)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.rank, rank) || other.rank == rank));
}


@override
int get hashCode => Object.hash(runtimeType,cleanerId,cleanerName,photoUrl,totalTasksCompleted,totalTasksAssigned,completionRate,averageCompletionTime,rating,rank);

@override
String toString() {
  return 'CleanerPerformanceAnalytics(cleanerId: $cleanerId, cleanerName: $cleanerName, photoUrl: $photoUrl, totalTasksCompleted: $totalTasksCompleted, totalTasksAssigned: $totalTasksAssigned, completionRate: $completionRate, averageCompletionTime: $averageCompletionTime, rating: $rating, rank: $rank)';
}


}

/// @nodoc
abstract mixin class $CleanerPerformanceAnalyticsCopyWith<$Res>  {
  factory $CleanerPerformanceAnalyticsCopyWith(CleanerPerformanceAnalytics value, $Res Function(CleanerPerformanceAnalytics) _then) = _$CleanerPerformanceAnalyticsCopyWithImpl;
@useResult
$Res call({
 String cleanerId, String cleanerName, String? photoUrl, int totalTasksCompleted, int totalTasksAssigned, double completionRate, Duration averageCompletionTime, double rating, int rank
});




}
/// @nodoc
class _$CleanerPerformanceAnalyticsCopyWithImpl<$Res>
    implements $CleanerPerformanceAnalyticsCopyWith<$Res> {
  _$CleanerPerformanceAnalyticsCopyWithImpl(this._self, this._then);

  final CleanerPerformanceAnalytics _self;
  final $Res Function(CleanerPerformanceAnalytics) _then;

/// Create a copy of CleanerPerformanceAnalytics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cleanerId = null,Object? cleanerName = null,Object? photoUrl = freezed,Object? totalTasksCompleted = null,Object? totalTasksAssigned = null,Object? completionRate = null,Object? averageCompletionTime = null,Object? rating = null,Object? rank = null,}) {
  return _then(_self.copyWith(
cleanerId: null == cleanerId ? _self.cleanerId : cleanerId // ignore: cast_nullable_to_non_nullable
as String,cleanerName: null == cleanerName ? _self.cleanerName : cleanerName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,totalTasksCompleted: null == totalTasksCompleted ? _self.totalTasksCompleted : totalTasksCompleted // ignore: cast_nullable_to_non_nullable
as int,totalTasksAssigned: null == totalTasksAssigned ? _self.totalTasksAssigned : totalTasksAssigned // ignore: cast_nullable_to_non_nullable
as int,completionRate: null == completionRate ? _self.completionRate : completionRate // ignore: cast_nullable_to_non_nullable
as double,averageCompletionTime: null == averageCompletionTime ? _self.averageCompletionTime : averageCompletionTime // ignore: cast_nullable_to_non_nullable
as Duration,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CleanerPerformanceAnalytics].
extension CleanerPerformanceAnalyticsPatterns on CleanerPerformanceAnalytics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CleanerPerformanceAnalytics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CleanerPerformanceAnalytics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CleanerPerformanceAnalytics value)  $default,){
final _that = this;
switch (_that) {
case _CleanerPerformanceAnalytics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CleanerPerformanceAnalytics value)?  $default,){
final _that = this;
switch (_that) {
case _CleanerPerformanceAnalytics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String cleanerId,  String cleanerName,  String? photoUrl,  int totalTasksCompleted,  int totalTasksAssigned,  double completionRate,  Duration averageCompletionTime,  double rating,  int rank)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CleanerPerformanceAnalytics() when $default != null:
return $default(_that.cleanerId,_that.cleanerName,_that.photoUrl,_that.totalTasksCompleted,_that.totalTasksAssigned,_that.completionRate,_that.averageCompletionTime,_that.rating,_that.rank);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String cleanerId,  String cleanerName,  String? photoUrl,  int totalTasksCompleted,  int totalTasksAssigned,  double completionRate,  Duration averageCompletionTime,  double rating,  int rank)  $default,) {final _that = this;
switch (_that) {
case _CleanerPerformanceAnalytics():
return $default(_that.cleanerId,_that.cleanerName,_that.photoUrl,_that.totalTasksCompleted,_that.totalTasksAssigned,_that.completionRate,_that.averageCompletionTime,_that.rating,_that.rank);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String cleanerId,  String cleanerName,  String? photoUrl,  int totalTasksCompleted,  int totalTasksAssigned,  double completionRate,  Duration averageCompletionTime,  double rating,  int rank)?  $default,) {final _that = this;
switch (_that) {
case _CleanerPerformanceAnalytics() when $default != null:
return $default(_that.cleanerId,_that.cleanerName,_that.photoUrl,_that.totalTasksCompleted,_that.totalTasksAssigned,_that.completionRate,_that.averageCompletionTime,_that.rating,_that.rank);case _:
  return null;

}
}

}

/// @nodoc


class _CleanerPerformanceAnalytics extends CleanerPerformanceAnalytics {
  const _CleanerPerformanceAnalytics({required this.cleanerId, required this.cleanerName, this.photoUrl, required this.totalTasksCompleted, required this.totalTasksAssigned, required this.completionRate, required this.averageCompletionTime, required this.rating, required this.rank}): super._();
  

@override final  String cleanerId;
@override final  String cleanerName;
@override final  String? photoUrl;
@override final  int totalTasksCompleted;
@override final  int totalTasksAssigned;
@override final  double completionRate;
@override final  Duration averageCompletionTime;
@override final  double rating;
@override final  int rank;

/// Create a copy of CleanerPerformanceAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CleanerPerformanceAnalyticsCopyWith<_CleanerPerformanceAnalytics> get copyWith => __$CleanerPerformanceAnalyticsCopyWithImpl<_CleanerPerformanceAnalytics>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CleanerPerformanceAnalytics&&(identical(other.cleanerId, cleanerId) || other.cleanerId == cleanerId)&&(identical(other.cleanerName, cleanerName) || other.cleanerName == cleanerName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.totalTasksCompleted, totalTasksCompleted) || other.totalTasksCompleted == totalTasksCompleted)&&(identical(other.totalTasksAssigned, totalTasksAssigned) || other.totalTasksAssigned == totalTasksAssigned)&&(identical(other.completionRate, completionRate) || other.completionRate == completionRate)&&(identical(other.averageCompletionTime, averageCompletionTime) || other.averageCompletionTime == averageCompletionTime)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.rank, rank) || other.rank == rank));
}


@override
int get hashCode => Object.hash(runtimeType,cleanerId,cleanerName,photoUrl,totalTasksCompleted,totalTasksAssigned,completionRate,averageCompletionTime,rating,rank);

@override
String toString() {
  return 'CleanerPerformanceAnalytics(cleanerId: $cleanerId, cleanerName: $cleanerName, photoUrl: $photoUrl, totalTasksCompleted: $totalTasksCompleted, totalTasksAssigned: $totalTasksAssigned, completionRate: $completionRate, averageCompletionTime: $averageCompletionTime, rating: $rating, rank: $rank)';
}


}

/// @nodoc
abstract mixin class _$CleanerPerformanceAnalyticsCopyWith<$Res> implements $CleanerPerformanceAnalyticsCopyWith<$Res> {
  factory _$CleanerPerformanceAnalyticsCopyWith(_CleanerPerformanceAnalytics value, $Res Function(_CleanerPerformanceAnalytics) _then) = __$CleanerPerformanceAnalyticsCopyWithImpl;
@override @useResult
$Res call({
 String cleanerId, String cleanerName, String? photoUrl, int totalTasksCompleted, int totalTasksAssigned, double completionRate, Duration averageCompletionTime, double rating, int rank
});




}
/// @nodoc
class __$CleanerPerformanceAnalyticsCopyWithImpl<$Res>
    implements _$CleanerPerformanceAnalyticsCopyWith<$Res> {
  __$CleanerPerformanceAnalyticsCopyWithImpl(this._self, this._then);

  final _CleanerPerformanceAnalytics _self;
  final $Res Function(_CleanerPerformanceAnalytics) _then;

/// Create a copy of CleanerPerformanceAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cleanerId = null,Object? cleanerName = null,Object? photoUrl = freezed,Object? totalTasksCompleted = null,Object? totalTasksAssigned = null,Object? completionRate = null,Object? averageCompletionTime = null,Object? rating = null,Object? rank = null,}) {
  return _then(_CleanerPerformanceAnalytics(
cleanerId: null == cleanerId ? _self.cleanerId : cleanerId // ignore: cast_nullable_to_non_nullable
as String,cleanerName: null == cleanerName ? _self.cleanerName : cleanerName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,totalTasksCompleted: null == totalTasksCompleted ? _self.totalTasksCompleted : totalTasksCompleted // ignore: cast_nullable_to_non_nullable
as int,totalTasksAssigned: null == totalTasksAssigned ? _self.totalTasksAssigned : totalTasksAssigned // ignore: cast_nullable_to_non_nullable
as int,completionRate: null == completionRate ? _self.completionRate : completionRate // ignore: cast_nullable_to_non_nullable
as double,averageCompletionTime: null == averageCompletionTime ? _self.averageCompletionTime : averageCompletionTime // ignore: cast_nullable_to_non_nullable
as Duration,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$StatusDistribution {

 String get status; int get count; double get percentage; Color get color;
/// Create a copy of StatusDistribution
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusDistributionCopyWith<StatusDistribution> get copyWith => _$StatusDistributionCopyWithImpl<StatusDistribution>(this as StatusDistribution, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusDistribution&&(identical(other.status, status) || other.status == status)&&(identical(other.count, count) || other.count == count)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode => Object.hash(runtimeType,status,count,percentage,color);

@override
String toString() {
  return 'StatusDistribution(status: $status, count: $count, percentage: $percentage, color: $color)';
}


}

/// @nodoc
abstract mixin class $StatusDistributionCopyWith<$Res>  {
  factory $StatusDistributionCopyWith(StatusDistribution value, $Res Function(StatusDistribution) _then) = _$StatusDistributionCopyWithImpl;
@useResult
$Res call({
 String status, int count, double percentage, Color color
});




}
/// @nodoc
class _$StatusDistributionCopyWithImpl<$Res>
    implements $StatusDistributionCopyWith<$Res> {
  _$StatusDistributionCopyWithImpl(this._self, this._then);

  final StatusDistribution _self;
  final $Res Function(StatusDistribution) _then;

/// Create a copy of StatusDistribution
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? count = null,Object? percentage = null,Object? color = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}

}


/// Adds pattern-matching-related methods to [StatusDistribution].
extension StatusDistributionPatterns on StatusDistribution {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatusDistribution value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatusDistribution() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatusDistribution value)  $default,){
final _that = this;
switch (_that) {
case _StatusDistribution():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatusDistribution value)?  $default,){
final _that = this;
switch (_that) {
case _StatusDistribution() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  int count,  double percentage,  Color color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatusDistribution() when $default != null:
return $default(_that.status,_that.count,_that.percentage,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  int count,  double percentage,  Color color)  $default,) {final _that = this;
switch (_that) {
case _StatusDistribution():
return $default(_that.status,_that.count,_that.percentage,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  int count,  double percentage,  Color color)?  $default,) {final _that = this;
switch (_that) {
case _StatusDistribution() when $default != null:
return $default(_that.status,_that.count,_that.percentage,_that.color);case _:
  return null;

}
}

}

/// @nodoc


class _StatusDistribution implements StatusDistribution {
  const _StatusDistribution({required this.status, required this.count, required this.percentage, required this.color});
  

@override final  String status;
@override final  int count;
@override final  double percentage;
@override final  Color color;

/// Create a copy of StatusDistribution
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusDistributionCopyWith<_StatusDistribution> get copyWith => __$StatusDistributionCopyWithImpl<_StatusDistribution>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusDistribution&&(identical(other.status, status) || other.status == status)&&(identical(other.count, count) || other.count == count)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode => Object.hash(runtimeType,status,count,percentage,color);

@override
String toString() {
  return 'StatusDistribution(status: $status, count: $count, percentage: $percentage, color: $color)';
}


}

/// @nodoc
abstract mixin class _$StatusDistributionCopyWith<$Res> implements $StatusDistributionCopyWith<$Res> {
  factory _$StatusDistributionCopyWith(_StatusDistribution value, $Res Function(_StatusDistribution) _then) = __$StatusDistributionCopyWithImpl;
@override @useResult
$Res call({
 String status, int count, double percentage, Color color
});




}
/// @nodoc
class __$StatusDistributionCopyWithImpl<$Res>
    implements _$StatusDistributionCopyWith<$Res> {
  __$StatusDistributionCopyWithImpl(this._self, this._then);

  final _StatusDistribution _self;
  final $Res Function(_StatusDistribution) _then;

/// Create a copy of StatusDistribution
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? count = null,Object? percentage = null,Object? color = null,}) {
  return _then(_StatusDistribution(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}


}

/// @nodoc
mixin _$AnalyticsSummary {

 DateTime get startDate; DateTime get endDate; int get totalReports; int get completedReports; int get pendingReports; int get inProgressReports; int get needsVerificationReports; double get completionRate; Duration get averageResponseTime; Duration get averageCompletionTime; List<TrendDataPoint> get dailyTrend; List<StatusDistribution> get statusDistribution; List<DepartmentAnalytics> get departmentAnalytics; List<CleanerPerformanceAnalytics> get cleanerPerformance;
/// Create a copy of AnalyticsSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsSummaryCopyWith<AnalyticsSummary> get copyWith => _$AnalyticsSummaryCopyWithImpl<AnalyticsSummary>(this as AnalyticsSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsSummary&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.totalReports, totalReports) || other.totalReports == totalReports)&&(identical(other.completedReports, completedReports) || other.completedReports == completedReports)&&(identical(other.pendingReports, pendingReports) || other.pendingReports == pendingReports)&&(identical(other.inProgressReports, inProgressReports) || other.inProgressReports == inProgressReports)&&(identical(other.needsVerificationReports, needsVerificationReports) || other.needsVerificationReports == needsVerificationReports)&&(identical(other.completionRate, completionRate) || other.completionRate == completionRate)&&(identical(other.averageResponseTime, averageResponseTime) || other.averageResponseTime == averageResponseTime)&&(identical(other.averageCompletionTime, averageCompletionTime) || other.averageCompletionTime == averageCompletionTime)&&const DeepCollectionEquality().equals(other.dailyTrend, dailyTrend)&&const DeepCollectionEquality().equals(other.statusDistribution, statusDistribution)&&const DeepCollectionEquality().equals(other.departmentAnalytics, departmentAnalytics)&&const DeepCollectionEquality().equals(other.cleanerPerformance, cleanerPerformance));
}


@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,totalReports,completedReports,pendingReports,inProgressReports,needsVerificationReports,completionRate,averageResponseTime,averageCompletionTime,const DeepCollectionEquality().hash(dailyTrend),const DeepCollectionEquality().hash(statusDistribution),const DeepCollectionEquality().hash(departmentAnalytics),const DeepCollectionEquality().hash(cleanerPerformance));

@override
String toString() {
  return 'AnalyticsSummary(startDate: $startDate, endDate: $endDate, totalReports: $totalReports, completedReports: $completedReports, pendingReports: $pendingReports, inProgressReports: $inProgressReports, needsVerificationReports: $needsVerificationReports, completionRate: $completionRate, averageResponseTime: $averageResponseTime, averageCompletionTime: $averageCompletionTime, dailyTrend: $dailyTrend, statusDistribution: $statusDistribution, departmentAnalytics: $departmentAnalytics, cleanerPerformance: $cleanerPerformance)';
}


}

/// @nodoc
abstract mixin class $AnalyticsSummaryCopyWith<$Res>  {
  factory $AnalyticsSummaryCopyWith(AnalyticsSummary value, $Res Function(AnalyticsSummary) _then) = _$AnalyticsSummaryCopyWithImpl;
@useResult
$Res call({
 DateTime startDate, DateTime endDate, int totalReports, int completedReports, int pendingReports, int inProgressReports, int needsVerificationReports, double completionRate, Duration averageResponseTime, Duration averageCompletionTime, List<TrendDataPoint> dailyTrend, List<StatusDistribution> statusDistribution, List<DepartmentAnalytics> departmentAnalytics, List<CleanerPerformanceAnalytics> cleanerPerformance
});




}
/// @nodoc
class _$AnalyticsSummaryCopyWithImpl<$Res>
    implements $AnalyticsSummaryCopyWith<$Res> {
  _$AnalyticsSummaryCopyWithImpl(this._self, this._then);

  final AnalyticsSummary _self;
  final $Res Function(AnalyticsSummary) _then;

/// Create a copy of AnalyticsSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startDate = null,Object? endDate = null,Object? totalReports = null,Object? completedReports = null,Object? pendingReports = null,Object? inProgressReports = null,Object? needsVerificationReports = null,Object? completionRate = null,Object? averageResponseTime = null,Object? averageCompletionTime = null,Object? dailyTrend = null,Object? statusDistribution = null,Object? departmentAnalytics = null,Object? cleanerPerformance = null,}) {
  return _then(_self.copyWith(
startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,totalReports: null == totalReports ? _self.totalReports : totalReports // ignore: cast_nullable_to_non_nullable
as int,completedReports: null == completedReports ? _self.completedReports : completedReports // ignore: cast_nullable_to_non_nullable
as int,pendingReports: null == pendingReports ? _self.pendingReports : pendingReports // ignore: cast_nullable_to_non_nullable
as int,inProgressReports: null == inProgressReports ? _self.inProgressReports : inProgressReports // ignore: cast_nullable_to_non_nullable
as int,needsVerificationReports: null == needsVerificationReports ? _self.needsVerificationReports : needsVerificationReports // ignore: cast_nullable_to_non_nullable
as int,completionRate: null == completionRate ? _self.completionRate : completionRate // ignore: cast_nullable_to_non_nullable
as double,averageResponseTime: null == averageResponseTime ? _self.averageResponseTime : averageResponseTime // ignore: cast_nullable_to_non_nullable
as Duration,averageCompletionTime: null == averageCompletionTime ? _self.averageCompletionTime : averageCompletionTime // ignore: cast_nullable_to_non_nullable
as Duration,dailyTrend: null == dailyTrend ? _self.dailyTrend : dailyTrend // ignore: cast_nullable_to_non_nullable
as List<TrendDataPoint>,statusDistribution: null == statusDistribution ? _self.statusDistribution : statusDistribution // ignore: cast_nullable_to_non_nullable
as List<StatusDistribution>,departmentAnalytics: null == departmentAnalytics ? _self.departmentAnalytics : departmentAnalytics // ignore: cast_nullable_to_non_nullable
as List<DepartmentAnalytics>,cleanerPerformance: null == cleanerPerformance ? _self.cleanerPerformance : cleanerPerformance // ignore: cast_nullable_to_non_nullable
as List<CleanerPerformanceAnalytics>,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsSummary].
extension AnalyticsSummaryPatterns on AnalyticsSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsSummary value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsSummary value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime startDate,  DateTime endDate,  int totalReports,  int completedReports,  int pendingReports,  int inProgressReports,  int needsVerificationReports,  double completionRate,  Duration averageResponseTime,  Duration averageCompletionTime,  List<TrendDataPoint> dailyTrend,  List<StatusDistribution> statusDistribution,  List<DepartmentAnalytics> departmentAnalytics,  List<CleanerPerformanceAnalytics> cleanerPerformance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsSummary() when $default != null:
return $default(_that.startDate,_that.endDate,_that.totalReports,_that.completedReports,_that.pendingReports,_that.inProgressReports,_that.needsVerificationReports,_that.completionRate,_that.averageResponseTime,_that.averageCompletionTime,_that.dailyTrend,_that.statusDistribution,_that.departmentAnalytics,_that.cleanerPerformance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime startDate,  DateTime endDate,  int totalReports,  int completedReports,  int pendingReports,  int inProgressReports,  int needsVerificationReports,  double completionRate,  Duration averageResponseTime,  Duration averageCompletionTime,  List<TrendDataPoint> dailyTrend,  List<StatusDistribution> statusDistribution,  List<DepartmentAnalytics> departmentAnalytics,  List<CleanerPerformanceAnalytics> cleanerPerformance)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsSummary():
return $default(_that.startDate,_that.endDate,_that.totalReports,_that.completedReports,_that.pendingReports,_that.inProgressReports,_that.needsVerificationReports,_that.completionRate,_that.averageResponseTime,_that.averageCompletionTime,_that.dailyTrend,_that.statusDistribution,_that.departmentAnalytics,_that.cleanerPerformance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime startDate,  DateTime endDate,  int totalReports,  int completedReports,  int pendingReports,  int inProgressReports,  int needsVerificationReports,  double completionRate,  Duration averageResponseTime,  Duration averageCompletionTime,  List<TrendDataPoint> dailyTrend,  List<StatusDistribution> statusDistribution,  List<DepartmentAnalytics> departmentAnalytics,  List<CleanerPerformanceAnalytics> cleanerPerformance)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsSummary() when $default != null:
return $default(_that.startDate,_that.endDate,_that.totalReports,_that.completedReports,_that.pendingReports,_that.inProgressReports,_that.needsVerificationReports,_that.completionRate,_that.averageResponseTime,_that.averageCompletionTime,_that.dailyTrend,_that.statusDistribution,_that.departmentAnalytics,_that.cleanerPerformance);case _:
  return null;

}
}

}

/// @nodoc


class _AnalyticsSummary extends AnalyticsSummary {
  const _AnalyticsSummary({required this.startDate, required this.endDate, required this.totalReports, required this.completedReports, required this.pendingReports, required this.inProgressReports, required this.needsVerificationReports, required this.completionRate, required this.averageResponseTime, required this.averageCompletionTime, required final  List<TrendDataPoint> dailyTrend, required final  List<StatusDistribution> statusDistribution, required final  List<DepartmentAnalytics> departmentAnalytics, required final  List<CleanerPerformanceAnalytics> cleanerPerformance}): _dailyTrend = dailyTrend,_statusDistribution = statusDistribution,_departmentAnalytics = departmentAnalytics,_cleanerPerformance = cleanerPerformance,super._();
  

@override final  DateTime startDate;
@override final  DateTime endDate;
@override final  int totalReports;
@override final  int completedReports;
@override final  int pendingReports;
@override final  int inProgressReports;
@override final  int needsVerificationReports;
@override final  double completionRate;
@override final  Duration averageResponseTime;
@override final  Duration averageCompletionTime;
 final  List<TrendDataPoint> _dailyTrend;
@override List<TrendDataPoint> get dailyTrend {
  if (_dailyTrend is EqualUnmodifiableListView) return _dailyTrend;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dailyTrend);
}

 final  List<StatusDistribution> _statusDistribution;
@override List<StatusDistribution> get statusDistribution {
  if (_statusDistribution is EqualUnmodifiableListView) return _statusDistribution;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statusDistribution);
}

 final  List<DepartmentAnalytics> _departmentAnalytics;
@override List<DepartmentAnalytics> get departmentAnalytics {
  if (_departmentAnalytics is EqualUnmodifiableListView) return _departmentAnalytics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_departmentAnalytics);
}

 final  List<CleanerPerformanceAnalytics> _cleanerPerformance;
@override List<CleanerPerformanceAnalytics> get cleanerPerformance {
  if (_cleanerPerformance is EqualUnmodifiableListView) return _cleanerPerformance;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cleanerPerformance);
}


/// Create a copy of AnalyticsSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsSummaryCopyWith<_AnalyticsSummary> get copyWith => __$AnalyticsSummaryCopyWithImpl<_AnalyticsSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsSummary&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.totalReports, totalReports) || other.totalReports == totalReports)&&(identical(other.completedReports, completedReports) || other.completedReports == completedReports)&&(identical(other.pendingReports, pendingReports) || other.pendingReports == pendingReports)&&(identical(other.inProgressReports, inProgressReports) || other.inProgressReports == inProgressReports)&&(identical(other.needsVerificationReports, needsVerificationReports) || other.needsVerificationReports == needsVerificationReports)&&(identical(other.completionRate, completionRate) || other.completionRate == completionRate)&&(identical(other.averageResponseTime, averageResponseTime) || other.averageResponseTime == averageResponseTime)&&(identical(other.averageCompletionTime, averageCompletionTime) || other.averageCompletionTime == averageCompletionTime)&&const DeepCollectionEquality().equals(other._dailyTrend, _dailyTrend)&&const DeepCollectionEquality().equals(other._statusDistribution, _statusDistribution)&&const DeepCollectionEquality().equals(other._departmentAnalytics, _departmentAnalytics)&&const DeepCollectionEquality().equals(other._cleanerPerformance, _cleanerPerformance));
}


@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,totalReports,completedReports,pendingReports,inProgressReports,needsVerificationReports,completionRate,averageResponseTime,averageCompletionTime,const DeepCollectionEquality().hash(_dailyTrend),const DeepCollectionEquality().hash(_statusDistribution),const DeepCollectionEquality().hash(_departmentAnalytics),const DeepCollectionEquality().hash(_cleanerPerformance));

@override
String toString() {
  return 'AnalyticsSummary(startDate: $startDate, endDate: $endDate, totalReports: $totalReports, completedReports: $completedReports, pendingReports: $pendingReports, inProgressReports: $inProgressReports, needsVerificationReports: $needsVerificationReports, completionRate: $completionRate, averageResponseTime: $averageResponseTime, averageCompletionTime: $averageCompletionTime, dailyTrend: $dailyTrend, statusDistribution: $statusDistribution, departmentAnalytics: $departmentAnalytics, cleanerPerformance: $cleanerPerformance)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsSummaryCopyWith<$Res> implements $AnalyticsSummaryCopyWith<$Res> {
  factory _$AnalyticsSummaryCopyWith(_AnalyticsSummary value, $Res Function(_AnalyticsSummary) _then) = __$AnalyticsSummaryCopyWithImpl;
@override @useResult
$Res call({
 DateTime startDate, DateTime endDate, int totalReports, int completedReports, int pendingReports, int inProgressReports, int needsVerificationReports, double completionRate, Duration averageResponseTime, Duration averageCompletionTime, List<TrendDataPoint> dailyTrend, List<StatusDistribution> statusDistribution, List<DepartmentAnalytics> departmentAnalytics, List<CleanerPerformanceAnalytics> cleanerPerformance
});




}
/// @nodoc
class __$AnalyticsSummaryCopyWithImpl<$Res>
    implements _$AnalyticsSummaryCopyWith<$Res> {
  __$AnalyticsSummaryCopyWithImpl(this._self, this._then);

  final _AnalyticsSummary _self;
  final $Res Function(_AnalyticsSummary) _then;

/// Create a copy of AnalyticsSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startDate = null,Object? endDate = null,Object? totalReports = null,Object? completedReports = null,Object? pendingReports = null,Object? inProgressReports = null,Object? needsVerificationReports = null,Object? completionRate = null,Object? averageResponseTime = null,Object? averageCompletionTime = null,Object? dailyTrend = null,Object? statusDistribution = null,Object? departmentAnalytics = null,Object? cleanerPerformance = null,}) {
  return _then(_AnalyticsSummary(
startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,totalReports: null == totalReports ? _self.totalReports : totalReports // ignore: cast_nullable_to_non_nullable
as int,completedReports: null == completedReports ? _self.completedReports : completedReports // ignore: cast_nullable_to_non_nullable
as int,pendingReports: null == pendingReports ? _self.pendingReports : pendingReports // ignore: cast_nullable_to_non_nullable
as int,inProgressReports: null == inProgressReports ? _self.inProgressReports : inProgressReports // ignore: cast_nullable_to_non_nullable
as int,needsVerificationReports: null == needsVerificationReports ? _self.needsVerificationReports : needsVerificationReports // ignore: cast_nullable_to_non_nullable
as int,completionRate: null == completionRate ? _self.completionRate : completionRate // ignore: cast_nullable_to_non_nullable
as double,averageResponseTime: null == averageResponseTime ? _self.averageResponseTime : averageResponseTime // ignore: cast_nullable_to_non_nullable
as Duration,averageCompletionTime: null == averageCompletionTime ? _self.averageCompletionTime : averageCompletionTime // ignore: cast_nullable_to_non_nullable
as Duration,dailyTrend: null == dailyTrend ? _self._dailyTrend : dailyTrend // ignore: cast_nullable_to_non_nullable
as List<TrendDataPoint>,statusDistribution: null == statusDistribution ? _self._statusDistribution : statusDistribution // ignore: cast_nullable_to_non_nullable
as List<StatusDistribution>,departmentAnalytics: null == departmentAnalytics ? _self._departmentAnalytics : departmentAnalytics // ignore: cast_nullable_to_non_nullable
as List<DepartmentAnalytics>,cleanerPerformance: null == cleanerPerformance ? _self._cleanerPerformance : cleanerPerformance // ignore: cast_nullable_to_non_nullable
as List<CleanerPerformanceAnalytics>,
  ));
}


}

// dart format on
