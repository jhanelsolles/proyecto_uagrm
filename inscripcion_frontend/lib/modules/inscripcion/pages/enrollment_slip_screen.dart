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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? (Theme.of(context).cardTheme.color ?? const Color(0xFF1E293B)) : Colors.white;

    if (isDesktop) {
      return Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            _buildHistorialSelector(registro, isDark),
            const Spacer(),
            _buildViewTabs(isDark),
          ],
        ),
      );
    }

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildHistorialSelector(registro, isDark),
                const SizedBox(width: 16),
                _buildOpcionesSelector(isDark),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildViewTabs(isDark),
        ],
      ),
    );
  }

  Widget _buildHistorialSelector(String registro, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Historial:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white70 : UAGRMTheme.textDark)),
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
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              isDense: true,
              hint: Text('Actual', style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black)),
              items: [
                DropdownMenuItem<String?>(value: null, child: Text('Actual', style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black))),
                ...periods.map((p) => DropdownMenuItem<String?>(
                  value: p['codigo']?.toString(),
                  child: Text(p['nombre']?.toString() ?? p['codigo']?.toString() ?? '', style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black)),
                )),
              ],
              onChanged: (val) => setState(() => selectedPeriodCodigo = val),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOpcionesSelector(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Opciones:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white70 : UAGRMTheme.textDark)),
        const SizedBox(width: 12),
        DropdownButton<String?>(
          value: null,
          underline: const SizedBox.shrink(),
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          isDense: true,
          hint: Text('Config', style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black)),
          items: [
            DropdownMenuItem<String?>(value: 'opt1', child: Text('Descargar', style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black))),
            DropdownMenuItem<String?>(value: 'opt2', child: Text('Compartir', style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black))),
          ],
          onChanged: (val) {},
        ),
      ],
    );
  }

  Widget _buildViewTabs(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabButton('Boleta Normal', !_isGraphicalView, isDark),
          _buildTabButton('Boleta Gráfica', _isGraphicalView, isDark),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, bool active, bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _isGraphicalView = title == 'Boleta Gráfica'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? (isDark ? UAGRMTheme.primaryBlue : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)] : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? (isDark ? Colors.white : UAGRMTheme.primaryBlue) : (isDark ? Colors.white54 : UAGRMTheme.textGrey),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('BOLETA GRÁFICA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? UAGRMTheme.accentCyan : UAGRMTheme.textDark)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Theme.of(context).cardTheme.color : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), 
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Text('Universidad Autónoma Gabriel René Moreno', style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey, letterSpacing: 0.5, fontFamily: isDark ? GoogleFonts.outfit().fontFamily : null)),
                      const SizedBox(height: 12),
                      Text('BOLETA DE INSCRIPCIÓN', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2, color: isDark ? Colors.white : UAGRMTheme.textDark)),
                      if (isDark) Container(margin: const EdgeInsets.only(top: 8), width: 80, height: 3, decoration: BoxDecoration(color: UAGRMTheme.accentCyan, borderRadius: BorderRadius.circular(2))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _webInfoField('Registro', estudiante['registro']?.toString() ?? '', isDark),
                      _webInfoField('Estudiante', estudiante['nombreCompleto'] ?? '', isDark),
                      _webInfoField('Carrera', carreraNombre, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildWebTable(materias, isDark),
                ),
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _summaryItem(materias.length.toString(), 'Materias', isDark),
                      const SizedBox(width: 48),
                      _summaryItem(totalCreditos.toString(), 'Créditos', isDark),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UAGRMTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.print),
                        label: const Text('IMPRIMIR COMPROBANTE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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

  Widget _webInfoField(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? UAGRMTheme.accentCyan : Colors.grey, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : UAGRMTheme.textDark, fontFamily: isDark ? GoogleFonts.outfit().fontFamily : null)),
      ],
    );
  }

  Widget _summaryItem(String value, String label, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? UAGRMTheme.accentCyan : UAGRMTheme.primaryBlue)),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey)),
      ],
    );
  }

  Widget _buildWebTable(List<dynamic> materias, bool isDark) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(100), // SIGLA aumentado para evitar desbordamiento
        1: FlexColumnWidth(4),
        2: FixedColumnWidth(70),
        3: FixedColumnWidth(180),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0), width: 2))),
          children: ['SIGLA', 'MATERIA', 'GRUPO', 'HORARIO'].map((t) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Text(t, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? Colors.white38 : Colors.grey, letterSpacing: 1)),
          )).toList(),
        ),
        ...materias.map((m) {
          final mat = m['materia'] ?? {};
          final oferta = m['oferta'] ?? {};
          return TableRow(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF1F5F9)))),
            children: [
              Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: Text(mat['codigo'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? UAGRMTheme.accentCyan : UAGRMTheme.primaryBlue, fontFamily: isDark ? GoogleFonts.firaCode().fontFamily : null, fontSize: 13))),
              Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: Text(mat['nombre'] ?? '', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13, fontFamily: isDark ? GoogleFonts.outfit().fontFamily : null))),
              Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: Text(oferta['grupo'] ?? m['grupo'] ?? '', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87))),
              Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: Text(TimeFormatter.formatHorario(oferta['horario'] ?? ''), style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : UAGRMTheme.textGrey))),
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
