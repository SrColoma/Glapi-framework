class_name MockAnalytics extends AnalyticsProvider

func initialize() -> void:
	print("🟢 MOCK ANALYTICS: Inicializado correctamente.")

func log_event(event_name: String, parameters: Dictionary) -> void:
	# Formateo limpio para la consola de Godot
	var params_str = str(parameters) if not parameters.is_empty() else "{}"
	print("📊 [ANALYTICS LOG] Evento: ", event_name.to_upper(), " | Params: ", params_str)

func set_user_property(property: String, value: String) -> void:
	print("👤 [ANALYTICS PROP] User Property -> ", property, " = ", value)

func set_user_id(user_id: String) -> void:
	print("🆔 [ANALYTICS ID] User ID Set -> ", user_id)
