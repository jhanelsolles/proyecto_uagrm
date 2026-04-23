import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inscripcion_frontend/config/theme/app_theme.dart';
import 'package:inscripcion_frontend/modules/inscripcion/widgets/main_layout.dart';
import 'package:provider/provider.dart';
import 'package:inscripcion_frontend/modules/inscripcion/services/registration_provider.dart';
import 'package:inscripcion_frontend/shared/utils/responsive_helper.dart';

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
            padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 24),
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
        Expanded(
          child: Text(
            'Maestro de Ofertas - $careerName',
            style: GoogleFonts.outfit(
              fontSize: Responsive.isMobile(context) ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: UAGRMTheme.textDark,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final isMobile = Responsive.isMobile(context);
    
    if (isMobile) {
      return Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: 'Buscar por sigla o nombre...',
              hintStyle: TextStyle(color: Theme.of(context).hintColor),
              prefixIcon: Icon(Icons.search, size: 20, color: Theme.of(context).primaryColor),
              filled: true,
              fillColor: Theme.of(context).cardTheme.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            initialValue: _selectedLevel,
            dropdownColor: Theme.of(context).cardTheme.color,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).cardTheme.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            hint: Text('Nivel / Semestre', style: TextStyle(color: Theme.of(context).hintColor)),
            items: [
              DropdownMenuItem(value: null, child: Text('Todos los niveles', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color))),
              ...List.generate(10, (index) => index + 1).map((lvl) => 
                DropdownMenuItem(value: lvl, child: Text('Nivel $lvl', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)))
              ),
            ],
            onChanged: (val) => setState(() => _selectedLevel = val),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: 'Buscar por sigla o nombre...',
              hintStyle: TextStyle(color: Theme.of(context).hintColor),
              prefixIcon: Icon(Icons.search, size: 20, color: Theme.of(context).primaryColor),
              filled: true,
              fillColor: Theme.of(context).cardTheme.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<int?>(
            initialValue: _selectedLevel,
            dropdownColor: Theme.of(context).cardTheme.color,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).cardTheme.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
            ),
            hint: Text('Nivel', style: TextStyle(color: Theme.of(context).hintColor)),
            items: [
              DropdownMenuItem(value: null, child: Text('Todos los niveles', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color))),
              ...List.generate(10, (index) => index + 1).map((lvl) => 
                DropdownMenuItem(value: lvl, child: Text('Nivel $lvl', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)))
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
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC)),
              horizontalMargin: 12,
              columnSpacing: 20,
              columns: [
                DataColumn(label: Text('Sigla', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleSmall?.color))),
                DataColumn(label: Text('Materia', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleSmall?.color))),
                DataColumn(label: Text('Nivel', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleSmall?.color))),
                DataColumn(label: Text('Grupo', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleSmall?.color))),
                DataColumn(label: Text('Turno', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleSmall?.color))),
                DataColumn(label: Text('Docente', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleSmall?.color))),
                DataColumn(label: Text('Horario', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleSmall?.color))),
                DataColumn(label: Text('Cupos', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleSmall?.color))),
                DataColumn(label: Text('Inscritos', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleSmall?.color))),
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
