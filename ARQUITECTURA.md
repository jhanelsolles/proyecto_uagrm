# 🏗️ ARQUITECTURA DEL SISTEMA

## 📐 Diagrama de Arquitectura

```text
┌─────────────────────────────────────────────────────────────┐
│                        FRONTEND                              │
│                  (Otra máquina/localhost)                    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Componentes React/Vue/Angular                      │    │
│  │  - Dashboard Estudiante                             │    │
│  │  - Módulo de Inscripción                            │    │
│  │  - Consulta de Materias                             │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ HTTP/GraphQL
                            │ (CORS Habilitado)
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    DOCKER NETWORK                            │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              DJANGO BACKEND                           │  │
│  │         (Container: inscripcion_backend)              │  │
│  │                                                       │  │
│  │  ┌─────────────────────────────────────────────┐    │  │
│  │  │         GraphQL API (Graphene)               │    │  │
│  │  │  - Query: todasCarreras                      │    │  │
│  │  │  - Query: perfilEstudiante                   │    │  │
│  │  │  - Query: materiasHabilitadas                │    │  │
│  │  │  - Query: inscripcionCompleta                │    │  │
│  │  │  - ... (14 queries totales)                  │    │  │
│  │  └─────────────────────────────────────────────┘    │  │
│  │                      │                                │  │
│  │                      │ ORM (Django Models)            │  │
│  │                      ▼                                │  │
│  │  ┌─────────────────────────────────────────────┐    │  │
│  │  │         Django ORM Layer                     │    │  │
│  │  │  - Carrera                                   │    │  │
│  │  │  - PlanEstudios                              │    │  │
│  │  │  - Materia                                   │    │  │
│  │  │  - Estudiante                                │    │  │
│  │  │  - Inscripcion                               │    │  │
│  │  │  - ... (8 modelos)                           │    │  │
│  │  └─────────────────────────────────────────────┘    │  │
│  │                                                       │  │
│  │  Port: 8000                                           │  │
│  │  Endpoints:                                           │  │
│  │  - /graphql/  (GraphQL Playground)                   │  │
│  │  - /admin/    (Django Admin)                         │  │
│  └──────────────────────────────────────────────────────┘  │
│                            │                                │
│                            │ PostgreSQL Protocol             │
│                            ▼                                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           POSTGRESQL DATABASE                         │  │
│  │         (Container: inscripcion_db)                   │  │
│  │                                                       │  │
│  │  Database: inscripcion_db                             │  │
│  │  User: admin                                          │  │
│  │  Port: 5432                                           │  │
│  │                                                       │  │
│  │  Tables:                                              │  │
│  │  - inscripcion_carrera                                │  │
│  │  - inscripcion_planestudios                           │  │
│  │  - inscripcion_materia                                │  │
│  │  - inscripcion_materiacarrerasemestre                 │  │
│  │  - inscripcion_estudiante                             │  │
│  │  - inscripcion_periodoacademico                       │  │
│  │  - inscripcion_inscripcion                            │  │
│  │  - inscripcion_inscripcionmateria                     │  │
│  │                                                       │  │
│  │  Volume: postgres_data (Persistencia)                 │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Flujo de Datos

### 1. Consulta de Perfil de Estudiante

```text
Frontend
   │
   │ POST /graphql/
   │ query { perfilEstudiante(registro: "218001234") { ... } }
   │
   ▼
Django GraphQL (schema.py)
   │
   │ resolve_perfil_estudiante()
   │
   ▼
Django ORM (models.py)
   │
   │ Estudiante.objects.get(registro="218001234")
   │
   ▼
PostgreSQL
   │
   │ SELECT * FROM inscripcion_estudiante WHERE registro='218001234'
   │
   ▼
Django ORM
   │
   │ Objeto Estudiante con relaciones (carrera, plan)
   │
   ▼
GraphQL Serializer
   │
   │ EstudianteType → JSON
   │
   ▼
Frontend
   │
   │ { data: { perfilEstudiante: { ... } } }
```

### 2. Consulta de Materias Habilitadas

```text
Frontend
   │
   │ query { materiasHabilitadas(registro: "218001234") { ... } }
   │
   ▼
Django GraphQL
   │
   │ resolve_materias_habilitadas()
   │
   ▼
Django ORM
   │
   │ 1. Obtener estudiante
   │ 2. Filtrar por carrera + semestre + habilitada=True
   │
   ▼
PostgreSQL
   │
   │ JOIN entre inscripcion_materiacarrerasemestre,
   │ inscripcion_materia, inscripcion_carrera
   │
   ▼
Django ORM
   │
   │ Lista de MateriaCarreraSemestre
   │
   ▼
GraphQL Serializer
   │
   │ List[MateriaCarreraSemestreType] → JSON
   │
   ▼
Frontend
   │
   │ { data: { materiasHabilitadas: [...] } }
```

---

## 🗄️ Modelo Entidad-Relación

```text
┌─────────────────┐
│    Carrera      │
│─────────────────│
│ codigo (PK)     │◄────┐
│ nombre          │     │
│ facultad        │     │
│ duracion_sem    │     │
└─────────────────┘     │
         │              │
         │ 1            │
         │              │
         │ N            │
         ▼              │
┌─────────────────┐     │
│  PlanEstudios   │     │
│─────────────────│     │
│ id (PK)         │     │
│ carrera_id (FK) │─────┘
│ codigo          │
│ año_vigencia   │
└─────────────────┘
         │
         │ 1
         │
         │ N
         ▼
┌──────────────────────────┐        ┌─────────────────┐
│ MateriaCarreraSemestre   │   N    │    Materia      │
│──────────────────────────│◄───────│─────────────────│
│ id (PK)                  │        │ id (PK)         │
│ carrera_id (FK)          │        │ codigo          │
│ plan_estudios_id (FK)    │        │ nombre          │
│ materia_id (FK)          │────────┤ creditos        │
│ semestre                 │   1    │ horas_teoricas  │
│ obligatoria              │        │ horas_practicas │
│ habilitada               │        └─────────────────┘
└──────────────────────────┘

┌─────────────────┐
│   Estudiante    │
│─────────────────│
│ registro (PK)   │
│ nombre          │
│ apellidos       │
│ carrera_id (FK) │──────┐
│ plan_id (FK)    │      │
│ semestre_actual │      │
│ modalidad       │      │
│ lugar_origen    │      │
└─────────────────┘      │
         │               │
         │ 1             │
         │               │
         │ N             │
         ▼               │
┌─────────────────┐      │
│  Inscripcion    │      │
│─────────────────│      │
│ id (PK)         │      │
│ estudiante (FK) │──────┘
│ periodo_id (FK) │──────┐
│ fecha_asignada  │      │
│ bloqueado       │      │
│ boleta_generada │      │
└─────────────────┘      │
         │               │
         │ 1             │
         │               │
         │ N             │
         ▼               │
┌─────────────────┐      │
│ InscripcionMat  │      │
│─────────────────│      │
│ id (PK)         │      │
│ inscripcion(FK) │      │
│ materia_id (FK) │      │
│ grupo           │      │
└─────────────────┘      │
                         │
                         │
                         │
                    ┌────┴──────────┐
                    │ PeriodoAcad   │
                    │───────────────│
                    │ id (PK)       │
                    │ codigo        │
                    │ nombre        │
                    │ activo        │
                    │ inscripc_hab  │
                    └───────────────┘
```

---

## 🔐 Seguridad y CORS

### Configuración CORS Actual (Desarrollo)

```python
CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOW_CREDENTIALS = True
```

### Configuración CORS Recomendada (Producción)

```python
CORS_ALLOW_ALL_ORIGINS = False
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://192.168.1.100:3000",
    "https://frontend.universidad.edu.bo",
]
CORS_ALLOW_CREDENTIALS = True
```

---

## 📊 Endpoints Disponibles

### GraphQL Endpoint

- **URL**: `http://localhost:8000/graphql/`
- **Método**: POST
- **Content-Type**: application/json
- **Body**: `{ "query": "...", "variables": {...} }`

### Admin Panel

- **URL**: `http://localhost:8000/admin/`
- **Método**: GET/POST
- **Autenticación**: Django Session

---

## 🚀 Escalabilidad

### Horizontal Scaling

```yaml
# docker-compose.yml (ejemplo)
services:
  web:
    deploy:
      replicas: 3
    
  nginx:
    image: nginx
    # Load balancer para múltiples instancias de Django
```

### Vertical Scaling

```yaml
services:
  db:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
```

---

## 📈 Monitoreo

### Logs en Tiempo Real

```bash
docker-compose logs -f web
docker-compose logs -f db
```

### Estado de Servicios

```bash
docker-compose ps
```

### Uso de Recursos

```bash
docker stats
```

---

## 🔄 Ciclo de Vida del Contenedor

```text
┌─────────────────┐
│  docker-compose │
│   up --build    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Build Dockerfile│
│ - Install deps  │
│ - Copy files    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Start DB       │
│  (PostgreSQL)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Wait for DB    │
│  (healthcheck)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Start Django   │
│  - migrate      │
│  - loaddata     │
│  - createsuperuser
│  - runserver    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Ready! 🚀      │
│  Port 8000      │
└─────────────────┘
```

---

## 🎯 Puntos Clave de la Arquitectura

1. **Separación de Servicios**: Django y PostgreSQL en contenedores separados
2. **Persistencia de Datos**: Volume para PostgreSQL
3. **Red Interna**: Comunicación entre contenedores vía Docker network
4. **CORS Habilitado**: Frontend puede estar en otra máquina
5. **GraphQL API**: Endpoint único para todas las consultas
6. **Sin Autenticación**: Acceso directo por ID de estudiante
7. **Auto-inicialización**: Datos de prueba cargados automáticamente
8. **Healthcheck**: Garantiza que DB esté lista antes de Django

---

## 🏗️ Arquitectura diseñada para ser escalable, mantenible y fácil de desplegar
