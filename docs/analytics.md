# Módulo: Analíticas (Analytics)

El módulo `AnalyticsService` es el pilar de la recolección de datos en el framework Glapi. Su arquitectura está fuertemente acoplada al `EventBus` del framework, de modo que el envío de eventos ocurra de forma pasiva y sin ensuciar la lógica del juego.

> [!TIP]
> **Event-Driven Analytics:** En lugar de inyectar llamadas de analíticas manualmente en tu código (`Glapi.analytics.send(...)`), el framework promueve que lances eventos de dominio (`Glapi.dispatch(MisEventos.new())`) y sea el módulo de analíticas el que los escuche automáticamente.

---

## 🚀 Uso en el Juego (`Service Layer`)

El Singleton global `Glapi` tiene definida la función principal para despachar eventos al tubo.

### 1. Despachar un Evento de Analítica (Recomendado)

En la carpeta `addons/glapi/core/events/` se recomienda definir clases que hereden de `GlapiEvent`.

```gdscript
# Dentro de tu código del juego (ej: al pasar de nivel)
# res://game/core/level_manager.gd

func complete_level(level_id: int):
	# 1. Haces tu lógica normal
	grant_rewards()
	
	# 2. Despachas el evento ciego al framework
	Glapi.dispatch(LevelCompletedEvent.new(level_id, "hard", 150))
```

El `AnalyticsService` recibe **automáticamente** ese evento que entró por el tubo principal de `Glapi.dispatch(event)`, y como el evento es una clase serializable, el servicio lo parsea a un `(String, Dictionary)` y lo envía a Firebase/GameAnalytics, etc.

### 2. Establecer Propiedades de Usuario (User Properties)

Si deseas etiquetar o segmentar al jugador activo en tus paneles (Ej: "Ballena", "Usuario de pago", "Tapa-dificil"), puedes fijar sus propiedades.

```gdscript
# Establecer que el usuario prefiere los controles táctiles
Glapi.analytics.set_user_property("control_preference", "touch")

# Clasificar demográficamente
Glapi.analytics.set_user_property("player_type", "whale")
```

> [!NOTE]
> Estas propiedades acompañarán automáticamente a todos los eventos que se envíen en el futuro durante la sesión actual del jugador.

---

## 🛠 Desarrollo de Adaptadores (Para Ingenieros)

Si tu equipo necesita enviar analíticas a un servicio propietario o a un plugin nuevo, debes crear un componente que herede de `IAnalyticsAdapter`.

### Interfaz Requerida

El nuevo adaptador debe proveer implementación para:
- `initialize() -> void:` Aquí se enciende el SDK del proveedor (ej: GameAnalytics).
- `send_event(event_name: String, parameters: Dictionary) -> void:` Lógica principal para rutear el evento y la carga útil (payload).
- `set_user_property(property_name: String, value: String) -> void:` Inyección de meta-datos persistentes para el usuario actual.

### Emisión de Señales

Este módulo **no emite señales** de asincronía (a menos que el adaptador propietario requiera confirmación de *Batch Uploads*, lo que rara vez es expuesto al *Front-end* del juego). La ejecución es del tipo *Fire-And-Forget*.
