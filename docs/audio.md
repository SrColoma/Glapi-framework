# Módulo: Audio (Godot, FMOD, Wwise)

El módulo `AudioService` de Glapi proporciona una arquitectura orientada a la inyección de dependencias para el manejo del sonido en el juego. Aísla completamente la lógica del juego (`res://game/`) del motor de sonido subyacente. 

Esto permite intercambiar la librería nativa de Godot por motores más profesionales como **FMOD** o **Wwise** sin modificar una sola línea del código de tus pantallas, armas o personajes.

---

## 🚀 Uso en el Juego (`Service Layer`)

El servicio vive a nivel global. Asumiendo que has expuesto una variable dentro del Singleton (ej. `Glapi.audio`), se usa para reproducir efectos, música y alterar los volúmenes de los buses.

### 1. Reproducir un Efecto de Sonido (SFX)
Independientemente del motor de sonido, puedes invocar un evento posicional o global por su nombre (Ej: un *FMOD Event* o un alias mapeado en tu `GodotAudioAdapter`).

```gdscript
# ent_player.gd
func _on_jump() -> void:
    # La posición 3D es opcional.
    Glapi.audio.play_sfx("sfx_player_jump", self.global_position)
```

### 2. Reproducir y Detener Música (BGM)
Lanza flujos de música continuos con un string o nombre de evento.

```gdscript
# view_main_menu.gd
func _ready() -> void:
    Glapi.audio.play_music("bgm_main_theme")

func _on_exit_pressed() -> void:
    # Puedes aplicar crossfades en adaptadores avanzados mandando transition_time
    Glapi.audio.stop_music(2.0)
```

### 3. Ajustar Volúmenes de Buses y Pausa Global
Si cambias un *Slider* en el menú de ajustes de tu UI, manda el cambio directamente al servicio. El adaptador traducirá "Master" o "SFX" a VCA's de FMOD, RTPC's de Wwise o buses nativos de Godot.

```gdscript
# view_settings.gd
func _on_master_volume_changed(value: float) -> void:
    # 'value' puede ser linear o Decibelios dependiendo de tu implementación
    Glapi.audio.set_bus_volume("Master", value)
```

Para mutear bruscamente el juego entero durante un anuncio recompensado:
```gdscript
func on_ad_started() -> void:
    Glapi.audio.pause_all()

func on_ad_closed() -> void:
    Glapi.audio.resume_all()
```

---

## 🔌 Inicialización y Adaptadores (Composition Root)

El `AudioService` requiere recibir un adaptador al arrancar la aplicación (`auto_bootstrap.gd`) usando el entrypoint principal de Glapi.

```gdscript
# res://framework/auto_bootstrap.gd

func _ready() -> void:
    # 1. Instancias el adapter
    var audio_adapter = GodotAudioAdapter.new()
    # (o FmodAudioAdapter.new(), etc)
    
    # 2. Se inyecta al final en el initialize (usar parámetros nombrados o posición)
    Glapi.initialize(
        null, null, null, null, null, null, null, null,
        audio_adapter
    )
    
    # ¡Listo! Glapi.audio está inyectado y acoplado al juego.
```
