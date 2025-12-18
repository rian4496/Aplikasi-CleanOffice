class BookingRequest {
  final String id;
  final String assetId;
  final String assetName;
  final String assetType; // e.g., 'vehicle', 'room', 'equipment'
  
  final String employeeId;
  final String employeeName;
  final String department; // Unit Kerja
  
  final DateTime startTime;
  final DateTime endTime;
  
  final String purpose; // Keperluan peminjaman
  final String status; 
  // Statuses: 
  // 'pending' (Menunggu persetujuan), 
  // 'approved' (Disetujui Kasubag), 
  // 'active' (Sedang digunakan/Check-in), 
  // 'completed' (Sudah kembali/Check-out),
  // 'rejected' (Ditolak),
  // 'cancelled' (Dibatalkan peminjam)
  
  final DateTime createdAt;
  final String? rejectionReason;
  
  final String? proofOfReturn; // Foto saat kembali (optional)

  const BookingRequest({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.assetType,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    required this.status,
    required this.createdAt,
    this.rejectionReason,
    this.proofOfReturn,
  });

  BookingRequest copyWith({
    String? id,
    String? assetId,
    String? assetName,
    String? assetType,
    String? employeeId,
    String? employeeName,
    String? department,
    DateTime? startTime,
    DateTime? endTime,
    String? purpose,
    String? status,
    DateTime? createdAt,
    String? rejectionReason,
    String? proofOfReturn,
  }) {
    return BookingRequest(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      assetName: assetName ?? this.assetName,
      assetType: assetType ?? this.assetType,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      department: department ?? this.department,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      proofOfReturn: proofOfReturn ?? this.proofOfReturn,
    );
  }
}
