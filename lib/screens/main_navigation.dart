import 'package:flutter/material.dart';
import 'schedule/schedule_screen.dart';
import 'employees/employee_history_screen.dart';
import 'employees/add_employee_screen.dart';
import 'time_entries/time_entry_screen.dart';
import 'dashboard/dashboard_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AddEmployeeScreen(),
    const ScheduleScreen(),
    const TimeEntryScreen(),
    const EmployeeHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
    );
  }
}
