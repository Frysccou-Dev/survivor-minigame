
Backend · Express + TypeScript
------------------------------

### Arquitectura en capas

- `routes/` recibe las peticiones, valida `ObjectId`, parámetros obligatorios y enruta a los servicios.
- `controllers/` conserva métodos útiles para escenarios donde se desee montar Express con controllers explícitos. En el run actual consumimos directamente los servicios desde las rutas para reducir capas en runtime.
- `services/` encapsula reglas:
	- `getSurvivorDetail` combina la definición del survivor, el estado del usuario simulado y sus picks.
	- `joinSurvivor` crea la relación usuario–survivor con 3 vidas iniciales y asegura idempotencia.
	- `makePick` evita duplicados y permite actualizar el pick solo si cambia el equipo.
	- `calculateWinners` retorna los jugadores con más vidas, desempata por `joinedAt`.
- `repositories/` aísla Mongoose, permitiendo cambiar ODM o agregar caching sin tocar servicios.

### Modelado del dominio

- **Survivor** (`models/Survivor.ts`): nombre, fecha de inicio, arreglo de partidos (`competition`), cantidad de vidas default.
- **Gamble** (`models/Gamble.ts`): representa la participación de un usuario. Guarda vidas restantes y fecha de ingreso para desempates.
- **Prediction** (`models/Prediction.ts`): historial de picks por partido con resultado opcional.

Se eligió separar apuestas (`Gamble`) y picks (`Prediction`) porque habilita analíticas y soporta múltiples usuarios reales sin duplicar la definición del survivor.

### Semillas y configuración

- `seeds/seedData.ts` corre inmediatamente tras conectar a Mongo. Así garantizamos datos coherentes en desarrollo/QA sin pasos manuales. (Se dejó tal y como venia)
- El archivo `.env` (no versionado) define `MONGO_URI` para apuntar a distintos clusters según ambiente.
- `config/user.ts` contiene `SIMULATED_USER_ID`; facilita migrar a autenticación real moviendo la lectura a un middleware.

### Scripts disponibles (package.json)

- `dev`: ejecuta la API con `ts-node` para obtener hot reload en desarrollo.
- `dev:watch`: agrega `nodemon` para reinicios automáticos.
- `build` + `start`: compilan TypeScript a `dist/` y levantan el servidor productivo.

Frontend · Flutter
------------------

Este proyecto es el punto de partida para la aplicación Flutter.

### Code Structure and Modularization (Nueva)

Para mantener un código limpio y mantenible, el proyecto se ha modularizado de la siguiente manera:

-   **Models**: Las clases de datos se definen en `lib/models/`, como `tournament_models.dart` para las estructuras de datos relacionadas con torneos.
-   **Widgets**: Los componentes reutilizables de la UI se separan en `lib/widgets/tournament/`, incluyendo:
    -   `header_section.dart`: Muestra la cabecera del torneo con estadísticas.
    -   `secondary_nav.dart`: Pestañas de navegación para diferentes secciones.
    -   `match_tile.dart`: Visualización individual de un partido con opciones de selección (pick).
    -   `stats_bar.dart` y `stat_tile.dart`: Componentes para la visualización de estadísticas.
    -   `debug_lives_controls.dart`: Controles de depuración para pruebas.
    -   `lives_depleted_banner.dart`: Banner que se muestra cuando se agotan las vidas.
-   **Screens**: Las pantallas principales están en `lib/screens/`, con `tournament_screens.dart` ahora enfocado en la lógica principal, delegando la UI a widgets modulares.
-   **Services**: Las interacciones con la API se gestionan en `lib/services/`.

Este enfoque modular reduce el tamaño de los archivos individuales (anteriormente más de 1300 líneas en una sola pantalla), mejora la reutilización y facilita el mantenimiento y las pruebas del codebase.

### Estructura de pantallas

- `SurvivorListScreen`: carga survivors desde la API, muestra tarjetas con gradientes y refresco pull-to-refresh.
- `SurvivorDetailScreen`: concentra la experiencia de juego con tabs (partidos, resultados, tabla), confirmación de picks y simulación de vidas.
- Jornadas expandibles: la jornada 1 usa los datos reales del torneo y se muestra abierta por defecto; las jornadas 2 a 5 se generan en front como mock, permanecen bloqueadas y sirven para anticipar el calendario.
- Widgets auxiliares (`_StatsBar`, `_MatchTile`, `_SecondaryNav`) mantienen el UI modular.

### Flujo de datos

- `lib/services/survivor_service.dart` usa `package:http` para consumir la API en `http://localhost:4300` durante desarrollo.
- Estado local dentro de `_SurvivorDetailScreenState` resuelve:
	- Una única confirmación de pick por partido (`_picks` + `_pickingMatches`).
	- Cálculo de vidas máximas vs. vidas actuales para mostrar `X/Y vidas`.
	- Banner cuando el jugador agota vidas.
	- Botones de debugging (`Simular perder 1 vida`, `Resetear vidas a 3`) para validar feedback visual sin depender del backend.
- Las jornadas se agrupan en `_TournamentStage`: la jornada 1 carga partidos reales, mientras que las jornadas 2-5 se generan con fechas semanales mock y quedan bloqueadas hasta contar con datos oficiales.
- Animaciones breves (`AnimatedSwitcher`, `AnimatedOpacity`) suavizan cambios, manteniendo la UI reactiva sin introducir gestores de estado externos (simplicidad primero).

### Diseño visual

- Tema oscuro con color semilla `#ED9320` inspirado en la paleta de Penka.
- Cabecera con imagen (`lib/public/header.jpg`) y gradiente semi-transparente: da identidad sin sacrificar legibilidad.
- Tabs compactas con relleno y estados activos bien contrastados.
- Se priorizó de momento `Material 3` para aprovechar componentes modernos sin sobrecargar con librerías adicionales.

Ciclo end-to-end
----------------

1. Al iniciar la API, `seedSurvivors()` inserta o actualiza los torneos mock.
2. La app Flutter consulta la lista y navega al survivor seleccionado.
3. El usuario se une (endpoint `/join/:id`), la API crea un `Gamble` con 3 vidas.
4. Cada pick (`/pick`) persiste un `Prediction`. El cliente bloquea selecciones repetidas vía confirmación modal.
5. Los controles de pérdida/reset de vidas actúan localmente para pruebas de interfaz; el backend permanecerá como fuente de verdad cuando se integre la lógica definitiva.

Decisiones de diseño y por qué
-------------------------------

### Backend

- **TypeScript estricto**: detecta errores de tipos antes de desplegar y documenta contratos entre capas.
- **Capa de servicios separada**: permite testear lógica de negocio sin montar Express ni Mongo, y prepara la base para unit tests.
- **Usuario simulado configurable**: evita bloquear flujos mientras se diseña autenticación real.
- **Seed automática**: garantiza ambientes reproducibles para QA/demo.
- **Docker Compose**: facilita levantar API + Mongo juntas para QA sin instalar dependencias globales.

### Frontend

- **Stateful widgets simples**: mantuve el estado local porque la UI aún es acotada; introducir un gestor (Provider, Riverpod) sería sobre-ingeniería hoy.
- **Confirmación de pick**: minimiza errores del usuario; después de confirmar queda bloqueado para replicar reglas reales del Survivor.
- **Controles de vidas in-app**: agilizan QA de banners y estilos sin tener que alterar la base de datos.
- **Diseño oscuro consistente**: amplifica la identidad del producto y contrasta con el naranja oficial (#ED9320).
- **Cliente HTTP manual**: con `package:http` alcanzó; aún no necesitamos dio ni interceptores porque los endpoints son pocos y simples.

Instalación y ejecución
-----------------------

> Nota: siguiendo los lineamientos internos, no se listan comandos exactos; usá tu herramienta preferida (terminal, scripts del IDE, tareas de CI) para ejecutar los scripts mencionados.

### Requisitos previos

- Node.js 18 (o compatible) + npm para la API.
- MongoDB 7 (local o remoto) o Docker si preferís contenedores.
- Flutter SDK 3.8.x o superior, con los toolchains móviles/plataformas que quieras probar.

### Backend

1. Instalá dependencias declaradas en `package.json`.
2. Creá un archivo `.env` en `backend/` con la variable `MONGO_URI` apuntando a tu instancia.
3. Ejecutá el script `dev` para desarrollo (o `dev:watch` si querés autoreload). Para producción, corré `build` seguido de `start`.
4. Opcional: si preferís contenedores, construí la imagen definida por `Dockerfile` o levantalos con los servicios del `docker-compose.yml`.

### Frontend

1. Resolvé las dependencias usando el gestor de paquetes de Flutter desde tu IDE o herramienta preferida.
2. Configurá un dispositivo o emulador.
3. Lanzá la aplicación desde tu IDE o mediante la tarea estándar de ejecución (`run`) del SDK de Flutter.
4. Asegurate de que la API esté accesible en `http://localhost:4300`; si usás otra URL, actualizá `baseUrl` en `lib/services/survivor_service.dart`.

Pruebas y validación
--------------------

- **Backend**: la estructura en capas deja lista la base para tests unitarios (por ejemplo sobre `SurvivorService`). Aún no se incluyeron suites de Jest o similares.
- **Frontend**: el scaffold de Flutter trae un test de contador en `test/widget_test.dart`. Reemplazalo por escenarios reales (p. ej. render del listado, confirmación de picks). Recomendación: ejecutá el runner de pruebas de Flutter desde tu herramienta preferida una vez que el archivo apunte a `SurvivorApp`.
- **Linting**: TypeScript usa `strict` en `tsconfig.json`. Flutter adopta las reglas de `flutter_lints` vía `analysis_options.yaml`.

Siguientes pasos sugeridos
--------------------------

- Integrar autenticación real y reemplazar `SIMULATED_USER_ID` por el usuario autenticado.
- Persistir la lógica de vidas en el backend (actualmente los botones de depuración solo actualizan estado local).
- Añadir cobertura de tests para servicios críticos y widgets clave.
- Internacionalizar la app Flutter si se planea multilenguaje.

Con esto tenés una vista completa del sistema y el razonamiento detrás de cada decisión técnica. ¡A seguir iterando! :)