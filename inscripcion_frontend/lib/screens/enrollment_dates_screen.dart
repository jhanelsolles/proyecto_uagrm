import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:inscripcion_frontend/config/theme/app_theme.dart';
import 'package:inscripcion_frontend/providers/registration_provider.dart';
import 'package:inscripcion_frontend/widgets/web_page_header.dart';

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

  // Datos de ejemplo
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
    final provider = context.watch<RegistrationProvider>();
    final studentRegister = provider.studentRegister;

    final content = _buildContent();

    if (kIsWeb) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WebPageHeader(
                title: 'Fechas de Inscripción',
                icon: Icons.calendar_month_outlined,
                subtitle: 'Consulta los periodos y fechas habilitadas para inscripción',
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: content,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Móvil: diseño original
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fechas de Inscripción'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner móvil
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [UAGRMTheme.primaryBlue, Color(0xFF1565C0)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.calendar_month, size: 48, color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        'Periodos de Inscripción',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                content,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (kIsWeb) ...[
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
            borderRadius: BorderRadius.circular(kIsWeb ? 8 : 8),
            boxShadow: kIsWeb
                ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Column(
            children: [
              // Encabezado tabla
              Container(
                decoration: const BoxDecoration(
                  color: UAGRMTheme.primaryBlue,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Row(
                  children: [
                    _headerCell('PERIODO', flex: 2, isWeb: kIsWeb),
                    _headerCell('FECHA DE INICIO', flex: 2, isWeb: kIsWeb),
                    _headerCell('FECHA FIN', flex: 2, isWeb: kIsWeb),
                    _headerCell('ESTADO', flex: 2, isWeb: kIsWeb),
                  ],
                ),
              ),
              // Filas
              ...datesData.asMap().entries.map((entry) {
                final isEven = entry.key % 2 == 0;
                final item = entry.value;
                final estado = item['estado'] ?? '';
                final isHabilitado = estado == 'HABILITADO';
                return Container(
                  decoration: BoxDecoration(
                    color: kIsWeb
                        ? (isEven ? Colors.white : const Color(0xFFFAFAFA))
                        : (isEven ? Colors.grey.shade300 : Colors.grey.shade400),
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(item['periodoHabilitado'] ?? '', style: TextStyle(fontSize: kIsWeb ? 13 : 12), textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text(item['fechaInicio'] ?? '', style: TextStyle(fontSize: kIsWeb ? 13 : 12), textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text(item['fechaFin'] ?? '', style: TextStyle(fontSize: kIsWeb ? 13 : 12), textAlign: TextAlign.center)),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: kIsWeb
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isHabilitado ? UAGRMTheme.successGreen.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
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

  Widget _headerCell(String text, {required int flex, required bool isWeb}) {
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
