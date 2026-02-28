class_name FirebaseAnalyticsAdapter extends IAnalyticsAdapter

var _is_initialized: bool = false
var _firebase: Object

func initialize() -> void:
	# Verificamos si el plugin de Firebase Analytics está instalado en el teléfono
	if Engine.has_singleton("FirebaseAnalytics"):
		_firebase = Engine.get_singleton("FirebaseAnalytics")
		_is_initialized = true
		print("🟢 FIREBASE ANALYTICS: SDK Inicializado en dispositivo móvil.")
	else:
		_is_initialized = false
		push_warning("⚠️ FIREBASE: Singleton 'FirebaseAnalytics' no encontrado. (Normal si estás en PC).")

func send_event(event_name: String, parameters: Dictionary) -> void:
	if not _is_initialized: return
	
	# La mayoría de plugins de Firebase en Godot usan el método logEvent o log_event
	if _firebase.has_method("logEvent"):
		_firebase.logEvent(event_name, parameters)
	elif _firebase.has_method("log_event"):
		_firebase.log_event(event_name, parameters)
	else:
		push_error("FIREBASE: Método para enviar eventos no reconocido en el plugin.")

func set_user_property(property_name: String, value: String) -> void:
	if not _is_initialized: return
	
	if _firebase.has_method("setUserProperty"):
		_firebase.setUserProperty(property_name, value)
	elif _firebase.has_method("set_user_property"):
		_firebase.set_user_property(property_name, value)
