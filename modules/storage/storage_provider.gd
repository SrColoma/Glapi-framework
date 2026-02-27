class_name StorageProvider extends GlapiProvider

func save_data(key: String, data: Dictionary) -> void:
	push_error("StorageProvider: save_data() no implementado en la clase hija.")

func load_data(key: String) -> Dictionary:
	push_error("StorageProvider: load_data() no implementado en la clase hija.")
	return {}
