from django.db import models
from .periodo import PeriodoAcademico


class EventoCalendario(models.Model):
    """Eventos del Calendario Académico"""
    TIPO_EVENTO_CHOICES = [
        ('ACADEMICO', 'Académico'),
        ('INSCRIPCION', 'Inscripción'),
        ('FERIADO', 'Feriado'),
        ('EXAMEN', 'Examen'),
    ]

    titulo = models.CharField(max_length=200, verbose_name="Título del Evento")
    fecha = models.DateField(verbose_name="Fecha del Evento")
    tipo = models.CharField(
        max_length=20, 
        choices=TIPO_EVENTO_CHOICES, 
        default='ACADEMICO',
        verbose_name="Tipo de Evento"
    )
    periodo = models.ForeignKey(
        PeriodoAcademico, 
        on_delete=models.CASCADE, 
        related_name='eventos',
        verbose_name="Periodo Académico"
    )

    class Meta:
        verbose_name = "Evento de Calendario"
        verbose_name_plural = "Eventos de Calendario"
        ordering = ['fecha']

    def __str__(self):
        return f"{self.fecha} - {self.titulo} ({self.get_tipo_display()})"
