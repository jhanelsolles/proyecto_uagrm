import 'package:flutter/material.dart';
import 'package:inscripcion_frontend/config/theme/app_theme.dart';
import 'package:inscripcion_frontend/modules/inscripcion/models/student.dart';
import 'package:inscripcion_frontend/modules/inscripcion/services/registration_provider.dart';
import 'package:provider/provider.dart';

class Sidebar extends StatelessWidget {
  final Student student;
  final String currentRoute;

  const Sidebar({
    super.key,
    required this.student,
    this.currentRoute = '/panel',
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrationProvider>();
    
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: UAGRMTheme.primaryBlue,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo y Título
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: UAGRMTheme.primaryRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AppInscripción',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'UAGRM',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),


          // Menú de Navegación
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _SidebarItem(
                  icon: Icons.edit_calendar_outlined,
                  title: 'Registrar Materias',
                  isActive: currentRoute == '/enrollment',
                  onTap: () => Navigator.pushReplacementNamed(context, '/enrollment'),
                ),
                _SidebarItem(
                  icon: Icons.checklist_rtl,
                  title: 'Materias Habilitadas',
                  isActive: currentRoute == '/enabled-subjects',
                  onTap: () => Navigator.pushReplacementNamed(context, '/enabled-subjects'),
                ),
                _SidebarItem(
                  icon: Icons.calendar_today_outlined,
                  title: 'Fecha/Hora Inscripción',
                  isActive: currentRoute == '/enrollment-dates',
                  onTap: () => Navigator.pushReplacementNamed(context, '/enrollment-dates'),
                ),
                _SidebarItem(
                  icon: Icons.description_outlined,
                  title: 'Boleta de Inscripción',
                  isActive: currentRoute == '/enrollment-slip',
                  onTap: () => Navigator.pushReplacementNamed(context, '/enrollment-slip'),
                ),
                _SidebarItem(
                  icon: Icons.paid_outlined,
                  title: 'Transacciones',
                  isActive: currentRoute == '/transactions',
                  onTap: () => Navigator.pushReplacementNamed(context, '/transactions'),
                ),
                _SidebarItem(
                  icon: Icons.calendar_month_outlined,
                  title: 'Calendario Académico',
                  isActive: currentRoute == '/calendar',
                  onTap: () => Navigator.pushReplacementNamed(context, '/calendar'),
                ),
                _SidebarItem(
                  icon: Icons.grid_view_outlined,
                  title: 'Maestro de Ofertas',
                  isActive: currentRoute == '/offers',
                  onTap: () => Navigator.pushReplacementNamed(context, '/offers'),
                ),
                _SidebarItem(
                  icon: Icons.credit_card_outlined,
                  title: 'Pagos',
                  isActive: currentRoute == '/payments',
                  onTap: () => Navigator.pushReplacementNamed(context, '/payments'),
                ),
              ],
            ),
          ),

          // Perfil del Usuario
          const Divider(color: Colors.white10, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: UAGRMTheme.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          student.fullName.isNotEmpty ? student.fullName.split(' ').map((e) => e[0]).take(2).join('') : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Reg: ${student.register}',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SidebarItem(
                  icon: Icons.logout,
                  title: 'Cerrar Sesión',
                  isExit: true,
                  onTap: () {
                    provider.clearSelection();
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final bool isExit;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    this.isActive = false,
    this.isExit = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isActive 
          ? UAGRMTheme.primaryRed 
          : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: Colors.white10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? Colors.white : (isExit ? Colors.white70 : Colors.white60),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isActive ? Colors.white : (isExit ? Colors.white70 : Colors.white60),
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    ),
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
