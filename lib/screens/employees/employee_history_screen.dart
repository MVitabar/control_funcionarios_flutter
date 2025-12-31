import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../providers/employee_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/time_entry_provider.dart';
import '../../models/employee.dart';
import '../../models/time_entry.dart';
import '../../services/time_entry_service.dart';
import '../time_entries/time_entry_screen.dart';

class EmployeeHistoryScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeHistoryScreen({super.key, this.employee});

  @override
  State<EmployeeHistoryScreen> createState() => _EmployeeHistoryScreenState();
}

class _EmployeeHistoryScreenState extends State<EmployeeHistoryScreen> {
  Employee? _selectedEmployee;
  DateTime? _startDate;
  DateTime? _endDate;
  List<TimeEntry> _allEntries = [];
  final Map<String, bool> _expandedEmployees = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Pre-select employee if provided
    _selectedEmployee = widget.employee;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check if user is authenticated
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        throw Exception(
          'Usuário não autenticado. Por favor inicie a sessão novamente.',
        );
      }

      // Load employees
      final employeeProvider = Provider.of<EmployeeProvider>(
        context,
        listen: false,
      );
      await employeeProvider.loadEmployees();

      // Load all time entries
      debugPrint('Carregando entradas de tempo do TimeEntryService...');
      final timeEntryService = TimeEntryService();
      final entries = await timeEntryService.getTimeEntries();
      debugPrint('Carregadas ${entries.length} entradas de tempo');

      // Filter out entries with invalid/empty employee names
      final validEntries = entries.where((entry) {
        return entry.employee.name.isNotEmpty;
      }).toList();

      if (validEntries.length < entries.length) {
        debugPrint(
          'Filtradas ${entries.length - validEntries.length} entradas com funcionários inválidos',
        );
      }

      if (!mounted) return;

      setState(() {
        _allEntries = validEntries;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
      String errorMessage = e.toString();

      // Check if it's an authentication error
      if (errorMessage.contains('401') ||
          errorMessage.contains('Unauthorized') ||
          errorMessage.contains('autenticado')) {
        errorMessage =
            'Sua sessão expirou. Por favor inicie a sessão novamente.';
        if (mounted) {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          await authProvider.logout();
          if (mounted) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredAndGroupedEntries() {
    // Get all employees for mapping
    final employeeProvider = Provider.of<EmployeeProvider>(
      context,
      listen: false,
    );
    final allEmployees = employeeProvider.employees;

    // Filter by date range and selected employee
    var filtered = _allEntries.where((entry) {
      // Date filter - only filter if dates are selected
      if (_startDate != null && _endDate != null) {
        if (entry.date.isBefore(_startDate!) || entry.date.isAfter(_endDate!)) {
          return false;
        }
      }

      // Employee filter
      if (_selectedEmployee != null &&
          entry.employee.id != _selectedEmployee!.id) {
        return false;
      }

      return true;
    }).toList();

    // Group entries by employee
    Map<String, List<TimeEntry>> grouped = {};
    for (var entry in filtered) {
      final employeeId = entry.employee.id;
      if (!grouped.containsKey(employeeId)) {
        grouped[employeeId] = [];
      }
      grouped[employeeId]!.add(entry);
    }

    // Convert to list format for rendering
    return grouped.entries.map((e) {
      final entries = e.value;
      final employeeReference = entries.first.employee;

      // Find the full Employee object from the employee list
      final fullEmployee = allEmployees.firstWhere(
        (emp) => emp.id == employeeReference.id,
        orElse: () => Employee(
          id: employeeReference.id,
          name: employeeReference.name,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      return {
        'employee': fullEmployee,
        'entries': entries,
        'isExpanded': _expandedEmployees[fullEmployee.id] ?? false,
      };
    }).toList();
  }

  Color _getStatusColor(TimeEntryStatus? status) {
    status ??= TimeEntryStatus.pending; // Default to pending if null
    switch (status) {
      case TimeEntryStatus.approved:
        return const Color(0xFF4CAF50);
      case TimeEntryStatus.rejected:
        return Colors.red;
      case TimeEntryStatus.pending:
        return Colors.orange;
    }
  }

  String _getStatusText(TimeEntryStatus? status) {
    status ??= TimeEntryStatus.pending; // Default to pending if null
    switch (status) {
      case TimeEntryStatus.approved:
        return 'Aprovado';
      case TimeEntryStatus.pending:
        return 'Pendente';
      case TimeEntryStatus.rejected:
        return 'Rejeitado';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  Duration _calculateWorkDuration(TimeEntry entry) {
    if (entry.exitTime == null) return Duration.zero;
    return entry.exitTime!.difference(entry.entryTime);
  }

  Duration _calculateTotalHours(List<TimeEntry> entries) {
    Duration total = Duration.zero;
    for (var entry in entries) {
      total += _calculateWorkDuration(entry);
    }
    return total;
  }

  double _calculateTotalExtraHours(List<TimeEntry> entries) {
    double total = 0.0;
    for (var entry in entries) {
      if (entry.extraHours != null) {
        total += entry.extraHours!;
      }
    }
    return total;
  }

  String _calculateTotalToPay(TimeEntry entry) {
    if (entry.total != null) {
      return '\$${entry.total!.toStringAsFixed(2)}';
    }
    
    // Si no hay total, intentar calcularlo
    final dailyRate = entry.dailyRate ?? 0.0;
    final regularHours = entry.regularHours != null 
        ? (entry.regularHours is double ? entry.regularHours as double : double.tryParse(entry.regularHours.toString()) ?? 0.0)
        : 0.0;
    final extraHours = entry.extraHours ?? 0.0;
    final extraRate = entry.extraHoursRate ?? (dailyRate / 8.0) * 1.5; // 1.5x el valor de la hora normal
    
    final total = (regularHours * (dailyRate / 8.0)) + (extraHours * extraRate);
    return '\$${total.toStringAsFixed(2)}';
  }

  String _calculateEmployeeTotalToPay(List<TimeEntry> entries) {
    double total = 0.0;
    
    for (var entry in entries) {
      if (entry.total != null) {
        total += entry.total!;
      } else {
        // Calcular el total si no está definido
        final dailyRate = entry.dailyRate ?? 0.0;
        final regularHours = entry.regularHours != null 
            ? (entry.regularHours is double ? entry.regularHours as double : double.tryParse(entry.regularHours.toString()) ?? 0.0)
            : 0.0;
        final extraHours = entry.extraHours ?? 0.0;
        final extraRate = entry.extraHoursRate ?? (dailyRate / 8.0) * 1.5;
        
        total += (regularHours * (dailyRate / 8.0)) + (extraHours * extraRate);
      }
    }
    
    return '\$${total.toStringAsFixed(2)}';
  }

  String _formatTotalHours(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  List<pw.TableRow> _buildEmployeeTableRows(
    List<Map<String, dynamic>> groupedEntries,
  ) {
    final List<pw.TableRow> rows = [];

    for (var group in groupedEntries) {
      final employee = group['employee'] as Employee;
      final entries = group['entries'] as List<TimeEntry>;

      // Sort entries by date
      entries.sort((a, b) => a.date.compareTo(b.date));

      // Employee header row (spanning all columns)
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _tableCell(employee.name, isHeader: true),
            _tableCell(''),
            _tableCell(''),
            _tableCell(''),
            _tableCell(''),
            _tableCell(''),
            _tableCell(''),
            _tableCell(''),
          ],
        ),
      );

      // Employee entries
      for (var entry in entries) {
        rows.add(
          pw.TableRow(
            children: [
              _tableCell(''), // Empty cell for employee name
              _tableCellCenter(DateFormat('dd/MM/yyyy').format(entry.date)),
              _tableCellCenter(DateFormat('HH:mm').format(entry.entryTime)),
              _tableCellCenter(
                entry.exitTime != null
                    ? DateFormat('HH:mm').format(entry.exitTime!)
                    : '--:--',
              ),
              _tableCellCenter(_formatDuration(_calculateWorkDuration(entry))),
              _tableCellCenter(
                entry.extraHours != null
                    ? '${entry.extraHours!.toStringAsFixed(1)}h'
                    : '-',
              ),
              _tableCellCenter(
                entry.notes?.isNotEmpty == true ? entry.notes! : '-',
              ),
              _tableCellRight(_calculateTotalToPay(entry)),
            ],
          ),
        );
      }

      // Employee totals row (matching React Native structure)
      final totalHours = _calculateTotalHours(entries);
      final totalExtraHours = _calculateTotalExtraHours(entries);
      final totalToPay = _calculateEmployeeTotalToPay(entries);

      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400)),
          ),
          children: [
            _tableCell(''),
            _tableCell(''),
            _tableCell(''),
            _tableCell(''),
            _tableCellCenter(_formatTotalHours(totalHours)),
            _tableCellCenter('${totalExtraHours.toStringAsFixed(1)}h'),
            _tableCell(''),
            _tableCellRight(totalToPay, isBold: true),
          ],
        ),
      );

      // Spacer row between employees
      rows.add(
        pw.TableRow(
          children: [
            pw.Container(height: 10),
            pw.Container(height: 10),
            pw.Container(height: 10),
            pw.Container(height: 10),
            pw.Container(height: 10),
            pw.Container(height: 10),
            pw.Container(height: 10),
            pw.Container(height: 10),
          ],
        ),
      );
    }

    return rows;
  }

  Future<void> _exportToPDF() async {
    try {
      // Solicitar permissão de armazenamento
      // await Permission.storage.request();

      // Obter as entradas agrupadas
      final groupedEntries = _getFilteredAndGroupedEntries();

      if (groupedEntries.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sem dados para exportar')),
        );
        return;
      }

      // Criar documento PDF
      final pdf = pw.Document();

      // Carregar uma fonte que suporta caracteres Unicode
      // final font = await PdfGoogleFonts.nunitoRegular();

      // Adicionar página ao PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(15),
          build: (pw.Context context) {
            final List<pw.Widget> widgets = [];

            // Título
            widgets.add(
              pw.Text(
                'Registros de Extras',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            );

            // Período de datas
            final dateRangeText = _startDate != null && _endDate != null
                ? 'Período: ${DateFormat('dd/MM/yyyy').format(_startDate!)} a ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                : 'Todos os períodos';

            widgets.add(
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Text(
                  dateRangeText,
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
                ),
              ),
            );

            // Agrupar entradas por funcionário e criar tabela estruturada
            final groupedEntries = _getFilteredAndGroupedEntries();

            widgets.add(
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2), // Funcionário
                  1: const pw.FlexColumnWidth(1), // Data
                  2: const pw.FlexColumnWidth(1), // Entrada
                  3: const pw.FlexColumnWidth(1), // Saída
                  4: const pw.FlexColumnWidth(1), // Total
                  5: const pw.FlexColumnWidth(1), // Extras
                  6: const pw.FlexColumnWidth(2), // Notas
                  7: const pw.FlexColumnWidth(1.2), // Total a Pagar
                },
                children: [
                  // Cabeçalho da tabela
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      _tableCell('Funcionário', isHeader: true),
                      _tableCellCenter('Data', isHeader: true),
                      _tableCellCenter('Entrada', isHeader: true),
                      _tableCellCenter('Saída', isHeader: true),
                      _tableCellCenter('Total', isHeader: true),
                      _tableCellCenter('Extras', isHeader: true),
                      _tableCellCenter('Notas', isHeader: true),
                      _tableCellRight('Total a Pagar', isHeader: true),
                    ],
                  ),
                  // Grupos de funcionários
                  ..._buildEmployeeTableRows(groupedEntries),
                ],
              ),
            );

            // Rodapé
            widgets.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 15),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Gerado em ${DateFormat('dd/MM/yyyy').format(DateTime.now())} às ${DateFormat('HH:mm').format(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            );

            return widgets;
          },
        ),
      );

      // Salvar PDF em arquivo
      final directory = await getTemporaryDirectory();
      final fileName =
          'relatorio_horarios_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = '${directory.path}/$fileName';
      final savedFile = File(file);
      await savedFile.writeAsBytes(await pdf.save());

      // Abrir o arquivo PDF gerado
      if (!mounted) return;

      if (mounted) {
        final result = await OpenFile.open(savedFile.path);

        if (result.type == ResultType.done) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PDF exportado com sucesso')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao abrir PDF: ${result.message}')),
            );
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao exportar PDF: $e')));
    }
  }

  pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      alignment: isHeader ? pw.Alignment.center : pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColors.black,
        ),
      ),
    );
  }

  pw.Widget _tableCellRight(
    String text, {
    bool isHeader = false,
    bool isBold = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: (isHeader || isBold)
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
          color: PdfColors.black,
        ),
      ),
    );
  }

  pw.Widget _tableCellCenter(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Horários'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF1E88E5), const Color(0xFF1565C0)],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  void _showTimeEntryOptions(
    BuildContext context,
    Employee employee,
    TimeEntry entry,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 16),
              Text(
                'Opções de entrada',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit, color: Color(0xFF1E88E5)),
                ),
                title: const Text('Editar entrada'),
                subtitle: const Text('Modificar os dados desta entrada'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimeEntryScreen(
                        employee: employee,
                        editingEntry: entry,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                title: const Text('Excluir entrada'),
                subtitle: const Text('Excluir esta entrada permanentemente'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, entry);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, TimeEntry entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: Text(
            'Tem certeza que deseja excluir a entrada do dia ${DateFormat('dd/MM/yyyy').format(entry.date)}? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteTimeEntry(entry);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTimeEntry(TimeEntry entry) async {
    try {
      await Provider.of<TimeEntryProvider>(
        context,
        listen: false,
      ).deleteTimeEntry(entry.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entrada excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the data to update the list
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir entrada: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar os dados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final groupedEntries = _getFilteredAndGroupedEntries();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Seção de Período de Datas e Filtro de Funcionários
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título da Seção
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF1E88E5,
                          ).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.date_range,
                          color: const Color(0xFF1E88E5),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Período',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E88E5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      // Export Button
                      if (groupedEntries.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            _exportToPDF();
                          },
                          icon: const Icon(
                            Icons.download,
                            color: Color(0xFF1E88E5),
                          ),
                          tooltip: 'Exportar',
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date Range Selector
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: Theme.of(context).colorScheme
                                        .copyWith(
                                          primary: const Color(0xFF1E88E5),
                                          secondary: const Color(0xFF1E88E5),
                                        ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (date != null) {
                              setState(() {
                                _startDate = date;
                                if (_endDate != null &&
                                    _startDate!.isAfter(_endDate!)) {
                                  _endDate = _startDate;
                                }
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(
                                    0xFF1E88E5,
                                  ).withValues(alpha: 0.05),
                                  const Color(
                                    0xFF1565C0,
                                  ).withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(
                                  0xFF1E88E5,
                                ).withValues(alpha: 0.15),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1E88E5,
                                  ).withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF1E88E5,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: const Color(0xFF1E88E5),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Data Início',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: const Color(0xFF1E88E5),
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _startDate != null
                                      ? DateFormat(
                                          'dd MMMM yyyy',
                                        ).format(_startDate!)
                                      : 'Selecionar data',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: _startDate ?? DateTime(2020),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: Theme.of(context).colorScheme
                                        .copyWith(
                                          primary: const Color(0xFF1E88E5),
                                          secondary: const Color(0xFF1E88E5),
                                        ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (date != null) {
                              setState(() {
                                _endDate = date;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(
                                    0xFF1E88E5,
                                  ).withValues(alpha: 0.05),
                                  const Color(
                                    0xFF1565C0,
                                  ).withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(
                                  0xFF1E88E5,
                                ).withValues(alpha: 0.15),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1E88E5,
                                  ).withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF1E88E5,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.event,
                                        size: 16,
                                        color: const Color(0xFF1E88E5),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Data Fim',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: const Color(0xFF1E88E5),
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _endDate != null
                                      ? DateFormat(
                                          'dd MMMM yyyy',
                                        ).format(_endDate!)
                                      : 'Selecionar data',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Employee Filter
                  Consumer<EmployeeProvider>(
                    builder: (context, employeeProvider, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1E88E5).withValues(alpha: 0.02),
                              const Color(0xFF1565C0).withValues(alpha: 0.02),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(
                              0xFF1E88E5,
                            ).withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF1E88E5,
                              ).withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Selecionar Funcionário',
                            labelStyle: TextStyle(
                              color: const Color(0xFF1E88E5),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1E88E5,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.people_outline,
                                color: const Color(0xFF1E88E5),
                                size: 20,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: const Color(0xFF1E88E5),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedEmployee?.id ?? 'all',
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              elevation: 8,
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF1E88E5,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: const Color(0xFF1E88E5),
                                ),
                              ),
                              style: const TextStyle(
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              selectedItemBuilder: (context) {
                                return [
                                  const Text(
                                    'Todos os funcionários',
                                    style: TextStyle(
                                      color: Color(0xFF1565C0),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  ...employeeProvider.employees.map((employee) {
                                    return Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: const Color(
                                            0xFF1E88E5,
                                          ).withValues(alpha: 0.1),
                                          child: Text(
                                            employee.name.isNotEmpty
                                                ? employee.name[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              color: Color(0xFF1E88E5),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            employee.name,
                                            style: const TextStyle(
                                              color: Color(0xFF1565C0),
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ];
                              },
                              items: [
                                DropdownMenuItem<String>(
                                  value: 'all',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.transparent,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF1E88E5,
                                            ).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.groups,
                                            color: const Color(0xFF1E88E5),
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Todos os funcionários',
                                            style: const TextStyle(
                                              color: Color(0xFF1565C0),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ...employeeProvider.employees
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      final index = entry.key;
                                      final employee = entry.value;
                                      return DropdownMenuItem(
                                        value: employee.id,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            color: Colors.transparent,
                                            border: index > 0
                                                ? Border(
                                                    top: BorderSide(
                                                      color: const Color(
                                                        0xFFE0E0E0,
                                                      ),
                                                      width: 1,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 18,
                                                backgroundColor: const Color(
                                                  0xFF1E88E5,
                                                ).withValues(alpha: 0.1),
                                                child: Text(
                                                  employee.name.isNotEmpty
                                                      ? employee.name[0]
                                                            .toUpperCase()
                                                      : '?',
                                                  style: const TextStyle(
                                                    color: Color(0xFF1E88E5),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      employee.name,
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF1565C0,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    if (employee.email != null)
                                                      Text(
                                                        employee.email!,
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 12,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: employee.isActive
                                                      ? const Color(
                                                          0xFF4CAF50,
                                                        ).withValues(alpha: 0.1)
                                                      : const Color(
                                                          0xFF9E9E9E,
                                                        ).withValues(
                                                          alpha: 0.1,
                                                        ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      employee.isActive
                                                          ? Icons.check_circle
                                                          : Icons.cancel,
                                                      color: employee.isActive
                                                          ? const Color(
                                                              0xFF4CAF50,
                                                            )
                                                          : const Color(
                                                              0xFF9E9E9E,
                                                            ),
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      employee.isActive
                                                          ? 'Ativo'
                                                          : 'Inativo',
                                                      style: TextStyle(
                                                        color: employee.isActive
                                                            ? const Color(
                                                                0xFF4CAF50,
                                                              )
                                                            : const Color(
                                                                0xFF9E9E9E,
                                                              ),
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  if (value == 'all') {
                                    _selectedEmployee = null;
                                  } else {
                                    _selectedEmployee = employeeProvider
                                        .employees
                                        .firstWhere(
                                          (emp) => emp.id == value,
                                          orElse: () => Employee(
                                            id: '',
                                            name: '',
                                            isActive: true,
                                            createdAt: DateTime.now(),
                                            updatedAt: DateTime.now(),
                                          ),
                                        );
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Entries List
          if (groupedEntries.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: groupedEntries.length,
              itemBuilder: (context, index) {
                final group = groupedEntries[index];
                final employee = group['employee'] as Employee;
                final entries = group['entries'] as List<TimeEntry>;
                final totalHours = _calculateTotalHours(entries);
                final totalExtraHours = _calculateTotalExtraHours(entries);

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    backgroundColor: Colors.transparent,
                    collapsedBackgroundColor: Colors.transparent,
                    tilePadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: const Color(
                        0xFF1E88E5,
                      ).withValues(alpha: 0.1),
                      child: Text(
                        employee.name.isNotEmpty
                            ? employee.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Color(0xFF1E88E5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1E88E5,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${entries.length} ${entries.length == 1 ? 'registro' : 'registros'}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E88E5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Total horas: ${(totalHours.inMinutes / 60).toStringAsFixed(1)}h',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (totalExtraHours > 0) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFF9800,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.access_time_filled,
                                  color: const Color(0xFFFF9800),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Horas extras: ${totalExtraHours.toStringAsFixed(1)}h',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF9800),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: entries.map((entry) {
                            final duration = _calculateWorkDuration(entry);
                            return InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                _showTimeEntryOptions(context, employee, entry);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF1E88E5,
                                    ).withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(entry.date),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                              entry.status,
                                            ).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            _getStatusText(entry.status),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: _getStatusColor(
                                                entry.status,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Entrada: ${DateFormat('HH:mm').format(entry.entryTime)}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        if (entry.exitTime != null) ...[
                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.exit_to_app,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Saída: ${DateFormat('HH:mm').format(entry.exitTime!)}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (duration != Duration.zero) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.schedule,
                                            size: 16,
                                            color: const Color(0xFF1E88E5),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Duração: ${_formatDuration(duration)}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF1E88E5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (entry.extraHours != null &&
                                        entry.extraHours! > 0) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFFF9800,
                                              ).withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Icon(
                                              Icons.access_time_filled,
                                              color: const Color(0xFFFF9800),
                                              size: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Extras: ${entry.extraHours!.toStringAsFixed(1)}h',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFFF9800),
                                            ),
                                          ),
                                          if (entry.extraHoursRate != null) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              '@ \$${entry.extraHoursRate!.toStringAsFixed(2)}/h',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                    if (entry.notes != null &&
                                        entry.notes!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.note,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                entry.notes!,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum registro para as datas selecionadas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustando o período ou os filtros',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
