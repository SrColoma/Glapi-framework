class_name ICrashlyticsAdapter extends GlapiAdapter

func initialize() -> void:
	push_error("ICrashlyticsAdapter: initialize() no implementado.")

# 🌟 ACTUALIZADO: Ahora exige 2 parámetros
func record_exception(error_name: String, description: String) -> void:
	push_error("ICrashlyticsAdapter: record_exception() no implementado.")

func log_message(message: String) -> void:
	push_error("ICrashlyticsAdapter: log_message() no implementado.")

func set_custom_key(key: String, value: String) -> void:
	push_error("ICrashlyticsAdapter: set_custom_key() no implementado.")

# 🌟 NUEVO: Añadimos la función para identificar al jugador
func set_user_id(user_id: String) -> void:
	push_error("ICrashlyticsAdapter: set_user_id() no implementado.")
