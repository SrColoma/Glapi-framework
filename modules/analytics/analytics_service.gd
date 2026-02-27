class_name AnalyticsService extends GlapiService

func _init(provider: AnalyticsProvider) -> void:
	_provider = provider
	
	if _provider.has_method("initialize"):
		_provider.initialize()

# --- Métodos Directos (Para Estado / Identidad) ---

func set_user_id(user_id: String) -> void:
	_provider.set_user_id(user_id)

func set_user_property(property_name: String, property_value: String) -> void:
	_provider.set_user_property(property_name, property_value)

# --- Manejador del Bus de Eventos (Para Comportamiento) ---

func handle_event(event: GlapiEvent) -> void:
	# 1. Ignorar la clase base instanciada por error
	if event.event_name == "" or event.event_name == "generic_event":
		return

	# 2. FILTRO DE EVENTOS INTERNOS:
	# Ignoramos eventos de comunicación del framework que no deben ir a Firebase
	if event.event_name.begins_with("internal_"):
		return

	# 3. Registro del evento de dominio
	var params = event.to_dict()
	_provider.log_event(event.event_name, params)
