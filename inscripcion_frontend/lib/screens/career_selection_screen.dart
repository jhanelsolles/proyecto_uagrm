import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:inscripcion_frontend/config/theme/app_theme.dart';
import 'package:inscripcion_frontend/models/career.dart';
import 'package:inscripcion_frontend/providers/registration_provider.dart';
import 'package:inscripcion_frontend/widgets/web_layout.dart';

class CareerSelectionScreen extends StatefulWidget {
  const CareerSelectionScreen({super.key});

  @override
  State<CareerSelectionScreen> createState() => _CareerSelectionScreenState();
}

class _CareerSelectionScreenState extends State<CareerSelectionScreen> {
  final String getCareersQuery = """
    query GetCarreras(\$registro: String!) {
      misCarreras(registro: \$registro) {
        carrera {
          codigo
          nombre
          facultad
          duracionSemestres
        }
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrationProvider>();

    return Scaffold(
      backgroundColor: kIsWeb ? const Color(0xFFF4F6F9) : Colors.white,
      appBar: AppBar(
        title: kIsWeb
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school, size: 20),
                  SizedBox(width: 8),
                  Text('Gestión de Inscripción — UAGRM'),
                ],
              )
            : Column(
                children: [
                  const Icon(Icons.school, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    'Gestión de Inscripción',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
        bottom: kIsWeb
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'SELECCIONE CARRERA',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(getCareersQuery),
          variables: {'registro': provider.studentRegister ?? ''},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error al cargar carreras:\n${result.exception.toString()}'),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: refetch, child: const Text('Reintentar')),
                ],
              ),
            );
          }

          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final List carrerasData = result.data?['misCarreras'] ?? [];

          if (kIsWeb) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Seleccionar Carrera',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: UAGRMTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tienes ${carrerasData.length} carrera(s) registrada(s). Elige una para continuar.',
                            style: const TextStyle(fontSize: 13, color: UAGRMTheme.textGrey),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: carrerasData.length,
                        itemBuilder: (context, index) {
                          final career = Career.fromJson(carrerasData[index]['carrera']);
                          return _CareerCard(career: career);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Móvil: lista original
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: carrerasData.length,
            itemBuilder: (context, index) {
              final career = Career.fromJson(carrerasData[index]['carrera']);
              return _CareerCard(career: career);
            },
          );
        },
      ),
    );
  }
}

class _CareerCard extends StatelessWidget {
  final Career career;

  const _CareerCard({required this.career});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrationProvider>();
    final isSelected = provider.selectedCareer?.code == career.code;

    return GestureDetector(
      onTap: () async {
        context.read<RegistrationProvider>().selectCareer(career);
        await Future.delayed(const Duration(milliseconds: 200));
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/panel');
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: kIsWeb ? 10 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kIsWeb ? 8 : 12),
          border: isSelected
              ? Border.all(color: UAGRMTheme.primaryBlue, width: 2)
              : Border.all(color: kIsWeb ? Colors.grey.shade200 : Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: isSelected ? UAGRMTheme.primaryBlue.withOpacity(0.2) : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(kIsWeb ? 14 : 20),
        child: Row(
          children: [
            Container(
              width: kIsWeb ? 40 : 56,
              height: kIsWeb ? 40 : 56,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.book,
                color: UAGRMTheme.primaryBlue,
                size: kIsWeb ? 22 : 30,
              ),
            ),
            SizedBox(width: kIsWeb ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    career.name,
                    style: TextStyle(
                      fontSize: kIsWeb ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: UAGRMTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    career.faculty,
                    style: TextStyle(
                      fontSize: kIsWeb ? 12 : 14,
                      color: UAGRMTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: UAGRMTheme.successGreen, size: 22)
            else
              const Icon(Icons.chevron_right, color: UAGRMTheme.textGrey, size: 18),
          ],
        ),
      ),
    );
  }
}
