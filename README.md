# Glapi Framework

**Glapi** es un framework modular y desacoplado para Godot 4.x, diseñado para abstraer la comunicación con servicios de terceros como analíticas, anuncios (ads), almacenamiento, crashlytics, remote config, IAPs y game services.

Su **arquitectura híbrida** combina el patrón **Adapter** (Servicio → Interfaz → Adapter), un **Bus de Eventos** para telemetría, y **Llamadas Asíncronas (`await`)** para interrupciones de UI, lo que permite un código de juego limpio, natural, testeable y agnóstico a los SDKs específicos que se utilicen.

## Módulos Disponibles

| Módulo | Servicio | Descripción |
|--------|----------|-------------|
| **Ads** | `Glapi.ads` | Anuncios (AdMob, Rewarded, Interstitial, Banner) |
| **Analytics** | `Glapi.analytics` | Analítica (Firebase, Godotx) |
| **Storage** | `Glapi.storage` | Almacenamiento local/híbrido |
| **Crashlytics** | `Glapi.crashlytics` | Reporte de crashes (Firebase, Godotx) |
| **Remote Config** | `Glapi.remote_config` | Configuración remota (Firebase) |
| **IAP** | `Glapi.iap` | Compras in-app (Google Play Billing) |
| **Game Services** | `Glapi.game_services` | Logros y leaderboards (Google Play Games) |

## Arquitectura

```
Juego → Glapi (Autoload) → Servicios → Adapters → SDKs
                                    ↓
                              Mock Adapters (testing)
```

- **Servicio**: Lógica de negocio (ej. `AdsService`)
- **Interfaz**: Define el contrato (ej. `IAdsAdapter`)
- **Adapter**: Implementación real (ej. `PoingStudiosAdMobAdapter`)
- **Mock Adapter**: Implementación para testing (ej. `MockAdsAdapter`)

---

## Instalación

### Git Submodule (Recomendado)
```bash
mkdir addons
git submodule add https://github.com/SrColoma/Glapi-framework.git addons/Glapi
```

### Activación
1. Abre tu proyecto en Godot
2. **Proyecto → Configuración del proyecto → Plugins**
3. Activa **Glapi Framework**
4. El autoload `Glapi` se registrará automáticamente

---

## Uso Básico

### Inicialización

```gdscript
func _ready() -> void:
    Glapi.initialize(
        PoingStudiosAdMobAdapter.new(),    # Ads
        GodotxAnalyticsAdapter.new(),       # Analytics
        null,                               # Storage (usa mock)
        GodotxCrashlyticsAdapter.new(),     # Crashlytics
        null,                               # Remote Config (usa mock)
        null,                               # IAP (usa mock)
        null                                # Game Services (usa mock)
    )
```

### Analítica (Fire-and-Forget)

```gdscript
Glapi.dispatch(LevelCompletedEvent.new(5, "normal"))
Glapi.dispatch(AdImpressionEvent.new("banner", "home_screen", "USD", 0.50))
```

### Anuncios (Asíncrono con await)

```gdscript
func _on_revive_pressed() -> void:
    get_tree().paused = true
    
    Glapi.ads.load_ad("rewarded", "ca-app-pub-xxx/yyy")
    await Glapi.ads.ad_loaded
    
    Glapi.ads.show_ad("rewarded")
    await Glapi.ads.ad_closed
    
    get_tree().paused = false
```

### Storage

```gdscript
# Guardar
Glapi.storage.save_data("settings", {"sound": true, "music": 0.8})

# Cargar
var settings = Glapi.storage.load_data("settings")
```

---

## Crear un Nuevo Adapter

1. Crea la interfaz en `modules/<modulo>/i_<modulo>_adapter.gd`
2. Crea el servicio en `modules/<modulo>/<modulo>_service.gd`
3. Crea el mock en `modules/<modulo>/adapters/mock_<modulo>_adapter.gd`
4. Crea el adapter real en `modules/<modulo>/adapters/real_<modulo>_adapter.gd`
5. Registra en `auto_Glapi.gd`

---

## Notas

- El autoload `Glapi` debe estar definido en `project.godot` o se registra automáticamente por el plugin
- En desarrollo (PC), los adapters que传入 `null` usarán automáticamente sus Mocks
- Los eventos de analítica se envían automáticamente en segundo plano (ej. AdImpressionEvent)
