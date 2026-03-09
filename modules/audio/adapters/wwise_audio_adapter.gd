class_name WwiseAudioAdapter extends IAudioAdapter

# Este adapter envuelve las llamadas nativas necesarias para trabajar 
# con el plugin de Audiokinetic Wwise en Godot 4.

func initialize() -> void:
	print("WwiseAudioAdapter: Inicializado. (Requiere Wwise integration)")
	# Normalmente el setup de Wwise se hace a la carga de la extensión.

func play_sfx(event_name: String, position: Vector3 = Vector3.ZERO) -> void:
	print("WwiseAudioAdapter: Reproduciendo AkEvent de Wwise -> ", event_name)
	# AkEvent.post_event(event_name, null) # Puede requerir GameObject/Nodo 3D
	audio_started.emit(event_name)

func play_music(event_name: String, transition_time: float = 0.0) -> void:
	print("WwiseAudioAdapter: Reproduciendo música de Wwise -> ", event_name)
	audio_started.emit(event_name)

func stop_music(transition_time: float = 0.0) -> void:
	print("WwiseAudioAdapter: Deteniendo música (o evento AkEvent global) de Wwise")
	audio_stopped.emit("music")

func set_bus_volume(bus_name: String, volume_db: float) -> void:
	print("WwiseAudioAdapter: Ajustando el RTPC o Bus Volumen -> ", bus_name)
	# Wwise API para set_rtpc_value o similar...

func pause_all() -> void:
	print("WwiseAudioAdapter: Pausando AkEvent globals")

func resume_all() -> void:
	print("WwiseAudioAdapter: Reanudando AkEvent globals")
