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

func get_value(section: String, key: String, default_val: Variant = null) -> Variant:
	return _config.get_value(section, key, default_val)

func save() -> void:
	var err: int = _config.save(CONFIG_PATH)
	if err != OK:
		push_error("SETTINGS LOCAL: Error al guardar la configuración, code: " + str(err))
