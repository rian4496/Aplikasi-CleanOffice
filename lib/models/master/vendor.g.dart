// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Vendor _$VendorFromJson(Map json) => $checkedCreate(
  '_Vendor',
  json,
  ($checkedConvert) {
    final val = _Vendor(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      address: $checkedConvert('address', (v) => v as String?),
      contactPerson: $checkedConvert('contact_person', (v) => v as String?),
      phone: $checkedConvert('phone', (v) => v as String?),
      email: $checkedConvert('email', (v) => v as String?),
      taxId: $checkedConvert('tax_id', (v) => v as String?),
      bankAccount: $checkedConvert('bank_account', (v) => v as String?),
      bankName: $checkedConvert('bank_name', (v) => v as String?),
      status: $checkedConvert('status', (v) => v as String? ?? 'active'),
      category: $checkedConvert('category', (v) => v as String? ?? 'Umum'),
    );
    return val;
  },
  fieldKeyMap: const {
    'contactPerson': 'contact_person',
    'taxId': 'tax_id',
    'bankAccount': 'bank_account',
    'bankName': 'bank_name',
  },
);

Map<String, dynamic> _$VendorToJson(_Vendor instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': ?instance.address,
  'contact_person': ?instance.contactPerson,
  'phone': ?instance.phone,
  'email': ?instance.email,
  'tax_id': ?instance.taxId,
  'bank_account': ?instance.bankAccount,
  'bank_name': ?instance.bankName,
  'status': instance.status,
  'category': instance.category,
};
