import 'package:flutter/material.dart';
import 'package:inscripcion_frontend/shared/utils/time_formatter.dart';
import 'package:inscripcion_frontend/config/theme/app_theme.dart';

class ScheduleGrid extends StatelessWidget {
  final List<dynamic> enrolledSubjects;

  const ScheduleGrid({super.key, required this.enrolledSubjects});

  @override
  Widget build(BuildContext context) {
    const startHour = 7;
    const endHour = 22;
    const totalHours = endHour - startHour;
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    const rowHeight = 55.0; // Un poco más compacto
    const hourColumnWidth = 70.0;

    final List<List<Color>> subjectGradients = [
      [const Color(0xFF059669), const Color(0xFF10B981)], // Verde vibrante
      [const Color(0xFF2563EB), const Color(0xFF3B82F6)], // Azul
      [const Color(0xFFE11D48), const Color(0xFFF43F5E)], // Rose/Rojo
      [const Color(0xFF7C3AED), const Color(0xFF8B5CF6)], // Púrpura
      [const Color(0xFFD97706), const Color(0xFFF59E0B)], // Naranja
      [const Color(0xFF0D9488), const Color(0xFF14B8A6)], // Teal
      [const Color(0xFF4F46E5), const Color(0xFF6366F1)], // Indigo
      [const Color(0xFFC026D3), const Color(0xFFD946EF)], // Fuchsia
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final dayWidth = (constraints.maxWidth - hourColumnWidth) / 6;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              // Cabecera
              Container(
                decoration: const BoxDecoration(
                  color: UAGRMTheme.primaryBlue,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: hourColumnWidth,
                      height: 50,
                      child: Center(
                        child: Text('HORA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white70, letterSpacing: 1)),
                      ),
                    ),
                    ...days.map((day) => Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border(left: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                            ),
                            child: Center(child: Text(day.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white))),
                          ),
                        )),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.transparent),

              // Grid Contenido
              Expanded(
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: totalHours * rowHeight,
                    child: Stack(
                      children: [
                        // Fondo Cuadrícula
                        Column(
                          children: List.generate(totalHours, (index) {
                            final hour = startHour + index;
                            return SizedBox(
                              height: rowHeight,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: hourColumnWidth,
                                    child: Center(
                                      child: Text(
                                        '${hour.toString().padLeft(2, '0')}:00',
                                        style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                  ...List.generate(6, (dayIndex) => Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: BorderSide(color: Colors.grey.shade100),
                                              bottom: BorderSide(color: Colors.grey.shade100),
                                            ),
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            );
                          }),
                        ),

                        // Bloques de materias
                        ..._buildBlocks(enrolledSubjects, startHour, rowHeight, hourColumnWidth, dayWidth, subjectGradients),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildBlocks(
    List<dynamic> subjects,
    int startHour,
    double rowHeight,
    double hourColumnWidth,
    double dayWidth,
    List<List<Color>> gradients,
  ) {
    final List<Widget> blocks = [];

    for (int i = 0; i < subjects.length; i++) {
      final item = subjects[i];
      final materia = item['materia'] as Map<String, dynamic>;
      final oferta = item['oferta'] as Map<String, dynamic>;
      final gradientColors = gradients[i % gradients.length];

      final scheduleStr = oferta['horario']?.toString() ?? '';
      final slots = ScheduleValidator.parseScheduleString(scheduleStr);

      for (final slot in slots) {
        final dayOffset = slot.dayIndex - 1;
        if (dayOffset < 0 || dayOffset > 5) continue;

        final startMinutesFromBase = slot.startMinutes - (startHour * 60);
        final durationMinutes = slot.endMinutes - slot.startMinutes;

        if (startMinutesFromBase < 0) continue;

        final top = (startMinutesFromBase / 60.0) * rowHeight;
        final height = (durationMinutes / 60.0) * rowHeight;

        blocks.add(
          Positioned(
            top: top,
            left: hourColumnWidth + (dayOffset * dayWidth),
            width: dayWidth,
            height: height,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: gradientColors[0].withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 3)),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(
                      Icons.menu_book,
                      size: 40,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          materia['codigo'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Gr: ${oferta['grupo'] ?? item['grupo'] ?? ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return blocks;
  }
}
