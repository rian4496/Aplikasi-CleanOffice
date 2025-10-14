import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/work_schedule.dart';

class WorkScheduleProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<WorkSchedule> _schedules = [];
  bool _isLoading = false;
  String? _error;

  List<WorkSchedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserSchedules(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection('schedules')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _schedules = snapshot.docs
          .map((doc) => WorkSchedule.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSchedule(WorkSchedule schedule) async {
    try {
      _error = null;
      await _firestore.collection('schedules').add(schedule.toMap());

      final newSchedule = schedule.copyWith();
      _schedules.insert(0, newSchedule);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSchedule(WorkSchedule schedule) async {
    try {
      _error = null;
      await _firestore
          .collection('schedules')
          .doc(schedule.id)
          .update(schedule.toMap());

      final index = _schedules.indexWhere((s) => s.id == schedule.id);
      if (index != -1) {
        _schedules[index] = schedule;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    try {
      _error = null;
      await _firestore.collection('schedules').doc(scheduleId).delete();

      _schedules.removeWhere((s) => s.id == scheduleId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  List<WorkSchedule> getSchedulesForDay(DateTime date) {
    final dayName = _getDayName(date.weekday).toLowerCase();
    return _schedules
        .where((schedule) => schedule.workDays.contains(dayName))
        .toList();
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        return '';
    }
  }
}
