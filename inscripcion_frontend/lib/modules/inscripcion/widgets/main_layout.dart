import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:inscripcion_frontend/config/theme/app_theme.dart';
import 'package:inscripcion_frontend/modules/inscripcion/models/student.dart';
import 'package:inscripcion_frontend/modules/inscripcion/services/registration_provider.dart';
import 'package:inscripcion_frontend/modules/inscripcion/services/theme_provider.dart';
import 'package:inscripcion_frontend/modules/inscripcion/widgets/sidebar.dart';
import 'package:inscripcion_frontend/shared/utils/responsive_helper.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;
  final String title;
  final String subtitle;

  const MainLayout({
    super.key,
    required this.child,
    this.currentRoute = '/panel',
    this.title = 'Dashboard',
    this.subtitle = 'Panel › Inicio',
  });

  final String getStudentQuery = """
    query GetStudent(\$registro: String!, \$codigoCarrera: String) {
      panelEstudiante(registro: \$registro, codigoCarrera: \$codigoCarrera) {
        estudiante {
          registro
          nombreCompleto
        }
        carrera {
          nombre
        }
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrationProvider>();
    final studentRegister = provider.studentRegister;
    final isDesktop = Responsive.isDesktop(context);

    if (studentRegister == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Query(
      options: QueryOptions(
        document: gql(getStudentQuery),
        variables: {
          'registro': studentRegister,
          'codigoCarrera': provider.selectedCareer?.code,
        },
        fetchPolicy: FetchPolicy.cacheFirst, // Importante para no petar la red
      ),
      builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result.isLoading && result.data == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final data = result.data?['panelEstudiante'];
        if (data == null && !result.isLoading) {
          return Scaffold(body: Center(child: Text('Error al cargar panel: ${result.exception?.toString() ?? "Sin datos"}')));
        }

        Student? student;
        if (data != null) {
          student = Student.fromJson(data);
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          drawer: (!isDesktop && student != null) ? Sidebar(student: student, currentRoute: currentRoute) : null,
          body: Row(
            children: [
              if (isDesktop && student != null) Sidebar(student: student, currentRoute: currentRoute),
              Expanded(
                child: Column(
                  children: [
                    if (student != null) _buildTopBar(context, student),
                    Expanded(
                      child: child,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, Student student) {
    final isDesktop = Responsive.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          if (!isDesktop)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isDark 
                    ? GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      )
                    : const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: UAGRMTheme.textDark,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: UAGRMTheme.textGrey),
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 16),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return IconButton(
                  icon: Icon(
                    themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
                    color: themeProvider.isDark ? Colors.amber : UAGRMTheme.primaryBlue,
                  ),
                  onPressed: () => themeProvider.toggle(),
                  tooltip: themeProvider.isDark ? 'Modo Claro' : 'Modo Noche',
                );
              },
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: UAGRMTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${student.career} - ${student.register}',
                style: isDark 
                  ? GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: UAGRMTheme.accentCyan,
                    )
                  : const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: UAGRMTheme.primaryBlue,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
