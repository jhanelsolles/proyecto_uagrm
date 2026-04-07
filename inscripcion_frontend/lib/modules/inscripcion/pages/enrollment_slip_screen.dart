import 'package:inscripcion_frontend/shared/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:inscripcion_frontend/config/theme/app_theme.dart';
import 'package:inscripcion_frontend/modules/inscripcion/services/registration_provider.dart';
import 'package:inscripcion_frontend/shared/utils/time_formatter.dart';
import 'package:inscripcion_frontend/shared/utils/pdf_generator.dart';
import 'package:inscripcion_frontend/modules/inscripcion/widgets/main_layout.dart';
import 'package:inscripcion_frontend/modules/inscripcion/widgets/schedule_grid.dart';
import 'package:google_fonts/google_fonts.dart';

class EnrollmentSlipScreen extends StatefulWidget {
  const EnrollmentSlipScreen({super.key});

  @override
  State<EnrollmentSlipScreen> createState() => _EnrollmentSlipScreenState();
}

class _EnrollmentSlipScreenState extends State<EnrollmentSlipScreen> {
  String? selectedPeriodCodigo;
  bool _isGraphicalView = false;

  final String getHistoricalPeriodsQuery = """
    query GetHistorialPeriodos(\$registro: String!) {
      historialPeriodosEstudiante(registro: \$registro) {
        codigo
        nombre
      }
    }
  """;

  final String getEnrollmentQuery = """
    query GetEnrollment(\$registro: String!, \$codigoCarrera: String, \$codigoPeriodo: String) {
      inscripcionCompleta(registro: \$registro, codigoCarrera: \$codigoCarrera, codigoPeriodo: \$codigoPeriodo) {
        id
        estudiante {
          registro
          nombreCompleto
        }
        periodoAcademico {
          codigo
          nombre
        }
        fechaInscripcionAsignada
        fechaInscripcionRealizada
        estado
        boletaGenerada
        numeroBoleta
        materiasInscritas {
          materia {
            codigo
            nombre
            creditos
          }
          oferta {
            grupo
            semestre
            horario
          }
          grupo
        }
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrationProvider>();
    final studentRegister = provider.studentRegister;
    final codigoCarrera = provider.selectedCareer?.code;
    final bool isTabletOrDesktop = Responsive.isTabletOrDesktop(context);

    return MainLayout(
      currentRoute: '/enrollment-slip',
      title: 'Boleta de Inscripción',
      subtitle: 'Panel › Boleta de Inscripción',
      child: Column(
        children: [
          _buildPeriodAndTabSelector(studentRegister ?? '', isTabletOrDesktop),
          Expanded(
            child: Query(
              options: QueryOptions(
                document: gql(getEnrollmentQuery),
                variables: {
                  'registro': studentRegister ?? '',
                  'codigoCarrera': codigoCarrera,
                  'codigoPeriodo': selectedPeriodCodigo,
                },
                fetchPolicy: FetchPolicy.networkOnly,
              ),
              builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
                if (result.hasException) return _buildError(context, result.exception.toString(), refetch);
                if (result.isLoading) return const Center(child: CircularProgressIndicator());
                final data = result.data?['inscripcionCompleta'];
                if (data == null) return _buildEmpty();

                return _isGraphicalView 
                    ? _buildGraphicalBoleta(context, data, provider)
                    : _buildTableBoleta(context, data, provider, isTabletOrDesktop);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodAndTabSelector(String registro, bool isDesktop) {
    if (isDesktop) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            _buildHistorialSelector(registro),
            const Spacer(),
            _buildViewTabs(),
          ],
        ),
      );
    }

    // Diseño para Móviles (Evitar desbordamiento)
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildHistorialSelector(registro),
                const SizedBox(width: 16),
                _buildOpcionesSelector(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildViewTabs(),
        ],
      ),
    );
  }

  Widget _buildHistorialSelector(String registro) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Historial:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: UAGRMTheme.textDark)),
        const SizedBox(width: 12),
        Query(
          options: QueryOptions(
            document: gql(getHistoricalPeriodsQuery),
            variables: {'registro': registro},
            fetchPolicy: FetchPolicy.cacheFirst,
          ),
          builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
            final periods = (result.data?['historialPeriodosEstudiante'] as List<dynamic>?) ?? [];
            return DropdownButton<String?>(
              value: selectedPeriodCodigo,
              underline: const SizedBox.shrink(),
              isDense: true,
              hint: const Text('Actual', style: TextStyle(fontSize: 13)),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Actual', style: TextStyle(fontSize: 13))),
                ...periods.map((p) => DropdownMenuItem<String?>(
                  value: p['codigo']?.toString(),
                  child: Text(p['nombre']?.toString() ?? p['codigo']?.toString() ?? '', style: const TextStyle(fontSize: 13)),
                )),
              ],
              onChanged: (val) => setState(() => selectedPeriodCodigo = val),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOpcionesSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Opciones:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: UAGRMTheme.textDark)),
        const SizedBox(width: 12),
        DropdownButton<String?>(
          value: null,
          underline: const SizedBox.shrink(),
          isDense: true,
          hint: const Text('Config', style: TextStyle(fontSize: 13)),
          items: const [
            DropdownMenuItem<String?>(value: 'opt1', child: Text('Descargar', style: TextStyle(fontSize: 13))),
            DropdownMenuItem<String?>(value: 'opt2', child: Text('Compartir', style: TextStyle(fontSize: 13))),
          ],
          onChanged: (val) {},
        ),
      ],
    );
  }

  Widget _buildViewTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabButton('Boleta Normal', !_isGraphicalView),
          _buildTabButton('Boleta Gráfica', _isGraphicalView),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, bool active) {
    return GestureDetector(
      onTap: () => setState(() => _isGraphicalView = title == 'Boleta Gráfica'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? UAGRMTheme.primaryBlue : UAGRMTheme.textGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildTableBoleta(BuildContext context, Map<String, dynamic> data, RegistrationProvider provider, bool isDesktop) {
    if (isDesktop) return _buildWebBoleta(context, data, provider);
    return _buildMobileBoleta(context, data, provider);
  }

  Widget _buildGraphicalBoleta(BuildContext context, Map<String, dynamic> data, RegistrationProvider provider) {
    final materias = data['materiasInscritas'] as List<dynamic>? ?? [];
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('BOLETA GRÁFICA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: UAGRMTheme.textDark)),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.print, size: 18),
                label: const Text('Imprimir'),
                onPressed: () => PdfGenerator.generateAndPrintBoleta(
                  data: data,
                  carreraNombre: provider.selectedCareer?.name ?? '',
                  carreraCodigo: provider.selectedCareer?.code ?? '',
                  isGraphical: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: ScheduleGrid(enrolledSubjects: materias)),
        ],
      ),
    );
  }

  Widget _buildWebBoleta(BuildContext context, Map<String, dynamic> data, RegistrationProvider provider) {
    final estudiante = data['estudiante'] as Map<String, dynamic>? ?? {};
    final materias = data['materiasInscritas'] as List<dynamic>? ?? [];
    final carreraNombre = provider.selectedCareer?.name ?? '';
    final carreraCodigo = provider.selectedCareer?.code ?? '';
    final totalCreditos = materias.fold<int>(0, (sum, item) => sum + ((item['materia']?['creditos'] as int?) ?? 0));

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      const Text('Universidad Autónoma Gabriel René Moreno', style: TextStyle(fontSize: 14, color: Colors.grey, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Text('BOLETA DE INSCRIPCIÓN', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _webInfoField('Registro', estudiante['registro']?.toString() ?? ''),
                      _webInfoField('Estudiante', estudiante['nombreCompleto'] ?? ''),
                      _webInfoField('Carrera', carreraNombre),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildWebTable(materias),
                ),
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _summaryItem(materias.length.toString(), 'Materias'),
                      const SizedBox(width: 40),
                      _summaryItem(totalCreditos.toString(), 'Créditos'),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.print),
                        label: const Text('IMPRIMIR COMPROBANTE'),
                        onPressed: () => PdfGenerator.generateAndPrintBoleta(
                          data: data,
                          carreraNombre: carreraNombre,
                          carreraCodigo: carreraCodigo,
                          isGraphical: false,
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

  Widget _webInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: UAGRMTheme.textDark)),
      ],
    );
  }

  Widget _summaryItem(String value, String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: UAGRMTheme.primaryBlue)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildWebTable(List<dynamic> materias) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(80),
        1: FlexColumnWidth(4),
        2: FixedColumnWidth(60),
        3: FixedColumnWidth(160),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 2))),
          children: ['SIGLA', 'MATERIA', 'GRUPO', 'HORARIO'].map((t) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
          )).toList(),
        ),
        ...materias.map((m) {
          final mat = m['materia'] ?? {};
          final oferta = m['oferta'] ?? {};
          return TableRow(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
            children: [
              Padding(padding: const EdgeInsets.all(12), child: Text(mat['codigo'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: UAGRMTheme.primaryBlue))),
              Padding(padding: const EdgeInsets.all(12), child: Text(mat['nombre'] ?? '')),
              Padding(padding: const EdgeInsets.all(12), child: Text(oferta['grupo'] ?? m['grupo'] ?? '', textAlign: TextAlign.center)),
              Padding(padding: const EdgeInsets.all(12), child: Text(TimeFormatter.formatHorario(oferta['horario'] ?? ''), style: const TextStyle(fontSize: 12, color: UAGRMTheme.textGrey))),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildMobileBoleta(BuildContext context, Map<String, dynamic> data, RegistrationProvider provider) {
    final materias = data['materiasInscritas'] as List<dynamic>? ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: materias.length,
      itemBuilder: (context, index) {
        final m = materias[index];
        final mat = m['materia'] ?? {};
        final oferta = m['oferta'] ?? {};
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(mat['nombre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(mat['codigo'] ?? '', style: const TextStyle(color: UAGRMTheme.primaryBlue, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    const Icon(Icons.group, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Gr: ${oferta['grupo'] ?? m['grupo'] ?? ''}'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(TimeFormatter.formatHorario(oferta['horario'] ?? ''), style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(BuildContext context, String error, VoidCallback? refetch) {
    return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, color: UAGRMTheme.errorRed, size: 48), const SizedBox(height: 16), Text('Error: $error', textAlign: TextAlign.center), const SizedBox(height: 16), ElevatedButton(onPressed: refetch, child: const Text('Reintentar'))])));
  }

  Widget _buildEmpty() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.description_outlined, size: 64, color: Colors.grey), const SizedBox(height: 16), const Text('No hay inscripción registrada', style: TextStyle(fontSize: 16, color: Colors.grey)), const SizedBox(height: 8), TextButton(onPressed: () => Navigator.pop(context), child: const Text('Volver'))]));
  }
}
