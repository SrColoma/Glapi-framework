class_name GodotAudioAdapter extends IAudioAdapter

# Este adapter es una implementación inicial (mock/prototype) 
# usando llamadas nativas pero actuando como cascarón.
# Útil si el proyecto no tiene FMOD o WWISE instalado en su momento.

func initialize() -> void:
	print("GodotAudioAdapter: Inicializado.")

func play_sfx(event_name: String, position: Vector3 = Vector3.ZERO) -> void:
	print("GodotAudioAdapter: Reproduciendo SFX -> ", event_name, " en ", position)
	audio_started.emit(event_name)

func play_music(event_name: String, transition_time: float = 0.0) -> void:
	print("GodotAudioAdapter: Reproduciendo Música -> ", event_name, " (transición: ", transition_time, "s)")
	audio_started.emit(event_name)

func stop_music(transition_time: float = 0.0) -> void:
	print("GodotAudioAdapter: Deteniendo Música (transición: ", transition_time, "s)")
	audio_stopped.emit("music")

func set_bus_volume(bus_name: String, volume_db: float) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, volume_db)
	else:
		push_error("GodotAudioAdapter: Bus de audio nativo no encontrado: ", bus_name)

func pause_all() -> void:
	print("GodotAudioAdapter: Pausando todas las reproducciones")

func resume_all() -> void:
	print("GodotAudioAdapter: Reanudando todas las reproducciones")
