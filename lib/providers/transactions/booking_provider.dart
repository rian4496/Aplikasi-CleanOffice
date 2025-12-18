import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transactions/booking_model.dart';

// Mock Data
final _mockBookings = [
  BookingRequest(
    id: 'BK-001',
    assetId: 'AST-CAR-005',
    assetName: 'Toyota Innova Reborn',
    assetType: 'vehicle',
    employeeId: 'EMP-001',
    employeeName: 'Budi Santoso (Peneliti)',
    department: 'Bidang Litbang',
    startTime: DateTime.now().add(const Duration(days: 1, hours: 9)),
    endTime: DateTime.now().add(const Duration(days: 1, hours: 16)),
    purpose: 'Survei Lapangan Lahan Gambut',
    status: 'pending',
    createdAt: DateTime.now(),
  ),
  BookingRequest(
    id: 'BK-002',
    assetId: 'AST-ROOM-101',
    assetName: 'Ruang Rapat Utama',
    assetType: 'room',
    employeeId: 'EMP-020',
    employeeName: 'Siti Aminah (Sekretariat)',
    department: 'Sekretariat',
    startTime: DateTime.now().subtract(const Duration(hours: 4)),
    endTime: DateTime.now().add(const Duration(hours: 2)),
    purpose: 'Rapat Koordinasi Anggaran',
    status: 'active',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  BookingRequest(
    id: 'BK-003',
    assetId: 'AST-EQP-010',
    assetName: 'Drone DJI Mavic 3',
    assetType: 'equipment',
    employeeId: 'EMP-005',
    employeeName: 'Ahmad Rizky (Staff IT)',
    department: 'Subbag Data & Info',
    startTime: DateTime.now().subtract(const Duration(days: 3)),
    endTime: DateTime.now().subtract(const Duration(days: 2)),
    purpose: 'Dokumentasi Proyek Jembatan',
    status: 'completed',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
];

// Async Notifier for CRUD
class BookingController extends AsyncNotifier<List<BookingRequest>> {
  @override
  Future<List<BookingRequest>> build() async {
    // Simulate API Delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockBookings;
  }

  Future<void> createBooking(BookingRequest booking) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 800));
    _mockBookings.add(booking);
    state = AsyncValue.data(_mockBookings);
  }
  
  Future<void> updateStatus(String id, String newStatus) async {
    state = const AsyncValue.loading();
    // In real app: call API
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _mockBookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      _mockBookings[index] = _mockBookings[index].copyWith(status: newStatus);
    }
    state = AsyncValue.data(_mockBookings);
  }
}

final bookingListProvider = AsyncNotifierProvider<BookingController, List<BookingRequest>>(BookingController.new);
