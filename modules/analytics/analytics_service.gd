class_name AnalyticsService extends GlapiService

func _init(adapter: IAnalyticsAdapter) -> void:
	_adapter = adapter
	_adapter.initialize()

# Este es el método que está conectado en _setup_analytics de auto_Glapi.gd
func handle_event(event: GlapiEvent) -> void:
	_adapter.send_event(event.event_name, event.parameters)

# Método directo para propiedades de usuario (no necesita ser un evento)
func set_user_property(property_name: String, value: String) -> void:
	if _adapter.has_method("set_user_property"):
		_adapter.set_user_property(property_name, value)
