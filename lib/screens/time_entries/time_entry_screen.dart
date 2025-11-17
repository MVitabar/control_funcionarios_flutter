import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/time_entry_provider.dart';
import '../../providers/employee_provider.dart';
import '../../models/employee.dart';
import '../../models/time_entry.dart';
import '../dashboard/dashboard_screen.dart';
import '../../constants/app_theme.dart';
import '../employees/employee_history_screen.dart';

class TimeEntryScreen extends StatefulWidget {
  final Employee? employee;
  final TimeEntry? editingEntry;
  
  const TimeEntryScreen({super.key, this.employee, this.editingEntry});

  @override
  State<TimeEntryScreen> createState() => _TimeEntryScreenState();
}

class _TimeEntryScreenState extends State<TimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _checkInController = TextEditingController();
  final _checkOutController = TextEditingController();
  final _notesController = TextEditingController();
  final _dailyRateController = TextEditingController();
  final _extraHoursRateController = TextEditingController();
  final _extraHoursController = TextEditingController();
  
  Employee? _selectedEmployee;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Load editing entry data if provided
    if (widget.editingEntry != null) {
      final entry = widget.editingEntry!;
      _selectedDate = entry.date;
      _checkInController.text = _formatTime(entry.entryTime);
      if (entry.exitTime != null) {
        _checkOutController.text = _formatTime(entry.exitTime!);
      }
      if (entry.dailyRate != null) {
        _dailyRateController.text = entry.dailyRate!.toStringAsFixed(2);
      }
      if (entry.extraHoursRate != null) {
        _extraHoursRateController.text = entry.extraHoursRate!.toStringAsFixed(2);
      }
      if (entry.extraHours != null) {
        _extraHoursController.text = _formatDurationToHHMM(entry.extraHours!);
      }
      _notesController.text = entry.notes ?? '';
      // Load employee from EmployeeReference if needed
      _loadEmployeeFromReference(entry.employee);
    } else {
      // Pre-select employee if provided for new entry
      _selectedEmployee = widget.employee;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmployeeProvider>(context, listen: false).loadEmployees();
      Provider.of<TimeEntryProvider>(context, listen: false).loadTimeEntries();
    });
  }

  @override
  void dispose() {
    _checkInController.dispose();
    _checkOutController.dispose();
    _notesController.dispose();
    _dailyRateController.dispose();
    _extraHoursRateController.dispose();
    _extraHoursController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedEmployee == null || _selectedDate == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final checkInTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        now.hour,
        now.minute,
      );

      DateTime? checkOutTime;
      if (_checkOutController.text.isNotEmpty) {
        final parts = _checkOutController.text.split(':');
        if (parts.length == 2) {
          checkOutTime = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
        }
      }

      await Provider.of<TimeEntryProvider>(context, listen: false).createTimeEntry(
        employeeId: _selectedEmployee!.id,
        date: _selectedDate!,
        checkIn: checkInTime,
        checkOut: checkOutTime,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        dailyRate: _dailyRateController.text.trim().isEmpty ? null : double.tryParse(_dailyRateController.text),
        extraHoursRate: _extraHoursRateController.text.trim().isEmpty ? null : double.tryParse(_extraHoursRateController.text),
        extraHours: _parseHHMMToDouble(_extraHoursController.text),
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sucesso!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Entrada de tempo criada com sucesso',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF616161),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Redirect to dashboard after closing dialog
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      (route) => false,
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar entrada de tempo: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _checkInController.clear();
    _checkOutController.clear();
    _notesController.clear();
    setState(() {
      _selectedEmployee = null;
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.editingEntry != null ? 'Editar Registro' : 'Entradas de Tempo'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E88E5),
                const Color(0xFF1565C0),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add Time Entry Form
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: const Color(0xFF1E88E5).withValues(alpha: 0.05),
                    blurRadius: 40,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E88E5).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                widget.editingEntry != null ? Icons.edit_outlined : Icons.add_circle_outline,
                                color: const Color(0xFF1E88E5),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Adicionar entrada',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1565C0),
                                  letterSpacing: 0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      Consumer<EmployeeProvider>(
                        builder: (context, employeeProvider, child) {
                          return FormField<Employee>(
                            initialValue: _selectedEmployee,
                            builder: (FormFieldState<Employee> state) {
                              if (_selectedEmployee != null) {
                                // Show read-only employee info when pre-selected
                                return InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Funcionário Selecionado',
                                    labelStyle: const TextStyle(
                                      color: Color(0xFF1565C0),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    hintText: 'Funcionário selecionado',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF212121),
                                    ),
                                    prefixIcon: Icon(Icons.person, color: const Color(0xFF1E88E5)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF1E88E5).withValues(alpha: 0.08),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _selectedEmployee!.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF1565C0),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EmployeeHistoryScreen(employee: _selectedEmployee),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.history,
                                              color: const Color(0xFF1E88E5),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Histórico',
                                              style: TextStyle(
                                                color: const Color(0xFF1E88E5),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              
                              // Show dropdown only when no employee is pre-selected
                              return InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Selecionar Funcionário',
                                  labelStyle: const TextStyle(
                                    color: Color(0xFF1565C0),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  hintText: 'Selecione um funcionário',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF212121),
                                  ),
                                  prefixIcon: Icon(Icons.people_outline, color: const Color(0xFF1E88E5)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF1E88E5).withValues(alpha: 0.08),
                                ),
                                child: DropdownButton<Employee>(
                                  value: null,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  hint: const Text(
                                    'Selecione um funcionário',
                                    style: TextStyle(
                                      color: Color(0xFF212121),
                                    ),
                                  ),
                                  items: employeeProvider.employees.map((employee) {
                                    return DropdownMenuItem(
                                      value: employee,
                                      child: Text(employee.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedEmployee = value;
                                    });
                                    state.didChange(value);
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Data',
                            labelStyle: const TextStyle(
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.w600,
                            ),
                            hintText: 'Selecione a data',
                            hintStyle: const TextStyle(
                              color: Color(0xFF212121),
                            ),
                            prefixIcon: Icon(Icons.calendar_today, color: const Color(0xFF1E88E5)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1E88E5).withValues(alpha: 0.08),
                          ),
                          child: Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Selecione a data',
                            style: const TextStyle(
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) {
                            final formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                            setState(() {
                              _checkInController.text = formattedTime;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Horário de Entrada',
                            labelStyle: const TextStyle(
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.w600,
                            ),
                            hintText: 'Selecione o horário',
                            hintStyle: const TextStyle(
                              color: Color(0xFF212121),
                            ),
                            prefixIcon: Icon(Icons.login, color: const Color(0xFF1E88E5)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1E88E5).withValues(alpha: 0.08),
                          ),
                          child: Text(
                            _checkInController.text.isEmpty ? 'Selecione o horário' : _checkInController.text,
                            style: const TextStyle(
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) {
                            final formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                            setState(() {
                              _checkOutController.text = formattedTime;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Horário de Saída (Opcional)',
                            labelStyle: const TextStyle(
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.w600,
                            ),
                            hintText: 'Selecione o horário',
                            hintStyle: const TextStyle(
                              color: Color(0xFF212121),
                            ),
                            prefixIcon: Icon(Icons.logout, color: const Color(0xFF1E88E5)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1E88E5).withValues(alpha: 0.08),
                          ),
                          child: Text(
                            _checkOutController.text.isEmpty ? 'Selecione o horário' : _checkOutController.text,
                            style: const TextStyle(
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        style: const TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Observações (Opcional)',
                          labelStyle: const TextStyle(
                            color: Color(0xFF1565C0),
                            fontWeight: FontWeight.w600,
                          ),
                          hintText: 'Digite alguma observação',
                          hintStyle: const TextStyle(
                            color: Color(0xFF212121),
                          ),
                          prefixIcon: Icon(Icons.note_alt_outlined, color: const Color(0xFF1E88E5)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1E88E5).withValues(alpha: 0.08),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      // Horas Extras (HH:MM)
                      TextFormField(
                        controller: _extraHoursController,
                        style: const TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Horas Extras (HH:MM)',
                          labelStyle: const TextStyle(
                            color: Color(0xFF1565C0),
                            fontWeight: FontWeight.w600,
                          ),
                          hintText: '00:00',
                          hintStyle: const TextStyle(
                            color: Color(0xFF212121),
                          ),
                          prefixIcon: Icon(Icons.schedule_outlined, color: const Color(0xFF1E88E5)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1E88E5).withValues(alpha: 0.08),
                          helperText: 'Formato: HH:MM (ex: 01:30 para uma hora e meia)',
                          helperStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Valor Diário
                      TextFormField(
                        controller: _dailyRateController,
                        style: const TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Valor Diário',
                          labelStyle: const TextStyle(
                            color: Color(0xFF1565C0),
                            fontWeight: FontWeight.w600,
                          ),
                          hintText: '0.00',
                          hintStyle: const TextStyle(
                            color: Color(0xFF212121),
                          ),
                          prefixIcon: Icon(Icons.attach_money_outlined, color: const Color(0xFF1E88E5)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1E88E5).withValues(alpha: 0.08),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 16),
                      
                      // Valor Hora Extra
                      TextFormField(
                        controller: _extraHoursRateController,
                        style: const TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Valor Hora Extra',
                          labelStyle: const TextStyle(
                            color: Color(0xFF1565C0),
                            fontWeight: FontWeight.w600,
                          ),
                          hintText: '0.00',
                          hintStyle: const TextStyle(
                            color: Color(0xFF212121),
                          ),
                          prefixIcon: Icon(Icons.access_time_outlined, color: const Color(0xFF1E88E5)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1E88E5).withValues(alpha: 0.08),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isLoading ? const Color(0xFF64B5F6) : const Color(0xFF1E88E5),
                                foregroundColor: Colors.white,
                                elevation: _isLoading ? 6 : 8,
                                shadowColor: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isLoading
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text('A guardar...'),
                                      ],
                                    )
                                  : Text(widget.editingEntry != null ? 'Guardar Alterações' : 'Adicionar Entrada'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _clearForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE3F2FD),
                              foregroundColor: const Color(0xFF1E88E5),
                              elevation: 4,
                              shadowColor: const Color(0xFF1E88E5).withValues(alpha: 0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            ),
                            child: const Text('Limpar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDurationToHHMM(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  double? _parseHHMMToDouble(String hhmm) {
    if (hhmm.isEmpty) return null;
    
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    
    try {
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      
      if (hours < 0 || minutes < 0 || minutes >= 60) return null;
      
      return hours + (minutes / 60.0);
    } catch (e) {
      return null;
    }
  }

  void _loadEmployeeFromReference(EmployeeReference reference) {
    // Try to find the full employee object from the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
      final employee = employeeProvider.employees.firstWhere(
        (e) => e.id == reference.id,
        orElse: () => Employee(
          id: reference.id,
          name: reference.name,
          email: reference.email,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      setState(() {
        _selectedEmployee = employee;
      });
    });
  }
}
