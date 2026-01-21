import 'package:freezed_annotation/freezed_annotation.dart';

part 'vendor.freezed.dart';
part 'vendor.g.dart';

@freezed
abstract class Vendor with _$Vendor {
  const factory Vendor({
    required String id,
    required String name,
    String? address,
    @JsonKey(name: 'contact_person') String? contactPerson,
    String? phone,
    String? email,
    @JsonKey(name: 'tax_id') String? taxId, // NPWP
    @JsonKey(name: 'bank_account') String? bankAccount,
    @JsonKey(name: 'bank_name') String? bankName,
    @JsonKey(name: 'image_url') String? imageUrl, // Foto lokasi/vendor
    @Default('active') String status,
    @Default('Umum') String category, // ATK, IT, Konstruksi, Catering, Umum
  }) = _Vendor;

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);
}
