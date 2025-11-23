// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item_freezed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InventoryItem _$InventoryItemFromJson(Map json) => $checkedCreate(
  '_InventoryItem',
  json,
  ($checkedConvert) {
    final val = _InventoryItem(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      category: $checkedConvert('category', (v) => v as String),
      currentStock: $checkedConvert('currentStock', (v) => (v as num).toInt()),
      maxStock: $checkedConvert('maxStock', (v) => (v as num).toInt()),
      minStock: $checkedConvert('minStock', (v) => (v as num).toInt()),
      unit: $checkedConvert('unit', (v) => v as String),
      description: $checkedConvert('description', (v) => v as String?),
      imageUrl: $checkedConvert('imageUrl', (v) => v as String?),
      createdAt: $checkedConvert(
        'createdAt',
        (v) => const ISODateTimeConverter().fromJson(v as String),
      ),
      updatedAt: $checkedConvert(
        'updatedAt',
        (v) => const ISODateTimeConverter().fromJson(v as String),
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$InventoryItemToJson(_InventoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'currentStock': instance.currentStock,
      'maxStock': instance.maxStock,
      'minStock': instance.minStock,
      'unit': instance.unit,
      'description': ?instance.description,
      'imageUrl': ?instance.imageUrl,
      'createdAt': const ISODateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const ISODateTimeConverter().toJson(instance.updatedAt),
    };

_StockRequest _$StockRequestFromJson(Map json) => $checkedCreate(
  '_StockRequest',
  json,
  ($checkedConvert) {
    final val = _StockRequest(
      id: $checkedConvert('id', (v) => v as String),
      itemId: $checkedConvert('itemId', (v) => v as String),
      itemName: $checkedConvert('itemName', (v) => v as String),
      requesterId: $checkedConvert('requesterId', (v) => v as String),
      requesterName: $checkedConvert('requesterName', (v) => v as String),
      requestedQuantity: $checkedConvert(
        'requestedQuantity',
        (v) => (v as num).toInt(),
      ),
      notes: $checkedConvert('notes', (v) => v as String?),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$StockRequestStatusEnumMap, v),
      ),
      requestedAt: $checkedConvert(
        'requestedAt',
        (v) => const ISODateTimeConverter().fromJson(v as String),
      ),
      approvedAt: $checkedConvert(
        'approvedAt',
        (v) => const NullableISODateTimeConverter().fromJson(v as String?),
      ),
      approvedBy: $checkedConvert('approvedBy', (v) => v as String?),
      approvedByName: $checkedConvert('approvedByName', (v) => v as String?),
      rejectionReason: $checkedConvert('rejectionReason', (v) => v as String?),
    );
    return val;
  },
);

Map<String, dynamic> _$StockRequestToJson(_StockRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemId': instance.itemId,
      'itemName': instance.itemName,
      'requesterId': instance.requesterId,
      'requesterName': instance.requesterName,
      'requestedQuantity': instance.requestedQuantity,
      'notes': ?instance.notes,
      'status': _$StockRequestStatusEnumMap[instance.status]!,
      'requestedAt': const ISODateTimeConverter().toJson(instance.requestedAt),
      'approvedAt': ?const NullableISODateTimeConverter().toJson(
        instance.approvedAt,
      ),
      'approvedBy': ?instance.approvedBy,
      'approvedByName': ?instance.approvedByName,
      'rejectionReason': ?instance.rejectionReason,
    };

const _$StockRequestStatusEnumMap = {
  StockRequestStatus.pending: 'pending',
  StockRequestStatus.approved: 'approved',
  StockRequestStatus.rejected: 'rejected',
  StockRequestStatus.fulfilled: 'fulfilled',
};
