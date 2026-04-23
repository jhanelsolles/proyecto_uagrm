from apps.inscripcion.models import EventoCalendario, PeriodoAcademico
from datetime import date

def populate():
    periodo, _ = PeriodoAcademico.objects.get_or_create(
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
        evento, created = EventoCalendario.objects.get_or_create(
            titulo=titulo,
            fecha=fecha,
            periodo=periodo,
            defaults={'tipo': tipo}
        )
        if created:
            print(f"Evento creado: {titulo}")
        else:
            print(f"Evento ya existe: {titulo}")

if __name__ == "__main__":
    populate()
