# Módulo: Crashlytics (Reporte de Errores)

El módulo `CrashlyticsService` centraliza el reporte de errores, excepciones fatales y registro de "migas de pan" (Logs) durante la ejecución del juego. Esto permite a los desarrolladores rastrear el comportamiento previo al crasheo y el estado interno de la sesión de un usuario de forma transparente.

> [!TIP]
> **Logs Silenciosos:** A diferencia del tradicional `print()`, las funciones de Crashlytics acumulan información que solo se envía a los servidores (ej: Firebase) si ocurre un error grave (Exception), ayudando a diagnosticar problemas de producción en un entorno vivo.

---

## 🚀 Uso en el Juego (`Service Layer`)

Interactúa con el servicio utilizando el Singleton `Glapi.crashlytics` desde cualquier parte de tu código `res://game/`.

### 1. Registrar una Excepción Simulada o Controlada (Exception)

Cuando el juego falla o entra en un bloque `catch`/`else` inesperado que afecta a la experiencia de forma fatal o semi-fatal.

```gdscript
func load_player_data(data: Dictionary):
	if not data.has("id"):
		Glapi.crashlytics.record_exception("MissingPlayerID", "Se intentó cargar data sin ID.")
		return
```

### 2. Dejar "Migas de Pan" (Logs)

Almacena registros de eventos clave que preceden a un error (ej. "Inició el combate", "Abrió el cofre"). El último lote de estos logs se adjuntará al reporte de error cuando el juego crashee.

```gdscript
func start_boss_fight():
	Glapi.crashlytics.log_message("Empezó pelea contra el jefe del nivel 5.")
```

### 3. Asignar Estado del Jugador (Custom Keys)

Los *Custom Keys* son pares de clave-valor que se adhieren a la sesión. Son la mejor forma de saber *¿Cómo estaba el juego configurado cuando falló?*.

```gdscript
# Al iniciar la partida puedes mandar información crítica
Glapi.crashlytics.set_custom_key("current_level", "5")
Glapi.crashlytics.set_custom_key("player_class", "warrior")
```

### 4. Seguimiento de Usuarios (User ID)

Permite atar los crasheos a una ID de jugador específico (útil para revisar si un error solo afecta a ciertas cuentas).

```gdscript
Glapi.crashlytics.set_user_id("user_db_812391")
```

---

## 🛠 Desarrollo de Adaptadores (Para Ingenieros)

Si tu equipo necesita enviar el reporte de errores a un backend propietario (como Sentry, Datadog o tu propio Node.js) en vez de Firebase Crashlytics, debes heredar tu clase de `ICrashlyticsAdapter`.

### Interfaz Requerida

El nuevo adaptador debe proveer implementación para:
- `initialize() -> void:` Configuración temprana del SDK o Logger.
- `record_exception(error_name: String, description: String) -> void:` Enviar el error explícito a la nube de inmediato o guardarlo en disco de forma segura.
- `log_message(message: String) -> void:` Almacenar un log informativo.
- `set_custom_key(key: String, value: String) -> void:` Almacenar estado de la variable clave-valor.
- `set_user_id(user_id: String) -> void:` (Opcional) Conectar la sesión actual a una métrica de usuario.

### Emisiones

Este módulo **no emite señales** de asincronía. La ejecución en el front-end es inmediata y silenciosa.
