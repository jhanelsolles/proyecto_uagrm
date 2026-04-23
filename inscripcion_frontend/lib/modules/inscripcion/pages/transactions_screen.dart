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
                          style: GoogleFonts.outfit(
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
                              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                              horizontalMargin: 12,
                              columnSpacing: 24,
                              columns: const [
                                DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Proceso', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Período', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Vía', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Materias', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
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
                                  DataCell(_buildProcessBadge(tx['tipoProcesoDisplay'])),
                                  DataCell(Text(tx['periodoAcademico']['codigo'], style: const TextStyle(fontSize: 13))),
                                  DataCell(_buildViaBadge(tx['viaDisplay'])),
                                  DataCell(
                                    Tooltip(
                                      message: materiasCodes,
                                      child: Text(
                                        materiasCodes, 
                                        style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold)
                                      ),
                                    )
                                  ),
                                  DataCell(_buildStatusBadge(tx['estado'])),
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

  Widget _buildProcessBadge(String process) {
    Color color;
    switch (process.toUpperCase()) {
      case 'INSCRIPCIÓN': color = const Color(0xFF1E293B); break;
      case 'ADICIÓN': color = const Color(0xFF0369A1); break;
      case 'RETIRO': color = const Color(0xFF0D9488); break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(process, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildViaBadge(String via) {
    bool isWeb = via.toUpperCase() == 'WEB';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isWeb ? const Color(0xFF1E293B) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        via, 
        style: TextStyle(
          color: isWeb ? Colors.white : Colors.black87, 
          fontSize: 11, 
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isConfirmed = status.toUpperCase() == 'CONFIRMADA';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: isConfirmed ? const Color(0xFF22C55E) : Colors.orange),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isConfirmed ? 'Confirmado' : status,
        style: TextStyle(
          color: isConfirmed ? const Color(0xFF15803D) : Colors.orange.shade800,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
