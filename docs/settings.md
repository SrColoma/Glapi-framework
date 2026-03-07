# Módulo: Settings (Configuración Local, Audio, UI)

El módulo `SettingsService` es el responsable de exponer y guardar las configuraciones globales que el jugador realiza en el front-end del juego (ej. Mute, Volumen de Música, Idioma, Pantalla Completa).

> [!TIP]
> **Separación de Intereses (Single Responsibility):** A diferencia del inventario o el oro (elementos del juego que se guardan en la nube usando `storage`), el módulo `settings` está diseñado para guardarse de manera **exclusivamente local** (en un archivo `settings.cfg`), ya que un usuario puede querer jugar en silencio en su teléfono, pero con el volumen al máximo al abrir la misma cuenta en su PC.

---

## 🚀 Uso en el Juego (`Service Layer`)

Interactúa con la configuración usando el Singleton global `Glapi.settings`.
Toda vez que uses un *Setter*, el motor gráfico aplicará el cambio en vivo (mutará el audio, cambiará la resolución, traducirá los textos) e instruirá a su Adaptador I/O a guardar el archivo.

### 1. Control de Audio
El servicio expone atajos convenientes para controlar los buses principales que deben estar creados en tu proyecto de Godot (`Master`, `Music`, `SFX`). 
*Los volúmenes se miden del `0.0` (Silencio) al `1.0` (Máximo).*

```gdscript
# Cambiar el volumen general al 50%
Glapi.settings.set_master_volume(0.5)

# Obtener si el volumen está por debajo de algo
if Glapi.settings.get_music_volume() < 0.2:
	print("La música está muy baja.")
```

### 2. Control Visual (Pantalla Completa)
Común en ports de PC o Web, permite encadenar el comportamiento a la API de DisplayServer.

```gdscript
func _on_chk_fullscreen_toggled(button_pressed: bool):
	Glapi.settings.set_fullscreen(button_pressed)
```

### 3. Localización (Idiomas)
Sincronizado con las tablas `.csv` nativas de Godot, cambia las variables al instante y las guarda para los reinicios posteriores.

```gdscript
func set_english():
	Glapi.settings.set_language("en")

func set_spanish():
	Glapi.settings.set_language("es")
```

### 4. Lectura y Escritura Libre (Diccionario)

Si tu juego tiene configuraciones específicas no estandarizadas, como `"invertir_eje_y"`, `"calidad_sombras"`, `"daltonismo_mode"`, puedes usar las funciones genéricas de lectura y escritura:

```gdscript
# Altera un valor de configuración que tu juego necesite y lo guarda globalmente
Glapi.settings.set_value("controles", "invert_y", true)

# Lee el valor con un respaldo (fallback) por si el usuario es nuevo
var is_inverted: bool = Glapi.settings.get_value("controles", "invert_y", false)
```

**Señales en VIVO:**
Si un nodo tuyo necesita saber si el modo daltónico fue activado desde otro menú del juego, puede suscribirse a:
`Glapi.settings.setting_changed.connect(_on_setting_changed)`

---

## 🛠 Desarrollo de Adaptadores (Para Ingenieros)

El `SettingsService` no requiere llamadas largas, ya que abstrae su Input/Output a `ISettingsAdapter`, garantizando que la lectura/escritura en disco es inmediata y bloqueante (no requiere promesas y debe ser síncrona).

### Interfaz Requerida

El nuevo adaptador (Si se quiere reemplazar el `ConfigFile` oficial por `JSON` u otro) debe proveer implementación simple de mapeo Hash (Dictionary):
- `initialize() -> void:` (Opcional) Cargar el archivo de disco a la RAM.
- `set_value(section: String, key: String, value: Variant) -> void`
- `get_value(section: String, key: String, default_val: Variant) -> Variant`
- `save() -> void:` Forzar volcado desde la RAM al Disco.

### Emisión de Señales
El adaptador **DEBE** asegurarse de emitir la señal internal cuando su base de datos mute:
- `setting_changed.emit(section, key, value)`
