import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inscripcion_frontend/config/theme/app_theme.dart';
import 'package:inscripcion_frontend/modules/inscripcion/widgets/main_layout.dart';
import 'package:provider/provider.dart';
import 'package:inscripcion_frontend/modules/inscripcion/services/registration_provider.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  final String getTransactionsQuery = """
    query GetTransactions(\$registro: String!) {
      misTransacciones(registro: \$registro) {
        id
        fechaInscripcionRealizada
        tipoProcesoDisplay
        periodoAcademico {
          codigo
        }
        viaDisplay
        estado
        materiasInscritas {
          oferta {
            materiaCarrera {
              materia {
                codigo
              }
            }
          }
          materia {
            codigo
          }
        }
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrationProvider>();
    final studentRegister = provider.studentRegister;

    return MainLayout(
      currentRoute: '/transactions',
      title: 'Transacciones',
      subtitle: 'Panel › Historial de Transacciones',
      child: Query(
        options: QueryOptions(
          document: gql(getTransactionsQuery),
          variables: {'registro': studentRegister},
        ),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isLoading) return const Center(child: CircularProgressIndicator());
          if (result.hasException) return Center(child: Text('Error: ${result.exception.toString()}'));

          final isDark = Theme.of(context).brightness == Brightness.dark;
          final transactions = result.data?['misTransacciones'] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_outlined, color: UAGRMTheme.primaryBlue),
                        const SizedBox(width: 12),
                        Text(
                          'Transacciones Realizadas',
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
                      ],
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: constraints.maxWidth),
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.white.withValues(alpha: 0.05) 
                                  : const Color(0xFFF8FAFC)
                              ),
                              horizontalMargin: 12,
                              columnSpacing: 24,
                                columns: [
                                  DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Theme.of(context).textTheme.titleSmall?.color : null))),
                                  DataColumn(label: Text('Proceso', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Theme.of(context).textTheme.titleSmall?.color : null))),
                                  DataColumn(label: Text('Período', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Theme.of(context).textTheme.titleSmall?.color : null))),
                                  DataColumn(label: Text('Vía', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Theme.of(context).textTheme.titleSmall?.color : null))),
                                  DataColumn(label: Text('Materias', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Theme.of(context).textTheme.titleSmall?.color : null))),
                                  DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Theme.of(context).textTheme.titleSmall?.color : null))),
                                ],
                              rows: transactions.map<DataRow>((tx) {
                                final dateStr = tx['fechaInscripcionRealizada'] != null 
                                    ? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(tx['fechaInscripcionRealizada']))
                                    : 'N/A';
                                
                                final materias = tx['materiasInscritas'] as List;
                                final materiasCodes = materias.map((m) {
                                  return m['oferta']?['materiaCarrera']?['materia']?['codigo'] ?? m['materia']?['codigo'] ?? '';
                                }).join('  ');

                                return DataRow(cells: [
                                  DataCell(Text(dateStr, style: const TextStyle(fontSize: 13))),
                                  DataCell(_buildProcessBadge(context, tx['tipoProcesoDisplay'])),
                                  DataCell(Text(tx['periodoAcademico']['codigo'], style: const TextStyle(fontSize: 13))),
                                  DataCell(_buildViaBadge(context, tx['viaDisplay'])),
                                  DataCell(
                                    Tooltip(
                                      message: materiasCodes,
                                      child: Text(
                                        materiasCodes, 
                                        style: TextStyle(
                                          fontSize: 11, 
                                          color: Theme.of(context).brightness == Brightness.dark ? UAGRMTheme.accentCyan : Colors.blueGrey, 
                                          fontWeight: FontWeight.bold
                                        )
                                      ),
                                    )
                                  ),
                                  DataCell(_buildStatusBadge(context, tx['estado'])),
                                ]);
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProcessBadge(BuildContext context, String process) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color color;
    switch (process.toUpperCase()) {
      case 'INSCRIPCIÓN': color = isDark ? const Color(0xFF0EA5E9) : const Color(0xFF1E293B); break;
      case 'ADICIÓN': color = isDark ? const Color(0xFF10B981) : const Color(0xFF0369A1); break;
      case 'RETIRO': color = isDark ? const Color(0xFFF43F5E) : const Color(0xFF0D9488); break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color, 
        borderRadius: BorderRadius.circular(20)
      ),
      child: Text(
        process, 
        style: const TextStyle(
          color: Colors.white, 
          fontSize: 11, 
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _buildViaBadge(BuildContext context, String via) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isWeb = via.toUpperCase() == 'WEB';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isWeb 
            ? (isDark ? UAGRMTheme.accentCyan.withValues(alpha: 0.1) : const Color(0xFF1E293B)) 
            : (isDark ? Colors.white10 : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(20),
        border: isWeb && isDark ? Border.all(color: UAGRMTheme.accentCyan.withValues(alpha: 0.3)) : null,
      ),
      child: Text(
        via, 
        style: TextStyle(
          color: isWeb ? (isDark ? UAGRMTheme.accentCyan : Colors.white) : (isDark ? Colors.white70 : Colors.black87), 
          fontSize: 11, 
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isConfirmed = status.toUpperCase() == 'CONFIRMADA';
    Color baseColor = isConfirmed ? const Color(0xFF22C55E) : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1),
        border: Border.all(color: baseColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isConfirmed ? 'Confirmado' : status,
        style: TextStyle(
          color: isDark ? baseColor : (isConfirmed ? const Color(0xFF15803D) : Colors.orange.shade800),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
