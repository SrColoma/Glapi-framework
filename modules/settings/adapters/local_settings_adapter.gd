class_name LocalSettingsAdapter extends ISettingsAdapter

const CONFIG_PATH: String = "user://settings.cfg"
var _config: ConfigFile

func initialize() -> void:
	_config = ConfigFile.new()
	var err: int = _config.load(CONFIG_PATH)
	if err != OK:
		print("⚙️ SETTINGS LOCAL: Archivo no encontrado. Creando configuración por defecto...")
		_setup_defaults()
		save()
	else:
		print("⚙️ SETTINGS LOCAL: Configuración cargada correctamente desde ", CONFIG_PATH)
		
	# Aplicar configuración de inmediato a los servidores (Audio, etc)
	apply_all()

func _setup_defaults() -> void:
	# Audio
	_config.set_value("audio", "master_volume", 1.0)
	_config.set_value("audio", "sfx_volume", 1.0)
	_config.set_value("audio", "music_volume", 1.0)
	# Localization
	_config.set_value("localization", "language", TranslationServer.get_locale())
	# Graphics
	var is_mobile: bool = OS.get_name() == "Android" or OS.get_name() == "iOS"
	_config.set_value("graphics", "fullscreen", is_mobile)

func set_value(section: String, key: String, value: Variant) -> void:
	_config.set_value(section, key, value)
	setting_changed.emit(section, key, value)
	# Aplicación inmediata para ciertas variables si es necesario
	_apply_single(section, key, value)

func get_value(section: String, key: String, default_val: Variant = null) -> Variant:
	return _config.get_value(section, key, default_val)

func save() -> void:
	var err: int = _config.save(CONFIG_PATH)
	if err != OK:
		push_error("SETTINGS LOCAL: Error al guardar la configuración, code: " + str(err))

func apply_all() -> void:
	# Localization
	var lang: String = get_value("localization", "language", TranslationServer.get_locale()) as String
	TranslationServer.set_locale(lang)
	
	# Graphics
	var is_full: bool = get_value("graphics", "fullscreen", false) as bool
	if is_full:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
	# Audio
	_apply_bus_volume("Master", get_value("audio", "master_volume", 1.0) as float)
	_apply_bus_volume("SFX", get_value("audio", "sfx_volume", 1.0) as float)
	_apply_bus_volume("Music", get_value("audio", "music_volume", 1.0) as float)

func _apply_single(section: String, key: String, value: Variant) -> void:
	if section == "audio":
		if key == "master_volume":
			_apply_bus_volume("Master", value as float)
		elif key == "sfx_volume":
			_apply_bus_volume("SFX", value as float)
		elif key == "music_volume":
			_apply_bus_volume("Music", value as float)
	elif section == "localization" and key == "language":
		TranslationServer.set_locale(value as String)
	elif section == "graphics" and key == "fullscreen":
		var enabled: bool = value as bool
		if enabled:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _apply_bus_volume(bus_name: String, linear_vol: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear_vol))
		# Si el volumen es 0, lo muteamos
		AudioServer.set_bus_mute(bus_idx, linear_vol <= 0.0)
