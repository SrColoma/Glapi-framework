# Módulo: Remote Config (Configuración Remota)

El módulo `RemoteConfigService` permite alterar el comportamiento, el balanceo y la apariencia de tu juego "al vuelo" a través de variables descargadas desde la nube (usualmente Firebase Remote Config), sin necesidad de obligar a los jugadores a descargar una actualización desde la App Store o Google Play.

> [!TIP]
> **A/B Testing:** Las herramientas de configuración remota son fundamentales para probar diferentes configuraciones en grupos separados de usuarios. Ej: ¿Si duplico la vida del jefe del nivel 10, la gente deja de jugar o compra más pociones?

---

## 🚀 Uso en el Juego (`Service Layer`)

Interactúa con la configuración remota usando el Singleton global `Glapi.remote_config`.

### 1. Descargar y Activar Valores Nubes (Fetch and Activate)

Por defecto, Remote Config usa los valores en caché de la sesión anterior o los valores locales de Godot para que el juego arranque instantáneamente sin depender del internet. Puedes solicitar una sincronización fresca (usualmente esto se hace al entrar al juego mientras carga).

```gdscript
func _ready():
	# Nos avisará cuando los nuevos datos del servidor estén activos
	Glapi.remote_config.config_loaded.connect(_on_cloud_config_ready)
	
	# Pide al servidor que nos mande los nuevos valores
	Glapi.remote_config.fetch_and_activate()

func _on_cloud_config_ready():
	print("¡Nuevas variables de la nube descargadas y listas para usar!")
```

### 2. Leer Variables Remotas (Getters)

Cuando quieres decidir cómo se comporta algo en el juego, simplemente le pides a Remote Config el valor de esa *"llave"*. 
**Importante:** Siempre provee un valor por defecto (Fallback) sólido por si el jugador nunca se conectó a internet.

#### Variables Numéricas (Balanceo)
```gdscript
func start_boss_fight():
	# 500 es el valor por defecto si no hay conexión
	var boss_health: int = Glapi.remote_config.get_int("boss_level_1_hp", 500)
	var boss_atk: float = Glapi.remote_config.get_float("boss_level_1_atk", 15.5)
	
	spawn_boss(boss_health, boss_atk)
```

#### Variables Booleanas (Feature Flags)
```gdscript
func show_main_menu():
	# Activar/Desactivar un modo de evento especial desde la nube
	var is_halloween_event_active = Glapi.remote_config.get_bool("enable_halloween_ui", false)
	
	if is_halloween_event_active:
		show_spooky_menu()
	else:
		show_normal_menu()
```

#### Variables de Texto (String)
```gdscript
func get_promo_message():
	var msg = Glapi.remote_config.get_string("daily_promo_text", "¡Juega ahora!")
	$PromoLabel.text = msg
```

---

## 🛠 Desarrollo de Adaptadores (Para Ingenieros)

Si tu equipo decide usar una plataforma diferente a Firebase (por ejemplo PlayFab o un backend Custom en AWS), tu adaptador debe extender `IRemoteConfigAdapter`.

### Interfaz Requerida

El nuevo adaptador debe proveer implementación para:
- `initialize() -> void:` 
- `fetch_and_activate() -> void:` Descargar los datos desde el servidor. OBLIGATORIO emitir `config_loaded.emit()` al terminar la descarga de forma exitosa.

Y reimplementar (hacer *override* de) los *Getters* tipados:
- `get_string(key: String, default_value: String) -> String`
- `get_int(key: String, default_value: int) -> int`
- `get_bool(key: String, default_value: bool) -> bool`
- `get_float(key: String, default_value: float) -> float`

> [!NOTE]
> Las funciones getter son totalmente sincrónicas en Front-end. El adaptador **DEBE** asegurarse de leer estos valores de su memoria caché local y no suspender el hilo (ni usar await) para solicitar el valor del servidor cada vez que alguien pregunta por una llave.
