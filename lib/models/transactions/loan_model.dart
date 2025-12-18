class LoanRequest {
  final String id;
  final String requestNumber; // Nomor Surat Permohonan
  final String borrowerName; // Pihak Peminjam (Instansi/Pusat)
  final String borrowerAddress;
  final String borrowerContact;
  
  final String assetId;
  final String assetName;
  final String assetCondition; // Baik / Rusak Ringan
  
  final DateTime startDate;
  final int durationYears; // Max 5 years
  final DateTime endDate;
  
  final String status; 
  // Statuses: 
  // 'draft' (Baru buat), 
  // 'submitted' (Diajukan ke Pengelola), 
  // 'verified' (Sudah diteliti Pengelola), 
  // 'approved' (SK Keluar),
  // 'active' (BAST Signed, Barang dibawa), 
  // 'returned' (Sudah kembali), 
  // 'rejected'
  
  final DateTime createdAt;
  final String? rejectionReason;
  
  // Documents (URLs/Path)
  final String? applicationLetterDoc; // Surat Permohonan
  final String? agreementDoc; // Naskah Perjanjian
  final String? bastHandoverDoc; // BAST Penyerahan
  final String? bastReturnDoc; // BAST Pengembalian

  const LoanRequest({
    required this.id,
    required this.requestNumber,
    required this.borrowerName,
    required this.borrowerAddress,
    required this.borrowerContact,
    required this.assetId,
    required this.assetName,
    required this.assetCondition,
    required this.startDate,
    required this.durationYears,
    required this.endDate,
    required this.status,
    required this.createdAt,
    this.rejectionReason,
    this.applicationLetterDoc,
    this.agreementDoc,
    this.bastHandoverDoc,
    this.bastReturnDoc,
  });
  
  // Helper to calculate EndDate automatically if needed, 
  // but usually strict based on agreement.

  LoanRequest copyWith({
    String? id,
    String? requestNumber,
    String? borrowerName,
    String? borrowerAddress,
    String? borrowerContact,
    String? assetId,
    String? assetName,
    String? assetCondition,
    DateTime? startDate,
    int? durationYears,
    DateTime? endDate,
    String? status,
    DateTime? createdAt,
    String? rejectionReason,
    String? applicationLetterDoc,
    String? agreementDoc,
    String? bastHandoverDoc,
    String? bastReturnDoc,
  }) {
    return LoanRequest(
      id: id ?? this.id,
      requestNumber: requestNumber ?? this.requestNumber,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowerAddress: borrowerAddress ?? this.borrowerAddress,
      borrowerContact: borrowerContact ?? this.borrowerContact,
      assetId: assetId ?? this.assetId,
      assetName: assetName ?? this.assetName,
      assetCondition: assetCondition ?? this.assetCondition,
      startDate: startDate ?? this.startDate,
      durationYears: durationYears ?? this.durationYears,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      applicationLetterDoc: applicationLetterDoc ?? this.applicationLetterDoc,
      agreementDoc: agreementDoc ?? this.agreementDoc,
      bastHandoverDoc: bastHandoverDoc ?? this.bastHandoverDoc,
      bastReturnDoc: bastReturnDoc ?? this.bastReturnDoc,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'request_number': requestNumber,
      'borrower_name': borrowerName,
      'borrower_address': borrowerAddress,
      'borrower_contact': borrowerContact,
      'asset_id': assetId,
      'start_date': startDate.toIso8601String(),
      'duration_years': durationYears,
      'end_date': endDate.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'rejection_reason': rejectionReason,
      'application_letter_doc': applicationLetterDoc,
      'agreement_doc': agreementDoc,
      'bast_handover_doc': bastHandoverDoc,
      'bast_return_doc': bastReturnDoc,
    };
  }

  factory LoanRequest.fromMap(Map<String, dynamic> map) {
    return LoanRequest(
      id: map['id']?.toString() ?? '',
      requestNumber: map['request_number'] ?? '',
      borrowerName: map['borrower_name'] ?? '',
      borrowerAddress: map['borrower_address'] ?? '',
      borrowerContact: map['borrower_contact'] ?? '',
      assetId: map['asset_id'] ?? '',
      assetName: map['asset_name'] ?? map['master_assets']?['name'] ?? 'Unknown Asset', // Nested join
      assetCondition: map['asset_condition'] ?? map['master_assets']?['condition'] ?? 'Baik',
      startDate: DateTime.parse(map['start_date']),
      durationYears: map['duration_years'] ?? 1,
      endDate: DateTime.parse(map['end_date']),
      status: map['status'] ?? 'draft',
      createdAt: DateTime.parse(map['created_at']),
      rejectionReason: map['rejection_reason'],
      applicationLetterDoc: map['application_letter_doc'],
      agreementDoc: map['agreement_doc'],
      bastHandoverDoc: map['bast_handover_doc'],
      bastReturnDoc: map['bast_return_doc'],
    );
  }
}
