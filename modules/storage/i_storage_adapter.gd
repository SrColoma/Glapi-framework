class_name IStorageAdapter extends GlapiAdapter

func initialize() -> void:
	push_error("IStorageAdapter: initialize() no implementado.")

# --- Configuración (Settings) ---
func save_settings(data: Dictionary) -> void:
	push_error("IStorageAdapter: save_settings() no implementado.")

func load_settings() -> Dictionary:
	push_error("IStorageAdapter: load_settings() no implementado.")
	return {}

# --- Estado del Jugador (State) ---
func save_state(data: Dictionary) -> void:
	push_error("IStorageAdapter: save_state() no implementado.")

func load_state() -> Dictionary:
	push_error("IStorageAdapter: load_state() no implementado.")
	return {}

func execute_query(sql: String, args: Array = []) -> Array:
	push_error("IStorageAdapter: execute_query() no implementado.")
	return []
