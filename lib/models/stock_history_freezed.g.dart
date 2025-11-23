// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_history_freezed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StockHistory _$StockHistoryFromJson(Map json) =>
    $checkedCreate('_StockHistory', json, ($checkedConvert) {
      final val = _StockHistory(
        id: $checkedConvert('id', (v) => v as String),
        itemId: $checkedConvert('itemId', (v) => v as String),
        itemName: $checkedConvert('itemName', (v) => v as String),
        action: $checkedConvert(
          'action',
          (v) => $enumDecode(_$StockActionEnumMap, v),
        ),
        quantity: $checkedConvert('quantity', (v) => (v as num).toInt()),
        previousStock: $checkedConvert(
          'previousStock',
          (v) => (v as num).toInt(),
        ),
        newStock: $checkedConvert('newStock', (v) => (v as num).toInt()),
        performedBy: $checkedConvert('performedBy', (v) => v as String),
        performedByName: $checkedConvert('performedByName', (v) => v as String),
        notes: $checkedConvert('notes', (v) => v as String?),
        timestamp: $checkedConvert(
          'timestamp',
          (v) => const ISODateTimeConverter().fromJson(v as String),
        ),
        referenceId: $checkedConvert('referenceId', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$StockHistoryToJson(_StockHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemId': instance.itemId,
      'itemName': instance.itemName,
      'action': _$StockActionEnumMap[instance.action]!,
      'quantity': instance.quantity,
      'previousStock': instance.previousStock,
      'newStock': instance.newStock,
      'performedBy': instance.performedBy,
      'performedByName': instance.performedByName,
      'notes': ?instance.notes,
      'timestamp': const ISODateTimeConverter().toJson(instance.timestamp),
      'referenceId': ?instance.referenceId,
    };

const _$StockActionEnumMap = {
  StockAction.add: 'add',
  StockAction.reduce: 'reduce',
  StockAction.adjustment: 'adjustment',
  StockAction.fulfillRequest: 'fulfillRequest',
  StockAction.initialStock: 'initialStock',
  StockAction.manual: 'manual',
  StockAction.systemCorrection: 'systemCorrection',
};
