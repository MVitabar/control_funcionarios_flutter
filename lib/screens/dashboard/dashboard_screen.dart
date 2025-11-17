import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/time_entry_provider.dart';
import '../../screens/time_entries/time_entry_screen.dart';
import '../employees/employee_list_screen.dart';
import '../employees/add_employee_screen.dart';
import '../employees/employee_history_screen.dart';
import '../../mixins/update_checker_mixin.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with UpdateCheckerMixin {
  @override
  void initState() {
    super.initState();
    // Load employees when dashboard is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmployeeProvider>(context, listen: false).loadEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header com gradiente
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF1E88E5),
                        const Color(0xFF1565C0),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bem-vindo de volta,',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.user?.name ?? 'Usuário',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Estamos felizes em vê-lo novamente',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
            
            // Estadísticas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Resumo',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1565C0),
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Consumer2<EmployeeProvider, TimeEntryProvider>(
              builder: (context, employeeProvider, timeEntryProvider, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _StatCard(
                        title: 'Funcionários',
                        value: employeeProvider.employees.length.toString(),
                        icon: Icons.people_outline,
                        color: const Color(0xFF4CAF50),
                      ),
                      const SizedBox(height: 12),
                      _StatCard(
                        title: 'Ativos',
                        value: employeeProvider.employees.where((e) => e.isActive).length.toString(),
                        icon: Icons.check_circle_outline,
                        color: const Color(0xFF2196F3),
                      ),
                      const SizedBox(height: 12),
                      _StatCard(
                        title: 'Inativos',
                        value: employeeProvider.employees.where((e) => !e.isActive).length.toString(),
                        icon: Icons.cancel_outlined,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 32),

            // Quick actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Ações Rápidas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      title: 'Novo Func.',
                      icon: Icons.person_add,
                      color: AppTheme.primaryColorLight,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddEmployeeScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      title: 'Registrar',
                      icon: Icons.access_time,
                      color: const Color(0xFF1E88E5),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmployeeHistoryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Recent employees
            Text(
              'Funcionários Recentes',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1565C0),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<EmployeeProvider>(
              builder: (context, employeeProvider, child) {
                if (employeeProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final recentEmployees = employeeProvider.employees.take(3).toList();

                if (recentEmployees.isEmpty) {
                  return Card(
                    elevation: 4,
                    shadowColor: Colors.black.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nenhum funcionário registrado',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmployeeListScreen(),
                                ),
                              );
                            },
                            child: const Text('Adicionar Primeiro Funcionário'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    ...recentEmployees.map((employee) => _EmployeeCard(
                      employee: employee,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimeEntryScreen(employee: employee),
                          ),
                        );
                      },
                    )),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmployeeListScreen(),
                          ),
                        );
                      },
                      child: const Text('Ver todos os funcionários'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: color,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final dynamic employee;
  final VoidCallback onTap;

  const _EmployeeCard({
    required this.employee,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person,
                    color: AppTheme.getPrimaryColor(context),
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
                      Text(
                        employee.email ?? 'Sem e-mail',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: employee.isActive 
                        ? AppTheme.getSuccessColor(context).withValues(alpha: 0.1)
                        : AppTheme.getDangerColor(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        employee.isActive ? Icons.check_circle : Icons.block,
                        color: employee.isActive 
                            ? AppTheme.getSuccessColor(context)
                            : AppTheme.getDangerColor(context),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        employee.isActive ? 'Ativo' : 'Inativo',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: employee.isActive 
                              ? AppTheme.getSuccessColor(context)
                              : AppTheme.getDangerColor(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
