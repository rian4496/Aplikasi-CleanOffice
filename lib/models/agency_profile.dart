class AgencyProfile {
  final String id;
  final String name;
  final String shortName;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String? logoUrl;
  final String city;
  final List<AgencySigner> signers;

  AgencyProfile({
    required this.id,
    required this.name,
    required this.shortName,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    this.logoUrl,
    required this.city,
    this.signers = const [],
  });

  factory AgencyProfile.fromJson(Map<String, dynamic> json) {
    return AgencyProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['short_name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      website: json['website'] as String,
      logoUrl: json['logo_url'] as String?,
      city: json['city'] as String,
      signers: (json['signers'] as List<dynamic>?)
              ?.map((e) => AgencySigner.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_name': shortName,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'logo_url': logoUrl,
      'city': city,
      'signers': signers.map((e) => e.toJson()).toList(),
    };
  }

  // Fallback default for initialization
  factory AgencyProfile.empty() {
    return AgencyProfile(
      id: '',
      name: 'Pemerintah Provinsi Kalimantan Selatan',
      shortName: 'PEMPROV KALSEL',
      address: 'Jl. Dharma Praja I, Komplek Perkantoran Pemerintah Provinsi Kalimantan Selatan',
      phone: '(0511) 4772033',
      email: 'info@kalselprov.go.id',
      website: 'kalselprov.go.id',
      city: 'Banjarbaru',
      signers: [],
    );
  }
}

class AgencySigner {
  final String name;
  final String nip;
  final String position; // Jabatan (e.g., Kepala Dinas)
  final String rank; // Pangkat/Golongan (e.g., Pembina Utama Muda / IV/c)
  final String roleLabel; // Label (e.g., Mengetahui, Diperiksa Oleh)
  final String? signatureUrl; // URL gambar tanda tangan/paraf

  AgencySigner({
    required this.name,
    required this.nip,
    required this.position,
    required this.rank,
    required this.roleLabel,
    this.signatureUrl,
  });

  factory AgencySigner.fromJson(Map<String, dynamic> json) {
    return AgencySigner(
      name: json['name'] as String,
      nip: json['nip'] as String,
      position: json['position'] as String,
      rank: json['rank'] as String,
      roleLabel: json['role_label'] as String,
      signatureUrl: json['signature_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nip': nip,
      'position': position,
      'rank': rank,
      'role_label': roleLabel,
      'signature_url': signatureUrl,
    };
  }
}
