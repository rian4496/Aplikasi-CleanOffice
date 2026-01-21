import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transactions/booking_model.dart';
import '../supabase_service_providers.dart';

// Mock Data removed - using Real API

// Async Notifier for CRUD
class BookingController extends AsyncNotifier<List<BookingRequest>> {
  @override
  Future<List<BookingRequest>> build() async {
    final service = ref.watch(supabaseDatabaseServiceProvider);
    return await service.getAllBookings(); // Real API
  }

  Future<void> createBooking(BookingRequest booking) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(supabaseDatabaseServiceProvider);
      
      // Conflict Check (Server-side check recommended, but doing client-side first for immediate feedback)
      final isAvailable = await service.checkBookingAvailability(
        booking.assetId, booking.startTime, booking.endTime
      );

      if (!isAvailable) {
        throw Exception('Jadwal bentrok! Aset ini sudah dibooking pada jam tersebut.');
      }

      await service.createBooking(booking);
      
      // Refresh list
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> updateStatus(String id, String newStatus) async {
    // Note: Add updateBookingStatus method in Service if missing, 
    // for now assuming logic similar to create.
    // Ideally user should implement updateStatus in service too.
    state = const AsyncValue.loading();
    // For now, reload 
    // TODO: Add service.updateBookingStatus(id, status)
    ref.invalidateSelf();
  }
}

final bookingListProvider = AsyncNotifierProvider<BookingController, List<BookingRequest>>(BookingController.new);
