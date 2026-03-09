class_name FmodAudioAdapter extends IAudioAdapter

# Este adapter envuelve las llamadas nativas necesarias para trabajar 
# con el GDExtension de FMOD Studio en Godot 4.

func initialize() -> void:
	print("FmodAudioAdapter: Inicializado. (Requiere addon de FMOD)")
	# Ej: FMODStudio.system_init()

func play_sfx(event_name: String, position: Vector3 = Vector3.ZERO) -> void:
	print("FmodAudioAdapter: Reproduciendo event_name de FMOD -> ", event_name)
	# var event_inst = FMODStudio.create_event_instance(event_name)
	# FMODStudio.event_set_3d_attributes(event_inst, position)
	# FMODStudio.event_start(event_inst)
	audio_started.emit(event_name)

func play_music(event_name: String, transition_time: float = 0.0) -> void:
	print("FmodAudioAdapter: Reproduciendo música en FMOD -> ", event_name)
	audio_started.emit(event_name)

func stop_music(transition_time: float = 0.0) -> void:
	print("FmodAudioAdapter: Deteniendo música en FMOD")
	audio_stopped.emit("music")

func set_bus_volume(bus_name: String, volume_db: float) -> void:
	# Convertir nombre a la ruta del bus (VCA, Group, o Bus normal) dependiendo del setup de FMOD
	var bus_path = "bus:/" + bus_name
	print("FmodAudioAdapter: Cambiando volumen en FMOD Bus -> ", bus_path)
	# var bus = FMODStudio.get_bus(bus_path)
	# FMODStudio.bus_set_volume(bus, <linear_volume_conversion>) 

func pause_all() -> void:
	print("FmodAudioAdapter: Pausando FMOD Master Bus")
	# FMODStudio.bus_set_paused(FMODStudio.get_bus("bus:/"), true)

func resume_all() -> void:
	print("FmodAudioAdapter: Reanudando FMOD Master Bus")
	# FMODStudio.bus_set_paused(FMODStudio.get_bus("bus:/"), false)
