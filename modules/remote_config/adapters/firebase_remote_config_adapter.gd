class_name FirebaseRemoteConfigAdapter extends IRemoteConfigAdapter

var _is_initialized: bool = false
var _firebase: Object

func initialize() -> void:
	if Engine.has_singleton("FirebaseRemoteConfig"):
		_firebase = Engine.get_singleton("FirebaseRemoteConfig")
		_is_initialized = true
		
		# Conectamos la señal de éxito del plugin (el nombre de la señal depende de tu plugin)
		if _firebase.has_signal("on_config_fetched"):
			_firebase.connect("on_config_fetched", _on_fetched)
			
		print("🟢 REMOTE CONFIG: SDK Inicializado.")
	else:
		_is_initialized = false
		push_warning("⚠️ REMOTE CONFIG: Singleton no encontrado.")

func fetch_and_activate() -> void:
	if not _is_initialized: 
		# Si no hay plugin, simulamos que cargó rápido para no bloquear el juego
		call_deferred("emit_signal", "config_loaded")
		return
		
	if _firebase.has_method("fetchAndActivate"):
		_firebase.fetchAndActivate()
	elif _firebase.has_method("fetch_and_activate"):
		_firebase.fetch_and_activate()

func _on_fetched() -> void:
	print("✅ REMOTE CONFIG: Datos descargados de la nube.")
	config_loaded.emit()

func get_string(key: String, default_value: String) -> String:
	if not _is_initialized: return default_value
	return _firebase.getString(key) if _firebase.has_method("getString") else default_value

func get_int(key: String, default_value: int) -> int:
	if not _is_initialized: return default_value
	return _firebase.getInt(key) if _firebase.has_method("getInt") else default_value

func get_bool(key: String, default_value: bool) -> bool:
	if not _is_initialized: return default_value
	return _firebase.getBoolean(key) if _firebase.has_method("getBoolean") else default_value

func get_float(key: String, default_value: float) -> float:
	if not _is_initialized: return default_value
	return _firebase.getFloat(key) if _firebase.has_method("getFloat") else default_value
