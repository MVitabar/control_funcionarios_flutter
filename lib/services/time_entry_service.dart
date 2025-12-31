import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/time_entry.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';

class TimeEntryService {
  final ApiClient _apiClient = ApiClient();

  // Get all time entries
  Future<List<TimeEntry>> getTimeEntries({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Set a very wide default date range if dates are not provided
      final defaultStart = startDate ?? DateTime(2020, 1, 1);
      final defaultEnd = endDate ?? DateTime(2030, 12, 31);

      // Format dates as YYYY-MM-DD (without time) to match API requirements
      final formattedStart = '${defaultStart.year.toString().padLeft(4, '0')}-${defaultStart.month.toString().padLeft(2, '0')}-${defaultStart.day.toString().padLeft(2, '0')}';
      final formattedEnd = '${defaultEnd.year.toString().padLeft(4, '0')}-${defaultEnd.month.toString().padLeft(2, '0')}-${defaultEnd.day.toString().padLeft(2, '0')}';

      debugPrint(
        'Buscando entradas de tempo com datas: $formattedStart a $formattedEnd',
      );

      final response = await _apiClient.get(
        ApiConstants.timeEntries,
        queryParameters: {
          'startDate': formattedStart,
          'endDate': formattedEnd,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        debugPrint('Analisadas ${data.length} entradas de tempo da API');
        return data.map((json) => TimeEntry.fromJson(json)).toList();
      } else {
        throw Exception(
          'Falha ao obter entradas de tempo: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Get time entry by ID
  Future<TimeEntry> getTimeEntry(String id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.timeEntries}/$id');

      if (response.statusCode == 200) {
        return TimeEntry.fromJson(response.data);
      } else {
        throw Exception(
          'Falha ao obter entrada de tempo: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Create new time entry
  Future<TimeEntry> createTimeEntry(TimeEntryCreateData entryData) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.timeEntries,
        data: entryData.toJson(),
      );

      if (response.statusCode == 201) {
        return TimeEntry.fromJson(response.data);
      } else {
        throw Exception(
          'Falha ao criar entrada de tempo: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Update time entry
  Future<TimeEntry> updateTimeEntry(
    String id,
    TimeEntryUpdateData entryData,
  ) async {
    try {
      final jsonData = entryData.toJson();
      debugPrint('=== UPDATE TIME ENTRY ===');
      debugPrint('ID: $id');
      debugPrint('Data being sent: $jsonData');

      final response = await _apiClient.put(
        '${ApiConstants.timeEntries}/$id',
        data: jsonData,
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        // Handle the _id field before parsing
        final responseData = Map<String, dynamic>.from(response.data);
        if (responseData['_id'] is Map) {
          responseData['_id'] = responseData['_id']?['\$oid'] ?? 
                              responseData['_id'].toString();
        }
        
        // Ensure employee is properly formatted if it exists
        if (responseData['employee'] is Map) {
          final employee = Map<String, dynamic>.from(responseData['employee']);
          if (employee['_id'] is Map) {
            employee['_id'] = employee['_id']?['\$oid'] ?? 
                            employee['_id'].toString();
            responseData['employee'] = employee;
          }
        }
        
        return TimeEntry.fromJson(responseData);
      } else {
        throw Exception(
          'Falha ao atualizar entrada de tempo: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      throw Exception(_apiClient.handleError(e));
    } catch (e) {
      debugPrint('Error in updateTimeEntry: $e');
      rethrow;
    }
  }

  // Register exit time for a time entry
  Future<TimeEntry> registerExitTime(String id, String exitTime) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.timeEntryExit}/$id/exit',
        data: {'exitTime': exitTime},
      );

      if (response.statusCode == 200) {
        return TimeEntry.fromJson(response.data);
      } else {
        throw Exception(
          'Falha ao registrar horário de saída: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Delete time entry
  Future<void> deleteTimeEntry(String id) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.timeEntries}/$id',
      );

      if (response.statusCode == 200) {
        // Time entry deleted successfully
        return;
      } else {
        throw Exception(
          'Falha ao excluir entrada de tempo: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Get time entries with filters
  Future<List<TimeEntry>> getTimeEntriesWithFilter(
    TimeEntryFilter filter,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.timeEntries,
        queryParameters: filter.toJson(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => TimeEntry.fromJson(json)).toList();
      } else {
        throw Exception(
          'Falha ao obter entradas de tempo filtradas: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Get time entries by employee
  Future<List<TimeEntry>> getTimeEntriesByEmployee(String employeeId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.timeEntriesByEmployee}/$employeeId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => TimeEntry.fromJson(json)).toList();
      } else {
        throw Exception(
          'Falha ao obter entradas de tempo do funcionário: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Get time entries by date range
  Future<List<TimeEntry>> getTimeEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.timeEntries,
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => TimeEntry.fromJson(json)).toList();
      } else {
        throw Exception(
          'Falha ao obter entradas de tempo por período: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Approve time entry
  Future<TimeEntry> approveTimeEntry(String id) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.timeEntryStatus}/$id/status',
        data: {'status': 'APPROVED'},
      );

      if (response.statusCode == 200) {
        return TimeEntry.fromJson(response.data);
      } else {
        throw Exception(
          'Falha ao aprovar entrada de tempo: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Reject time entry
  Future<TimeEntry> rejectTimeEntry(String id, String reason) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.timeEntryStatus}/$id/status',
        data: {'status': 'REJECTED', 'reason': reason},
      );

      if (response.statusCode == 200) {
        return TimeEntry.fromJson(response.data);
      } else {
        throw Exception(
          'Falha ao rejeitar entrada de tempo: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Get pending time entries
  Future<List<TimeEntry>> getPendingTimeEntries() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.timeEntries,
        queryParameters: {'status': 'PENDING'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => TimeEntry.fromJson(json)).toList();
      } else {
        throw Exception(
          'Falha ao obter entradas de tempo pendentes: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Get time entry statistics
  Future<Map<String, dynamic>> getTimeEntryStatistics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.timeEntries}/statistics',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Falha ao obter estatísticas de entradas de tempo: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }
}
