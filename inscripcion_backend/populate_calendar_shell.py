from apps.inscripcion.models import EventoCalendario, PeriodoAcademico
from datetime import date

p, _ = PeriodoAcademico.objects.get_or_create(
    codigo='1/2025',
    defaults={
        'nombre': 'Primer Semestre 2025',
        'tipo': '1/2025',
        'fecha_inicio': date(2025, 2, 1),
        'fecha_fin': date(2025, 7, 31),
        'activo': True,
        'inscripciones_habilitadas': True
    }
)

eventos = [
    ('Inicio de actividades académicas - Semestre 1/2025', date(2025, 2, 3), 'ACADEMICO'),
    ('Inscripción estudiantes antiguos', date(2025, 2, 15), 'INSCRIPCION'),
    ('Período de adición de materias', date(2025, 2, 25), 'INSCRIPCION'),
    ('Feriado - Día del Departamento', date(2025, 3, 1), 'FERIADO'),
    ('Período de retiro de materias', date(2025, 3, 10), 'INSCRIPCION'),
    ('Primer examen parcial', date(2025, 4, 14), 'EXAMEN'),
]

for titulo, fecha, tipo in eventos:
    EventoCalendario.objects.get_or_create(
        titulo=titulo,
        fecha=fecha,
        periodo=p,
        defaults={'tipo': tipo}
    )
print("SUCCESS_POPULATED")
