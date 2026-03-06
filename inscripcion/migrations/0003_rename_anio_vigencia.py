from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('inscripcion', '0002_alter_planestudios_options'),
    ]

    operations = [
        # La columna en la BD se llama "año_vigencia" (con ñ), pero el modelo
        # usa "anio_vigencia". SQLite soporta ALTER TABLE RENAME COLUMN desde 3.25.
        migrations.RunSQL(
            sql='ALTER TABLE inscripcion_planestudios RENAME COLUMN "a\u00f1o_vigencia" TO "anio_vigencia"',
            reverse_sql='ALTER TABLE inscripcion_planestudios RENAME COLUMN "anio_vigencia" TO "a\u00f1o_vigencia"',
        ),
    ]

