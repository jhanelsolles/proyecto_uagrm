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
        }
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrationProvider>();
    final studentRegister = provider.studentRegister;

    if (studentRegister == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No se ha proporcionado un registro o la sesión se ha reiniciado.', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Volver al Inicio de Sesión'),
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
              ),
            ],
          ),
        ),
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
                  color: UAGRMTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                student.career,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Grid de Acciones
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 4 : (isMobile ? 1 : 2),
            crossAxisSpacing: isMobile ? 16 : 24,
            mainAxisSpacing: isMobile ? 16 : 24,
            childAspectRatio: isMobile ? 2.8 : 1.4,
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
                isAvailable: true,
                onTap: () => Navigator.pushReplacementNamed(context, '/enrollment-slip'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isMobile = !Responsive.isDesktop(context) && !Responsive.isTablet(context);

    return InkWell(
      onTap: isAvailable ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 10),
              decoration: BoxDecoration(
                color: isAvailable ? const Color(0xFFF1F5F9) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isAvailable ? UAGRMTheme.primaryBlue : Colors.grey,
                size: isMobile ? 22 : 24,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: isAvailable ? const Color(0xFF1E293B) : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: isAvailable ? const Color(0xFF64748B) : Colors.grey.shade400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
