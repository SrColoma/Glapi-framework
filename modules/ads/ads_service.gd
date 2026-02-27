class_name AdsService extends GlapiService

func _init(provider: AdsProvider) -> void:
	_provider = provider
	_provider.initialize()
	
	# Conectar las señales de la infraestructura para convertirlas en eventos de dominio
	_provider.ad_closed.connect(_on_provider_ad_closed)
	_provider.ad_rewarded.connect(_on_provider_ad_rewarded)
	_provider.ad_impression_recorded.connect(_on_provider_ad_impression)

func handle_event(event: GlapiEvent) -> void:
	# Interceptar peticiones que vienen del juego
	if event is ShowAdRequestedEvent:
		var req_event = event as ShowAdRequestedEvent
		var format = _parse_format_string(req_event.format_requested)
		_provider.show_ad(format)

# --- Funciones Auxiliares ---

func _parse_format_string(format_str: String) -> AdsProvider.AdFormat:
	match format_str.to_lower():
		"banner": return AdsProvider.AdFormat.BANNER
		"interstitial": return AdsProvider.AdFormat.INTERSTITIAL
		"rewarded": return AdsProvider.AdFormat.REWARDED
		"rewarded_interstitial": return AdsProvider.AdFormat.REWARDED_INTERSTITIAL
		"native": return AdsProvider.AdFormat.NATIVE
		"app_open": return AdsProvider.AdFormat.APP_OPEN
		_:
			push_error("AdsService: Formato no reconocido -> " + format_str)
			return AdsProvider.AdFormat.INTERSTITIAL # Fallback seguro

# --- Callbacks del Provider (De la Infraestructura hacia el Dominio) ---

func _on_provider_ad_closed(_format: AdsProvider.AdFormat) -> void:
	# Avisar al juego que puede quitar la pausa
	Glapi.dispatch(AdClosedEvent.new())

func _on_provider_ad_rewarded(_format: AdsProvider.AdFormat, reward_type: String, reward_amount: int) -> void:
	# Otorgar la recompensa en el juego
	Glapi.dispatch(AdRewardedEvent.new(reward_type, reward_amount))

func _on_provider_ad_impression(format_name: String, ad_unit_name: String, currency: String, value: float) -> void:
	# Magia de la arquitectura: 
	# Al despachar esto, el `AnalyticsService` lo atrapará automáticamente y lo enviará a Firebase.
	Glapi.dispatch(AdImpressionEvent.new(format_name, ad_unit_name, currency, value))
