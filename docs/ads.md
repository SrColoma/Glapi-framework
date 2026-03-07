# Módulo: Ads (Anuncios)

El módulo `AdsService` es el encargado de gestionar la monetización a través de anuncios dentro del framework Glapi. Actúa como un intermediario ciego entre el código del juego y los SDKs de publicidad (por ejemplo, AdMob o AppLovin).

> [!TIP]
> **Agnosticismo del Motor:** Gracias a este módulo, si en el futuro decides cambiar de red de anuncios, tu código en `res://game/` no cambiará ni una sola línea.

---

## 🚀 Uso en el Juego (`Service Layer`)

Para interactuar con los anuncios, utiliza el Singleton global `Glapi.ads`. 
Puedes suscribirte a sus señales para reaccionar a eventos asíncronos o enviar comandos directos.

### 1. Cargar y Mostrar un Anuncio

Los métodos en el servicio de Anuncios reciben un `format_str` (String) que indica el tipo de anuncio a operar.

```gdscript
# Cargar un Banner en la parte inferior de la pantalla (Default)
Glapi.ads.load_ad("banner")

# Mostrar el anuncio cargado
Glapi.ads.show_ad("banner")

# Ocultarlo temporalmente o destruirlo permanentemente
Glapi.ads.hide_ad("banner")
Glapi.ads.destroy_ad("banner")
```

#### Formatos Compatibles (`format_str`):
- `"banner"`
- `"interstitial"`
- `"rewarded"`
- `"rewarded_interstitial"`
- `"native"`
- `"app_open"`

> [!NOTE]
> Puedes pasar parámetros opcionales a `load_ad()` para personalizar el comportamiento (ej. el `ad_unit_id` personalizado, posición o tamaño para los banners).

### 2. Eventos Asíncronos (Señales)

La capa de servicios mapea limpiamente todos los callbacks de los adaptadores:

```gdscript
func _ready():
	Glapi.ads.ad_loaded.connect(_on_ad_loaded)
	Glapi.ads.ad_failed_to_load.connect(_on_ad_failed)
	Glapi.ads.ad_closed.connect(_on_ad_closed)
	Glapi.ads.ad_rewarded.connect(_on_ad_rewarded)

func _on_ad_loaded(format: IAdsAdapter.AdFormat):
	print("El formato ", format, " se ha cargado.")

func _on_ad_rewarded(format: IAdsAdapter.AdFormat, reward_type: String, amount: int):
	print("¡Recibiste ", amount, " ", reward_type, "!")
```

---

## 🛠 Desarrollo de Adaptadores (Para Ingenieros)

Si necesitas implementar un nuevo plugin de publicidad, debes crear una clase que herede de `IAdsAdapter`.

### Interfaz Requerida

Tu clase de adaptador debe implementar los siguientes métodos:
- `initialize() -> void:` Se ejecuta en la inyección de `Glapi`. Configura aquí tus inicializaciones del SDK.
- `load_ad(format, ad_unit_id, position, size) -> void:` Llama aquí la lógica asíncrona de carga.
- `show_ad(format) -> void:` Muestra el anuncio.
- `hide_ad(format) -> void:`
- `destroy_ad(format) -> void:`

### Emisión de Señales

El adaptador **DEBE** emitir las señales heredadas al terminar sus tareas:
* `ad_loaded.emit(format)`
* `ad_failed_to_load.emit(format, error_msg)`
* `ad_closed.emit(format)`
* `ad_rewarded.emit(format, rewardType, rewardAmount)`

> [!IMPORTANT]
> **Analíticas Automáticas:** Al emitir la señal internal `ad_impression_recorded` desde tu adaptador, `AdsService` disparará de manera automática un `AdImpressionEvent` hacia el tubo general de analíticas (`Glapi.dispatch`), inyectando ARPDAU sin intervención manual del usuario.
