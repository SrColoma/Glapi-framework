class_name MockStorage extends StorageProvider

# Usamos un diccionario como base de datos temporal en memoria
var _memory_db: Dictionary = {}

func initialize() -> void:
	print("🟢 MOCK STORAGE: Inicializado. Usando base de datos temporal en RAM.")

func save_data(key: String, data: Dictionary) -> void:
	# Duplicamos los datos para evitar referencias cruzadas accidentales en memoria
	_memory_db[key] = data.duplicate(true)
	print("💾 MOCK STORAGE: Datos guardados -> Clave: [", key, "] | Contenido: ", data)

func load_data(key: String) -> Dictionary:
	if _memory_db.has(key):
		print("📂 MOCK STORAGE: Datos cargados -> Clave: [", key, "]")
		return _memory_db[key].duplicate(true)
	else:
		print("⚠️ MOCK STORAGE: Clave no encontrada -> [", key, "]. Retornando diccionario vacío.")
		return {}
