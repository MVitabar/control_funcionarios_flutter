import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_provider.dart';
import '../../models/employee.dart';
import '../time_entries/time_entry_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmployeeProvider>(context, listen: false).loadEmployees();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Employee> _getFilteredEmployees(List<Employee> employees) {
    if (_searchQuery.isEmpty) {
      return employees;
    }
    return employees.where((employee) {
      return employee.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (employee.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  void _showEmployeeOptions(BuildContext context, Employee employee) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              employee.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.access_time, color: const Color(0xFF1E88E5)),
              title: const Text('Registros de Horário'),
              subtitle: const Text('Registrar entrada e saída do funcionário'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimeEntryScreen(employee: employee),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person_off, color: employee.isActive ? Colors.orange : Colors.green),
              title: Text(employee.isActive ? 'Desativar Funcionário' : 'Ativar Funcionário'),
              subtitle: Text(employee.isActive ? 'Alterar estado para inativo' : 'Alterar estado para ativo'),
              onTap: () {
                Navigator.pop(context);
                _toggleEmployeeStatus(employee);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir Funcionário'),
              subtitle: const Text('Excluir permanentemente do sistema'),
              onTap: () {
                Navigator.pop(context);
                _deleteEmployee(employee);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleEmployeeStatus(Employee employee) async {
    try {
      await Provider.of<EmployeeProvider>(context, listen: false)
          .toggleEmployeeStatus(employee.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Funcionário ${employee.isActive ? 'desativado' : 'ativado'} com sucesso',
            ),
            backgroundColor: employee.isActive ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar estado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Funcionário'),
        content: Text('Tem certeza que deseja excluir ${employee.name}? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (mounted) {
        try {
          await Provider.of<EmployeeProvider>(context, listen: false)
              .deleteEmployee(employee.id);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Funcionário excluído com sucesso'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao excluir funcionário: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Todos os Funcionários',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E88E5),
                Color(0xFF1565C0),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: Color(0xFF1565C0),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'Buscar funcionários...',
                labelStyle: const TextStyle(
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.w600,
                ),
                hintText: 'Digite o nome do funcionário',
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                ),
                prefixIcon: Icon(Icons.search, color: const Color(0xFF1E88E5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1E88E5),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFF1E88E5).withValues(alpha: 0.08),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: const Color(0xFF1E88E5)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Employee List
          Expanded(
            child: Consumer<EmployeeProvider>(
              builder: (context, employeeProvider, child) {
                if (employeeProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (employeeProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Erro: ${employeeProvider.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            employeeProvider.loadEmployees();
                          },
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredEmployees = _getFilteredEmployees(employeeProvider.employees);

                if (filteredEmployees.isEmpty) {
                  return const Center(
                    child: Text('Nenhum funcionário encontrado'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredEmployees.length,
                  itemBuilder: (context, index) {
                    final employee = filteredEmployees[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            _showEmployeeOptions(context, employee);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: employee.isActive
                                        ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                                        : const Color(0xFF9E9E9E).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: employee.isActive
                                          ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                                          : const Color(0xFF9E9E9E).withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: employee.isActive
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFF9E9E9E),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        employee.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1565C0),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (employee.email != null && employee.email!.isNotEmpty)
                                        Text(
                                          employee.email!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: employee.isActive
                                                  ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                                                  : const Color(0xFF9E9E9E).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              employee.isActive ? 'Ativo' : 'Inativo',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: employee.isActive
                                                    ? const Color(0xFF4CAF50)
                                                    : const Color(0xFF9E9E9E),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: const Color(0xFF1E88E5).withValues(alpha: 0.6),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
