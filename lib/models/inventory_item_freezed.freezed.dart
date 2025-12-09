// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_item_freezed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InventoryItem {

 String get id; String get name; String get category;// 'alat', 'consumable', 'ppe'
 int get currentStock; int get maxStock; int get minStock; String get unit; String? get description; String? get imageUrl;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime get updatedAt;
/// Create a copy of InventoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryItemCopyWith<InventoryItem> get copyWith => _$InventoryItemCopyWithImpl<InventoryItem>(this as InventoryItem, _$identity);

  /// Serializes this InventoryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.currentStock, currentStock) || other.currentStock == currentStock)&&(identical(other.maxStock, maxStock) || other.maxStock == maxStock)&&(identical(other.minStock, minStock) || other.minStock == minStock)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,currentStock,maxStock,minStock,unit,description,imageUrl,createdAt,updatedAt);

@override
String toString() {
  return 'InventoryItem(id: $id, name: $name, category: $category, currentStock: $currentStock, maxStock: $maxStock, minStock: $minStock, unit: $unit, description: $description, imageUrl: $imageUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $InventoryItemCopyWith<$Res>  {
  factory $InventoryItemCopyWith(InventoryItem value, $Res Function(InventoryItem) _then) = _$InventoryItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, String category, int currentStock, int maxStock, int minStock, String unit, String? description, String? imageUrl,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class _$InventoryItemCopyWithImpl<$Res>
    implements $InventoryItemCopyWith<$Res> {
  _$InventoryItemCopyWithImpl(this._self, this._then);

  final InventoryItem _self;
  final $Res Function(InventoryItem) _then;

/// Create a copy of InventoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? category = null,Object? currentStock = null,Object? maxStock = null,Object? minStock = null,Object? unit = null,Object? description = freezed,Object? imageUrl = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,currentStock: null == currentStock ? _self.currentStock : currentStock // ignore: cast_nullable_to_non_nullable
as int,maxStock: null == maxStock ? _self.maxStock : maxStock // ignore: cast_nullable_to_non_nullable
as int,minStock: null == minStock ? _self.minStock : minStock // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryItem].
extension InventoryItemPatterns on InventoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryItem value)  $default,){
final _that = this;
switch (_that) {
case _InventoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String category,  int currentStock,  int maxStock,  int minStock,  String unit,  String? description,  String? imageUrl, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryItem() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.currentStock,_that.maxStock,_that.minStock,_that.unit,_that.description,_that.imageUrl,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String category,  int currentStock,  int maxStock,  int minStock,  String unit,  String? description,  String? imageUrl, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _InventoryItem():
return $default(_that.id,_that.name,_that.category,_that.currentStock,_that.maxStock,_that.minStock,_that.unit,_that.description,_that.imageUrl,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String category,  int currentStock,  int maxStock,  int minStock,  String unit,  String? description,  String? imageUrl, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _InventoryItem() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.currentStock,_that.maxStock,_that.minStock,_that.unit,_that.description,_that.imageUrl,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InventoryItem extends InventoryItem {
  const _InventoryItem({required this.id, required this.name, required this.category, required this.currentStock, required this.maxStock, required this.minStock, required this.unit, this.description, this.imageUrl, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt}): super._();
  factory _InventoryItem.fromJson(Map<String, dynamic> json) => _$InventoryItemFromJson(json);

@override final  String id;
@override final  String name;
@override final  String category;
// 'alat', 'consumable', 'ppe'
@override final  int currentStock;
@override final  int maxStock;
@override final  int minStock;
@override final  String unit;
@override final  String? description;
@override final  String? imageUrl;
@override@TimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime updatedAt;

/// Create a copy of InventoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryItemCopyWith<_InventoryItem> get copyWith => __$InventoryItemCopyWithImpl<_InventoryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InventoryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.currentStock, currentStock) || other.currentStock == currentStock)&&(identical(other.maxStock, maxStock) || other.maxStock == maxStock)&&(identical(other.minStock, minStock) || other.minStock == minStock)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,currentStock,maxStock,minStock,unit,description,imageUrl,createdAt,updatedAt);

@override
String toString() {
  return 'InventoryItem(id: $id, name: $name, category: $category, currentStock: $currentStock, maxStock: $maxStock, minStock: $minStock, unit: $unit, description: $description, imageUrl: $imageUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$InventoryItemCopyWith<$Res> implements $InventoryItemCopyWith<$Res> {
  factory _$InventoryItemCopyWith(_InventoryItem value, $Res Function(_InventoryItem) _then) = __$InventoryItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String category, int currentStock, int maxStock, int minStock, String unit, String? description, String? imageUrl,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class __$InventoryItemCopyWithImpl<$Res>
    implements _$InventoryItemCopyWith<$Res> {
  __$InventoryItemCopyWithImpl(this._self, this._then);

  final _InventoryItem _self;
  final $Res Function(_InventoryItem) _then;

/// Create a copy of InventoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? category = null,Object? currentStock = null,Object? maxStock = null,Object? minStock = null,Object? unit = null,Object? description = freezed,Object? imageUrl = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_InventoryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,currentStock: null == currentStock ? _self.currentStock : currentStock // ignore: cast_nullable_to_non_nullable
as int,maxStock: null == maxStock ? _self.maxStock : maxStock // ignore: cast_nullable_to_non_nullable
as int,minStock: null == minStock ? _self.minStock : minStock // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$StockRequest {

 String get id; String get itemId; String get itemName; String get requesterId; String get requesterName; int get requestedQuantity; String? get notes; StockRequestStatus get status;@TimestampConverter() DateTime get requestedAt;@NullableTimestampConverter() DateTime? get approvedAt; String? get approvedBy; String? get approvedByName; String? get rejectionReason;
/// Create a copy of StockRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockRequestCopyWith<StockRequest> get copyWith => _$StockRequestCopyWithImpl<StockRequest>(this as StockRequest, _$identity);

  /// Serializes this StockRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.requesterId, requesterId) || other.requesterId == requesterId)&&(identical(other.requesterName, requesterName) || other.requesterName == requesterName)&&(identical(other.requestedQuantity, requestedQuantity) || other.requestedQuantity == requestedQuantity)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.approvedByName, approvedByName) || other.approvedByName == approvedByName)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,itemName,requesterId,requesterName,requestedQuantity,notes,status,requestedAt,approvedAt,approvedBy,approvedByName,rejectionReason);

@override
String toString() {
  return 'StockRequest(id: $id, itemId: $itemId, itemName: $itemName, requesterId: $requesterId, requesterName: $requesterName, requestedQuantity: $requestedQuantity, notes: $notes, status: $status, requestedAt: $requestedAt, approvedAt: $approvedAt, approvedBy: $approvedBy, approvedByName: $approvedByName, rejectionReason: $rejectionReason)';
}


}

/// @nodoc
abstract mixin class $StockRequestCopyWith<$Res>  {
  factory $StockRequestCopyWith(StockRequest value, $Res Function(StockRequest) _then) = _$StockRequestCopyWithImpl;
@useResult
$Res call({
 String id, String itemId, String itemName, String requesterId, String requesterName, int requestedQuantity, String? notes, StockRequestStatus status,@TimestampConverter() DateTime requestedAt,@NullableTimestampConverter() DateTime? approvedAt, String? approvedBy, String? approvedByName, String? rejectionReason
});




}
/// @nodoc
class _$StockRequestCopyWithImpl<$Res>
    implements $StockRequestCopyWith<$Res> {
  _$StockRequestCopyWithImpl(this._self, this._then);

  final StockRequest _self;
  final $Res Function(StockRequest) _then;

/// Create a copy of StockRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? itemId = null,Object? itemName = null,Object? requesterId = null,Object? requesterName = null,Object? requestedQuantity = null,Object? notes = freezed,Object? status = null,Object? requestedAt = null,Object? approvedAt = freezed,Object? approvedBy = freezed,Object? approvedByName = freezed,Object? rejectionReason = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,requesterId: null == requesterId ? _self.requesterId : requesterId // ignore: cast_nullable_to_non_nullable
as String,requesterName: null == requesterName ? _self.requesterName : requesterName // ignore: cast_nullable_to_non_nullable
as String,requestedQuantity: null == requestedQuantity ? _self.requestedQuantity : requestedQuantity // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StockRequestStatus,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as String?,approvedByName: freezed == approvedByName ? _self.approvedByName : approvedByName // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StockRequest].
extension StockRequestPatterns on StockRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockRequest value)  $default,){
final _that = this;
switch (_that) {
case _StockRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockRequest value)?  $default,){
final _that = this;
switch (_that) {
case _StockRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String itemId,  String itemName,  String requesterId,  String requesterName,  int requestedQuantity,  String? notes,  StockRequestStatus status, @TimestampConverter()  DateTime requestedAt, @NullableTimestampConverter()  DateTime? approvedAt,  String? approvedBy,  String? approvedByName,  String? rejectionReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockRequest() when $default != null:
return $default(_that.id,_that.itemId,_that.itemName,_that.requesterId,_that.requesterName,_that.requestedQuantity,_that.notes,_that.status,_that.requestedAt,_that.approvedAt,_that.approvedBy,_that.approvedByName,_that.rejectionReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String itemId,  String itemName,  String requesterId,  String requesterName,  int requestedQuantity,  String? notes,  StockRequestStatus status, @TimestampConverter()  DateTime requestedAt, @NullableTimestampConverter()  DateTime? approvedAt,  String? approvedBy,  String? approvedByName,  String? rejectionReason)  $default,) {final _that = this;
switch (_that) {
case _StockRequest():
return $default(_that.id,_that.itemId,_that.itemName,_that.requesterId,_that.requesterName,_that.requestedQuantity,_that.notes,_that.status,_that.requestedAt,_that.approvedAt,_that.approvedBy,_that.approvedByName,_that.rejectionReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String itemId,  String itemName,  String requesterId,  String requesterName,  int requestedQuantity,  String? notes,  StockRequestStatus status, @TimestampConverter()  DateTime requestedAt, @NullableTimestampConverter()  DateTime? approvedAt,  String? approvedBy,  String? approvedByName,  String? rejectionReason)?  $default,) {final _that = this;
switch (_that) {
case _StockRequest() when $default != null:
return $default(_that.id,_that.itemId,_that.itemName,_that.requesterId,_that.requesterName,_that.requestedQuantity,_that.notes,_that.status,_that.requestedAt,_that.approvedAt,_that.approvedBy,_that.approvedByName,_that.rejectionReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StockRequest extends StockRequest {
  const _StockRequest({required this.id, required this.itemId, required this.itemName, required this.requesterId, required this.requesterName, required this.requestedQuantity, this.notes, required this.status, @TimestampConverter() required this.requestedAt, @NullableTimestampConverter() this.approvedAt, this.approvedBy, this.approvedByName, this.rejectionReason}): super._();
  factory _StockRequest.fromJson(Map<String, dynamic> json) => _$StockRequestFromJson(json);

@override final  String id;
@override final  String itemId;
@override final  String itemName;
@override final  String requesterId;
@override final  String requesterName;
@override final  int requestedQuantity;
@override final  String? notes;
@override final  StockRequestStatus status;
@override@TimestampConverter() final  DateTime requestedAt;
@override@NullableTimestampConverter() final  DateTime? approvedAt;
@override final  String? approvedBy;
@override final  String? approvedByName;
@override final  String? rejectionReason;

/// Create a copy of StockRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockRequestCopyWith<_StockRequest> get copyWith => __$StockRequestCopyWithImpl<_StockRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StockRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.requesterId, requesterId) || other.requesterId == requesterId)&&(identical(other.requesterName, requesterName) || other.requesterName == requesterName)&&(identical(other.requestedQuantity, requestedQuantity) || other.requestedQuantity == requestedQuantity)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.approvedByName, approvedByName) || other.approvedByName == approvedByName)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,itemName,requesterId,requesterName,requestedQuantity,notes,status,requestedAt,approvedAt,approvedBy,approvedByName,rejectionReason);

@override
String toString() {
  return 'StockRequest(id: $id, itemId: $itemId, itemName: $itemName, requesterId: $requesterId, requesterName: $requesterName, requestedQuantity: $requestedQuantity, notes: $notes, status: $status, requestedAt: $requestedAt, approvedAt: $approvedAt, approvedBy: $approvedBy, approvedByName: $approvedByName, rejectionReason: $rejectionReason)';
}


}

/// @nodoc
abstract mixin class _$StockRequestCopyWith<$Res> implements $StockRequestCopyWith<$Res> {
  factory _$StockRequestCopyWith(_StockRequest value, $Res Function(_StockRequest) _then) = __$StockRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String itemId, String itemName, String requesterId, String requesterName, int requestedQuantity, String? notes, StockRequestStatus status,@TimestampConverter() DateTime requestedAt,@NullableTimestampConverter() DateTime? approvedAt, String? approvedBy, String? approvedByName, String? rejectionReason
});




}
/// @nodoc
class __$StockRequestCopyWithImpl<$Res>
    implements _$StockRequestCopyWith<$Res> {
  __$StockRequestCopyWithImpl(this._self, this._then);

  final _StockRequest _self;
  final $Res Function(_StockRequest) _then;

/// Create a copy of StockRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? itemId = null,Object? itemName = null,Object? requesterId = null,Object? requesterName = null,Object? requestedQuantity = null,Object? notes = freezed,Object? status = null,Object? requestedAt = null,Object? approvedAt = freezed,Object? approvedBy = freezed,Object? approvedByName = freezed,Object? rejectionReason = freezed,}) {
  return _then(_StockRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,requesterId: null == requesterId ? _self.requesterId : requesterId // ignore: cast_nullable_to_non_nullable
as String,requesterName: null == requesterName ? _self.requesterName : requesterName // ignore: cast_nullable_to_non_nullable
as String,requestedQuantity: null == requestedQuantity ? _self.requestedQuantity : requestedQuantity // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StockRequestStatus,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as String?,approvedByName: freezed == approvedByName ? _self.approvedByName : approvedByName // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
