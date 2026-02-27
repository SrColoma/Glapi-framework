class_name StorageService extends GlapiService

func _init(provider: StorageProvider) -> void:
	_provider = provider

# Escucha lo que viene del juego
func handle_event(event: GlapiEvent) -> void:
	# El framework no sabe qué es un "InventoryEvent" o "LevelEvent", 
	# solo sabe guardar cosas si el juego se lo pide explícitamente.
	if event.event_name == "save_requested":
		var payload = event.to_dict()
		if payload.has("key") and payload.has("data"):
			_provider.save_data(payload["key"], payload["data"])
			print("💾 FRAMEWORK: Guardando datos en clave: ", payload["key"])

# Función directa para que auto_framework extraiga datos al arrancar
func get_saved_data(key: String) -> Dictionary:
	return _provider.load_data(key)
