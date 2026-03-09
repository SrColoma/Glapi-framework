class_name IAudioAdapter extends GlapiAdapter

signal audio_started(event_name: String)
signal audio_stopped(event_name: String)

func initialize() -> void:
	pass

func register_stream(event_name: String, stream: Variant) -> void:
	push_warning("IAudioAdapter: Este adaptador no soporta el registro dinámico de streams. Ignite.")
	pass

func play_sfx(event_name: String, position: Vector3 = Vector3.ZERO) -> void:
	push_error("IAudioAdapter: play_sfx() no implementado.")

func play_music(event_name: String, transition_time: float = 0.0) -> void:
	push_error("IAudioAdapter: play_music() no implementado.")

func stop_music(transition_time: float = 0.0) -> void:
	push_error("IAudioAdapter: stop_music() no implementado.")

func set_bus_volume(bus_name: String, volume_db: float) -> void:
	push_error("IAudioAdapter: set_bus_volume() no implementado.")

func pause_all() -> void:
	push_error("IAudioAdapter: pause_all() no implementado.")

func resume_all() -> void:
	push_error("IAudioAdapter: resume_all() no implementado.")
