class_name IStorageAdapter extends GlapiAdapter

func initialize() -> void:
	push_error("IStorageAdapter: initialize() no implementado.")


# --- Estado del Jugador (State) ---
func save_state(data: Dictionary) -> void:
	push_error("IStorageAdapter: save_state() no implementado.")

func load_state() -> Dictionary:
	push_error("IStorageAdapter: load_state() no implementado.")
	return {}

func execute_query(sql: String, args: Array = []) -> Array:
	push_error("IStorageAdapter: execute_query() no implementado.")
	return []
