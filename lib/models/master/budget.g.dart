// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Budget _$BudgetFromJson(Map json) => $checkedCreate(
  '_Budget',
  json,
  ($checkedConvert) {
    final val = _Budget(
      id: $checkedConvert('id', (v) => v as String),
      fiscalYear: $checkedConvert('fiscal_year', (v) => (v as num).toInt()),
      sourceName: $checkedConvert('source_name', (v) => v as String),
      totalAmount: $checkedConvert(
        'total_amount',
        (v) => (v as num).toDouble(),
      ),
      remainingAmount: $checkedConvert(
        'remaining_amount',
        (v) => (v as num).toDouble(),
      ),
      status: $checkedConvert('status', (v) => v as String),
      description: $checkedConvert('description', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'fiscalYear': 'fiscal_year',
    'sourceName': 'source_name',
    'totalAmount': 'total_amount',
    'remainingAmount': 'remaining_amount',
  },
);

Map<String, dynamic> _$BudgetToJson(_Budget instance) => <String, dynamic>{
  'id': instance.id,
  'fiscal_year': instance.fiscalYear,
  'source_name': instance.sourceName,
  'total_amount': instance.totalAmount,
  'remaining_amount': instance.remainingAmount,
  'status': instance.status,
  'description': ?instance.description,
};
