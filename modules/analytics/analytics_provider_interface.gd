class_name IAnalyticsProvider extends GlapiProvider

func initialize() -> void:
	push_error("IAnalyticsProvider: initialize() no implementado.")

# Método principal para registrar eventos (nivel completado, compra, muerte, etc.)
func send_event(event_name: String, parameters: Dictionary) -> void:
	push_error("IAnalyticsProvider: send_event() no implementado.")

# Útil para segmentar jugadores (ej: "tipo_jugador" = "ballena", "preferencia_control" = "tactil")
func set_user_property(property_name: String, value: String) -> void:
	push_error("IAnalyticsProvider: set_user_property() no implementado.")
