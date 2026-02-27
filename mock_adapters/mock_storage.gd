class_name MockStorage extends StorageProvider

func initialize() -> void:
	print("🟢 MOCK ANALYTICS: Inicializado correctamente en PC.")

func log_event(event_name: String, parameters: Dictionary) -> void:
	print("🟢 MOCK ANALYTICS: Evento registrado -> [", event_name, "] ", parameters)
