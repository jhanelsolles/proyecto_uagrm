import os
import sys
import django
from datetime import date

# Configurar el entorno de Django
sys.path.append('c:\\Users\\HP\\Documents\\proyecto_uagrm\\inscripcion_backend')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from apps.inscripcion.models import EventoCalendario, PeriodoAcademico

def populate():
    # Obtener el periodo actual (o crear uno si no existe)
    periodo, _ = PeriodoAcademico.objects.get_or_create(
        codigo='1-2025',
        defaults={
            'nombre': 'Primer Semestre 2025',
            'fecha_inicio': date(2025, 2, 1),
            'fecha_fin': date(2025, 7, 15),
            'activo': True,
            'inscripciones_habilitadas': True
        }
    )

    events = [
        {
            'titulo': 'Inicio de Clases 1-2025',
            'fecha': date(2025, 2, 17),
            'tipo': 'ACADEMICO',
            'periodo': periodo
        },
        {
            'titulo': 'Periodo de Inscripciones Regulares',
            'fecha': date(2025, 2, 3),
            'tipo': 'INSCRIPCION',
            'periodo': periodo
        },
        {
            'titulo': 'Feriado de Carnaval',
            'fecha': date(2025, 3, 3),
            'tipo': 'FERIADO',
            'periodo': periodo
        },
        {
            'titulo': 'Primer Parcial - Facultad de Ingeniería',
            'fecha': date(2025, 4, 15),
            'tipo': 'EXAMEN',
            'periodo': periodo
        },
        {
            'titulo': 'Vencimiento de Cuota de Pago',
            'fecha': date(2025, 5, 5),
            'tipo': 'ACADEMICO',
            'periodo': periodo
        },
        {
            'titulo': 'Segundo Parcial - General',
            'fecha': date(2025, 5, 20),
            'tipo': 'EXAMEN',
            'periodo': periodo
        },
        {
            'titulo': 'Feriado de Corpus Christi',
            'fecha': date(2025, 6, 19),
            'tipo': 'FERIADO',
            'periodo': periodo
        },
        {
            'titulo': 'Exámenes Finales',
            'fecha': date(2025, 7, 1),
            'tipo': 'EXAMEN',
            'periodo': periodo
        },
        {
            'titulo': 'Cierre de Gestión 1-2025',
            'fecha': date(2025, 7, 15),
            'tipo': 'ACADEMICO',
            'periodo': periodo
        },
    ]

    print(f"Poblando eventos para el periodo {periodo.nombre}...")
    created_count = 0
    for event_data in events:
        obj, created = EventoCalendario.objects.get_or_create(
            titulo=event_data['titulo'],
            fecha=event_data['fecha'],
            defaults={
                'tipo': event_data['tipo'],
                'periodo': event_data['periodo']
            }
        )
        if created:
            created_count += 1
            print(f"Creado: {obj.titulo}")
        else:
            print(f"Ya existe: {obj.titulo}")

    print(f"Proceso finalizado. Se crearon {created_count} nuevos eventos.")

if __name__ == '__main__':
    populate()
