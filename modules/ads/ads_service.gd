class_name AdsService extends GlapiService

const AdFormat = IAdsAdapter.AdFormat
const BannerPosition = IAdsAdapter.BannerPosition
const BannerSize = IAdsAdapter.BannerSize

signal ad_loaded(format: IAdsAdapter.AdFormat)
signal ad_failed_to_load(format: IAdsAdapter.AdFormat, error_msg: String)
signal ad_closed(format: IAdsAdapter.AdFormat)
signal ad_rewarded(format: IAdsAdapter.AdFormat, reward_type: String, reward_amount: int)

func _init(adapter: IAdsAdapter) -> void:
	_adapter = adapter
	_adapter.initialize()
	_adapter.ad_loaded.connect(func(f): ad_loaded.emit(f))
	_adapter.ad_failed_to_load.connect(func(f, e): ad_failed_to_load.emit(f, e))
	_adapter.ad_closed.connect(_on_adapter_ad_closed)
	_adapter.ad_rewarded.connect(_on_adapter_ad_rewarded)
	_adapter.ad_impression_recorded.connect(_on_adapter_ad_impression)


func load_ad(format_str: String, ad_unit_id: String = "", position: IAdsAdapter.BannerPosition = IAdsAdapter.BannerPosition.BOTTOM, size: IAdsAdapter.BannerSize = IAdsAdapter.BannerSize.BANNER) -> void:
	var format = _parse_format_string(format_str)
	_adapter.load_ad(format, ad_unit_id, position, size)

func show_ad(format_str: String) -> void:
	var format = _parse_format_string(format_str)
	_adapter.show_ad(format)

func hide_ad(format_str: String) -> void:
	var format = _parse_format_string(format_str)
	if _adapter.has_method("hide_ad"): _adapter.hide_ad(format)

func destroy_ad(format_str: String) -> void:
	var format = _parse_format_string(format_str)
	if _adapter.has_method("destroy_ad"): _adapter.destroy_ad(format)

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

# --- Callbacks del adapter ---

func _on_adapter_ad_closed(format: IAdsAdapter.AdFormat) -> void:
	# Emitimos la señal local del servicio para que el juego la atrape (await)
	ad_closed.emit(format)

func _on_adapter_ad_rewarded(format: IAdsAdapter.AdFormat, reward_type: String, reward_amount: int) -> void:
	# Emitimos la señal local para dar la recompensa
	ad_rewarded.emit(format, reward_type, reward_amount)

func _on_adapter_ad_impression(format_name: String, ad_unit_name: String, currency: String, value: float) -> void:
	# 🌟 ARQUITECTURA LIMPIA EN ACCIÓN 🌟
	# Esto alimenta a Firebase/Analítica sin que el desarrollador mueva un dedo en el código del juego.
	# (Asegúrate de que Glapi.gd sea accesible globalmente o usa la ruta correcta si tu autoload se llama de otra forma).
	Glapi.dispatch(AdImpressionEvent.new(format_name, ad_unit_name, currency, value))
