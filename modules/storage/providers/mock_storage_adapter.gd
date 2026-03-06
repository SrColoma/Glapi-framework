class_name MockStorageAdapter extends IStorageAdapter

var _mock_state: Dictionary = {}

func initialize() -> void:
	print("🟡 MOCK STORAGE: Inicializado (Modo Solo Memoria. No se escribirá en disco).")


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
