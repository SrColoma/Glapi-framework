class_name GodotxCrashlyticsAdapter extends ICrashlyticsAdapter

var _crashlytics: Object
var _is_ready: bool = false

func initialize() -> void:
	if Engine.has_singleton("GodotxFirebaseCrashlytics"):
		_crashlytics = Engine.get_singleton("GodotxFirebaseCrashlytics")
		_crashlytics.crashlytics_initialized.connect(func(success):
			_is_ready = success
			print("🐛 FIREBASE CRASHLYTICS: Inicialización -> ", success)
		)
		_crashlytics.initialize()
	else:
		_is_ready = false
		push_warning("⚠️ CRASHLYTICS: Singleton no encontrado. (Modo PC)")

func log_message(message: String) -> void:
	if not _is_ready or not _crashlytics:
		return
	_crashlytics.log_message(message)

# 🌟 CORREGIDO: Evadimos el bug del plugin concatenando la info en el log
func record_exception(error_name: String, description: String) -> void:
	if not _is_ready or not _crashlytics:
		return
	
	# Empaquetamos el nombre y la descripción en un texto limpio
	var full_error = "Exception Captured [%s]: %s" % [error_name, description]
	_crashlytics.log_message(full_error)
	
	# Si en el futuro el autor del plugin arregla/agrega record_exception, 
	# esto lo usará automáticamente sin romper el juego ahora.
	if _crashlytics.has_method("record_exception"):
		_crashlytics.call("record_exception", error_name, description)
		
	print("🚨 FIREBASE: Excepción registrada en Crashlytics -> ", error_name)

# 🌟 CORREGIDO: Evitamos el set_custom_value que causa el error JNI
func set_custom_key(key: String, value: String) -> void:
	if not _is_ready or not _crashlytics:
		return
		
	# Lo dejamos como una "miga de pan". Firebase lo leerá igual cuando haya un crash.
	_crashlytics.log_message("Custom Key -> " + key + ": " + value)
	
func set_user_id(user_id: String) -> void:
	if not _is_ready or not _crashlytics:
		return
	_crashlytics.set_user_id(user_id)
