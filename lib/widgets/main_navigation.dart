import 'package:flutter/material.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/schedule/schedule_screen.dart';
import '../../screens/employees/employee_list_screen.dart';
import '../../constants/app_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ScheduleScreen(),
    const EmployeeListScreen(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard),
      label: 'Inicio',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.schedule_outlined),
      activeIcon: Icon(Icons.schedule),
      label: 'Horários',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.people_outline),
      activeIcon: Icon(Icons.people),
      label: 'Funcionários',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _bottomNavItems,
        selectedItemColor: AppTheme.primaryColorLight,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
