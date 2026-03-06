class_name StorageService extends GlapiService

# Variables en memoria (Caché)
var state: Dictionary = {}

func _init(adapter: IStorageAdapter) -> void:
	_adapter = adapter
	_adapter.initialize()
	
	# Cargamos los datos del disco a la memoria al iniciar
	_load_all()

# --- Métodos que usa el juego ---

func get_state(key: String, default_value = null) -> Variant:
	return state.get(key, default_value)

func set_state(key: String, value: Variant, auto_save: bool = true) -> void:
	state[key] = value
	if auto_save:
		save_all_state()

# --- Métodos de sincronización con el disco ---

func save_all_state() -> void:
	_adapter.save_state(state)

func _load_all() -> void:
	var loaded_state = _adapter.load_state()
	state.merge(loaded_state, true)
