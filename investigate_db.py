import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'inscripcion_backend.settings')
django.setup()

from inscripcion.models import Estudiante, Carrera, EstudianteCarrera, PeriodoAcademico, Bloqueo

print("=== ESTUDIANTES ===")
for est in Estudiante.objects.all():
    print(f"  Registro: {est.registro} | Nombre: {est.nombre_completo}")

print("\n=== CARRERAS ===")
for c in Carrera.objects.all():
    print(f"  {c.codigo} - {c.nombre}")

print("\n=== ESTUDIANTE-CARRERA ===")
for ec in EstudianteCarrera.objects.select_related('estudiante', 'carrera').all():
    print(f"  {ec.estudiante.registro} -> {ec.carrera.codigo} | Semestre {ec.semestre_actual} | Activa: {ec.activa}")

print("\n=== PERIODOS ===")
for p in PeriodoAcademico.objects.all():
    print(f"  {p.codigo} - {p.nombre} | Activo: {p.activo}")

print("\n=== BLOQUEOS ===")
for b in Bloqueo.objects.all():
    print(f"  {b.estudiante_carrera.estudiante.registro} | Motivo: {b.motivo} | Activo: {b.activo}")

print("\n=== OK - Todos los datos cargados correctamente ===")
