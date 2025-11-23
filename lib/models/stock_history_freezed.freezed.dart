// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_history_freezed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StockHistory {

 String get id; String get itemId; String get itemName; StockAction get action; int get quantity; int get previousStock; int get newStock; String get performedBy; String get performedByName; String? get notes;@ISODateTimeConverter() DateTime get timestamp; String? get referenceId;
/// Create a copy of StockHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockHistoryCopyWith<StockHistory> get copyWith => _$StockHistoryCopyWithImpl<StockHistory>(this as StockHistory, _$identity);

  /// Serializes this StockHistory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockHistory&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.action, action) || other.action == action)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.previousStock, previousStock) || other.previousStock == previousStock)&&(identical(other.newStock, newStock) || other.newStock == newStock)&&(identical(other.performedBy, performedBy) || other.performedBy == performedBy)&&(identical(other.performedByName, performedByName) || other.performedByName == performedByName)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,itemName,action,quantity,previousStock,newStock,performedBy,performedByName,notes,timestamp,referenceId);

@override
String toString() {
  return 'StockHistory(id: $id, itemId: $itemId, itemName: $itemName, action: $action, quantity: $quantity, previousStock: $previousStock, newStock: $newStock, performedBy: $performedBy, performedByName: $performedByName, notes: $notes, timestamp: $timestamp, referenceId: $referenceId)';
}


}

/// @nodoc
abstract mixin class $StockHistoryCopyWith<$Res>  {
  factory $StockHistoryCopyWith(StockHistory value, $Res Function(StockHistory) _then) = _$StockHistoryCopyWithImpl;
@useResult
$Res call({
 String id, String itemId, String itemName, StockAction action, int quantity, int previousStock, int newStock, String performedBy, String performedByName, String? notes,@ISODateTimeConverter() DateTime timestamp, String? referenceId
});




}
/// @nodoc
class _$StockHistoryCopyWithImpl<$Res>
    implements $StockHistoryCopyWith<$Res> {
  _$StockHistoryCopyWithImpl(this._self, this._then);

  final StockHistory _self;
  final $Res Function(StockHistory) _then;

/// Create a copy of StockHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? itemId = null,Object? itemName = null,Object? action = null,Object? quantity = null,Object? previousStock = null,Object? newStock = null,Object? performedBy = null,Object? performedByName = null,Object? notes = freezed,Object? timestamp = null,Object? referenceId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as StockAction,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,previousStock: null == previousStock ? _self.previousStock : previousStock // ignore: cast_nullable_to_non_nullable
as int,newStock: null == newStock ? _self.newStock : newStock // ignore: cast_nullable_to_non_nullable
as int,performedBy: null == performedBy ? _self.performedBy : performedBy // ignore: cast_nullable_to_non_nullable
as String,performedByName: null == performedByName ? _self.performedByName : performedByName // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StockHistory].
extension StockHistoryPatterns on StockHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockHistory value)  $default,){
final _that = this;
switch (_that) {
case _StockHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockHistory value)?  $default,){
final _that = this;
switch (_that) {
case _StockHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String itemId,  String itemName,  StockAction action,  int quantity,  int previousStock,  int newStock,  String performedBy,  String performedByName,  String? notes, @ISODateTimeConverter()  DateTime timestamp,  String? referenceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockHistory() when $default != null:
return $default(_that.id,_that.itemId,_that.itemName,_that.action,_that.quantity,_that.previousStock,_that.newStock,_that.performedBy,_that.performedByName,_that.notes,_that.timestamp,_that.referenceId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String itemId,  String itemName,  StockAction action,  int quantity,  int previousStock,  int newStock,  String performedBy,  String performedByName,  String? notes, @ISODateTimeConverter()  DateTime timestamp,  String? referenceId)  $default,) {final _that = this;
switch (_that) {
case _StockHistory():
return $default(_that.id,_that.itemId,_that.itemName,_that.action,_that.quantity,_that.previousStock,_that.newStock,_that.performedBy,_that.performedByName,_that.notes,_that.timestamp,_that.referenceId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String itemId,  String itemName,  StockAction action,  int quantity,  int previousStock,  int newStock,  String performedBy,  String performedByName,  String? notes, @ISODateTimeConverter()  DateTime timestamp,  String? referenceId)?  $default,) {final _that = this;
switch (_that) {
case _StockHistory() when $default != null:
return $default(_that.id,_that.itemId,_that.itemName,_that.action,_that.quantity,_that.previousStock,_that.newStock,_that.performedBy,_that.performedByName,_that.notes,_that.timestamp,_that.referenceId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StockHistory extends StockHistory {
  const _StockHistory({required this.id, required this.itemId, required this.itemName, required this.action, required this.quantity, required this.previousStock, required this.newStock, required this.performedBy, required this.performedByName, this.notes, @ISODateTimeConverter() required this.timestamp, this.referenceId}): super._();
  factory _StockHistory.fromJson(Map<String, dynamic> json) => _$StockHistoryFromJson(json);

@override final  String id;
@override final  String itemId;
@override final  String itemName;
@override final  StockAction action;
@override final  int quantity;
@override final  int previousStock;
@override final  int newStock;
@override final  String performedBy;
@override final  String performedByName;
@override final  String? notes;
@override@ISODateTimeConverter() final  DateTime timestamp;
@override final  String? referenceId;

/// Create a copy of StockHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockHistoryCopyWith<_StockHistory> get copyWith => __$StockHistoryCopyWithImpl<_StockHistory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StockHistoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockHistory&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.action, action) || other.action == action)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.previousStock, previousStock) || other.previousStock == previousStock)&&(identical(other.newStock, newStock) || other.newStock == newStock)&&(identical(other.performedBy, performedBy) || other.performedBy == performedBy)&&(identical(other.performedByName, performedByName) || other.performedByName == performedByName)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,itemName,action,quantity,previousStock,newStock,performedBy,performedByName,notes,timestamp,referenceId);

@override
String toString() {
  return 'StockHistory(id: $id, itemId: $itemId, itemName: $itemName, action: $action, quantity: $quantity, previousStock: $previousStock, newStock: $newStock, performedBy: $performedBy, performedByName: $performedByName, notes: $notes, timestamp: $timestamp, referenceId: $referenceId)';
}


}

/// @nodoc
abstract mixin class _$StockHistoryCopyWith<$Res> implements $StockHistoryCopyWith<$Res> {
  factory _$StockHistoryCopyWith(_StockHistory value, $Res Function(_StockHistory) _then) = __$StockHistoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String itemId, String itemName, StockAction action, int quantity, int previousStock, int newStock, String performedBy, String performedByName, String? notes,@ISODateTimeConverter() DateTime timestamp, String? referenceId
});




}
/// @nodoc
class __$StockHistoryCopyWithImpl<$Res>
    implements _$StockHistoryCopyWith<$Res> {
  __$StockHistoryCopyWithImpl(this._self, this._then);

  final _StockHistory _self;
  final $Res Function(_StockHistory) _then;

/// Create a copy of StockHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? itemId = null,Object? itemName = null,Object? action = null,Object? quantity = null,Object? previousStock = null,Object? newStock = null,Object? performedBy = null,Object? performedByName = null,Object? notes = freezed,Object? timestamp = null,Object? referenceId = freezed,}) {
  return _then(_StockHistory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as StockAction,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,previousStock: null == previousStock ? _self.previousStock : previousStock // ignore: cast_nullable_to_non_nullable
as int,newStock: null == newStock ? _self.newStock : newStock // ignore: cast_nullable_to_non_nullable
as int,performedBy: null == performedBy ? _self.performedBy : performedBy // ignore: cast_nullable_to_non_nullable
as String,performedByName: null == performedByName ? _self.performedByName : performedByName // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
