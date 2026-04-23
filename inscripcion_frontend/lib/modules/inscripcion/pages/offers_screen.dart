import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inscripcion_frontend/config/theme/app_theme.dart';
import 'package:inscripcion_frontend/modules/inscripcion/widgets/main_layout.dart';
import 'package:provider/provider.dart';
import 'package:inscripcion_frontend/modules/inscripcion/services/registration_provider.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  String _searchQuery = "";
  int? _selectedLevel;

  final String getOffersQuery = """
    query GetOffers(\$carrera: String) {
      ofertasMateria(codigoCarrera: \$carrera) {
        id
        materiaCodigo
        materiaNombre
        semestre
        grupo
        turnoDisplay
        docente
        horario
        cuposDisponibles
        cupoActual
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrationProvider>();
    final careerCode = provider.selectedCareer?.code;

    return MainLayout(
      currentRoute: '/offers',
      title: 'Maestro de Ofertas',
      subtitle: 'Panel › Consulta de Ofertas Académicas',
      child: Query(
        options: QueryOptions(
          document: gql(getOffersQuery),
          variables: {'carrera': careerCode},
        ),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isLoading) return const Center(child: CircularProgressIndicator());
          if (result.hasException) return Center(child: Text('Error: ${result.exception.toString()}'));

          List offers = result.data?['ofertasMateria'] ?? [];
          
          // Aplicar filtros locales
          var filteredOffers = offers.where((o) {
            final matchesSearch = o['materiaNombre'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                 o['materiaCodigo'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesLevel = _selectedLevel == null || o['semestre'] == _selectedLevel;
            return matchesSearch && matchesLevel;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(provider.selectedCareer?.name ?? ''),
                const SizedBox(height: 24),
                _buildFilters(),
                const SizedBox(height: 24),
                Expanded(
                  child: Card(
                    elevation: 4,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: _buildTable(filteredOffers),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String careerName) {
    return Row(
      children: [
        const Icon(Icons.grid_view_outlined, color: UAGRMTheme.primaryBlue, size: 28),
        const SizedBox(width: 12),
        Text(
          'Maestro de Ofertas - $careerName',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: UAGRMTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Buscar por sigla o nombre...',
              prefixIcon: const Icon(Icons.search, size: 20),
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<int?>(
            initialValue: _selectedLevel,
            decoration: InputDecoration(
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            hint: const Text('Nivel'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos los niveles')),
              ...List.generate(10, (index) => index + 1).map((lvl) => 
                DropdownMenuItem(value: lvl, child: Text('Nivel $lvl'))
              ),
            ],
            onChanged: (val) => setState(() => _selectedLevel = val),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(List offers) {
    if (offers.isEmpty) return const Center(child: Text('No se encontraron ofertas.'));

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              horizontalMargin: 12,
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('Sigla')),
                DataColumn(label: Text('Materia')),
                DataColumn(label: Text('Nivel')),
                DataColumn(label: Text('Grupo')),
                DataColumn(label: Text('Turno')),
                DataColumn(label: Text('Docente')),
                DataColumn(label: Text('Horario')),
                DataColumn(label: Text('Cupos')),
                DataColumn(label: Text('Inscritos')),
              ],
              rows: offers.map<DataRow>((o) {
                return DataRow(cells: [
                  DataCell(Text(o['materiaCodigo'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                  DataCell(Text(o['materiaNombre'], style: const TextStyle(fontSize: 12))),
                  DataCell(Center(child: _buildCircleBadge(o['semestre'].toString()))),
                  DataCell(Text(o['grupo'], style: const TextStyle(fontSize: 12))),
                  DataCell(_buildTurnBadge(o['turnoDisplay'])),
                  DataCell(Text(o['docente'], style: const TextStyle(fontSize: 12))),
                  DataCell(Text(o['horario'], style: const TextStyle(fontSize: 11, color: Colors.grey))),
                  DataCell(Text(
                    o['cuposDisponibles'].toString(), 
                    style: TextStyle(
                      color: o['cuposDisponibles'] <= 5 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold
                    )
                  )),
                  DataCell(Text(o['cupoActual'].toString())),
                ]);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircleBadge(String text) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(child: Text(text, style: const TextStyle(fontSize: 10))),
    );
  }

  Widget _buildTurnBadge(String turn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        turn, 
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
      ),
    );
  }
}
