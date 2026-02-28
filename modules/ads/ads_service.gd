class_name AdsService extends GlapiService

const AdFormat = IAdsAdapter.AdFormat
const BannerPosition = IAdsAdapter.BannerPosition

# Señales que el juego podrá escuchar o "esperar" (await)
signal ad_loaded(format: IAdsAdapter.AdFormat)
signal ad_failed_to_load(format: IAdsAdapter.AdFormat, error_msg: String)
signal ad_closed(format: IAdsAdapter.AdFormat)
signal ad_rewarded(format: IAdsAdapter.AdFormat, reward_type: String, reward_amount: int)

func _init(provider: IAdsAdapter) -> void:
	_provider = provider
	_provider.initialize()
	
	# Conectamos las señales del provider hacia el servicio
	_provider.ad_loaded.connect(func(f): ad_loaded.emit(f))
	_provider.ad_failed_to_load.connect(func(f, e): ad_failed_to_load.emit(f, e))
	_provider.ad_closed.connect(_on_provider_ad_closed)
	_provider.ad_rewarded.connect(_on_provider_ad_rewarded)
	
	# Esta es la conexión especial que comunica Ads con Analytics
	_provider.ad_impression_recorded.connect(_on_provider_ad_impression)

# --- Métodos Directos (Reemplazan a handle_event) ---

func load_ad(format_str: String, ad_unit_id: String = "", position: IAdsAdapter.BannerPosition = IAdsAdapter.BannerPosition.BOTTOM) -> void:
	var format = _parse_format_string(format_str)
	_provider.load_ad(format, ad_unit_id, position)

func show_ad(format_str: String) -> void:
	var format = _parse_format_string(format_str)
	_provider.show_ad(format)

# Añade el nuevo método hide_ad
func hide_ad(format_str: String) -> void:
	var format = _parse_format_string(format_str)
	if _provider.has_method("hide_ad"):
		_provider.hide_ad(format)

func destroy_ad(format_str: String) -> void:
	var format = _parse_format_string(format_str)
	if _provider.has_method("destroy_ad"):
		_provider.destroy_ad(format)

# --- Funciones Auxiliares ---

func _parse_format_string(format_str: String) -> IAdsAdapter.AdFormat:
	match format_str.to_lower():
		"banner": return IAdsAdapter.AdFormat.BANNER
		"interstitial": return IAdsAdapter.AdFormat.INTERSTITIAL
		"rewarded": return IAdsAdapter.AdFormat.REWARDED
		"rewarded_interstitial": return IAdsAdapter.AdFormat.REWARDED_INTERSTITIAL
		"native": return IAdsAdapter.AdFormat.NATIVE
		"app_open": return IAdsAdapter.AdFormat.APP_OPEN
		_:
			push_error("AdsService: Formato no reconocido -> " + format_str)
			return IAdsAdapter.AdFormat.INTERSTITIAL

# --- Callbacks del Provider ---

func _on_provider_ad_closed(format: IAdsAdapter.AdFormat) -> void:
	# Emitimos la señal local del servicio para que el juego la atrape (await)
	ad_closed.emit(format)

func _on_provider_ad_rewarded(format: IAdsAdapter.AdFormat, reward_type: String, reward_amount: int) -> void:
	# Emitimos la señal local para dar la recompensa
	ad_rewarded.emit(format, reward_type, reward_amount)

func _on_provider_ad_impression(format_name: String, ad_unit_name: String, currency: String, value: float) -> void:
	# 🌟 ARQUITECTURA LIMPIA EN ACCIÓN 🌟
	# Esto alimenta a Firebase/Analítica sin que el desarrollador mueva un dedo en el código del juego.
	# (Asegúrate de que Glapi.gd sea accesible globalmente o usa la ruta correcta si tu autoload se llama de otra forma).
	Glapi.dispatch(AdImpressionEvent.new(format_name, ad_unit_name, currency, value))
