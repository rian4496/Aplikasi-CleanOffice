// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stat_card_data_freezed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StatCardData {

 String get label; String get sublabel; int get value; double get percentage; Color get accentColor; IconData get icon; int? get comparisonValue;// For showing trend (+12, -5, etc.)
 bool get isPositiveTrend;
/// Create a copy of StatCardData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatCardDataCopyWith<StatCardData> get copyWith => _$StatCardDataCopyWithImpl<StatCardData>(this as StatCardData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatCardData&&(identical(other.label, label) || other.label == label)&&(identical(other.sublabel, sublabel) || other.sublabel == sublabel)&&(identical(other.value, value) || other.value == value)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.comparisonValue, comparisonValue) || other.comparisonValue == comparisonValue)&&(identical(other.isPositiveTrend, isPositiveTrend) || other.isPositiveTrend == isPositiveTrend));
}


@override
int get hashCode => Object.hash(runtimeType,label,sublabel,value,percentage,accentColor,icon,comparisonValue,isPositiveTrend);

@override
String toString() {
  return 'StatCardData(label: $label, sublabel: $sublabel, value: $value, percentage: $percentage, accentColor: $accentColor, icon: $icon, comparisonValue: $comparisonValue, isPositiveTrend: $isPositiveTrend)';
}


}

/// @nodoc
abstract mixin class $StatCardDataCopyWith<$Res>  {
  factory $StatCardDataCopyWith(StatCardData value, $Res Function(StatCardData) _then) = _$StatCardDataCopyWithImpl;
@useResult
$Res call({
 String label, String sublabel, int value, double percentage, Color accentColor, IconData icon, int? comparisonValue, bool isPositiveTrend
});




}
/// @nodoc
class _$StatCardDataCopyWithImpl<$Res>
    implements $StatCardDataCopyWith<$Res> {
  _$StatCardDataCopyWithImpl(this._self, this._then);

  final StatCardData _self;
  final $Res Function(StatCardData) _then;

/// Create a copy of StatCardData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? sublabel = null,Object? value = null,Object? percentage = null,Object? accentColor = null,Object? icon = null,Object? comparisonValue = freezed,Object? isPositiveTrend = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,sublabel: null == sublabel ? _self.sublabel : sublabel // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,accentColor: null == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as Color,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,comparisonValue: freezed == comparisonValue ? _self.comparisonValue : comparisonValue // ignore: cast_nullable_to_non_nullable
as int?,isPositiveTrend: null == isPositiveTrend ? _self.isPositiveTrend : isPositiveTrend // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StatCardData].
extension StatCardDataPatterns on StatCardData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatCardData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatCardData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatCardData value)  $default,){
final _that = this;
switch (_that) {
case _StatCardData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatCardData value)?  $default,){
final _that = this;
switch (_that) {
case _StatCardData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String sublabel,  int value,  double percentage,  Color accentColor,  IconData icon,  int? comparisonValue,  bool isPositiveTrend)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatCardData() when $default != null:
return $default(_that.label,_that.sublabel,_that.value,_that.percentage,_that.accentColor,_that.icon,_that.comparisonValue,_that.isPositiveTrend);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String sublabel,  int value,  double percentage,  Color accentColor,  IconData icon,  int? comparisonValue,  bool isPositiveTrend)  $default,) {final _that = this;
switch (_that) {
case _StatCardData():
return $default(_that.label,_that.sublabel,_that.value,_that.percentage,_that.accentColor,_that.icon,_that.comparisonValue,_that.isPositiveTrend);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String sublabel,  int value,  double percentage,  Color accentColor,  IconData icon,  int? comparisonValue,  bool isPositiveTrend)?  $default,) {final _that = this;
switch (_that) {
case _StatCardData() when $default != null:
return $default(_that.label,_that.sublabel,_that.value,_that.percentage,_that.accentColor,_that.icon,_that.comparisonValue,_that.isPositiveTrend);case _:
  return null;

}
}

}

/// @nodoc


class _StatCardData extends StatCardData {
  const _StatCardData({required this.label, required this.sublabel, required this.value, required this.percentage, required this.accentColor, required this.icon, this.comparisonValue, this.isPositiveTrend = true}): super._();
  

@override final  String label;
@override final  String sublabel;
@override final  int value;
@override final  double percentage;
@override final  Color accentColor;
@override final  IconData icon;
@override final  int? comparisonValue;
// For showing trend (+12, -5, etc.)
@override@JsonKey() final  bool isPositiveTrend;

/// Create a copy of StatCardData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatCardDataCopyWith<_StatCardData> get copyWith => __$StatCardDataCopyWithImpl<_StatCardData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatCardData&&(identical(other.label, label) || other.label == label)&&(identical(other.sublabel, sublabel) || other.sublabel == sublabel)&&(identical(other.value, value) || other.value == value)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.comparisonValue, comparisonValue) || other.comparisonValue == comparisonValue)&&(identical(other.isPositiveTrend, isPositiveTrend) || other.isPositiveTrend == isPositiveTrend));
}


@override
int get hashCode => Object.hash(runtimeType,label,sublabel,value,percentage,accentColor,icon,comparisonValue,isPositiveTrend);

@override
String toString() {
  return 'StatCardData(label: $label, sublabel: $sublabel, value: $value, percentage: $percentage, accentColor: $accentColor, icon: $icon, comparisonValue: $comparisonValue, isPositiveTrend: $isPositiveTrend)';
}


}

/// @nodoc
abstract mixin class _$StatCardDataCopyWith<$Res> implements $StatCardDataCopyWith<$Res> {
  factory _$StatCardDataCopyWith(_StatCardData value, $Res Function(_StatCardData) _then) = __$StatCardDataCopyWithImpl;
@override @useResult
$Res call({
 String label, String sublabel, int value, double percentage, Color accentColor, IconData icon, int? comparisonValue, bool isPositiveTrend
});




}
/// @nodoc
class __$StatCardDataCopyWithImpl<$Res>
    implements _$StatCardDataCopyWith<$Res> {
  __$StatCardDataCopyWithImpl(this._self, this._then);

  final _StatCardData _self;
  final $Res Function(_StatCardData) _then;

/// Create a copy of StatCardData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? sublabel = null,Object? value = null,Object? percentage = null,Object? accentColor = null,Object? icon = null,Object? comparisonValue = freezed,Object? isPositiveTrend = null,}) {
  return _then(_StatCardData(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,sublabel: null == sublabel ? _self.sublabel : sublabel // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,accentColor: null == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as Color,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,comparisonValue: freezed == comparisonValue ? _self.comparisonValue : comparisonValue // ignore: cast_nullable_to_non_nullable
as int?,isPositiveTrend: null == isPositiveTrend ? _self.isPositiveTrend : isPositiveTrend // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
