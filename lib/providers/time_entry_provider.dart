import 'package:flutter/foundation.dart';
import '../models/time_entry.dart';
import '../services/time_entry_service.dart';

class TimeEntryProvider extends ChangeNotifier {
  final TimeEntryService _timeEntryService = TimeEntryService();

  List<TimeEntry> _timeEntries = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<TimeEntry> get timeEntries => _timeEntries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set time entries (for employee-specific loading)
  void setTimeEntries(List<TimeEntry> entries) {
    _timeEntries = entries;
    notifyListeners();
  }

  // Get today's entries
  List<TimeEntry> get todayEntries {
    final now = DateTime.now();
    return _timeEntries.where((entry) {
      return entry.date.year == now.year &&
          entry.date.month == now.month &&
          entry.date.day == now.day;
    }).toList();
  }

  // Get pending entries
  List<TimeEntry> get pendingEntries {
    return _timeEntries.where((entry) => entry.status == TimeEntryStatus.pending).toList();
  }

  // Get approved entries
  List<TimeEntry> get approvedEntries {
    return _timeEntries.where((entry) => entry.status == TimeEntryStatus.approved).toList();
  }

  // Load all time entries
  Future<void> loadTimeEntries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _timeEntries = await _timeEntryService.getTimeEntries();
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao carregar entradas de tempo: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create time entry
  Future<void> createTimeEntry({
    required String employeeId,
    required DateTime date,
    required DateTime checkIn,
    DateTime? checkOut,
    DateTime? breakStart,
    DateTime? breakEnd,
    String? notes,
    double? dailyRate,
    double? extraHoursRate,
    double? extraHours,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final entryData = TimeEntryCreateData(
        employee: employeeId,
        date: date,
        entryTime: checkIn,
        exitTime: checkOut,
        notes: notes,
        dailyRate: dailyRate,
        extraHoursRate: extraHoursRate,
        extraHours: extraHours,
      ).withCalculatedTotal(); // Calculate and include total

      debugPrint('Creating time entry with data: ${entryData.toJson()}');
      final timeEntry = await _timeEntryService.createTimeEntry(entryData);
      _timeEntries.add(timeEntry);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating time entry: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update time entry
  Future<void> updateTimeEntry({
    required String id,
    required String employeeId,
    required DateTime date,
    required DateTime checkIn,
    DateTime? checkOut,
    DateTime? breakStart,
    DateTime? breakEnd,
    String? notes,
    double? dailyRate,
    double? extraHoursRate,
    double? extraHours,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final entryData = TimeEntryUpdateData(
        date: date,
        entryTime: checkIn,
        exitTime: checkOut,
        notes: notes,
        dailyRate: dailyRate,
        extraHoursRate: extraHoursRate,
        extraHours: extraHours,
      ).withCalculatedTotal(); // Calculate and include total

      debugPrint('Updating time entry with data: ${entryData.toJson()}');
      final updatedEntry = await _timeEntryService.updateTimeEntry(id, entryData);
      
      final index = _timeEntries.indexWhere((entry) => entry.id == id);
      if (index != -1) {
        _timeEntries[index] = updatedEntry;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating time entry: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete time entry
  Future<void> deleteTimeEntry(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _timeEntryService.deleteTimeEntry(id);
      _timeEntries.removeWhere((entry) => entry.id == id);
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao excluir entrada de tempo: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Approve time entry
  Future<void> approveTimeEntry(String id) async {
    try {
      final updatedEntry = await _timeEntryService.approveTimeEntry(id);
      
      final index = _timeEntries.indexWhere((entry) => entry.id == id);
      if (index != -1) {
        _timeEntries[index] = updatedEntry;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao aprovar entrada de tempo: $e');
      rethrow;
    }
  }

  // Reject time entry
  Future<void> rejectTimeEntry(String id, {String reason = 'Rejected'}) async {
    try {
      final updatedEntry = await _timeEntryService.rejectTimeEntry(id, reason);
      
      final index = _timeEntries.indexWhere((entry) => entry.id == id);
      if (index != -1) {
        _timeEntries[index] = updatedEntry;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao rejeitar entrada de tempo: $e');
      rethrow;
    }
  }

  // Get time entries by employee
  Future<List<TimeEntry>> getEmployeeTimeEntries(String employeeId) async {
    try {
      return await _timeEntryService.getTimeEntriesByEmployee(employeeId);
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao obter entradas de tempo do funcionário: $e');
      return [];
    }
  }

  // Get time entries by date range
  Future<List<TimeEntry>> getTimeEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _timeEntryService.getTimeEntriesByDateRange(
        startDate,
        endDate,
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao obter entradas de tempo por período: $e');
      return [];
    }
  }

  // Get time entry statistics
  Future<Map<String, dynamic>> getTimeEntryStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final now = DateTime.now();
      final start = startDate ?? DateTime(now.year, now.month, 1);
      final end = endDate ?? DateTime(now.year, now.month + 1, 0);
      
      return await _timeEntryService.getTimeEntryStatistics(start, end);
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao obter estatísticas de entradas de tempo: $e');
      return {};
    }
  }

  // Get time entry by ID
  TimeEntry? getTimeEntryById(String id) {
    try {
      return _timeEntries.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh time entries
  Future<void> refreshTimeEntries() async {
    await loadTimeEntries();
  }
}
