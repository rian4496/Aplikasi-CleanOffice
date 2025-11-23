// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filter_model_freezed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportFilter {

 String? get searchQuery; List<String>? get statuses; List<String>? get locations; DateTime? get startDate; DateTime? get endDate; bool? get isUrgent; String? get assignedTo;
/// Create a copy of ReportFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportFilterCopyWith<ReportFilter> get copyWith => _$ReportFilterCopyWithImpl<ReportFilter>(this as ReportFilter, _$identity);

  /// Serializes this ReportFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportFilter&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&const DeepCollectionEquality().equals(other.statuses, statuses)&&const DeepCollectionEquality().equals(other.locations, locations)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.isUrgent, isUrgent) || other.isUrgent == isUrgent)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,searchQuery,const DeepCollectionEquality().hash(statuses),const DeepCollectionEquality().hash(locations),startDate,endDate,isUrgent,assignedTo);

@override
String toString() {
  return 'ReportFilter(searchQuery: $searchQuery, statuses: $statuses, locations: $locations, startDate: $startDate, endDate: $endDate, isUrgent: $isUrgent, assignedTo: $assignedTo)';
}


}

/// @nodoc
abstract mixin class $ReportFilterCopyWith<$Res>  {
  factory $ReportFilterCopyWith(ReportFilter value, $Res Function(ReportFilter) _then) = _$ReportFilterCopyWithImpl;
@useResult
$Res call({
 String? searchQuery, List<String>? statuses, List<String>? locations, DateTime? startDate, DateTime? endDate, bool? isUrgent, String? assignedTo
});




}
/// @nodoc
class _$ReportFilterCopyWithImpl<$Res>
    implements $ReportFilterCopyWith<$Res> {
  _$ReportFilterCopyWithImpl(this._self, this._then);

  final ReportFilter _self;
  final $Res Function(ReportFilter) _then;

/// Create a copy of ReportFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchQuery = freezed,Object? statuses = freezed,Object? locations = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? isUrgent = freezed,Object? assignedTo = freezed,}) {
  return _then(_self.copyWith(
searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,statuses: freezed == statuses ? _self.statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<String>?,locations: freezed == locations ? _self.locations : locations // ignore: cast_nullable_to_non_nullable
as List<String>?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isUrgent: freezed == isUrgent ? _self.isUrgent : isUrgent // ignore: cast_nullable_to_non_nullable
as bool?,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportFilter].
extension ReportFilterPatterns on ReportFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportFilter value)  $default,){
final _that = this;
switch (_that) {
case _ReportFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ReportFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? searchQuery,  List<String>? statuses,  List<String>? locations,  DateTime? startDate,  DateTime? endDate,  bool? isUrgent,  String? assignedTo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportFilter() when $default != null:
return $default(_that.searchQuery,_that.statuses,_that.locations,_that.startDate,_that.endDate,_that.isUrgent,_that.assignedTo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? searchQuery,  List<String>? statuses,  List<String>? locations,  DateTime? startDate,  DateTime? endDate,  bool? isUrgent,  String? assignedTo)  $default,) {final _that = this;
switch (_that) {
case _ReportFilter():
return $default(_that.searchQuery,_that.statuses,_that.locations,_that.startDate,_that.endDate,_that.isUrgent,_that.assignedTo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? searchQuery,  List<String>? statuses,  List<String>? locations,  DateTime? startDate,  DateTime? endDate,  bool? isUrgent,  String? assignedTo)?  $default,) {final _that = this;
switch (_that) {
case _ReportFilter() when $default != null:
return $default(_that.searchQuery,_that.statuses,_that.locations,_that.startDate,_that.endDate,_that.isUrgent,_that.assignedTo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportFilter extends ReportFilter {
  const _ReportFilter({this.searchQuery, final  List<String>? statuses, final  List<String>? locations, this.startDate, this.endDate, this.isUrgent, this.assignedTo}): _statuses = statuses,_locations = locations,super._();
  factory _ReportFilter.fromJson(Map<String, dynamic> json) => _$ReportFilterFromJson(json);

@override final  String? searchQuery;
 final  List<String>? _statuses;
@override List<String>? get statuses {
  final value = _statuses;
  if (value == null) return null;
  if (_statuses is EqualUnmodifiableListView) return _statuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _locations;
@override List<String>? get locations {
  final value = _locations;
  if (value == null) return null;
  if (_locations is EqualUnmodifiableListView) return _locations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  DateTime? startDate;
@override final  DateTime? endDate;
@override final  bool? isUrgent;
@override final  String? assignedTo;

/// Create a copy of ReportFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportFilterCopyWith<_ReportFilter> get copyWith => __$ReportFilterCopyWithImpl<_ReportFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportFilterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportFilter&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&const DeepCollectionEquality().equals(other._statuses, _statuses)&&const DeepCollectionEquality().equals(other._locations, _locations)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.isUrgent, isUrgent) || other.isUrgent == isUrgent)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,searchQuery,const DeepCollectionEquality().hash(_statuses),const DeepCollectionEquality().hash(_locations),startDate,endDate,isUrgent,assignedTo);

@override
String toString() {
  return 'ReportFilter(searchQuery: $searchQuery, statuses: $statuses, locations: $locations, startDate: $startDate, endDate: $endDate, isUrgent: $isUrgent, assignedTo: $assignedTo)';
}


}

/// @nodoc
abstract mixin class _$ReportFilterCopyWith<$Res> implements $ReportFilterCopyWith<$Res> {
  factory _$ReportFilterCopyWith(_ReportFilter value, $Res Function(_ReportFilter) _then) = __$ReportFilterCopyWithImpl;
@override @useResult
$Res call({
 String? searchQuery, List<String>? statuses, List<String>? locations, DateTime? startDate, DateTime? endDate, bool? isUrgent, String? assignedTo
});




}
/// @nodoc
class __$ReportFilterCopyWithImpl<$Res>
    implements _$ReportFilterCopyWith<$Res> {
  __$ReportFilterCopyWithImpl(this._self, this._then);

  final _ReportFilter _self;
  final $Res Function(_ReportFilter) _then;

/// Create a copy of ReportFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchQuery = freezed,Object? statuses = freezed,Object? locations = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? isUrgent = freezed,Object? assignedTo = freezed,}) {
  return _then(_ReportFilter(
searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,statuses: freezed == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<String>?,locations: freezed == locations ? _self._locations : locations // ignore: cast_nullable_to_non_nullable
as List<String>?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isUrgent: freezed == isUrgent ? _self.isUrgent : isUrgent // ignore: cast_nullable_to_non_nullable
as bool?,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SavedFilter {

 String get id; String get name; ReportFilter get filter;@ISODateTimeConverter() DateTime get createdAt;
/// Create a copy of SavedFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedFilterCopyWith<SavedFilter> get copyWith => _$SavedFilterCopyWithImpl<SavedFilter>(this as SavedFilter, _$identity);

  /// Serializes this SavedFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedFilter&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,filter,createdAt);

@override
String toString() {
  return 'SavedFilter(id: $id, name: $name, filter: $filter, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SavedFilterCopyWith<$Res>  {
  factory $SavedFilterCopyWith(SavedFilter value, $Res Function(SavedFilter) _then) = _$SavedFilterCopyWithImpl;
@useResult
$Res call({
 String id, String name, ReportFilter filter,@ISODateTimeConverter() DateTime createdAt
});


$ReportFilterCopyWith<$Res> get filter;

}
/// @nodoc
class _$SavedFilterCopyWithImpl<$Res>
    implements $SavedFilterCopyWith<$Res> {
  _$SavedFilterCopyWithImpl(this._self, this._then);

  final SavedFilter _self;
  final $Res Function(SavedFilter) _then;

/// Create a copy of SavedFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? filter = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as ReportFilter,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of SavedFilter
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportFilterCopyWith<$Res> get filter {
  
  return $ReportFilterCopyWith<$Res>(_self.filter, (value) {
    return _then(_self.copyWith(filter: value));
  });
}
}


/// Adds pattern-matching-related methods to [SavedFilter].
extension SavedFilterPatterns on SavedFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedFilter value)  $default,){
final _that = this;
switch (_that) {
case _SavedFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedFilter value)?  $default,){
final _that = this;
switch (_that) {
case _SavedFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  ReportFilter filter, @ISODateTimeConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedFilter() when $default != null:
return $default(_that.id,_that.name,_that.filter,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  ReportFilter filter, @ISODateTimeConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _SavedFilter():
return $default(_that.id,_that.name,_that.filter,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  ReportFilter filter, @ISODateTimeConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SavedFilter() when $default != null:
return $default(_that.id,_that.name,_that.filter,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavedFilter extends SavedFilter {
  const _SavedFilter({required this.id, required this.name, required this.filter, @ISODateTimeConverter() required this.createdAt}): super._();
  factory _SavedFilter.fromJson(Map<String, dynamic> json) => _$SavedFilterFromJson(json);

@override final  String id;
@override final  String name;
@override final  ReportFilter filter;
@override@ISODateTimeConverter() final  DateTime createdAt;

/// Create a copy of SavedFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedFilterCopyWith<_SavedFilter> get copyWith => __$SavedFilterCopyWithImpl<_SavedFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedFilterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedFilter&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,filter,createdAt);

@override
String toString() {
  return 'SavedFilter(id: $id, name: $name, filter: $filter, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SavedFilterCopyWith<$Res> implements $SavedFilterCopyWith<$Res> {
  factory _$SavedFilterCopyWith(_SavedFilter value, $Res Function(_SavedFilter) _then) = __$SavedFilterCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, ReportFilter filter,@ISODateTimeConverter() DateTime createdAt
});


@override $ReportFilterCopyWith<$Res> get filter;

}
/// @nodoc
class __$SavedFilterCopyWithImpl<$Res>
    implements _$SavedFilterCopyWith<$Res> {
  __$SavedFilterCopyWithImpl(this._self, this._then);

  final _SavedFilter _self;
  final $Res Function(_SavedFilter) _then;

/// Create a copy of SavedFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? filter = null,Object? createdAt = null,}) {
  return _then(_SavedFilter(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as ReportFilter,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of SavedFilter
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportFilterCopyWith<$Res> get filter {
  
  return $ReportFilterCopyWith<$Res>(_self.filter, (value) {
    return _then(_self.copyWith(filter: value));
  });
}
}

// dart format on
