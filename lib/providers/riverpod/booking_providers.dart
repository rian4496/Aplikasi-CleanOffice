// lib/providers/riverpod/booking_providers.dart
// SIM-ASET: Booking Providers

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/booking.dart';
import 'auth_providers.dart';

// ==================== SUPABASE CLIENT ====================
final _supabase = Supabase.instance.client;

// ==================== ALL BOOKINGS PROVIDER ====================
final allBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final response = await _supabase
      .from('bookings')
      .select('''
        *,
        assets(name)
      ''')
      .order('start_time', ascending: false);

  return (response as List)
      .map((json) => Booking.fromSupabase(json))
      .toList();
});

// ==================== PENDING BOOKINGS PROVIDER ====================
final pendingBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final response = await _supabase
      .from('bookings')
      .select('''
        *,
        assets(name)
      ''')
      .eq('status', 'pending')
      .order('start_time');

  return (response as List)
      .map((json) => Booking.fromSupabase(json))
      .toList();
});

// ==================== MY BOOKINGS PROVIDER ====================
final myBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final response = await _supabase
      .from('bookings')
      .select('''
        *,
        assets(name)
      ''')
      .eq('user_id', user.id)
      .order('start_time', ascending: false);

  return (response as List)
      .map((json) => Booking.fromSupabase(json))
      .toList();
});

// ==================== BOOKINGS FOR ASSET PROVIDER ====================
final bookingsForAssetProvider = FutureProvider.family<List<Booking>, String>((ref, assetId) async {
  final response = await _supabase
      .from('bookings')
      .select()
      .eq('asset_id', assetId)
      .eq('status', 'approved')
      .gte('end_time', DateTime.now().toIso8601String())
      .order('start_time');

  return (response as List)
      .map((json) => Booking.fromSupabase(json))
      .toList();
});

// ==================== TODAY'S BOOKINGS PROVIDER ====================
final todaysBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  final response = await _supabase
      .from('bookings')
      .select('''
        *,
        assets(name)
      ''')
      .eq('status', 'approved')
      .gte('start_time', startOfDay.toIso8601String())
      .lt('start_time', endOfDay.toIso8601String())
      .order('start_time');

  return (response as List)
      .map((json) => Booking.fromSupabase(json))
      .toList();
});

// ==================== BOOKING STATS PROVIDER ====================
final bookingStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final bookings = await ref.watch(allBookingsProvider.future);

  return {
    'total': bookings.length,
    'pending': bookings.where((b) => b.status == BookingStatus.pending).length,
    'approved': bookings.where((b) => b.status == BookingStatus.approved).length,
    'rejected': bookings.where((b) => b.status == BookingStatus.rejected).length,
    'completed': bookings.where((b) => b.status == BookingStatus.completed).length,
  };
});

// ==================== CHECK BOOKING CONFLICT PROVIDER ====================
/// Check if there's a conflict for a specific asset in a time range
final checkBookingConflictProvider = FutureProvider.family<bool, BookingConflictCheck>((ref, check) async {
  final response = await _supabase
      .from('bookings')
      .select('id')
      .eq('asset_id', check.assetId)
      .eq('status', 'approved')
      .lte('start_time', check.endTime.toIso8601String())
      .gte('end_time', check.startTime.toIso8601String());

  return (response as List).isNotEmpty;
});

// Helper class for conflict check
class BookingConflictCheck {
  final String assetId;
  final DateTime startTime;
  final DateTime endTime;

  BookingConflictCheck({
    required this.assetId,
    required this.startTime,
    required this.endTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingConflictCheck &&
          runtimeType == other.runtimeType &&
          assetId == other.assetId &&
          startTime == other.startTime &&
          endTime == other.endTime;

  @override
  int get hashCode => assetId.hashCode ^ startTime.hashCode ^ endTime.hashCode;
}
