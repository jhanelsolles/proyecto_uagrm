import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:inscripcion_frontend/shared/utils/time_formatter.dart';

class _ScheduleEvent {
  final String codigo;
  final String grupo;
  final String colorHex;
  _ScheduleEvent(this.codigo, this.grupo, this.colorHex);
}

class PdfGenerator {
  static Future<void> generateAndPrintBoleta({
    required Map<String, dynamic> data,
    required String carreraNombre,
    required String carreraCodigo,
    bool isGraphical = false,
  }) async {
    final pdf = pw.Document();

    final estudiante = data['estudiante'] as Map<String, dynamic>? ?? {};
    final periodo = data['periodoAcademico'] as Map<String, dynamic>? ?? {};
    final materias = data['materiasInscritas'] as List<dynamic>? ?? [];

    final nombrePeriodo = periodo['nombre'] ?? periodo['codigo'] ?? '1/2026';
    final totalCreditos = materias.fold<int>(
        0, (sum, item) => sum + ((item['materia']?['creditos'] as int?) ?? 0));

    // Añadir página con el formato A4
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(nombrePeriodo),
            pw.SizedBox(height: 24),
            _buildStudentInfo(estudiante, carreraNombre, carreraCodigo),
            pw.SizedBox(height: 24),
            isGraphical ? _buildGraphicalTable(materias) : _buildNormalTable(materias),
            pw.SizedBox(height: 24),
            _buildSummary(materias.length, totalCreditos),
          ];
        },
      ),
    );

    // Intentar mostrar o descargar el PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Boleta_Inscripcion_${estudiante['registro'] ?? 'Alumno'}.pdf',
    );
  }

  static pw.Widget _buildHeader(String nombrePeriodo) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#004b87'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Center(
        child: pw.Text(
          'BOLETA DE INSCRIPCIÓN - $nombrePeriodo',
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildStudentInfo(
      Map<String, dynamic> estudiante, String carreraNombre, String carreraCodigo) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoItem('REGISTRO', estudiante['registro']?.toString() ?? ''),
          _buildInfoItem('NOMBRE', estudiante['nombreCompleto'] ?? ''),
          _buildInfoItem('CARRERA', '$carreraCodigo $carreraNombre'),
          _buildInfoItem('LUGAR', 'SANTA CRUZ'),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9,
            color: PdfColors.grey600,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
      ],
    );
  }

  static final List<String> _subjectColors = [
    '#10B981', '#3B82F6', '#F43F5E', '#8B5CF6', '#F59E0B', '#14B8A6', '#6366F1', '#D946EF'
  ];

  static pw.Widget _buildGraphicalTable(List<dynamic> materias) {
    if (materias.isEmpty) {
      return pw.Center(
        child: pw.Text(
          'No hay materias inscritas',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
        ),
      );
    }

    // 1. Inicializar la matriz de 15 horas (07:00 a 21:00) x 6 días (Lunes a Sábado)
    final grid = List.generate(15, (_) => List<_ScheduleEvent?>.filled(6, null));

    // 2. Llenar la matriz
    for (int i = 0; i < materias.length; i++) {
      final item = materias[i];
      final materia = item['materia'] as Map<String, dynamic>? ?? {};
      final oferta = item['oferta'] as Map<String, dynamic>? ?? {};
      
      final codigo = materia['codigo']?.toString() ?? '';
      final grupo = oferta['grupo'] ?? item['grupo']?.toString() ?? '';
      final horarioStr = oferta['horario']?.toString() ?? '';
      final colorHex = _subjectColors[i % _subjectColors.length];
      
      final slots = ScheduleValidator.parseScheduleString(horarioStr);
      final event = _ScheduleEvent(codigo, grupo, colorHex);

      for (final slot in slots) {
        final col = slot.dayIndex - 1; // 0 para Lunes
        if (col < 0 || col > 5) continue;

        // Horas de 7 a 21
        for (int row = 0; row < 15; row++) {
          final rowHoraInicio = (7 + row) * 60;
          final rowHoraFin = rowHoraInicio + 60;

          // Si el slot choca con la hora de esta fila, se lo asignamos
          if (rowHoraInicio < slot.endMinutes && rowHoraFin > slot.startMinutes) {
            grid[row][col] = event;
          }
        }
      }
    }

    final headers = ['HORA', 'LUNES', 'MARTES', 'MIÉR', 'JUEV', 'VIER', 'SÁB'];
    final tableRows = <pw.TableRow>[];

    // Cabecera
    tableRows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColor.fromHex('#003366')), // Azul UAGRM
        children: headers.map((h) => pw.Container(
          height: 25,
          alignment: pw.Alignment.center,
          child: pw.Text(
            h, 
            style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9),
            textAlign: pw.TextAlign.center,
          ),
        )).toList(),
      )
    );

    // Filas de cuadrícula
    for (int row = 0; row < 15; row++) {
      final hourStr = '${(7 + row).toString().padLeft(2, '0')}:00';
      
      final rowChildren = <pw.Widget>[
        // Columna de hora
        pw.Container(
          height: 35,
          alignment: pw.Alignment.topCenter,
          padding: const pw.EdgeInsets.only(top: 4, right: 4),
          decoration: const pw.BoxDecoration(
            border: pw.Border(right: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
          ),
          child: pw.Text(hourStr, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        ),
      ];

      for (int col = 0; col < 6; col++) {
        final ev = grid[row][col];
        
        if (ev == null) {
          // Celda vacía
          rowChildren.add(pw.Container(
            height: 35,
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                right: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
              ),
            ),
          ));
        } else {
          // Celda con materia
          final isContinuation = (row > 0 && grid[row - 1][col]?.codigo == ev.codigo);
          final isLast = (row == 14 || grid[row + 1][col]?.codigo != ev.codigo);

          rowChildren.add(pw.Container(
            height: 35,
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                right: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
              ),
            ),
            child: pw.Container(
              margin: const pw.EdgeInsets.symmetric(horizontal: 2),
              decoration: pw.BoxDecoration(
                 color: PdfColor.fromHex(ev.colorHex),
                 borderRadius: pw.BorderRadius.only(
                     topLeft: isContinuation ? pw.Radius.zero : const pw.Radius.circular(4),
                     topRight: isContinuation ? pw.Radius.zero : const pw.Radius.circular(4),
                     bottomLeft: isLast ? const pw.Radius.circular(4) : pw.Radius.zero,
                     bottomRight: isLast ? const pw.Radius.circular(4) : pw.Radius.zero,
                 )
              ),
              padding: const pw.EdgeInsets.all(4),
              child: isContinuation 
                 ? pw.SizedBox() // Vacio para simular rowspan
                 : pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(ev.codigo, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.white)),
                      pw.Text('Gr: ${ev.grupo}', style: pw.TextStyle(fontSize: 7, color: PdfColors.white)),
                    ],
                 ),
            ),
          ));
        }
      }
      tableRows.add(pw.TableRow(children: rowChildren));
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.ClipRRect(
        horizontalRadius: 6,
        verticalRadius: 6,
        child: pw.Table(
          columnWidths: {
            0: const pw.FixedColumnWidth(35), // Hora
            1: const pw.FlexColumnWidth(),
            2: const pw.FlexColumnWidth(),
            3: const pw.FlexColumnWidth(),
            4: const pw.FlexColumnWidth(),
            5: const pw.FlexColumnWidth(),
            6: const pw.FlexColumnWidth(),
          },
          children: tableRows,
        ),
      ),
    );
  }

  static pw.Widget _buildNormalTable(List<dynamic> materias) {
    if (materias.isEmpty) {
      return pw.Center(
        child: pw.Text(
          'No hay materias inscritas',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
        ),
      );
    }

    final headers = [
      'SIGLA',
      'GRUPO',
      'NOMBRE MATERIA',
      'CRÉD',
      'SEM',
      'HORARIO',
      'MODALIDAD'
    ];

    final data = materias.map((item) {
      final materia = item['materia'] as Map<String, dynamic>? ?? {};
      final oferta = item['oferta'] as Map<String, dynamic>? ?? {};
      return [
        materia['codigo']?.toString() ?? '',
        oferta['grupo'] ?? item['grupo']?.toString() ?? '',
        materia['nombre']?.toString() ?? '',
        materia['creditos']?.toString() ?? '',
        oferta['semestre']?.toString() ?? '0',
        TimeFormatter.formatHorario(oferta['horario']?.toString() ?? ''),
        'PRESENCIAL',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#004b87')),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.centerLeft,
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      columnWidths: {
        0: const pw.FixedColumnWidth(55),
        1: const pw.FixedColumnWidth(50),
        2: const pw.FlexColumnWidth(3),
        3: const pw.FixedColumnWidth(45),
        4: const pw.FixedColumnWidth(30),
        5: const pw.FlexColumnWidth(2),
        6: const pw.FixedColumnWidth(85),
      },
    );
  }

  static pw.Widget _buildSummary(int totalMaterias, int totalCreditos) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryData('Materias inscritas', totalMaterias.toString()),
          _buildSummaryData('Créditos totales', totalCreditos.toString()),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryData(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#004b87'),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }
}
