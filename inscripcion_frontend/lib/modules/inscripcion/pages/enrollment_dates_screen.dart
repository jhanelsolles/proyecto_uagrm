import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inscripcion_frontend/config/theme/app_theme.dart';
import 'package:inscripcion_frontend/modules/inscripcion/widgets/main_layout.dart';
import 'package:inscripcion_frontend/shared/utils/responsive_helper.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLarge) ...[
          const Text(
            'Periodos de Inscripción',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: UAGRMTheme.textDark),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isLarge
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: UAGRMTheme.primaryBlue,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Row(
                  children: [
                    _headerCell('PERIODO', flex: 2),
                    _headerCell('FECHA DE INICIO', flex: 2),
                    _headerCell('FECHA FIN', flex: 2),
                    _headerCell('ESTADO', flex: 2),
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
                    color: isLarge
                        ? (isEven ? Colors.white : const Color(0xFFFAFAFA))
                        : (isEven ? Colors.grey.shade300 : Colors.grey.shade400),
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(item['periodoHabilitado'] ?? '', style: TextStyle(fontSize: isLarge ? 13 : 12), textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text(item['fechaInicio'] ?? '', style: TextStyle(fontSize: isLarge ? 13 : 12), textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text(item['fechaFin'] ?? '', style: TextStyle(fontSize: isLarge ? 13 : 12), textAlign: TextAlign.center)),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: isLarge
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isHabilitado ? UAGRMTheme.successGreen.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: isHabilitado ? UAGRMTheme.successGreen : Colors.orange),
                                  ),
                                  child: Text(
                                    estado,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isHabilitado ? UAGRMTheme.successGreen : Colors.orange,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : Text(estado, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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

  Widget _headerCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
