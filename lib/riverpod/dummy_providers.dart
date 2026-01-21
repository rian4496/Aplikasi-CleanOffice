import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/report.dart';
import '../../models/request.dart';
import '../../models/user_profile.dart';

// ==================== DUMMY REPORTS ====================
final dummyReports = <Report>[
  Report(
    id: 'dummy1',
    userId: 'user1',
    userName: 'John Doe',
    location: 'Ruang Meeting A',
    title: 'Lantai kotor',
    description: 'Lantai ruang meeting kotor perlu dibersihkan',
    date: DateTime.now().subtract(const Duration(hours: 2)),
    status: ReportStatus.pending,
    isUrgent: true,
    imageUrl: null,
    cleanerId: null,
    cleanerName: null,
    completedAt: null,
    departmentId: 'dept1',
  ),
  Report(
    id: 'dummy2',
    userId: 'user2',
    userName: 'Jane Smith',
    location: 'Toilet Lt. 2',
    title: 'Toilet kotor',
    description: 'Toilet perlu dibersihkan, tisu habis',
    date: DateTime.now().subtract(const Duration(hours: 5)),
    status: ReportStatus.inProgress,
    isUrgent: false,
    imageUrl: null,
    cleanerId: 'cleaner1',
    cleanerName: 'Budi Santoso',
    completedAt: null,
    departmentId: 'dept1',
  ),
  Report(
    id: 'dummy3',
    userId: 'user3',
    userName: 'Bob Wilson',
    location: 'Pantry Lt. 3',
    title: 'Sampah menumpuk',
    description: 'Tempat sampah di pantry sudah penuh',
    date: DateTime.now().subtract(const Duration(days: 1)),
    status: ReportStatus.completed,
    isUrgent: false,
    imageUrl: null,
    cleanerId: 'cleaner2',
    cleanerName: 'Siti Aminah',
    completedAt: DateTime.now().subtract(const Duration(hours: 12)),
    departmentId: 'dept1',
  ),
  Report(
    id: 'dummy4',
    userId: 'user1',
    userName: 'John Doe',
    location: 'Ruang Server',
    title: 'AC bocor',
    description: 'AC ruang server bocor, lantai basah',
    date: DateTime.now().subtract(const Duration(hours: 1)),
    status: ReportStatus.pending,
    isUrgent: true,
    imageUrl: null,
    cleanerId: null,
    cleanerName: null,
    completedAt: null,
    departmentId: 'dept1',
  ),
  Report(
    id: 'dummy5',
    userId: 'user4',
    userName: 'Alice Brown',
    location: 'Lobby',
    title: 'Kaca kotor',
    description: 'Kaca pintu lobby perlu dibersihkan',
    date: DateTime.now().subtract(const Duration(hours: 8)),
    status: ReportStatus.completed,
    isUrgent: false,
    imageUrl: null,
    cleanerId: 'cleaner1',
    cleanerName: 'Budi Santoso',
    completedAt: DateTime.now().subtract(const Duration(hours: 2)),
    departmentId: 'dept1',
  ),
];

// ==================== DUMMY REQUESTS ====================
final dummyRequests = <Request>[
  Request(
    id: 'req1',
    requestedBy: 'user1',
    requestedByName: 'John Doe',
    requestedByRole: 'employee',
    location: 'Ruang Meeting B',
    description: 'Mohon jadwal cleaning rutin mingguan',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    status: RequestStatus.pending,
    isUrgent: false,
    assignedTo: null,
    assignedToName: null,
    completedAt: null,
  ),
  Request(
    id: 'req2',
    requestedBy: 'user2',
    requestedByName: 'Jane Smith',
    requestedByRole: 'employee',
    location: 'Ruang Arsip',
    description: 'Perlu deep cleaning untuk ruang arsip',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    status: RequestStatus.assigned,
    isUrgent: true,
    assignedTo: 'cleaner2',
    assignedToName: 'Siti Aminah',
    completedAt: null,
  ),
  Request(
    id: 'req3',
    requestedBy: 'user3',
    requestedByName: 'Bob Wilson',
    requestedByRole: 'employee',
    location: 'Gudang',
    description: 'Ada tikus di gudang, perlu pest control',
    createdAt: DateTime.now().subtract(const Duration(hours: 24)),
    status: RequestStatus.completed,
    isUrgent: false,
    assignedTo: 'cleaner1',
    assignedToName: 'Budi Santoso',
    completedAt: DateTime.now().subtract(const Duration(hours: 6)),
  ),
];

// ==================== DUMMY CLEANERS ====================
final dummyCleaners = <UserProfile>[
  UserProfile(
    uid: 'cleaner1',
    email: 'budi@cleanoffice.com',
    displayName: 'Budi Santoso',
    role: 'cleaner',
    photoURL: null,
    phoneNumber: '081234567890',
    joinDate: DateTime.now().subtract(const Duration(days: 365)),
    departmentId: 'dept1',
    status: 'active',
  ),
  UserProfile(
    uid: 'cleaner2',
    email: 'siti@cleanoffice.com',
    displayName: 'Siti Aminah',
    role: 'cleaner',
    photoURL: null,
    phoneNumber: '081234567891',
    joinDate: DateTime.now().subtract(const Duration(days: 200)),
    departmentId: 'dept1',
    status: 'active',
  ),
  UserProfile(
    uid: 'cleaner3',
    email: 'ahmad@cleanoffice.com',
    displayName: 'Ahmad Hidayat',
    role: 'cleaner',
    photoURL: null,
    phoneNumber: '081234567892',
    joinDate: DateTime.now().subtract(const Duration(days: 500)),
    departmentId: 'dept1',
    status: 'inactive',
  ),
];

// ==================== DUMMY PROVIDERS ====================

/// Provider dummy untuk all reports
final dummyAllReportsProvider = StreamProvider.family<List<Report>, String?>((
  ref,
  departmentId,
) {
  // Return stream with dummy data
  return Stream.value(dummyReports);
});

/// Provider dummy untuk all requests
final dummyAllRequestsProvider = StreamProvider.family<List<Request>, String?>((
  ref,
  departmentId,
) {
  return Stream.value(dummyRequests);
});

/// Provider dummy untuk cleaners
final dummyCleanersProvider = StreamProvider.family<List<UserProfile>, String?>((
  ref,
  departmentId,
) {
  return Stream.value(dummyCleaners);
});

/// Provider untuk reports yang butuh verifikasi (pending + urgent)
final dummyNeedsVerificationReportsProvider = StreamProvider.family<List<Report>, String?>((
  ref,
  departmentId,
) {
  final needsVerification = dummyReports.where((r) => 
    r.status == ReportStatus.pending || r.isUrgent
  ).toList();
  return Stream.value(needsVerification);
});

