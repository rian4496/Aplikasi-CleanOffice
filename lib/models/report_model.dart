import 'package:cloud_firestore/cloud_firestore.dart';
import 'report_status.dart';

/// Model untuk laporan kebersihan yang diperluas dengan field-field tambahan
/// untuk mendukung workflow lengkap dari pembuatan hingga verifikasi
class Report {
  final String id;
  final String title;
  final String location;
  final DateTime date;
  final ReportStatus status;
  
  // Informasi Pembuat Laporan (Employee)
  final String userId;
  final String userName;
  final String? userEmail;
  
  // Informasi Petugas Kebersihan (Cleaner)
  final String? cleanerId;
  final String? cleanerName;
  
  // Informasi Supervisor
  final String? verifiedBy;
  final String? verifiedByName;
  final DateTime? verifiedAt;
  final String? verificationNotes;
  
  // Detail Laporan
  final String? imageUrl;
  final String? description;
  final bool isUrgent;
  
  // Timestamp
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  
  // Department (untuk filtering supervisor)
  final String? departmentId;

  Report({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.status,
    required this.userId,
    required this.userName,
    this.userEmail,
    this.cleanerId,
    this.cleanerName,
    this.verifiedBy,
    this.verifiedByName,
    this.verifiedAt,
    this.verificationNotes,
    this.imageUrl,
    this.description,
    this.isUrgent = false,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.departmentId,
  });

  /// Convert dari Firestore document ke Report object
  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Report(
      id: doc.id,
      title: data['title'] as String? ?? '',
      location: data['location'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ReportStatus.fromString(data['status'] as String? ?? 'pending'),
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      userEmail: data['userEmail'] as String?,
      cleanerId: data['cleanerId'] as String?,
      cleanerName: data['cleanerName'] as String?,
      verifiedBy: data['verifiedBy'] as String?,
      verifiedByName: data['verifiedByName'] as String?,
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      verificationNotes: data['verificationNotes'] as String?,
      imageUrl: data['imageUrl'] as String?,
      description: data['description'] as String?,
      isUrgent: data['isUrgent'] as bool? ?? false,
      assignedAt: (data['assignedAt'] as Timestamp?)?.toDate(),
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      departmentId: data['departmentId'] as String?,
    );
  }

  /// Convert dari Map ke Report object (untuk compatibility)
  factory Report.fromMap(String id, Map<String, dynamic> data) {
    return Report(
      id: id,
      title: data['title'] as String? ?? '',
      location: data['location'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ReportStatus.fromString(data['status'] as String? ?? 'pending'),
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      userEmail: data['userEmail'] as String?,
      cleanerId: data['cleanerId'] as String?,
      cleanerName: data['cleanerName'] as String?,
      verifiedBy: data['verifiedBy'] as String?,
      verifiedByName: data['verifiedByName'] as String?,
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      verificationNotes: data['verificationNotes'] as String?,
      imageUrl: data['imageUrl'] as String?,
      description: data['description'] as String?,
      isUrgent: data['isUrgent'] as bool? ?? false,
      assignedAt: (data['assignedAt'] as Timestamp?)?.toDate(),
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      departmentId: data['departmentId'] as String?,
    );
  }

  /// Convert Report object ke Map untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'location': location,
      'date': Timestamp.fromDate(date),
      'status': status.toFirestore(),
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'cleanerId': cleanerId,
      'cleanerName': cleanerName,
      'verifiedBy': verifiedBy,
      'verifiedByName': verifiedByName,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'verificationNotes': verificationNotes,
      'imageUrl': imageUrl,
      'description': description,
      'isUrgent': isUrgent,
      'assignedAt': assignedAt != null ? Timestamp.fromDate(assignedAt!) : null,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'departmentId': departmentId,
    };
  }

  /// Copy with method untuk immutability
  Report copyWith({
    String? id,
    String? title,
    String? location,
    DateTime? date,
    ReportStatus? status,
    String? userId,
    String? userName,
    String? userEmail,
    String? cleanerId,
    String? cleanerName,
    String? verifiedBy,
    String? verifiedByName,
    DateTime? verifiedAt,
    String? verificationNotes,
    String? imageUrl,
    String? description,
    bool? isUrgent,
    DateTime? assignedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? departmentId,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      date: date ?? this.date,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      cleanerId: cleanerId ?? this.cleanerId,
      cleanerName: cleanerName ?? this.cleanerName,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedByName: verifiedByName ?? this.verifiedByName,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isUrgent: isUrgent ?? this.isUrgent,
      assignedAt: assignedAt ?? this.assignedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      departmentId: departmentId ?? this.departmentId,
    );
  }

  /// Helper methods
  bool get isAssigned => cleanerId != null;
  bool get isVerified => status == ReportStatus.verified;
  bool get needsVerification => status == ReportStatus.completed;
  
  /// Durasi pengerjaan (jika ada)
  Duration? get workDuration {
    if (startedAt != null && completedAt != null) {
      return completedAt!.difference(startedAt!);
    }
    return null;
  }

  /// Response time (dari dibuat hingga ditugaskan)
  Duration? get responseTime {
    if (assignedAt != null) {
      return assignedAt!.difference(date);
    }
    return null;
  }
}