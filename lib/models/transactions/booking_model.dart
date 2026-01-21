class BookingRequest {
  final String id;
  final String assetId;
  final String assetName; // from JOIN
  final String assetType; // Defaults to 'room' if not in DB, or from JOIN
  
  final String userId; // maps to user_id
  final String employeeName; // from JOIN (user display_name)
  final String department; // from JOIN
  
  final String title; // New field
  final DateTime startTime;
  final DateTime endTime;
  
  final String purpose;
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
  
  final String? notes; // New field

  const BookingRequest({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.assetType,
    required this.userId,
    required this.employeeName,
    required this.department,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    required this.status,
    required this.createdAt,
    this.rejectionReason,
    this.notes,
  });

  BookingRequest copyWith({
    String? id,
    String? assetId,
    String? assetName,
    String? assetType,
    String? userId,
    String? employeeName,
    String? department,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? purpose,
    String? status,
    DateTime? createdAt,
    String? rejectionReason,
    String? notes,
  }) {
    return BookingRequest(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      assetName: assetName ?? this.assetName,
      assetType: assetType ?? this.assetType,
      userId: userId ?? this.userId,
      employeeName: employeeName ?? this.employeeName,
      department: department ?? this.department,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_id': assetId,
      'user_id': userId,
      'title': title,
      'purpose': purpose,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status,
      'rejection_reason': rejectionReason,
      'notes': notes,
      // 'created_at' omitted usually for inserts as DB defaults it, but okay to include
    };
  }

  factory BookingRequest.fromJson(Map<String, dynamic> map) {
    // Handle nested JOINs
    final assetData = map['assets'] as Map<String, dynamic>?;
    final userData = map['users'] as Map<String, dynamic>?;

    return BookingRequest(
      id: map['id']?.toString() ?? '',
      assetId: map['asset_id'] ?? '',
      assetName: assetData?['name'] ?? map['asset_name'] ?? 'Unknown Asset',
      assetType: 'room', // Default since SQL table assumes rooms mostly? or fetch from asset category
      userId: map['user_id'] ?? '',
      employeeName: userData?['display_name'] ?? map['employee_name'] ?? 'Unknown User',
      department: userData?['department'] ?? map['department'] ?? '-',
      title: map['title'] ?? 'No Title',
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      purpose: map['purpose'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      rejectionReason: map['rejection_reason'],
      notes: map['notes'],
    );
  }
}
