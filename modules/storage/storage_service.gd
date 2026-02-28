class_name StorageService extends GlapiService

# Variables en memoria (Caché)
var settings: Dictionary = {}
var state: Dictionary = {}

# Estructuras por defecto para que el juego nunca crashee si es la primera vez que se abre
const DEFAULT_SETTINGS = {
	"master_volume": 1.0,
	"sfx_volume": 1.0,
	"language": "es"
}

const DEFAULT_STATE = {
	"coins": 0,
	"unlocked_levels": [1],
	"high_score": 0,
	"last_login": ""
}

func _init(provider: IStorageProvider) -> void:
	_provider = provider
	_provider.initialize()
	
	# Cargamos los datos del disco a la memoria al iniciar
	_load_all()

# --- Métodos que usa el juego ---

func get_state(key: String, default_value = null) -> Variant:
	return state.get(key, default_value)

func set_state(key: String, value: Variant, auto_save: bool = true) -> void:
	state[key] = value
	if auto_save:
		save_all_state()

func get_setting(key: String, default_value = null) -> Variant:
	return settings.get(key, default_value)

func set_setting(key: String, value: Variant, auto_save: bool = true) -> void:
	settings[key] = value
	if auto_save:
		save_all_settings()

# --- Métodos de sincronización con el disco ---

func save_all_state() -> void:
	_provider.save_state(state)

func save_all_settings() -> void:
	_provider.save_settings(settings)

func _load_all() -> void:
	# Mezclamos los datos guardados con los defaults, por si añadiste nuevas variables en una actualización
	var loaded_settings = _provider.load_settings()
	settings = DEFAULT_SETTINGS.duplicate(true)
	settings.merge(loaded_settings, true)
	
	var loaded_state = _provider.load_state()
	state = DEFAULT_STATE.duplicate(true)
	state.merge(loaded_state, true)
