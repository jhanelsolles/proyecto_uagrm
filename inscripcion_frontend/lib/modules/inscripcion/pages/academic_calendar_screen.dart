import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:inscripcion_frontend/config/theme/app_theme.dart';
import 'package:inscripcion_frontend/modules/inscripcion/widgets/main_layout.dart';
import 'package:inscripcion_frontend/shared/utils/responsive_helper.dart';
import 'package:intl/intl.dart';

class AcademicCalendarScreen extends StatelessWidget {
  const AcademicCalendarScreen({super.key});

  static const String getCalendarQuery = """
    query GetAcademicCalendar {
      eventosCalendario {
        id
        titulo
        fecha
        tipo
        tipoDisplay
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/calendar',
      title: 'Calendario Académico',
      subtitle: 'Panel › Calendario Académico',
      child: Query(
        options: QueryOptions(
          document: gql(getCalendarQuery),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Center(child: Text('Error: ${result.exception.toString()}'));
          }

          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final List events = result.data?['eventosCalendario'] ?? [];

          if (events.isEmpty) {
            return const Center(
              child: Text(
                'No hay eventos programados para este periodo.',
                style: TextStyle(color: UAGRMTheme.textGrey),
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: EdgeInsets.all(Responsive.horizontalPadding(context)),
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  ...events.map((event) => _buildEventCard(context, event)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? UAGRMTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: UAGRMTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month, color: UAGRMTheme.primaryBlue, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calendario Académico 2025',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Universidad Autónoma Gabriel René Moreno',
                  style: TextStyle(color: UAGRMTheme.textGrey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final DateTime eventDate = DateTime.parse(event['fecha']);
    final String month = DateFormat('MMM', 'es').format(eventDate).toLowerCase();
    final String day = eventDate.day.toString();
    
    final String tipo = event['tipo'];
    final String tipoDisplay = event['tipoDisplay'];

    Color tagColor;
    switch (tipo) {
      case 'ACADEMICO':
        tagColor = UAGRMTheme.primaryBlue;
        break;
      case 'INSCRIPCION':
        tagColor = UAGRMTheme.secondaryBlue;
        break;
      case 'FERIADO':
        tagColor = UAGRMTheme.successGreen;
        break;
      case 'EXAMEN':
        tagColor = UAGRMTheme.primaryRed;
        break;
      default:
        tagColor = UAGRMTheme.textGrey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? UAGRMTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Fecha lateral
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    month,
                    style: TextStyle(
                      color: tagColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    day,
                    style: TextStyle(
                      color: isDark ? Colors.white : UAGRMTheme.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1, color: Colors.transparent),
            // Contenido
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        event['titulo'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : UAGRMTheme.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildTag(tipoDisplay, tagColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
