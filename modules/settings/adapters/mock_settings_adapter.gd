class_name MockSettingsAdapter extends ISettingsAdapter

var _memory_config: Dictionary = {}

func initialize() -> void:
	print("⚙️ SETTINGS MOCK: Inicializado en memoria.")
	
func set_value(section: String, key: String, value: Variant) -> void:
	if not _memory_config.has(section):
		_memory_config[section] = {}
	_memory_config[section][key] = value
	setting_changed.emit(section, key, value)

func get_value(section: String, key: String, default_val: Variant = null) -> Variant:
	if _memory_config.has(section) and _memory_config[section].has(key):
		return _memory_config[section][key]
	return default_val

func apply_all() -> void:
	print("⚙️ SETTINGS MOCK: apply_all() invocado.")

func save() -> void:
	print("⚙️ SETTINGS MOCK: save() invocado (nada persistido, es un mock).")
