import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee.freezed.dart';
part 'employee.g.dart';

@freezed
abstract class Employee with _$Employee {
  const factory Employee({
    required String id,
    required String nip,
    @JsonKey(name: 'full_name') required String fullName,
    String? email,
    String? phone,
    String? position, // Jabatan (contoh: Analis Kepegawaian)
    @JsonKey(name: 'employee_type') @Default('pns') String employeeType, // pns, pppk, honorer
    @JsonKey(name: 'golongan_pangkat') String? golonganPangkat, // Hanya untuk ASN: I/a, II/b, III/c, IV/d
    String? eselon, // Hanya untuk ASN dengan jabatan struktural: I, II, III, IV
    @JsonKey(name: 'organization_id') String? organizationId,
    @Default('active') String status,
    @JsonKey(name: 'photo_url') String? photoUrl,
    @JsonKey(name: 'department_name') String? departmentName, // For convenience in UI, joined query
  }) = _Employee;

  factory Employee.fromJson(Map<String, dynamic> json) => _$EmployeeFromJson(json);
}

/// Enum untuk tipe pegawai
class EmployeeType {
  static const String pns = 'pns'; // Sebelumnya asn
  static const String pppk = 'pppk'; // Sebelumnya kontrak
  static const String honorer = 'honorer';
  
  static List<String> get all => [pns, pppk, honorer];
  
  static String getDisplayName(String type) {
    switch (type) {
      case pns: return 'PNS (Pegawai Negeri Sipil)';
      case pppk: return 'PPPK (P3K)';
      case honorer: return 'Tenaga Honorer';
      default: return type;
    }
  }
}

/// Daftar Golongan Pangkat ASN (Lengkap dengan Nama Pangkat)
class GolonganPangkat {
  static List<String> get all => [
    // Golongan IV (Pembina)
    'IV/e - Pembina Utama',
    'IV/d - Pembina Utama Madya',
    'IV/c - Pembina Utama Muda',
    'IV/b - Pembina Tingkat I',
    'IV/a - Pembina',
    
    // Golongan III (Penata)
    'III/d - Penata Tingkat I',
    'III/c - Penata',
    'III/b - Penata Muda Tingkat I',
    'III/a - Penata Muda',
    
    // Golongan II (Pengatur)
    'II/d - Pengatur Tingkat I',
    'II/c - Pengatur',
    'II/b - Pengatur Muda Tingkat I',
    'II/a - Pengatur Muda',
    
    // Golongan I (Juru)
    'I/d - Juru Tingkat I',
    'I/c - Juru',
    'I/b - Juru Muda Tingkat I',
    'I/a - Juru Muda',
  ];
}

/// Daftar Eselon (Jabatan Struktural)
class Eselon {
  static List<String> get all => [
    'I/a', 'I/b',
    'II/a', 'II/b',
    'III/a', 'III/b',
    'IV/a', 'IV/b',
    'V/a',
  ];
}
