class_name GodotxAnalyticsAdapter extends IAnalyticsAdapter

var _analytics: Object
var _is_ready: bool = false

func initialize() -> void:
	if Engine.has_singleton("GodotxFirebaseAnalytics"):
		_analytics = Engine.get_singleton("GodotxFirebaseAnalytics")
		_analytics.analytics_initialized.connect(func(success):
			_is_ready = success
			print("📊 FIREBASE ANALYTICS: Inicialización -> ", success)
		)
		_analytics.initialize()
	else:
		_is_ready = false
		push_warning("⚠️ ANALYTICS: Singleton no encontrado. (Modo PC)")

# 🌟 CORREGIDO: Coincide exactamente con IAnalyticsAdapter
func send_event(event_name: String, parameters: Dictionary) -> void:
	if not _is_ready or not _analytics:
		return
		
	# Firebase prefiere que los valores sean strings, así que hacemos una limpieza rápida
	var clean_params: Dictionary = {}
	for key in parameters:
		clean_params[key] = str(parameters[key])

	# 🌟 LLAMADA AL SDK NATIVO
	_analytics.log_event(event_name, clean_params)
	print("📈 FIREBASE: Evento enviado al servidor -> ", event_name)

# 🌟 NUEVO: Cumplimos el contrato añadiendo set_user_property
func set_user_property(property_name: String, value: String) -> void:
	if not _is_ready or not _analytics:
		return
	_analytics.set_user_property(property_name, value)
