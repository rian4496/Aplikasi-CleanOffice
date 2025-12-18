// Master Data Models - Plain Dart (non-Freezed for compatibility)

// 1. MASTER PEGAWAI
class MasterPegawai {
  final String id;
  final String nip;
  final String namaLengkap;
  final String? email;
  final String? noHp;
  final String? jabatan;
  final String? golongan;
  final String? unitKerjaId;
  final String? fotoUrl;
  final String? alamat;
  final String status;

  const MasterPegawai({
    required this.id,
    required this.nip,
    required this.namaLengkap,
    this.email,
    this.noHp,
    this.jabatan,
    this.golongan,
    this.unitKerjaId,
    this.fotoUrl,
    this.alamat,
    this.status = 'aktif',
  });

  factory MasterPegawai.fromJson(Map<String, dynamic> json) {
    return MasterPegawai(
      id: json['id']?.toString() ?? '',
      nip: json['nip'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? json['namaLengkap'] ?? '',
      email: json['email'],
      noHp: json['no_hp'] ?? json['noHp'],
      jabatan: json['jabatan'],
      golongan: json['golongan'],
      unitKerjaId: json['unit_kerja_id'] ?? json['unitKerjaId'],
      fotoUrl: json['foto_url'] ?? json['fotoUrl'],
      alamat: json['alamat'],
      status: json['status'] ?? 'aktif',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nip': nip,
    'nama_lengkap': namaLengkap,
    'email': email,
    'no_hp': noHp,
    'jabatan': jabatan,
    'golongan': golongan,
    'unit_kerja_id': unitKerjaId,
    'foto_url': fotoUrl,
    'alamat': alamat,
    'status': status,
  };

  MasterPegawai copyWith({
    String? id,
    String? nip,
    String? namaLengkap,
    String? email,
    String? noHp,
    String? jabatan,
    String? golongan,
    String? unitKerjaId,
    String? fotoUrl,
    String? alamat,
    String? status,
  }) {
    return MasterPegawai(
      id: id ?? this.id,
      nip: nip ?? this.nip,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      jabatan: jabatan ?? this.jabatan,
      golongan: golongan ?? this.golongan,
      unitKerjaId: unitKerjaId ?? this.unitKerjaId,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      alamat: alamat ?? this.alamat,
      status: status ?? this.status,
    );
  }
}

// 2. MASTER ORGANISASI
class MasterOrganisasi {
  final String id;
  final String code;
  final String name;
  final String? parentId;
  final String? description;

  const MasterOrganisasi({
    required this.id,
    required this.code,
    required this.name,
    this.parentId,
    this.description,
  });

  factory MasterOrganisasi.fromJson(Map<String, dynamic> json) {
    return MasterOrganisasi(
      id: json['id']?.toString() ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      parentId: json['parent_id'] ?? json['parentId'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'parent_id': parentId,
    'description': description,
  };

  MasterOrganisasi copyWith({
    String? id,
    String? code,
    String? name,
    String? parentId,
    String? description,
  }) {
    return MasterOrganisasi(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      description: description ?? this.description,
    );
  }
}

// 3. MASTER ANGGARAN
class MasterAnggaran {
  final String id;
  final String kodeRekening;
  final String uraian;
  final int tahunAnggaran;
  final double paguAwal;
  final double paguTerpakai;

  const MasterAnggaran({
    required this.id,
    required this.kodeRekening,
    required this.uraian,
    required this.tahunAnggaran,
    this.paguAwal = 0,
    this.paguTerpakai = 0,
  });

  factory MasterAnggaran.fromJson(Map<String, dynamic> json) {
    return MasterAnggaran(
      id: json['id']?.toString() ?? '',
      kodeRekening: json['kode_rekening'] ?? json['kodeRekening'] ?? '',
      uraian: json['uraian'] ?? '',
      tahunAnggaran: json['tahun_anggaran'] ?? json['tahunAnggaran'] ?? DateTime.now().year,
      paguAwal: (json['pagu_awal'] ?? json['paguAwal'] ?? 0).toDouble(),
      paguTerpakai: (json['pagu_terpakai'] ?? json['paguTerpakai'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kode_rekening': kodeRekening,
    'uraian': uraian,
    'tahun_anggaran': tahunAnggaran,
    'pagu_awal': paguAwal,
    'pagu_terpakai': paguTerpakai,
  };

  MasterAnggaran copyWith({
    String? id,
    String? kodeRekening,
    String? uraian,
    int? tahunAnggaran,
    double? paguAwal,
    double? paguTerpakai,
  }) {
    return MasterAnggaran(
      id: id ?? this.id,
      kodeRekening: kodeRekening ?? this.kodeRekening,
      uraian: uraian ?? this.uraian,
      tahunAnggaran: tahunAnggaran ?? this.tahunAnggaran,
      paguAwal: paguAwal ?? this.paguAwal,
      paguTerpakai: paguTerpakai ?? this.paguTerpakai,
    );
  }
}

// 4. MASTER ASET
class MasterAset {
  final String id;
  final String assetCode;
  final String name;
  final String? category; // New field
  final String? conditionId;
  final String? locationId;
  final String? imageUrl;

  const MasterAset({
    required this.id,
    required this.assetCode,
    required this.name,
    this.category,
    this.conditionId,
    this.locationId,
    this.imageUrl,
  });

  factory MasterAset.fromJson(Map<String, dynamic> json) {
    return MasterAset(
      id: json['id']?.toString() ?? '',
      assetCode: json['asset_code'] ?? json['assetCode'] ?? '',
      name: json['name'] ?? '',
      category: json['category'],
      conditionId: json['condition_id'] ?? json['conditionId'],
      locationId: json['location_id'] ?? json['locationId'],
      imageUrl: json['image_url'] ?? json['imageUrl'],
    );
  }

  // Logic: Movable vs Immovable based on KIB
  bool get isMovable {
    final cat = (category ?? '').toLowerCase();
    // KIB A (Tanah), C (Gedung), D (Jalan/Irigasi) -> Tidak Bergerak
    if (cat.contains('tanah') || cat.contains('gedung') || cat.contains('bangunan') || cat.contains('jalan') || cat.contains('irigasi')) {
      return false;
    }
    // Default to Movable (KIB B & E) for everything else (Electronics, Vehicles, etc.)
    return true; 
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'asset_code': assetCode,
    'name': name,
    'category': category,
    'condition_id': conditionId,
    'location_id': locationId,
    'image_url': imageUrl,
  };

  MasterAset copyWith({
    String? id,
    String? assetCode,
    String? name,
    String? category,
    String? conditionId,
    String? locationId,
    String? imageUrl,
  }) {
    return MasterAset(
      id: id ?? this.id,
      assetCode: assetCode ?? this.assetCode,
      name: name ?? this.name,
      category: category ?? this.category,
      conditionId: conditionId ?? this.conditionId,
      locationId: locationId ?? this.locationId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

// 5. MASTER VENDOR
class MasterVendor {
  final String id;
  final String namaPerusahaan;
  final String? npwp;
  final String? kontakPerson;
  final String status;
  final double rating;

  const MasterVendor({
    required this.id,
    required this.namaPerusahaan,
    this.npwp,
    this.kontakPerson,
    this.status = 'unverified',
    this.rating = 0.0,
  });

  factory MasterVendor.fromJson(Map<String, dynamic> json) {
    return MasterVendor(
      id: json['id']?.toString() ?? '',
      namaPerusahaan: json['nama_perusahaan'] ?? json['namaPerusahaan'] ?? '',
      npwp: json['npwp'],
      kontakPerson: json['kontak_person'] ?? json['kontakPerson'],
      status: json['status_verifikasi'] ?? json['status'] ?? 'unverified',
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama_perusahaan': namaPerusahaan,
    'npwp': npwp,
    'kontak_person': kontakPerson,
    'status_verifikasi': status,
    'rating': rating,
  };

  MasterVendor copyWith({
    String? id,
    String? namaPerusahaan,
    String? npwp,
    String? kontakPerson,
    String? status,
    double? rating,
  }) {
    return MasterVendor(
      id: id ?? this.id,
      namaPerusahaan: namaPerusahaan ?? this.namaPerusahaan,
      npwp: npwp ?? this.npwp,
      kontakPerson: kontakPerson ?? this.kontakPerson,
      status: status ?? this.status,
      rating: rating ?? this.rating,
    );
  }
}
