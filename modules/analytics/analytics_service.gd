class_name AnalyticsService extends GlapiService

func _init(provider: IAnalyticsProvider) -> void:
	_provider = provider
	_provider.initialize()

# Este es el método que está conectado en _setup_analytics de auto_Glapi.gd
func handle_event(event: GlapiEvent) -> void:
	_provider.send_event(event.event_name, event.parameters)

# Método directo para propiedades de usuario (no necesita ser un evento)
func set_user_property(property_name: String, value: String) -> void:
	if _provider.has_method("set_user_property"):
		_provider.set_user_property(property_name, value)
