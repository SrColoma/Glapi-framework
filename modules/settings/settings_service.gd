class_name SettingsService extends GlapiService

signal setting_changed(section: String, key: String, value: Variant)

func _init(adapter: ISettingsAdapter) -> void:
	_adapter = adapter
	_adapter.setting_changed.connect(_on_setting_changed)
	if _adapter.has_method("initialize"):
		_adapter.initialize()
	apply_all()

func _on_setting_changed(section: String, key: String, value: Variant) -> void:
	setting_changed.emit(section, key, value)
	_apply_single(section, key, value)

# Métodos Core
func set_value(section: String, key: String, value: Variant) -> void:
	_adapter.set_value(section, key, value)

func get_value(section: String, key: String, default_val: Variant = null) -> Variant:
	return _adapter.get_value(section, key, default_val)

func save() -> void:
	_adapter.save()

func apply_all() -> void:
	var lang: String = get_value("localization", "language", TranslationServer.get_locale()) as String
	TranslationServer.set_locale(lang)
	
	var is_full: bool = get_value("graphics", "fullscreen", false) as bool
	if is_full:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
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
		AudioServer.set_bus_mute(bus_idx, linear_vol <= 0.0)

# Convenience Methods - Audio (Volumen Lineal 0.0 - 1.0)
func set_master_volume(linear_volume: float) -> void:
	set_value("audio", "master_volume", linear_volume)

func get_master_volume() -> float:
	return get_value("audio", "master_volume", 1.0) as float

func set_sfx_volume(linear_volume: float) -> void:
	set_value("audio", "sfx_volume", linear_volume)

func get_sfx_volume() -> float:
	return get_value("audio", "sfx_volume", 1.0) as float

func set_music_volume(linear_volume: float) -> void:
	set_value("audio", "music_volume", linear_volume)

func get_music_volume() -> float:
	return get_value("audio", "music_volume", 1.0) as float

# Convenience Methods - Localization
func set_language(locale: String) -> void:
	set_value("localization", "language", locale)
	TranslationServer.set_locale(locale)

func get_language() -> String:
	return get_value("localization", "language", TranslationServer.get_locale()) as String

# Convenience Methods - Graphics
func set_fullscreen(enabled: bool) -> void:
	set_value("graphics", "fullscreen", enabled)
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func is_fullscreen() -> bool:
	return get_value("graphics", "fullscreen", false) as bool
