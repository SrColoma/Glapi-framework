# Game Launch Acceleration Pipeline (Glapi)

**Glapi Framework** es un framework modular y desacoplado para Godot 4.x, diseñado para estandarizar y abstraer la estructura base de cualquier videojuego. 

Su **arquitectura híbrida** combina el patrón **Adapter** (Servicio → Interfaz → Adapter), un **Bus de Eventos** tipado para telemetría, y **Llamadas Asíncronas (`await`)**, permitiendo un código de juego extremadamente limpio, natural, testeable y 100% agnóstico a las herramientas subyacentes.

---

## Módulos Disponibles

Glapi centraliza las herramientas más importantes de la producción de videojuegos bajo un único Autoload llamado `Glapi`.

| Módulo | Llamada | Descripción (Resumen) | Patrón Principal |
|--------|---------|-----------------------|-------------|
| **Ads** | `Glapi.ads` | Redes de Anuncios (AdMob, UnityAds) async. | Adapter |
| **Analytics** | `Glapi.analytics` | Telemetría (Firebase, Godotx) fire-and-forget. | Adapter |
| **Storage** | `Glapi.storage` | Almacenamiento local, cloud híbrido y encriptado. | Adapter |
| **Crashlytics** | `Glapi.crashlytics` | Reporte automatizado de errores y crashes fatales. | Adapter |
| **Remote Config**| `Glapi.remote_config`| AB Testing y switches en vivo. | Adapter |
| **IAP** | `Glapi.iap` | Compras dentro de la aplicación (In-App Purchases). | Adapter |
| **Game Services**| `Glapi.game_services`| Control de Logros y Tablas de Puntuación leaderboards.| Adapter |
| **Settings** | `Glapi.settings` | Gestor de estado reactivo y local para el Menú de Opciones.| Adapter |
| **Audio** | `Glapi.audio` | Motor acústico físico agnóstico (Godot Avanzado, FMOD, Wwise).| Adapter |
| **Scene Transition**| `Glapi.scene_transition`| Cambios de pantalla corrutinados con fades. | Manager Directo |
| **Overlays** | `Glapi.overlays` | Gestión Z-Index de Popups genéricos y menús modales. | Manager Directo |
| **Time** | `Glapi.time` | Control del tiempo seguro anti-cheat y cronómetros offline. | Manager Directo |
| **Input** | `Glapi.input` | Detector de plataformas en vivo (Mando/Táctil/PC) y vibración.| Manager Directo |
| **Debug** | `Glapi.debug` | Consola flotante _in-game_ con comandos personalizados. | Manager Directo |
| **Pooling** | `Glapi.pooling` | Object Pool ultrarrápido genérico para escupir miles de nodos. | Manager Directo |

---

## Componentes Activos (IA y Lógica)

Además de los servicios globales (Autoloads), Glapi expone una carpeta de `components/` con Nodos listos para arrastrar y soltar a tus entidades, proveyendo arquitecturas de toma de decisiones robustas:

- **FSM (Máquina de Estados Finitos)**: Para controladores de jugador simples, jefes con fases estáticas y animaciones de UI complejas.
- **Behavior Tree (Árboles de Comportamiento)**: Para IA enemiga estándar, patrullajes, y NPCs reactivos jerárquicos. Incluye Decorators, Composites (Selector/Sequence) y Leaves base.
- **GOAP (Goal-Oriented Action Planning)**: El pináculo de la IA dinámica. Para aldeanos, simuladores de vida y enemigos paramétricos complejos. Define estados del mundo ("Tiene Madera") y deja que los NPCs armen su propio plan en tiempo real. 

---

## Arquitectura (Capa de Servicios)

Esta es la jerarquía de los módulos que requieren comunicación externa o configuraciones que pueden variar dependiendo de la plataforma de destino de nuestro juego.

```
Juego → Glapi (Autoload) → Servicios → Adapters → SDKs
							   ↓
						 Mock Adapters (Desarrollo / PC / Testing)
```

- **Servicio**: Lógica de negocio dura e inquebrantable (ej. `AudioService`)
- **Interfaz**: Define el contrato con el mundo exterior (ej. `IAudioAdapter`)
- **Adapter**: Implementación real (ej. `FmodAudioAdapter`, `GodotAudioAdapter`)
- **Mock Adapter**: Implementación segura que no crashea en PC (ej. `MockAdsAdapter`)

---

## Instalación

### Git Submodule (Recomendado)
```bash
mkdir addons
git submodule add https://github.com/SrColoma/Glapi-framework.git addons/glapi
```

### Activación
1. Abre tu proyecto en Godot
2. **Proyecto → Configuración del proyecto → Plugins**
3. Activa **Glapi Framework**
4. El autoload `Glapi` se registrará y compilará automáticamente.

### Herramienta: Generador de Proyecto Base

Glapi incluye un script constructor que preparará la arquitectura de tu juego (las carpetas inmutables fuera de addons) automáticamente con un solo clic:

1. Ve a `addons/glapi/tools/` en tu FileSystem.
2. Haz clic derecho sobre **`project_generator.gd`** > **"Run"** (o Ejecutar).

**¿Qué hace el Generador?**
- Crea obligatoriamente `res://game/core/` y `res://game/screens/`.
- Trae hacia fuera tu plantilla de *Product Requirements Document* (`PRD.md`) base.
- Combina y crea tu **Splash Screen** interactiva (`res://game/screens/splash/splash_screen.tscn`) inyectando directamente el `auto_bootstrap.gd` (plantilla).
- Fija esa nueva escena como el **Main Scene** del proyecto en la configuración del motor listos para Play (F5).

---

## Inicialización Obligatoria (Bootstrap)

Dado que Glapi no sabe si quieres usar Firebase, GameAnalytics o nada, debes inyectarle sus dependencias tan pronto como arranque el juego (`_ready` de la primera pantalla `splash_screen.gd` o `auto_bootstrap.gd`):

```gdscript
func _ready() -> void:
	# Por parámetros ordinales, el framework te obliga a ser estricto.
	Glapi.initialize(
		null,                               # Ads (null cargará MockAds internamente)
		GodotxAnalyticsAdapter.new(),       # Analytics
		null,                               # Storage 
		GodotxCrashlyticsAdapter.new(),     # Crashlytics
		null,                               # Remote Config 
		null,                               # IAP 
		null,                               # Game Services 
		null,                               # Settings 
		GodotAudioAdapter.new()             # Audio (El motor físico de Godot proveído por Glapi)
	)
```

> **Nota:** Todos los módulos tipo "Manager Directo" (`time`, `overlays`, `scene_transition`, etc.) se auto-construyen por detrás al llamar `initialize` y no requieren inyección de adaptadores al no interactuar con el exterior.

---

## Guía Visual Rápida de Uso

### 🎵 Audio y Ajustes (Reactivo)
```gdscript
# Nunca modificamos el bus volumétrico a mano. Le advertimos al Settings.
Glapi.settings.set_master_volume(0.5)

# AudioService (que escucha internamente a Settings) aplica el cambio físico para ti.
Glapi.audio.play_sfx("shoot", player.global_position)
```

### 📺 Anuncios (Asíncronos)
```gdscript
func _on_revive_pressed() -> void:
	Glapi.ads.load_ad("rewarded", "ca-app-pub-xx")
	await Glapi.ads.ad_loaded
	
	Glapi.ads.show_ad("rewarded")
	await Glapi.ads.ad_closed
```

### 💾 Almacenamiento
```gdscript
# Guardar
Glapi.storage.save_data("game_record", {"score": 5000})

# Cargar fuerte
var rec = Glapi.storage.load_data("game_record")
```

### 🎬 Transiciones 
```gdscript
# Cambiar la escena limpiamente esperando a que el telón cierre
Glapi.scene_transition.change_scene("res://game/level_1.tscn")
await Glapi.scene_transition.transition_finished
```

---

## Estructura para crear Modos Personalizados

Para inyectar tu propia pasarela externa de SDKs (Ej: Cambiar Godotx Crashlytics por Sentry, o GodotAudio por Wwise):
1. Crea tu archivo en la carpeta adaptadores basándote en la interfaz exigible: `modules/<modulo>/adapters/mi_nuevo_adapter.gd` `extends I<Modulo>Adapter`
2. En tu archivo del juego Boot (`auto_bootstrap.gd`), reemplaza la instanciación:
```gdscript
	Glapi.initialize(
		# ..., 
		MiNuevoCrashlyticsAdapter.new() # ← Así de fácil.
	)
```

---

## Licencia
*Desarrollado internamente para la aceleración y modularización agnóstica de sistemas de videojuegos.*
