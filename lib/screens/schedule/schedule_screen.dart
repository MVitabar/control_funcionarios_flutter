import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/time_entry_provider.dart';
import '../../providers/employee_provider.dart';
import '../../models/time_entry.dart';
import '../../constants/app_theme.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<TimeEntry>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TimeEntryProvider>(context, listen: false).loadTimeEntries();
      Provider.of<EmployeeProvider>(context, listen: false).loadEmployees();
      _loadEvents();
    });
  }

  List<TimeEntry> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _loadEvents() {
    final timeEntryProvider = Provider.of<TimeEntryProvider>(context, listen: false);
    final entries = timeEntryProvider.timeEntries;
    
    final Map<DateTime, List<TimeEntry>> events = {};
    for (final entry in entries) {
      final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (events[day] == null) {
        events[day] = [];
      }
      events[day]!.add(entry);
    }
    
    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _events = events;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        backgroundColor: AppTheme.primaryColorLight,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, timeEntryProvider, child) {
          if (timeEntryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (timeEntryProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Erro: ${timeEntryProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      timeEntryProvider.refreshTimeEntries();
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              TableCalendar<TimeEntry>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                eventLoader: _getEventsForDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: const CalendarStyle(
                  markersMaxCount: 3,
                  markerDecoration: BoxDecoration(
                    color: AppTheme.primaryColorLight,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildEventList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventList() {
    final events = _getEventsForDay(_selectedDay!);
    
    if (events.isEmpty) {
      return const Center(
        child: Text('Nenhuma entrada de tempo para este dia'),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final entry = events[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(entry.status),
              child: const Icon(Icons.access_time, color: Colors.white),
            ),
            title: Text(entry.employee.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Entrada: ${_formatTime(entry.entryTime)}'),
                if (entry.exitTime != null)
                  Text('Saída: ${_formatTime(entry.exitTime!)}'),
                if (entry.notes != null && entry.notes!.isNotEmpty)
                  Text('Observações: ${entry.notes}'),
              ],
            ),
            trailing: _buildStatusChip(entry.status),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(TimeEntryStatus status) {
    Color backgroundColor;
    String displayText;

    switch (status) {
      case TimeEntryStatus.pending:
        backgroundColor = AppTheme.warningColor;
        displayText = 'Pendente';
        break;
      case TimeEntryStatus.approved:
        backgroundColor = AppTheme.successColor;
        displayText = 'Aprovado';
        break;
      case TimeEntryStatus.rejected:
        backgroundColor = AppTheme.dangerColor;
        displayText = 'Rejeitado';
        break;
    }

    return Chip(
      label: Text(displayText),
      backgroundColor: backgroundColor,
      labelStyle: const TextStyle(color: Colors.white),
    );
  }

  Color _getStatusColor(TimeEntryStatus status) {
    switch (status) {
      case TimeEntryStatus.pending:
        return AppTheme.warningColor;
      case TimeEntryStatus.approved:
        return AppTheme.successColor;
      case TimeEntryStatus.rejected:
        return AppTheme.dangerColor;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
