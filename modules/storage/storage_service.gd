class_name StorageService extends GlapiService

func _init(provider: StorageProvider) -> void:
	_provider = provider
	
	# Si el provider tiene un método initialize (como el Mock), lo llamamos
	if _provider.has_method("initialize"):
		_provider.initialize()

# Eliminamos handle_event(). Ahora la comunicación es directa.

func save_data(key: String, data: Dictionary) -> void:
	_provider.save_data(key, data)

func load_data(key: String) -> Dictionary:
	return _provider.load_data(key)
