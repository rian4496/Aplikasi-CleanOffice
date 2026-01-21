// lib/riverpod/teknisi_providers.dart
// Riverpod providers for Teknisi role - handles kerusakan (damage) tickets

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ticket.dart';
import 'ticket_providers.dart';
import 'auth_providers.dart';

// teknisiInboxProvider is defined in ticket_providers.dart to avoid circular deps
// Use: import 'ticket_providers.dart' to access it

// ==================== TEKNISI TASKS ====================
// Tickets claimed/assigned to current teknisi user
final teknisiTasksProvider = FutureProvider<List<Ticket>>((ref) async {
  final repo = ref.watch(ticketRepositoryProvider);
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];
  return repo.getTeknisiTasks(user.uid);
});

// ==================== TEKNISI STATS ====================
// Statistics for teknisi dashboard
final teknisiTicketStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.watch(ticketRepositoryProvider);
  final user = ref.watch(currentUserProvider).value;
  if (user == null) {
    return {
      'assigned': 0,
      'inProgress': 0,
      'completed': 0,
      'total': 0,
      'completedToday': 0,
      'avgWorkTimeMinutes': 0,
    };
  }
  
  try {
    // Get all tickets for this teknisi
    final allTickets = await repo.getTickets(type: TicketType.kerusakan);
    final myTickets = allTickets.where((t) => t.assignedTo == user.uid).toList();
    
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    final assigned = myTickets.where((t) => t.status == TicketStatus.claimed).length;
    final inProgress = myTickets.where((t) => t.status == TicketStatus.inProgress).length;
    final completed = myTickets.where((t) => t.status == TicketStatus.completed).length;
    final completedToday = myTickets.where((t) => 
      t.status == TicketStatus.completed && 
      t.completedAt != null && 
      t.completedAt!.isAfter(todayStart)
    ).length;
    
    // Calculate average work time (from claimed to completed)
    int totalMinutes = 0;
    int countWithTime = 0;
    for (final t in myTickets.where((t) => t.status == TicketStatus.completed && t.claimedAt != null && t.completedAt != null)) {
      final workTime = t.completedAt!.difference(t.claimedAt!);
      totalMinutes += workTime.inMinutes;
      countWithTime++;
    }
    final avgWorkTimeMinutes = countWithTime > 0 ? totalMinutes ~/ countWithTime : 0;
    
    return {
      'assigned': assigned,
      'inProgress': inProgress,
      'completed': completed,
      'total': myTickets.length,
      'completedToday': completedToday,
      'avgWorkTimeMinutes': avgWorkTimeMinutes,
    };
  } catch (e) {
    return {
      'assigned': 0,
      'inProgress': 0,
      'completed': 0,
      'total': 0,
      'completedToday': 0,
      'avgWorkTimeMinutes': 0,
    };
  }
});
