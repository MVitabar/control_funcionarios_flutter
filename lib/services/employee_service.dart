import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/employee.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';

class EmployeeService {
  final ApiClient _apiClient = ApiClient();

  // Get all employees
  Future<List<Employee>> getEmployees() async {
    try {
      debugPrint('Buscando funcionários em: ${ApiConstants.employees}');
      final response = await _apiClient.get(
        ApiConstants.employees,
        queryParameters: {'activeOnly': 'true'},
      );
      
      debugPrint('Status da resposta dos funcionários: ${response.statusCode}');
      debugPrint('Dados da resposta dos funcionários: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        debugPrint('Analisados ${data.length} funcionários');
        return data.map((json) => Employee.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao obter funcionários: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException ao obter funcionários: ${e.type}');
      debugPrint('Status da resposta: ${e.response?.statusCode}');
      debugPrint('Dados da resposta: ${e.response?.data}');
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Get employee by ID
  Future<Employee> getEmployee(String id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.employees}/$id');

      if (response.statusCode == 200) {
        return Employee.fromJson(response.data);
      } else {
        throw Exception('Falha ao obter funcionário: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Create new employee
  Future<Employee> createEmployee(EmployeeCreateData employeeData) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.employees,
        data: employeeData.toJson(),
      );

      if (response.statusCode == 201) {
        return Employee.fromJson(response.data);
      } else {
        throw Exception('Falha ao criar funcionário: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Update employee
  Future<Employee> updateEmployee(String id, EmployeeUpdateData employeeData) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.employees}/$id',
        data: employeeData.toJson(),
      );

      if (response.statusCode == 200) {
        return Employee.fromJson(response.data);
      } else {
        throw Exception('Falha ao atualizar funcionário: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Delete employee
  Future<void> deleteEmployee(String id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.employees}/$id');

      if (response.statusCode == 200) {
        // Employee deleted successfully
        return;
      } else {
        throw Exception('Falha ao excluir funcionário: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Toggle employee active status
  Future<Employee> toggleEmployeeStatus(String id, bool isActive) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.employees}/$id',
        data: {'isActive': isActive},
      );

      if (response.statusCode == 200) {
        return Employee.fromJson(response.data);
      } else {
        throw Exception('Falha ao atualizar status do funcionário: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Erro ao alternar status do funcionário: $e');
      throw Exception(_apiClient.handleError(e));
    } catch (e) {
      debugPrint('Erro ao alternar status do funcionário: $e');
      throw Exception('Falha ao atualizar status do funcionário: $e');
    }
  }

  // Get active employees only
  Future<List<Employee>> getActiveEmployees() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.employees,
        queryParameters: {'isActive': true},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Employee.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao obter funcionários ativos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Search employees by name
  Future<List<Employee>> searchEmployees(String query) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.employees,
        queryParameters: {'search': query},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Employee.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao pesquisar funcionários: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }
}
