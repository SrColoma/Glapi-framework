class_name AudioService extends GlapiService

signal audio_started(event_name: String)
signal audio_stopped(event_name: String)

func _init(adapter: IAudioAdapter) -> void:
	_adapter = adapter
	_adapter.initialize()
	_adapter.audio_started.connect(func(e): audio_started.emit(e))
	_adapter.audio_stopped.connect(func(e): audio_stopped.emit(e))

func play_sfx(event_name: String, position: Vector3 = Vector3.ZERO) -> void:
	_adapter.play_sfx(event_name, position)

func play_music(event_name: String, transition_time: float = 0.0) -> void:
	_adapter.play_music(event_name, transition_time)

func stop_music(transition_time: float = 0.0) -> void:
	_adapter.stop_music(transition_time)

func set_bus_volume(bus_name: String, volume_db: float) -> void:
	_adapter.set_bus_volume(bus_name, volume_db)

func pause_all() -> void:
	if _adapter.has_method("pause_all"):
		_adapter.pause_all()

func resume_all() -> void:
	if _adapter.has_method("resume_all"):
		_adapter.resume_all()
