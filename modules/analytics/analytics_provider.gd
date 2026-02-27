class_name AnalyticsProvider extends GlapiProvider

func initialize() -> void:
	push_error("AnalyticsProvider: initialize() no implementado.")

func log_event(event_name: String, parameters: Dictionary) -> void:
	push_error("AnalyticsProvider: log_event() no implementado.")

func set_user_property(property: String, value: String) -> void:
	push_error("AnalyticsProvider: set_user_property() no implementado.")

func set_user_id(user_id: String) -> void:
	push_error("AnalyticsProvider: set_user_id() no implementado.")
