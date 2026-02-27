class_name AnalyticsService extends GlapiService

func _init(provider: AnalyticsProvider) -> void:
	_provider = provider
	_provider.initialize()

func handle_event(event: GlapiEvent) -> void:
	# 1. Ignorar la clase base instanciada por error
	if event.event_name == "" or event.event_name == "generic_event":
		return

	# 2. Manejar comandos de configuración (Propiedades de usuario)
	if event is SetUserPropertyEvent:
		var prop_event = event as SetUserPropertyEvent
		_provider.set_user_property(prop_event.property_name, prop_event.property_value)
		return

	# 3. FILTRO DE EVENTOS INTERNOS:
	# Ignoramos eventos de comunicación del framework (ej. "internal_show_ad", "internal_ad_closed")
	if event.event_name.begins_with("internal_"):
		return

	# 4. Si pasó los filtros, es un evento de dominio real (Firebase standard). Se registra.
	var params = event.to_dict()
	_provider.log_event(event.event_name, params)
