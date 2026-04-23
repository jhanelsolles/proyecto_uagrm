import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:inscripcion_frontend/config/theme/app_theme.dart';
import 'package:inscripcion_frontend/modules/inscripcion/models/student.dart';
import 'package:inscripcion_frontend/modules/inscripcion/services/registration_provider.dart';
import 'package:inscripcion_frontend/modules/inscripcion/widgets/main_layout.dart';
import 'package:inscripcion_frontend/shared/utils/responsive_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class MainPanelScreen extends StatefulWidget {
  const MainPanelScreen({super.key});

  @override
  State<MainPanelScreen> createState() => _MainPanelScreenState();
}

class _MainPanelScreenState extends State<MainPanelScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  final String getPanelQuery = """
    query GetPanel(\$registro: String!, \$codigoCarrera: String) {
      panelEstudiante(registro: \$registro, codigoCarrera: \$codigoCarrera) {
        estudiante {
          registro
          nombreCompleto
        }
        carrera {
          nombre
        }
        semestreActual
        modalidad
        estado
        periodoActual {
          inscripcionesHabilitadas
        }
        opcionesDisponibles {
          fechasInscripcion
          bloqueo
          boleta
          inscripcion
          transacciones
          maestroOfertas
          pagos
          calendarioAcademico
        }
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrationProvider>();
    final studentRegister = provider.studentRegister;

    if (studentRegister == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MainLayout(
      currentRoute: '/panel',
      title: 'Dashboard',
      subtitle: 'Panel › Inicio',
      child: Query(
        options: QueryOptions(
          document: gql(getPanelQuery),
          variables: {
            'registro': studentRegister,
            'codigoCarrera': provider.selectedCareer?.code,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: UAGRMTheme.errorRed, size: 48),
                  const SizedBox(height: 16),
                  Text('Error al cargar panel:\n\${result.exception.toString()}'),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: refetch, child: const Text('Reintentar')),
                ],
              ),
            );
          }

          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = result.data?['panelEstudiante'];
          if (data == null) {
            return const Center(child: Text('No se encontraron datos.'));
          }

          final student = Student.fromJson(data);
          final optionsJson = data['opcionesDisponibles'] ?? {};
          final periodJson = data['periodoActual'];
          final options = PanelOptions.fromJson(optionsJson, periodJson);

          return _buildDashboardContent(context, student, options);
        },
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, Student student, PanelOptions options) {
    final isDesktop = Responsive.isDesktop(context);
    final isMobile = !isDesktop && !Responsive.isTablet(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mensaje de Bienvenida
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bienvenido, ${student.fullName.split(' ')[0]}",
                style: GoogleFonts.outfit(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark ? UAGRMTheme.darkText : UAGRMTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                student.career,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Theme.of(context).brightness == Brightness.dark ? UAGRMTheme.darkTextSecondary : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Tarjetas de Resumen
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3, // Siempre 3 columnas en horizontal
            crossAxisSpacing: isMobile ? 8 : 12,
            mainAxisSpacing: 12,
            childAspectRatio: isMobile ? 0.95 : (isDesktop ? 3.5 : 3.0),
            children: [
              _StatusSummaryCard(
                title: 'Semestre Actual',
                value: student.semester,
                icon: Icons.trending_up,
                accentColor: UAGRMTheme.primaryBlue,
              ),
              _StatusSummaryCard(
                title: 'Modalidad',
                value: student.modality,
                icon: Icons.menu_book_outlined,
                accentColor: UAGRMTheme.secondaryBlue,
              ),
              _StatusSummaryCard(
                title: 'Estado',
                value: student.status,
                icon: Icons.verified_user_outlined,
                accentColor: UAGRMTheme.successGreen,
                isStatus: true,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Grid de Acciones
          Text(
            'Opciones Disponibles',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? UAGRMTheme.darkText : UAGRMTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 4 : (isMobile ? 1 : 2),
            crossAxisSpacing: isMobile ? 12 : 20,
            mainAxisSpacing: isMobile ? 12 : 20,
            childAspectRatio: isMobile ? 3.0 : 1.4,
            children: [
              _DashboardCard(
                icon: Icons.edit_calendar_outlined,
                title: 'Registrar Materias',
                description: 'Inscribir, adicionar o retirar materias',
                isAvailable: options.enrollment,
                onTap: () => Navigator.pushReplacementNamed(context, '/enrollment'),
              ),
              _DashboardCard(
                icon: Icons.checklist_rtl,
                title: 'Materias Habilitadas',
                description: 'Ver materias disponibles para inscripción',
                isAvailable: options.enabledSubjects,
                onTap: () => Navigator.pushReplacementNamed(context, '/enabled-subjects'),
              ),
              _DashboardCard(
                icon: Icons.calendar_today_outlined,
                title: 'Fecha/Hora Inscripción',
                description: 'Consultar fechas asignadas',
                isAvailable: options.inscriptionDates,
                onTap: () => Navigator.pushReplacementNamed(context, '/enrollment-dates'),
              ),
              _DashboardCard(
                icon: Icons.description_outlined,
                title: 'Boleta de Inscripción',
                description: 'Ver e imprimir boleta',
                isAvailable: options.enrollmentSlips,
                onTap: () => Navigator.pushReplacementNamed(context, '/enrollment-slip'),
              ),
              _DashboardCard(
                icon: Icons.paid_outlined,
                title: 'Transacciones',
                description: 'Historial de movimientos',
                isAvailable: options.transactions,
                onTap: () => Navigator.pushReplacementNamed(context, '/transactions'),
              ),
              _DashboardCard(
                icon: Icons.grid_view_outlined,
                title: 'Maestro de Ofertas',
                description: 'Ver maestros de ofertas',
                isAvailable: options.masterOffers,
                onTap: () => Navigator.pushReplacementNamed(context, '/offers'),
              ),
              _DashboardCard(
                icon: Icons.calendar_month_outlined,
                title: 'Calendario Académico',
                description: 'Ver eventos y fechas importantes',
                isAvailable: options.academicCalendar,
                onTap: () => Navigator.pushReplacementNamed(context, '/calendar'),
              ),
              _DashboardCard(
                icon: Icons.credit_card_outlined,
                title: 'Pagos',
                description: 'Sistema de pagos UAGRM',
                isAvailable: options.payments,
                onTap: () => Navigator.pushReplacementNamed(context, '/payments'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isStatus;
  final Color accentColor;

  const _StatusSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.isStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [
                const Color(0xFF1E293B),
                const Color(0xFF0F172A),
              ]
            : [
                UAGRMTheme.primaryBlue,
                UAGRMTheme.primaryBlue.withValues(alpha: 0.9),
                const Color(0xFF0D47A1),
              ],
        ),
        border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.1)) : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (Theme.of(context).brightness == Brightness.dark ? Colors.black : UAGRMTheme.primaryBlue).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white10,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 24, 
              vertical: isMobile ? 12 : 12
            ),
            child: isMobile 
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 20,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isStatus 
                          ? (value.toUpperCase() == 'ACTIVO' ? const Color(0xFF4ADE80) : Colors.orangeAccent)
                          : (isDark ? UAGRMTheme.accentCyan : Colors.white),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            value,
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isStatus 
                                ? (value.toUpperCase() == 'ACTIVO' ? const Color(0xFF4ADE80) : Colors.orangeAccent)
                                : (isDark ? UAGRMTheme.accentCyan : Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        color: isDark ? UAGRMTheme.accentCyan : Colors.white,
                        size: 28,
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

class _DashboardCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isAvailable;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = !Responsive.isDesktop(context) && !Responsive.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: widget.isAvailable ? widget.onTap : null,
      onHover: (value) => setState(() => _isHovered = value),
      onHighlightChanged: (value) => setState(() => _isHovered = value),
      borderRadius: BorderRadius.circular(16),
      splashColor: UAGRMTheme.primaryBlue.withValues(alpha: 0.1),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: _isHovered ? 1.04 : 1.0,
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isDark ? UAGRMTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered 
                  ? UAGRMTheme.primaryBlue.withValues(alpha: 0.5) 
                  : (isDark ? Colors.white10 : Colors.transparent), 
              width: 1.5
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered 
                    ? UAGRMTheme.primaryBlue.withValues(alpha: 0.1) 
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: isMobile 
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.isAvailable 
                          ? (_isHovered ? UAGRMTheme.primaryBlue : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9))) 
                          : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.isAvailable 
                          ? (_isHovered ? Colors.white : UAGRMTheme.primaryBlue) 
                          : Colors.grey,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: widget.isAvailable 
                                ? (isDark ? Colors.white : const Color(0xFF1E293B)) 
                                : Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: widget.isAvailable 
                                ? (isDark ? Colors.white60 : const Color(0xFF64748B)) 
                                : Colors.grey.shade400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.isAvailable 
                          ? (_isHovered ? UAGRMTheme.primaryBlue : const Color(0xFFF1F5F9)) 
                          : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: _isHovered ? [
                        BoxShadow(
                          color: UAGRMTheme.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ] : [],
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.isAvailable 
                          ? (_isHovered ? Colors.white : UAGRMTheme.primaryBlue) 
                          : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.isAvailable 
                          ? (isDark ? Colors.white : const Color(0xFF1E293B)) 
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isAvailable 
                          ? (isDark ? Colors.white60 : const Color(0xFF64748B)) 
                          : Colors.grey.shade400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
