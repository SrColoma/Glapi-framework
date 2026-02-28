class_name MockStorageAdapter extends IStorageAdapter

# Diccionarios temporales que solo vivirán mientras el juego esté abierto
var _mock_settings: Dictionary = {}
var _mock_state: Dictionary = {}

func initialize() -> void:
	print("🟡 MOCK STORAGE: Inicializado (Modo Solo Memoria. No se escribirá en disco).")

# ==========================================
# ⚙️ CONFIGURACIÓN (Settings)
# ==========================================

func save_settings(data: Dictionary) -> void:
	_mock_settings = data.duplicate(true)
	print("🟡 MOCK STORAGE: Simulando guardado de Settings...")
	# Imprimimos lo que se guardaría para que puedas depurar
	print(JSON.stringify(_mock_settings, "  "))

func load_settings() -> Dictionary:
	if _mock_settings.is_empty():
		print("🟡 MOCK STORAGE: Cargando Settings. (Están vacíos, se usarán los defaults).")
	else:
		print("🟡 MOCK STORAGE: Cargando Settings desde la memoria temporal.")
	return _mock_settings

# ==========================================
# 🛡️ ESTADO DEL JUGADOR (State)
# ==========================================

func save_state(data: Dictionary) -> void:
	_mock_state = data.duplicate(true)
	print("🟡 MOCK STORAGE: Simulando guardado de Estado (Encriptación Falsa)...")
	# Imprimimos el estado para que compruebes si las monedas/items están correctos
	print(JSON.stringify(_mock_state, "  "))

func load_state() -> Dictionary:
	if _mock_state.is_empty():
		print("🟡 MOCK STORAGE: Cargando Estado. (Es un 'jugador nuevo', se usarán defaults).")
	else:
		print("🟡 MOCK STORAGE: Cargando Estado desde la memoria temporal.")
	return _mock_state
