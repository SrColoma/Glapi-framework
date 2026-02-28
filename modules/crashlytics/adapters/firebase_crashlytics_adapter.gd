class_name FirebaseCrashlyticsAdapter extends ICrashlyticsAdapter

var _is_initialized: bool = false
var _firebase: Object

func initialize() -> void:
	if Engine.has_singleton("FirebaseCrashlytics"):
		_firebase = Engine.get_singleton("FirebaseCrashlytics")
		_is_initialized = true
		print("🟢 CRASHLYTICS: SDK Inicializado en dispositivo móvil.")
	else:
		_is_initialized = false
		push_warning("⚠️ CRASHLYTICS: Singleton 'FirebaseCrashlytics' no encontrado.")

func record_exception(message: String) -> void:
	if not _is_initialized: return
	if _firebase.has_method("recordException"):
		_firebase.recordException(message)
	elif _firebase.has_method("record_exception"):
		_firebase.record_exception(message)

func log_message(message: String) -> void:
	if not _is_initialized: return
	if _firebase.has_method("log"):
		_firebase.log(message)

func set_custom_key(key: String, value: String) -> void:
	if not _is_initialized: return
	if _firebase.has_method("setCustomKey"):
		_firebase.setCustomKey(key, value)
