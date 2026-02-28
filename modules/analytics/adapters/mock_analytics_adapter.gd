class_name MockAnalyticsAdapter extends IAnalyticsAdapter

func initialize() -> void:
	print("🔵 MOCK ANALYTICS: SDK Inicializado.")

func send_event(event_name: String, parameters: Dictionary) -> void:
	# Formateamos los parámetros para que se vean legibles en la consola de Godot
	var params_str = ""
	if parameters.size() > 0:
		params_str = JSON.stringify(parameters)
	
	print("📈 MOCK ANALYTICS: Evento Registrado -> [ ", event_name, " ] | Params: ", params_str)

func set_user_property(property_name: String, value: String) -> void:
	print("👤 MOCK ANALYTICS: Propiedad de Usuario -> [ ", property_name, " ] = ", value)
