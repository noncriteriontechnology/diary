import 'package:flutter/foundation.dart';
import '../models/appointment.dart';
import '../services/api_service.dart';

class AppointmentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Appointment> _appointments = [];
  List<Appointment> _calendarAppointments = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;

  List<Appointment> get appointments => _appointments;
  List<Appointment> get calendarAppointments => _calendarAppointments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadAppointments({
    bool refresh = false,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? clientId,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _appointments.clear();
    }

    if (!_hasMoreData || _isLoading) return;

    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getAppointments(
        page: _currentPage,
        limit: 20,
        startDate: startDate,
        endDate: endDate,
        status: status,
        clientId: clientId,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          _appointments = response.data!;
        } else {
          _appointments.addAll(response.data!);
        }
        
        _currentPage++;
        _hasMoreData = response.data!.length == 20;
        notifyListeners();
      } else {
        _setError(response.error ?? 'Failed to load appointments');
      }
    } catch (e) {
      _setError('An unexpected error occurred while loading appointments');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCalendarAppointments({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getCalendarAppointments(
        startDate: startDate,
        endDate: endDate,
      );

      if (response.success && response.data != null) {
        _calendarAppointments = response.data!;
        notifyListeners();
      } else {
        _setError(response.error ?? 'Failed to load calendar appointments');
      }
    } catch (e) {
      _setError('An unexpected error occurred while loading calendar');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createAppointment({
    required String clientId,
    required String title,
    String? description,
    required DateTime startDateTime,
    required DateTime endDateTime,
    String? location,
    String appointmentType = 'Consultation',
    String status = 'Scheduled',
    String priority = 'Medium',
    int reminderMinutes = 30,
    bool isRecurring = false,
    Map<String, dynamic>? recurringPattern,
    List<Map<String, dynamic>>? attendees,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final appointmentData = {
        'clientId': clientId,
        'title': title,
        'description': description,
        'startDateTime': startDateTime.toIso8601String(),
        'endDateTime': endDateTime.toIso8601String(),
        'location': location,
        'appointmentType': appointmentType,
        'status': status,
        'priority': priority,
        'reminderMinutes': reminderMinutes,
        'isRecurring': isRecurring,
        'recurringPattern': recurringPattern,
        'attendees': attendees,
      };

      final response = await _apiService.createAppointment(appointmentData);

      if (response.success && response.data != null) {
        _appointments.insert(0, response.data!);
        _calendarAppointments.add(response.data!);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to create appointment');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred while creating appointment');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAppointment(String id, Map<String, dynamic> updates) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.updateAppointment(id, updates);

      if (response.success && response.data != null) {
        final index = _appointments.indexWhere((appointment) => appointment.id == id);
        if (index != -1) {
          _appointments[index] = response.data!;
        }
        
        final calendarIndex = _calendarAppointments.indexWhere((appointment) => appointment.id == id);
        if (calendarIndex != -1) {
          _calendarAppointments[calendarIndex] = response.data!;
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to update appointment');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred while updating appointment');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAppointment(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.deleteAppointment(id);

      if (response.success) {
        _appointments.removeWhere((appointment) => appointment.id == id);
        _calendarAppointments.removeWhere((appointment) => appointment.id == id);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to delete appointment');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred while deleting appointment');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  List<Appointment> getAppointmentsForDate(DateTime date) {
    return _calendarAppointments.where((appointment) {
      final appointmentDate = appointment.startDateTime.toLocal();
      return appointmentDate.year == date.year &&
             appointmentDate.month == date.month &&
             appointmentDate.day == date.day;
    }).toList();
  }

  List<Appointment> getTodayAppointments() {
    final today = DateTime.now();
    return getAppointmentsForDate(today);
  }

  List<Appointment> getUpcomingAppointments({int days = 7}) {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));
    
    return _appointments.where((appointment) {
      return appointment.startDateTime.isAfter(now) &&
             appointment.startDateTime.isBefore(futureDate) &&
             appointment.status != 'Cancelled' &&
             appointment.status != 'Completed';
    }).toList()..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }

  List<Appointment> getAppointmentsByStatus(String status) {
    return _appointments.where((appointment) => appointment.status == status).toList();
  }

  List<Appointment> getAppointmentsByClient(String clientId) {
    return _appointments.where((appointment) => appointment.clientId == clientId).toList();
  }

  bool hasConflict(DateTime startTime, DateTime endTime, {String? excludeId}) {
    return _calendarAppointments.any((appointment) {
      if (excludeId != null && appointment.id == excludeId) return false;
      if (appointment.status == 'Cancelled' || appointment.status == 'Completed') return false;
      
      return (startTime.isBefore(appointment.endDateTime) && endTime.isAfter(appointment.startDateTime));
    });
  }
}
