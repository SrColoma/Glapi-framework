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

### 3. Ajustar Volúmenes (Menú de Ajustes)
Gracias a la integración con `SettingsService`, **NUNCA** debes modificar el volumen directamente desde el menú llamando a `Glapi.audio.set_bus_volume()`.

El flujo correcto es:
1. El jugador mueve el slider en la UI.
2. La UI le dice a Settings que guarde la preferencia: `Glapi.settings.set_master_volume(0.5)`.
3. `SettingsService` guarda el dato y emite la señal de que el volumen cambió.
4. `AudioService` (que está escuchando secretamente) atrapa la señal y, **él mismo**, aplica los decibelios en el motor de Godot, FMOD o Wwise.

```gdscript
# view_settings.gd 
# IMPORTANTE: Observa que hablamos con Settings, NO con Audio.
func _on_master_slider_value_changed(value: float) -> void:
    # value = 0.0 a 1.0 (Linear)
    Glapi.settings.set_master_volume(value)
```

Para mutear bruscamente el juego entero durante un anuncio recompensado:
```gdscript
func on_ad_started() -> void:
    Glapi.audio.pause_all()

func on_ad_closed() -> void:
    Glapi.audio.resume_all()
```

### 4. Registrar Audios Dinámicamente
Para proyectos pequeños o medianos que usan el adaptador nativo `GodotAudioAdapter` y no desean usar un software externo pesado como FMOD Studio o bancos de sonido, Glapi permite inyectar recursos `AudioStream` (archivos `.wav`, `.ogg` o generadores) directamente por código usando el método agnóstico `register_stream`.

Esto evita tener que crear Diccionarios largos o referenciar nodos en tu Editor gráfico. Puedes cargar los recursos en tu script y dárselos a conocer al motor:

```gdscript
func _ready() -> void:
    # 1. Cargamos nuestro archivo de disco local
    var jump_sfx = preload("res://assets/audio/jump.wav")
    
    # 2. Le damos un alias/etiqueta y le entregamos el flujo
    Glapi.audio.register_stream("sfx_player_jump", jump_sfx)
    
    # 3. Ahora el evento "sfx_player_jump" existe en la memoria del motor global.
    # Cualquier pantalla puede llamarlo.
    Glapi.audio.play_sfx("sfx_player_jump")
```
> **Nota de Diseño**: Adaptadores avanzados de bancos (como FMOD/Wwise) típicamente ignorarán el método `register_stream`, ya que ellos manejan sus propios Master Banks y GUIDs internamente. ¡El método es seguro de llamar igual!

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
