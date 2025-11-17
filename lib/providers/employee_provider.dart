import 'package:flutter/foundation.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';

class EmployeeProvider extends ChangeNotifier {
  final EmployeeService _employeeService = EmployeeService();

  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all employees
  Future<void> loadEmployees() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _employees = await _employeeService.getEmployees();
      debugPrint('EmployeeProvider: Carregados ${_employees.length} funcionários');
      debugPrint('EmployeeProvider: Lista de funcionários: ${_employees.map((e) => e.name).toList()}');
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao carregar funcionários: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create employee
  Future<void> createEmployee({
    required String name,
    String? email,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final employeeData = EmployeeCreateData(
        name: name,
        email: email,
      );
      final employee = await _employeeService.createEmployee(employeeData);
      _employees.add(employee);
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao criar funcionário: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update employee
  Future<void> updateEmployee({
    required String id,
    String? name,
    String? email,
    bool? isActive,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final employeeData = EmployeeUpdateData(
        name: name,
        email: email,
        isActive: isActive,
      );
      final updatedEmployee = await _employeeService.updateEmployee(id, employeeData);
      
      final index = _employees.indexWhere((emp) => emp.id == id);
      if (index != -1) {
        _employees[index] = updatedEmployee;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao atualizar funcionário: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete employee
  Future<void> deleteEmployee(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _employeeService.deleteEmployee(id);
      _employees.removeWhere((emp) => emp.id == id);
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao excluir funcionário: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle employee status
  Future<void> toggleEmployeeStatus(String id) async {
    try {
      final employee = _employees.firstWhere((emp) => emp.id == id);
      final updatedEmployee = await _employeeService.toggleEmployeeStatus(id, !employee.isActive);
      
      // Update local state
      final index = _employees.indexWhere((emp) => emp.id == id);
      if (index != -1) {
        _employees[index] = updatedEmployee;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao alternar status do funcionário: $e');
      rethrow;
    }
  }

  // Search employees
  Future<List<Employee>> searchEmployees(String query) async {
    try {
      return await _employeeService.searchEmployees(query);
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao pesquisar funcionários: $e');
      return [];
    }
  }

  // Get employee by ID
  Employee? getEmployeeById(String id) {
    try {
      return _employees.firstWhere((emp) => emp.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh employees
  Future<void> refreshEmployees() async {
    await loadEmployees();
  }
}
