class_name IStorageProvider extends GlapiProvider

func initialize() -> void:
	push_error("IStorageProvider: initialize() no implementado.")

# --- Configuración (Settings) ---
func save_settings(data: Dictionary) -> void:
	push_error("IStorageProvider: save_settings() no implementado.")

func load_settings() -> Dictionary:
	push_error("IStorageProvider: load_settings() no implementado.")
	return {}

# --- Estado del Jugador (State) ---
func save_state(data: Dictionary) -> void:
	push_error("IStorageProvider: save_state() no implementado.")

func load_state() -> Dictionary:
	push_error("IStorageProvider: load_state() no implementado.")
	return {}
