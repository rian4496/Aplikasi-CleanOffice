// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chart_data_freezed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChartDataPoint {

 DateTime get date; double get value; String? get label; Color? get color; Map<String, dynamic>? get metadata;
/// Create a copy of ChartDataPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChartDataPointCopyWith<ChartDataPoint> get copyWith => _$ChartDataPointCopyWithImpl<ChartDataPoint>(this as ChartDataPoint, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChartDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label)&&(identical(other.color, color) || other.color == color)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}


@override
int get hashCode => Object.hash(runtimeType,date,value,label,color,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'ChartDataPoint(date: $date, value: $value, label: $label, color: $color, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $ChartDataPointCopyWith<$Res>  {
  factory $ChartDataPointCopyWith(ChartDataPoint value, $Res Function(ChartDataPoint) _then) = _$ChartDataPointCopyWithImpl;
@useResult
$Res call({
 DateTime date, double value, String? label, Color? color, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$ChartDataPointCopyWithImpl<$Res>
    implements $ChartDataPointCopyWith<$Res> {
  _$ChartDataPointCopyWithImpl(this._self, this._then);

  final ChartDataPoint _self;
  final $Res Function(ChartDataPoint) _then;

/// Create a copy of ChartDataPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? value = null,Object? label = freezed,Object? color = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChartDataPoint].
extension ChartDataPointPatterns on ChartDataPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChartDataPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChartDataPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChartDataPoint value)  $default,){
final _that = this;
switch (_that) {
case _ChartDataPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChartDataPoint value)?  $default,){
final _that = this;
switch (_that) {
case _ChartDataPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double value,  String? label,  Color? color,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChartDataPoint() when $default != null:
return $default(_that.date,_that.value,_that.label,_that.color,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double value,  String? label,  Color? color,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _ChartDataPoint():
return $default(_that.date,_that.value,_that.label,_that.color,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double value,  String? label,  Color? color,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _ChartDataPoint() when $default != null:
return $default(_that.date,_that.value,_that.label,_that.color,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc


class _ChartDataPoint implements ChartDataPoint {
  const _ChartDataPoint({required this.date, required this.value, this.label, this.color, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  

@override final  DateTime date;
@override final  double value;
@override final  String? label;
@override final  Color? color;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ChartDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChartDataPointCopyWith<_ChartDataPoint> get copyWith => __$ChartDataPointCopyWithImpl<_ChartDataPoint>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChartDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label)&&(identical(other.color, color) || other.color == color)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}


@override
int get hashCode => Object.hash(runtimeType,date,value,label,color,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'ChartDataPoint(date: $date, value: $value, label: $label, color: $color, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$ChartDataPointCopyWith<$Res> implements $ChartDataPointCopyWith<$Res> {
  factory _$ChartDataPointCopyWith(_ChartDataPoint value, $Res Function(_ChartDataPoint) _then) = __$ChartDataPointCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double value, String? label, Color? color, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$ChartDataPointCopyWithImpl<$Res>
    implements _$ChartDataPointCopyWith<$Res> {
  __$ChartDataPointCopyWithImpl(this._self, this._then);

  final _ChartDataPoint _self;
  final $Res Function(_ChartDataPoint) _then;

/// Create a copy of ChartDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? value = null,Object? label = freezed,Object? color = freezed,Object? metadata = freezed,}) {
  return _then(_ChartDataPoint(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

/// @nodoc
mixin _$ChartDataSeries {

 String get name; List<ChartDataPoint> get points; Color get color; bool get showDots; bool get showArea;
/// Create a copy of ChartDataSeries
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChartDataSeriesCopyWith<ChartDataSeries> get copyWith => _$ChartDataSeriesCopyWithImpl<ChartDataSeries>(this as ChartDataSeries, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChartDataSeries&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.color, color) || other.color == color)&&(identical(other.showDots, showDots) || other.showDots == showDots)&&(identical(other.showArea, showArea) || other.showArea == showArea));
}


@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(points),color,showDots,showArea);

@override
String toString() {
  return 'ChartDataSeries(name: $name, points: $points, color: $color, showDots: $showDots, showArea: $showArea)';
}


}

/// @nodoc
abstract mixin class $ChartDataSeriesCopyWith<$Res>  {
  factory $ChartDataSeriesCopyWith(ChartDataSeries value, $Res Function(ChartDataSeries) _then) = _$ChartDataSeriesCopyWithImpl;
@useResult
$Res call({
 String name, List<ChartDataPoint> points, Color color, bool showDots, bool showArea
});




}
/// @nodoc
class _$ChartDataSeriesCopyWithImpl<$Res>
    implements $ChartDataSeriesCopyWith<$Res> {
  _$ChartDataSeriesCopyWithImpl(this._self, this._then);

  final ChartDataSeries _self;
  final $Res Function(ChartDataSeries) _then;

/// Create a copy of ChartDataSeries
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? points = null,Object? color = null,Object? showDots = null,Object? showArea = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<ChartDataPoint>,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,showDots: null == showDots ? _self.showDots : showDots // ignore: cast_nullable_to_non_nullable
as bool,showArea: null == showArea ? _self.showArea : showArea // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChartDataSeries].
extension ChartDataSeriesPatterns on ChartDataSeries {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChartDataSeries value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChartDataSeries() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChartDataSeries value)  $default,){
final _that = this;
switch (_that) {
case _ChartDataSeries():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChartDataSeries value)?  $default,){
final _that = this;
switch (_that) {
case _ChartDataSeries() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  List<ChartDataPoint> points,  Color color,  bool showDots,  bool showArea)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChartDataSeries() when $default != null:
return $default(_that.name,_that.points,_that.color,_that.showDots,_that.showArea);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  List<ChartDataPoint> points,  Color color,  bool showDots,  bool showArea)  $default,) {final _that = this;
switch (_that) {
case _ChartDataSeries():
return $default(_that.name,_that.points,_that.color,_that.showDots,_that.showArea);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  List<ChartDataPoint> points,  Color color,  bool showDots,  bool showArea)?  $default,) {final _that = this;
switch (_that) {
case _ChartDataSeries() when $default != null:
return $default(_that.name,_that.points,_that.color,_that.showDots,_that.showArea);case _:
  return null;

}
}

}

/// @nodoc


class _ChartDataSeries extends ChartDataSeries {
  const _ChartDataSeries({required this.name, required final  List<ChartDataPoint> points, required this.color, this.showDots = true, this.showArea = false}): _points = points,super._();
  

@override final  String name;
 final  List<ChartDataPoint> _points;
@override List<ChartDataPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

@override final  Color color;
@override@JsonKey() final  bool showDots;
@override@JsonKey() final  bool showArea;

/// Create a copy of ChartDataSeries
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChartDataSeriesCopyWith<_ChartDataSeries> get copyWith => __$ChartDataSeriesCopyWithImpl<_ChartDataSeries>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChartDataSeries&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.color, color) || other.color == color)&&(identical(other.showDots, showDots) || other.showDots == showDots)&&(identical(other.showArea, showArea) || other.showArea == showArea));
}


@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_points),color,showDots,showArea);

@override
String toString() {
  return 'ChartDataSeries(name: $name, points: $points, color: $color, showDots: $showDots, showArea: $showArea)';
}


}

/// @nodoc
abstract mixin class _$ChartDataSeriesCopyWith<$Res> implements $ChartDataSeriesCopyWith<$Res> {
  factory _$ChartDataSeriesCopyWith(_ChartDataSeries value, $Res Function(_ChartDataSeries) _then) = __$ChartDataSeriesCopyWithImpl;
@override @useResult
$Res call({
 String name, List<ChartDataPoint> points, Color color, bool showDots, bool showArea
});




}
/// @nodoc
class __$ChartDataSeriesCopyWithImpl<$Res>
    implements _$ChartDataSeriesCopyWith<$Res> {
  __$ChartDataSeriesCopyWithImpl(this._self, this._then);

  final _ChartDataSeries _self;
  final $Res Function(_ChartDataSeries) _then;

/// Create a copy of ChartDataSeries
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? points = null,Object? color = null,Object? showDots = null,Object? showArea = null,}) {
  return _then(_ChartDataSeries(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<ChartDataPoint>,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,showDots: null == showDots ? _self.showDots : showDots // ignore: cast_nullable_to_non_nullable
as bool,showArea: null == showArea ? _self.showArea : showArea // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$LocationStats {

 String get location; int get totalReports; int get urgentReports; int get completedReports; int get pendingReports; Duration? get averageCompletionTime;
/// Create a copy of LocationStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationStatsCopyWith<LocationStats> get copyWith => _$LocationStatsCopyWithImpl<LocationStats>(this as LocationStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationStats&&(identical(other.location, location) || other.location == location)&&(identical(other.totalReports, totalReports) || other.totalReports == totalReports)&&(identical(other.urgentReports, urgentReports) || other.urgentReports == urgentReports)&&(identical(other.completedReports, completedReports) || other.completedReports == completedReports)&&(identical(other.pendingReports, pendingReports) || other.pendingReports == pendingReports)&&(identical(other.averageCompletionTime, averageCompletionTime) || other.averageCompletionTime == averageCompletionTime));
}


@override
int get hashCode => Object.hash(runtimeType,location,totalReports,urgentReports,completedReports,pendingReports,averageCompletionTime);

@override
String toString() {
  return 'LocationStats(location: $location, totalReports: $totalReports, urgentReports: $urgentReports, completedReports: $completedReports, pendingReports: $pendingReports, averageCompletionTime: $averageCompletionTime)';
}


}

/// @nodoc
abstract mixin class $LocationStatsCopyWith<$Res>  {
  factory $LocationStatsCopyWith(LocationStats value, $Res Function(LocationStats) _then) = _$LocationStatsCopyWithImpl;
@useResult
$Res call({
 String location, int totalReports, int urgentReports, int completedReports, int pendingReports, Duration? averageCompletionTime
});




}
/// @nodoc
class _$LocationStatsCopyWithImpl<$Res>
    implements $LocationStatsCopyWith<$Res> {
  _$LocationStatsCopyWithImpl(this._self, this._then);

  final LocationStats _self;
  final $Res Function(LocationStats) _then;

/// Create a copy of LocationStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? location = null,Object? totalReports = null,Object? urgentReports = null,Object? completedReports = null,Object? pendingReports = null,Object? averageCompletionTime = freezed,}) {
  return _then(_self.copyWith(
location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,totalReports: null == totalReports ? _self.totalReports : totalReports // ignore: cast_nullable_to_non_nullable
as int,urgentReports: null == urgentReports ? _self.urgentReports : urgentReports // ignore: cast_nullable_to_non_nullable
as int,completedReports: null == completedReports ? _self.completedReports : completedReports // ignore: cast_nullable_to_non_nullable
as int,pendingReports: null == pendingReports ? _self.pendingReports : pendingReports // ignore: cast_nullable_to_non_nullable
as int,averageCompletionTime: freezed == averageCompletionTime ? _self.averageCompletionTime : averageCompletionTime // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationStats].
extension LocationStatsPatterns on LocationStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationStats value)  $default,){
final _that = this;
switch (_that) {
case _LocationStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationStats value)?  $default,){
final _that = this;
switch (_that) {
case _LocationStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String location,  int totalReports,  int urgentReports,  int completedReports,  int pendingReports,  Duration? averageCompletionTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationStats() when $default != null:
return $default(_that.location,_that.totalReports,_that.urgentReports,_that.completedReports,_that.pendingReports,_that.averageCompletionTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String location,  int totalReports,  int urgentReports,  int completedReports,  int pendingReports,  Duration? averageCompletionTime)  $default,) {final _that = this;
switch (_that) {
case _LocationStats():
return $default(_that.location,_that.totalReports,_that.urgentReports,_that.completedReports,_that.pendingReports,_that.averageCompletionTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String location,  int totalReports,  int urgentReports,  int completedReports,  int pendingReports,  Duration? averageCompletionTime)?  $default,) {final _that = this;
switch (_that) {
case _LocationStats() when $default != null:
return $default(_that.location,_that.totalReports,_that.urgentReports,_that.completedReports,_that.pendingReports,_that.averageCompletionTime);case _:
  return null;

}
}

}

/// @nodoc


class _LocationStats extends LocationStats {
  const _LocationStats({required this.location, required this.totalReports, this.urgentReports = 0, this.completedReports = 0, this.pendingReports = 0, this.averageCompletionTime}): super._();
  

@override final  String location;
@override final  int totalReports;
@override@JsonKey() final  int urgentReports;
@override@JsonKey() final  int completedReports;
@override@JsonKey() final  int pendingReports;
@override final  Duration? averageCompletionTime;

/// Create a copy of LocationStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationStatsCopyWith<_LocationStats> get copyWith => __$LocationStatsCopyWithImpl<_LocationStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationStats&&(identical(other.location, location) || other.location == location)&&(identical(other.totalReports, totalReports) || other.totalReports == totalReports)&&(identical(other.urgentReports, urgentReports) || other.urgentReports == urgentReports)&&(identical(other.completedReports, completedReports) || other.completedReports == completedReports)&&(identical(other.pendingReports, pendingReports) || other.pendingReports == pendingReports)&&(identical(other.averageCompletionTime, averageCompletionTime) || other.averageCompletionTime == averageCompletionTime));
}


@override
int get hashCode => Object.hash(runtimeType,location,totalReports,urgentReports,completedReports,pendingReports,averageCompletionTime);

@override
String toString() {
  return 'LocationStats(location: $location, totalReports: $totalReports, urgentReports: $urgentReports, completedReports: $completedReports, pendingReports: $pendingReports, averageCompletionTime: $averageCompletionTime)';
}


}

/// @nodoc
abstract mixin class _$LocationStatsCopyWith<$Res> implements $LocationStatsCopyWith<$Res> {
  factory _$LocationStatsCopyWith(_LocationStats value, $Res Function(_LocationStats) _then) = __$LocationStatsCopyWithImpl;
@override @useResult
$Res call({
 String location, int totalReports, int urgentReports, int completedReports, int pendingReports, Duration? averageCompletionTime
});




}
/// @nodoc
class __$LocationStatsCopyWithImpl<$Res>
    implements _$LocationStatsCopyWith<$Res> {
  __$LocationStatsCopyWithImpl(this._self, this._then);

  final _LocationStats _self;
  final $Res Function(_LocationStats) _then;

/// Create a copy of LocationStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? location = null,Object? totalReports = null,Object? urgentReports = null,Object? completedReports = null,Object? pendingReports = null,Object? averageCompletionTime = freezed,}) {
  return _then(_LocationStats(
location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,totalReports: null == totalReports ? _self.totalReports : totalReports // ignore: cast_nullable_to_non_nullable
as int,urgentReports: null == urgentReports ? _self.urgentReports : urgentReports // ignore: cast_nullable_to_non_nullable
as int,completedReports: null == completedReports ? _self.completedReports : completedReports // ignore: cast_nullable_to_non_nullable
as int,pendingReports: null == pendingReports ? _self.pendingReports : pendingReports // ignore: cast_nullable_to_non_nullable
as int,averageCompletionTime: freezed == averageCompletionTime ? _self.averageCompletionTime : averageCompletionTime // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}


}

/// @nodoc
mixin _$StatusStats {

 String get status; int get count; double get percentage; Color get color;
/// Create a copy of StatusStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusStatsCopyWith<StatusStats> get copyWith => _$StatusStatsCopyWithImpl<StatusStats>(this as StatusStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusStats&&(identical(other.status, status) || other.status == status)&&(identical(other.count, count) || other.count == count)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode => Object.hash(runtimeType,status,count,percentage,color);

@override
String toString() {
  return 'StatusStats(status: $status, count: $count, percentage: $percentage, color: $color)';
}


}

/// @nodoc
abstract mixin class $StatusStatsCopyWith<$Res>  {
  factory $StatusStatsCopyWith(StatusStats value, $Res Function(StatusStats) _then) = _$StatusStatsCopyWithImpl;
@useResult
$Res call({
 String status, int count, double percentage, Color color
});




}
/// @nodoc
class _$StatusStatsCopyWithImpl<$Res>
    implements $StatusStatsCopyWith<$Res> {
  _$StatusStatsCopyWithImpl(this._self, this._then);

  final StatusStats _self;
  final $Res Function(StatusStats) _then;

/// Create a copy of StatusStats
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


/// Adds pattern-matching-related methods to [StatusStats].
extension StatusStatsPatterns on StatusStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatusStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatusStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatusStats value)  $default,){
final _that = this;
switch (_that) {
case _StatusStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatusStats value)?  $default,){
final _that = this;
switch (_that) {
case _StatusStats() when $default != null:
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
case _StatusStats() when $default != null:
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
case _StatusStats():
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
case _StatusStats() when $default != null:
return $default(_that.status,_that.count,_that.percentage,_that.color);case _:
  return null;

}
}

}

/// @nodoc


class _StatusStats implements StatusStats {
  const _StatusStats({required this.status, required this.count, required this.percentage, required this.color});
  

@override final  String status;
@override final  int count;
@override final  double percentage;
@override final  Color color;

/// Create a copy of StatusStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusStatsCopyWith<_StatusStats> get copyWith => __$StatusStatsCopyWithImpl<_StatusStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusStats&&(identical(other.status, status) || other.status == status)&&(identical(other.count, count) || other.count == count)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode => Object.hash(runtimeType,status,count,percentage,color);

@override
String toString() {
  return 'StatusStats(status: $status, count: $count, percentage: $percentage, color: $color)';
}


}

/// @nodoc
abstract mixin class _$StatusStatsCopyWith<$Res> implements $StatusStatsCopyWith<$Res> {
  factory _$StatusStatsCopyWith(_StatusStats value, $Res Function(_StatusStats) _then) = __$StatusStatsCopyWithImpl;
@override @useResult
$Res call({
 String status, int count, double percentage, Color color
});




}
/// @nodoc
class __$StatusStatsCopyWithImpl<$Res>
    implements _$StatusStatsCopyWith<$Res> {
  __$StatusStatsCopyWithImpl(this._self, this._then);

  final _StatusStats _self;
  final $Res Function(_StatusStats) _then;

/// Create a copy of StatusStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? count = null,Object? percentage = null,Object? color = null,}) {
  return _then(_StatusStats(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}


}

/// @nodoc
mixin _$CleanerPerformanceChart {

 String get cleanerId; String get cleanerName; int get totalCompleted; int get completedToday; int get completedThisWeek; int get completedThisMonth; Duration? get averageCompletionTime; double get rating;
/// Create a copy of CleanerPerformanceChart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CleanerPerformanceChartCopyWith<CleanerPerformanceChart> get copyWith => _$CleanerPerformanceChartCopyWithImpl<CleanerPerformanceChart>(this as CleanerPerformanceChart, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CleanerPerformanceChart&&(identical(other.cleanerId, cleanerId) || other.cleanerId == cleanerId)&&(identical(other.cleanerName, cleanerName) || other.cleanerName == cleanerName)&&(identical(other.totalCompleted, totalCompleted) || other.totalCompleted == totalCompleted)&&(identical(other.completedToday, completedToday) || other.completedToday == completedToday)&&(identical(other.completedThisWeek, completedThisWeek) || other.completedThisWeek == completedThisWeek)&&(identical(other.completedThisMonth, completedThisMonth) || other.completedThisMonth == completedThisMonth)&&(identical(other.averageCompletionTime, averageCompletionTime) || other.averageCompletionTime == averageCompletionTime)&&(identical(other.rating, rating) || other.rating == rating));
}


@override
int get hashCode => Object.hash(runtimeType,cleanerId,cleanerName,totalCompleted,completedToday,completedThisWeek,completedThisMonth,averageCompletionTime,rating);

@override
String toString() {
  return 'CleanerPerformanceChart(cleanerId: $cleanerId, cleanerName: $cleanerName, totalCompleted: $totalCompleted, completedToday: $completedToday, completedThisWeek: $completedThisWeek, completedThisMonth: $completedThisMonth, averageCompletionTime: $averageCompletionTime, rating: $rating)';
}


}

/// @nodoc
abstract mixin class $CleanerPerformanceChartCopyWith<$Res>  {
  factory $CleanerPerformanceChartCopyWith(CleanerPerformanceChart value, $Res Function(CleanerPerformanceChart) _then) = _$CleanerPerformanceChartCopyWithImpl;
@useResult
$Res call({
 String cleanerId, String cleanerName, int totalCompleted, int completedToday, int completedThisWeek, int completedThisMonth, Duration? averageCompletionTime, double rating
});




}
/// @nodoc
class _$CleanerPerformanceChartCopyWithImpl<$Res>
    implements $CleanerPerformanceChartCopyWith<$Res> {
  _$CleanerPerformanceChartCopyWithImpl(this._self, this._then);

  final CleanerPerformanceChart _self;
  final $Res Function(CleanerPerformanceChart) _then;

/// Create a copy of CleanerPerformanceChart
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cleanerId = null,Object? cleanerName = null,Object? totalCompleted = null,Object? completedToday = null,Object? completedThisWeek = null,Object? completedThisMonth = null,Object? averageCompletionTime = freezed,Object? rating = null,}) {
  return _then(_self.copyWith(
cleanerId: null == cleanerId ? _self.cleanerId : cleanerId // ignore: cast_nullable_to_non_nullable
as String,cleanerName: null == cleanerName ? _self.cleanerName : cleanerName // ignore: cast_nullable_to_non_nullable
as String,totalCompleted: null == totalCompleted ? _self.totalCompleted : totalCompleted // ignore: cast_nullable_to_non_nullable
as int,completedToday: null == completedToday ? _self.completedToday : completedToday // ignore: cast_nullable_to_non_nullable
as int,completedThisWeek: null == completedThisWeek ? _self.completedThisWeek : completedThisWeek // ignore: cast_nullable_to_non_nullable
as int,completedThisMonth: null == completedThisMonth ? _self.completedThisMonth : completedThisMonth // ignore: cast_nullable_to_non_nullable
as int,averageCompletionTime: freezed == averageCompletionTime ? _self.averageCompletionTime : averageCompletionTime // ignore: cast_nullable_to_non_nullable
as Duration?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CleanerPerformanceChart].
extension CleanerPerformanceChartPatterns on CleanerPerformanceChart {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CleanerPerformanceChart value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CleanerPerformanceChart() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CleanerPerformanceChart value)  $default,){
final _that = this;
switch (_that) {
case _CleanerPerformanceChart():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CleanerPerformanceChart value)?  $default,){
final _that = this;
switch (_that) {
case _CleanerPerformanceChart() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String cleanerId,  String cleanerName,  int totalCompleted,  int completedToday,  int completedThisWeek,  int completedThisMonth,  Duration? averageCompletionTime,  double rating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CleanerPerformanceChart() when $default != null:
return $default(_that.cleanerId,_that.cleanerName,_that.totalCompleted,_that.completedToday,_that.completedThisWeek,_that.completedThisMonth,_that.averageCompletionTime,_that.rating);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String cleanerId,  String cleanerName,  int totalCompleted,  int completedToday,  int completedThisWeek,  int completedThisMonth,  Duration? averageCompletionTime,  double rating)  $default,) {final _that = this;
switch (_that) {
case _CleanerPerformanceChart():
return $default(_that.cleanerId,_that.cleanerName,_that.totalCompleted,_that.completedToday,_that.completedThisWeek,_that.completedThisMonth,_that.averageCompletionTime,_that.rating);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String cleanerId,  String cleanerName,  int totalCompleted,  int completedToday,  int completedThisWeek,  int completedThisMonth,  Duration? averageCompletionTime,  double rating)?  $default,) {final _that = this;
switch (_that) {
case _CleanerPerformanceChart() when $default != null:
return $default(_that.cleanerId,_that.cleanerName,_that.totalCompleted,_that.completedToday,_that.completedThisWeek,_that.completedThisMonth,_that.averageCompletionTime,_that.rating);case _:
  return null;

}
}

}

/// @nodoc


class _CleanerPerformanceChart extends CleanerPerformanceChart {
  const _CleanerPerformanceChart({required this.cleanerId, required this.cleanerName, required this.totalCompleted, this.completedToday = 0, this.completedThisWeek = 0, this.completedThisMonth = 0, this.averageCompletionTime, this.rating = 0.0}): super._();
  

@override final  String cleanerId;
@override final  String cleanerName;
@override final  int totalCompleted;
@override@JsonKey() final  int completedToday;
@override@JsonKey() final  int completedThisWeek;
@override@JsonKey() final  int completedThisMonth;
@override final  Duration? averageCompletionTime;
@override@JsonKey() final  double rating;

/// Create a copy of CleanerPerformanceChart
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CleanerPerformanceChartCopyWith<_CleanerPerformanceChart> get copyWith => __$CleanerPerformanceChartCopyWithImpl<_CleanerPerformanceChart>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CleanerPerformanceChart&&(identical(other.cleanerId, cleanerId) || other.cleanerId == cleanerId)&&(identical(other.cleanerName, cleanerName) || other.cleanerName == cleanerName)&&(identical(other.totalCompleted, totalCompleted) || other.totalCompleted == totalCompleted)&&(identical(other.completedToday, completedToday) || other.completedToday == completedToday)&&(identical(other.completedThisWeek, completedThisWeek) || other.completedThisWeek == completedThisWeek)&&(identical(other.completedThisMonth, completedThisMonth) || other.completedThisMonth == completedThisMonth)&&(identical(other.averageCompletionTime, averageCompletionTime) || other.averageCompletionTime == averageCompletionTime)&&(identical(other.rating, rating) || other.rating == rating));
}


@override
int get hashCode => Object.hash(runtimeType,cleanerId,cleanerName,totalCompleted,completedToday,completedThisWeek,completedThisMonth,averageCompletionTime,rating);

@override
String toString() {
  return 'CleanerPerformanceChart(cleanerId: $cleanerId, cleanerName: $cleanerName, totalCompleted: $totalCompleted, completedToday: $completedToday, completedThisWeek: $completedThisWeek, completedThisMonth: $completedThisMonth, averageCompletionTime: $averageCompletionTime, rating: $rating)';
}


}

/// @nodoc
abstract mixin class _$CleanerPerformanceChartCopyWith<$Res> implements $CleanerPerformanceChartCopyWith<$Res> {
  factory _$CleanerPerformanceChartCopyWith(_CleanerPerformanceChart value, $Res Function(_CleanerPerformanceChart) _then) = __$CleanerPerformanceChartCopyWithImpl;
@override @useResult
$Res call({
 String cleanerId, String cleanerName, int totalCompleted, int completedToday, int completedThisWeek, int completedThisMonth, Duration? averageCompletionTime, double rating
});




}
/// @nodoc
class __$CleanerPerformanceChartCopyWithImpl<$Res>
    implements _$CleanerPerformanceChartCopyWith<$Res> {
  __$CleanerPerformanceChartCopyWithImpl(this._self, this._then);

  final _CleanerPerformanceChart _self;
  final $Res Function(_CleanerPerformanceChart) _then;

/// Create a copy of CleanerPerformanceChart
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cleanerId = null,Object? cleanerName = null,Object? totalCompleted = null,Object? completedToday = null,Object? completedThisWeek = null,Object? completedThisMonth = null,Object? averageCompletionTime = freezed,Object? rating = null,}) {
  return _then(_CleanerPerformanceChart(
cleanerId: null == cleanerId ? _self.cleanerId : cleanerId // ignore: cast_nullable_to_non_nullable
as String,cleanerName: null == cleanerName ? _self.cleanerName : cleanerName // ignore: cast_nullable_to_non_nullable
as String,totalCompleted: null == totalCompleted ? _self.totalCompleted : totalCompleted // ignore: cast_nullable_to_non_nullable
as int,completedToday: null == completedToday ? _self.completedToday : completedToday // ignore: cast_nullable_to_non_nullable
as int,completedThisWeek: null == completedThisWeek ? _self.completedThisWeek : completedThisWeek // ignore: cast_nullable_to_non_nullable
as int,completedThisMonth: null == completedThisMonth ? _self.completedThisMonth : completedThisMonth // ignore: cast_nullable_to_non_nullable
as int,averageCompletionTime: freezed == averageCompletionTime ? _self.averageCompletionTime : averageCompletionTime // ignore: cast_nullable_to_non_nullable
as Duration?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$ChartConfig {

 ChartTimeRange get timeRange; bool get showGrid; bool get showLegend; bool get showTooltips; bool get animated; double? get maxY; double? get minY;
/// Create a copy of ChartConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChartConfigCopyWith<ChartConfig> get copyWith => _$ChartConfigCopyWithImpl<ChartConfig>(this as ChartConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChartConfig&&(identical(other.timeRange, timeRange) || other.timeRange == timeRange)&&(identical(other.showGrid, showGrid) || other.showGrid == showGrid)&&(identical(other.showLegend, showLegend) || other.showLegend == showLegend)&&(identical(other.showTooltips, showTooltips) || other.showTooltips == showTooltips)&&(identical(other.animated, animated) || other.animated == animated)&&(identical(other.maxY, maxY) || other.maxY == maxY)&&(identical(other.minY, minY) || other.minY == minY));
}


@override
int get hashCode => Object.hash(runtimeType,timeRange,showGrid,showLegend,showTooltips,animated,maxY,minY);

@override
String toString() {
  return 'ChartConfig(timeRange: $timeRange, showGrid: $showGrid, showLegend: $showLegend, showTooltips: $showTooltips, animated: $animated, maxY: $maxY, minY: $minY)';
}


}

/// @nodoc
abstract mixin class $ChartConfigCopyWith<$Res>  {
  factory $ChartConfigCopyWith(ChartConfig value, $Res Function(ChartConfig) _then) = _$ChartConfigCopyWithImpl;
@useResult
$Res call({
 ChartTimeRange timeRange, bool showGrid, bool showLegend, bool showTooltips, bool animated, double? maxY, double? minY
});




}
/// @nodoc
class _$ChartConfigCopyWithImpl<$Res>
    implements $ChartConfigCopyWith<$Res> {
  _$ChartConfigCopyWithImpl(this._self, this._then);

  final ChartConfig _self;
  final $Res Function(ChartConfig) _then;

/// Create a copy of ChartConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timeRange = null,Object? showGrid = null,Object? showLegend = null,Object? showTooltips = null,Object? animated = null,Object? maxY = freezed,Object? minY = freezed,}) {
  return _then(_self.copyWith(
timeRange: null == timeRange ? _self.timeRange : timeRange // ignore: cast_nullable_to_non_nullable
as ChartTimeRange,showGrid: null == showGrid ? _self.showGrid : showGrid // ignore: cast_nullable_to_non_nullable
as bool,showLegend: null == showLegend ? _self.showLegend : showLegend // ignore: cast_nullable_to_non_nullable
as bool,showTooltips: null == showTooltips ? _self.showTooltips : showTooltips // ignore: cast_nullable_to_non_nullable
as bool,animated: null == animated ? _self.animated : animated // ignore: cast_nullable_to_non_nullable
as bool,maxY: freezed == maxY ? _self.maxY : maxY // ignore: cast_nullable_to_non_nullable
as double?,minY: freezed == minY ? _self.minY : minY // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChartConfig].
extension ChartConfigPatterns on ChartConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChartConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChartConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChartConfig value)  $default,){
final _that = this;
switch (_that) {
case _ChartConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChartConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ChartConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChartTimeRange timeRange,  bool showGrid,  bool showLegend,  bool showTooltips,  bool animated,  double? maxY,  double? minY)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChartConfig() when $default != null:
return $default(_that.timeRange,_that.showGrid,_that.showLegend,_that.showTooltips,_that.animated,_that.maxY,_that.minY);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChartTimeRange timeRange,  bool showGrid,  bool showLegend,  bool showTooltips,  bool animated,  double? maxY,  double? minY)  $default,) {final _that = this;
switch (_that) {
case _ChartConfig():
return $default(_that.timeRange,_that.showGrid,_that.showLegend,_that.showTooltips,_that.animated,_that.maxY,_that.minY);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChartTimeRange timeRange,  bool showGrid,  bool showLegend,  bool showTooltips,  bool animated,  double? maxY,  double? minY)?  $default,) {final _that = this;
switch (_that) {
case _ChartConfig() when $default != null:
return $default(_that.timeRange,_that.showGrid,_that.showLegend,_that.showTooltips,_that.animated,_that.maxY,_that.minY);case _:
  return null;

}
}

}

/// @nodoc


class _ChartConfig implements ChartConfig {
  const _ChartConfig({this.timeRange = ChartTimeRange.thirtyDays, this.showGrid = true, this.showLegend = true, this.showTooltips = true, this.animated = true, this.maxY, this.minY});
  

@override@JsonKey() final  ChartTimeRange timeRange;
@override@JsonKey() final  bool showGrid;
@override@JsonKey() final  bool showLegend;
@override@JsonKey() final  bool showTooltips;
@override@JsonKey() final  bool animated;
@override final  double? maxY;
@override final  double? minY;

/// Create a copy of ChartConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChartConfigCopyWith<_ChartConfig> get copyWith => __$ChartConfigCopyWithImpl<_ChartConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChartConfig&&(identical(other.timeRange, timeRange) || other.timeRange == timeRange)&&(identical(other.showGrid, showGrid) || other.showGrid == showGrid)&&(identical(other.showLegend, showLegend) || other.showLegend == showLegend)&&(identical(other.showTooltips, showTooltips) || other.showTooltips == showTooltips)&&(identical(other.animated, animated) || other.animated == animated)&&(identical(other.maxY, maxY) || other.maxY == maxY)&&(identical(other.minY, minY) || other.minY == minY));
}


@override
int get hashCode => Object.hash(runtimeType,timeRange,showGrid,showLegend,showTooltips,animated,maxY,minY);

@override
String toString() {
  return 'ChartConfig(timeRange: $timeRange, showGrid: $showGrid, showLegend: $showLegend, showTooltips: $showTooltips, animated: $animated, maxY: $maxY, minY: $minY)';
}


}

/// @nodoc
abstract mixin class _$ChartConfigCopyWith<$Res> implements $ChartConfigCopyWith<$Res> {
  factory _$ChartConfigCopyWith(_ChartConfig value, $Res Function(_ChartConfig) _then) = __$ChartConfigCopyWithImpl;
@override @useResult
$Res call({
 ChartTimeRange timeRange, bool showGrid, bool showLegend, bool showTooltips, bool animated, double? maxY, double? minY
});




}
/// @nodoc
class __$ChartConfigCopyWithImpl<$Res>
    implements _$ChartConfigCopyWith<$Res> {
  __$ChartConfigCopyWithImpl(this._self, this._then);

  final _ChartConfig _self;
  final $Res Function(_ChartConfig) _then;

/// Create a copy of ChartConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timeRange = null,Object? showGrid = null,Object? showLegend = null,Object? showTooltips = null,Object? animated = null,Object? maxY = freezed,Object? minY = freezed,}) {
  return _then(_ChartConfig(
timeRange: null == timeRange ? _self.timeRange : timeRange // ignore: cast_nullable_to_non_nullable
as ChartTimeRange,showGrid: null == showGrid ? _self.showGrid : showGrid // ignore: cast_nullable_to_non_nullable
as bool,showLegend: null == showLegend ? _self.showLegend : showLegend // ignore: cast_nullable_to_non_nullable
as bool,showTooltips: null == showTooltips ? _self.showTooltips : showTooltips // ignore: cast_nullable_to_non_nullable
as bool,animated: null == animated ? _self.animated : animated // ignore: cast_nullable_to_non_nullable
as bool,maxY: freezed == maxY ? _self.maxY : maxY // ignore: cast_nullable_to_non_nullable
as double?,minY: freezed == minY ? _self.minY : minY // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc
mixin _$TrendData {

 Map<DateTime, int> get totalReports; Map<DateTime, int> get completedReports; Map<DateTime, int> get pendingReports; Map<DateTime, int> get urgentReports;
/// Create a copy of TrendData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrendDataCopyWith<TrendData> get copyWith => _$TrendDataCopyWithImpl<TrendData>(this as TrendData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrendData&&const DeepCollectionEquality().equals(other.totalReports, totalReports)&&const DeepCollectionEquality().equals(other.completedReports, completedReports)&&const DeepCollectionEquality().equals(other.pendingReports, pendingReports)&&const DeepCollectionEquality().equals(other.urgentReports, urgentReports));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(totalReports),const DeepCollectionEquality().hash(completedReports),const DeepCollectionEquality().hash(pendingReports),const DeepCollectionEquality().hash(urgentReports));

@override
String toString() {
  return 'TrendData(totalReports: $totalReports, completedReports: $completedReports, pendingReports: $pendingReports, urgentReports: $urgentReports)';
}


}

/// @nodoc
abstract mixin class $TrendDataCopyWith<$Res>  {
  factory $TrendDataCopyWith(TrendData value, $Res Function(TrendData) _then) = _$TrendDataCopyWithImpl;
@useResult
$Res call({
 Map<DateTime, int> totalReports, Map<DateTime, int> completedReports, Map<DateTime, int> pendingReports, Map<DateTime, int> urgentReports
});




}
/// @nodoc
class _$TrendDataCopyWithImpl<$Res>
    implements $TrendDataCopyWith<$Res> {
  _$TrendDataCopyWithImpl(this._self, this._then);

  final TrendData _self;
  final $Res Function(TrendData) _then;

/// Create a copy of TrendData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalReports = null,Object? completedReports = null,Object? pendingReports = null,Object? urgentReports = null,}) {
  return _then(_self.copyWith(
totalReports: null == totalReports ? _self.totalReports : totalReports // ignore: cast_nullable_to_non_nullable
as Map<DateTime, int>,completedReports: null == completedReports ? _self.completedReports : completedReports // ignore: cast_nullable_to_non_nullable
as Map<DateTime, int>,pendingReports: null == pendingReports ? _self.pendingReports : pendingReports // ignore: cast_nullable_to_non_nullable
as Map<DateTime, int>,urgentReports: null == urgentReports ? _self.urgentReports : urgentReports // ignore: cast_nullable_to_non_nullable
as Map<DateTime, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [TrendData].
extension TrendDataPatterns on TrendData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrendData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrendData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrendData value)  $default,){
final _that = this;
switch (_that) {
case _TrendData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrendData value)?  $default,){
final _that = this;
switch (_that) {
case _TrendData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<DateTime, int> totalReports,  Map<DateTime, int> completedReports,  Map<DateTime, int> pendingReports,  Map<DateTime, int> urgentReports)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrendData() when $default != null:
return $default(_that.totalReports,_that.completedReports,_that.pendingReports,_that.urgentReports);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<DateTime, int> totalReports,  Map<DateTime, int> completedReports,  Map<DateTime, int> pendingReports,  Map<DateTime, int> urgentReports)  $default,) {final _that = this;
switch (_that) {
case _TrendData():
return $default(_that.totalReports,_that.completedReports,_that.pendingReports,_that.urgentReports);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<DateTime, int> totalReports,  Map<DateTime, int> completedReports,  Map<DateTime, int> pendingReports,  Map<DateTime, int> urgentReports)?  $default,) {final _that = this;
switch (_that) {
case _TrendData() when $default != null:
return $default(_that.totalReports,_that.completedReports,_that.pendingReports,_that.urgentReports);case _:
  return null;

}
}

}

/// @nodoc


class _TrendData extends TrendData {
  const _TrendData({required final  Map<DateTime, int> totalReports, required final  Map<DateTime, int> completedReports, required final  Map<DateTime, int> pendingReports, required final  Map<DateTime, int> urgentReports}): _totalReports = totalReports,_completedReports = completedReports,_pendingReports = pendingReports,_urgentReports = urgentReports,super._();
  

 final  Map<DateTime, int> _totalReports;
@override Map<DateTime, int> get totalReports {
  if (_totalReports is EqualUnmodifiableMapView) return _totalReports;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_totalReports);
}

 final  Map<DateTime, int> _completedReports;
@override Map<DateTime, int> get completedReports {
  if (_completedReports is EqualUnmodifiableMapView) return _completedReports;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_completedReports);
}

 final  Map<DateTime, int> _pendingReports;
@override Map<DateTime, int> get pendingReports {
  if (_pendingReports is EqualUnmodifiableMapView) return _pendingReports;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_pendingReports);
}

 final  Map<DateTime, int> _urgentReports;
@override Map<DateTime, int> get urgentReports {
  if (_urgentReports is EqualUnmodifiableMapView) return _urgentReports;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_urgentReports);
}


/// Create a copy of TrendData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrendDataCopyWith<_TrendData> get copyWith => __$TrendDataCopyWithImpl<_TrendData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrendData&&const DeepCollectionEquality().equals(other._totalReports, _totalReports)&&const DeepCollectionEquality().equals(other._completedReports, _completedReports)&&const DeepCollectionEquality().equals(other._pendingReports, _pendingReports)&&const DeepCollectionEquality().equals(other._urgentReports, _urgentReports));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_totalReports),const DeepCollectionEquality().hash(_completedReports),const DeepCollectionEquality().hash(_pendingReports),const DeepCollectionEquality().hash(_urgentReports));

@override
String toString() {
  return 'TrendData(totalReports: $totalReports, completedReports: $completedReports, pendingReports: $pendingReports, urgentReports: $urgentReports)';
}


}

/// @nodoc
abstract mixin class _$TrendDataCopyWith<$Res> implements $TrendDataCopyWith<$Res> {
  factory _$TrendDataCopyWith(_TrendData value, $Res Function(_TrendData) _then) = __$TrendDataCopyWithImpl;
@override @useResult
$Res call({
 Map<DateTime, int> totalReports, Map<DateTime, int> completedReports, Map<DateTime, int> pendingReports, Map<DateTime, int> urgentReports
});




}
/// @nodoc
class __$TrendDataCopyWithImpl<$Res>
    implements _$TrendDataCopyWith<$Res> {
  __$TrendDataCopyWithImpl(this._self, this._then);

  final _TrendData _self;
  final $Res Function(_TrendData) _then;

/// Create a copy of TrendData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalReports = null,Object? completedReports = null,Object? pendingReports = null,Object? urgentReports = null,}) {
  return _then(_TrendData(
totalReports: null == totalReports ? _self._totalReports : totalReports // ignore: cast_nullable_to_non_nullable
as Map<DateTime, int>,completedReports: null == completedReports ? _self._completedReports : completedReports // ignore: cast_nullable_to_non_nullable
as Map<DateTime, int>,pendingReports: null == pendingReports ? _self._pendingReports : pendingReports // ignore: cast_nullable_to_non_nullable
as Map<DateTime, int>,urgentReports: null == urgentReports ? _self._urgentReports : urgentReports // ignore: cast_nullable_to_non_nullable
as Map<DateTime, int>,
  ));
}


}

// dart format on
