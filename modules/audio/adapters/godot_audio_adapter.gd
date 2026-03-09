class_name GodotAudioAdapter extends IAudioAdapter

var _manager: GlapiGodotAudioManager

func initialize() -> void:
	# El adaptador es responsable de instanciar al Manager físico y ponerlo en el SceneTree
	_manager = GlapiGodotAudioManager.new()
	Engine.get_main_loop().root.call_deferred("add_child", _manager)
	print("GodotAudioAdapter: Motor Nativo Inicializado.")

func register_stream(event_name: String, stream: Variant) -> void:
	if stream is AudioStream and _manager:
		_manager.register_stream(event_name, stream as AudioStream)

func play_sfx(event_name: String, position: Vector3 = Vector3.ZERO) -> void:
	# Si el nombre del evento tiene el sufijo especial de polifonia
	if event_name.ends_with("_poly"):
		_manager.play_sfx_polyphonic(event_name)
	else:
		_manager.play_sfx(event_name)
		
	audio_started.emit(event_name)

func play_music(event_name: String, transition_time: float = 0.0) -> void:
	_manager.play_music(event_name)
	audio_started.emit("music_" + event_name)

func stop_music(transition_time: float = 0.0) -> void:
	_manager.stop_music()
	audio_stopped.emit("music")

# Implementación de decibelios para Godot
func set_bus_volume(bus_name: String, linear_vol: float) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear_vol))
		AudioServer.set_bus_mute(bus_idx, linear_vol <= 0.0)
	else:
		push_error("GodotAudioAdapter: Bus no encontrado: ", bus_name)

func pause_all() -> void:
	# Podríamos pausar el SceneTree del manager o mutear master
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus_idx, true)

func resume_all() -> void:
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus_idx, false)
