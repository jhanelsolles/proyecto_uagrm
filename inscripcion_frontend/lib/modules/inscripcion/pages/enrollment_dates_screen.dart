import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inscripcion_frontend/config/theme/app_theme.dart';
import 'package:inscripcion_frontend/modules/inscripcion/widgets/main_layout.dart';
import 'package:inscripcion_frontend/shared/utils/responsive_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class EnrollmentDatesScreen extends StatefulWidget {
  const EnrollmentDatesScreen({super.key});

  @override
  State<EnrollmentDatesScreen> createState() => _EnrollmentDatesScreenState();
}

class _EnrollmentDatesScreenState extends State<EnrollmentDatesScreen> {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );
    }
  }

  final String getDatesQuery = """
    query GetEnrollmentDates(\$registro: String!) {
      fechasInscripcion(registro: \$registro) {
        periodoHabilitado
        fechaInicio
        fechaFin
        estado
      }
    }
  """;

  final List<Map<String, dynamic>> datesData = [
    {
      'periodoHabilitado': '2025-1',
      'fechaInicio': '2025-02-01',
      'fechaFin': '2025-02-15',
      'estado': 'HABILITADO'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isLarge = Responsive.isTabletOrDesktop(context);
    final content = _buildContent(isLarge);

    return MainLayout(
      currentRoute: '/enrollment-dates',
      title: 'Fechas de Inscripción',
      subtitle: 'Panel › Fechas de Inscripción',
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.isDesktop(context) ? 800 : 640,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(Responsive.horizontalPadding(context)),
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isLarge) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLarge) ...[
          Text(
            'Periodos de Inscripción',
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: isDark ? UAGRMTheme.accentCyan : UAGRMTheme.primaryBlue,
              fontFamily: isDark ? GoogleFonts.outfit().fontFamily : null,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Theme.of(context).cardTheme.color : Colors.white,
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200, width: 1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: UAGRMTheme.primaryBlue,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    _headerCell('PERIODO', flex: 2, isDark: isDark),
                    _headerCell('FECHA DE INICIO', flex: 3, isDark: isDark),
                    _headerCell('FECHA FIN', flex: 3, isDark: isDark),
                    _headerCell('ESTADO', flex: 2, isDark: isDark),
                  ],
                ),
              ),
              ...datesData.asMap().entries.map((entry) {
                final isEven = entry.key % 2 == 0;
                final item = entry.value;
                final estado = item['estado'] ?? '';
                final isHabilitado = estado == 'HABILITADO';
                return Container(
                  decoration: BoxDecoration(
                    color: isEven ? Colors.transparent : (isDark ? Colors.white.withValues(alpha: 0.01) : const Color(0xFFFAFAFA)),
                    border: Border(bottom: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(item['periodoHabilitado'] ?? '', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : UAGRMTheme.textDark, fontFamily: isDark ? GoogleFonts.outfit().fontFamily : null), textAlign: TextAlign.center)),
                      Expanded(flex: 3, child: Text(item['fechaInicio'] ?? '', style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : UAGRMTheme.textGrey), textAlign: TextAlign.center)),
                      Expanded(flex: 3, child: Text(item['fechaFin'] ?? '', style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : UAGRMTheme.textGrey), textAlign: TextAlign.center)),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isHabilitado ? UAGRMTheme.successGreen.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: (isHabilitado ? UAGRMTheme.successGreen : Colors.orange).withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              estado,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isHabilitado ? UAGRMTheme.successGreen : Colors.orange,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _headerCell(String text, {required int flex, required bool isDark}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 0.5,
          fontFamily: isDark ? GoogleFonts.outfit().fontFamily : null,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
