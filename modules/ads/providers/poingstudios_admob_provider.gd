class_name PoingStudiosAdMobProvider extends IAdsProvider

var _banner_view: AdView
var _interstitial_ad: InterstitialAd
var _rewarded_ad: RewardedAd
var _rewarded_interstitial_ad: RewardedInterstitialAd
var _app_open_ad: AppOpenAd
# Nota: NativeAd requiere una configuración de UI específica en Poing Studios usando NativeAdView

var _is_initialized: bool = false

func initialize() -> void:
	if Engine.has_singleton("MobileAds"):
		MobileAds.initialize()
		_is_initialized = true
		print("🟢 ADMOB: SDK de Poing Studios inicializado correctamente.")
	else:
		_is_initialized = false
		push_warning("⚠️ ADMOB: Singleton no encontrado. El provider está inactivo (Modo PC).")

# --- 1. Carga de Anuncios ---

func load_ad(format: AdFormat, ad_unit_id: String = "", position: BannerPosition = BannerPosition.BOTTOM) -> void:
	if not _is_initialized: return
	var request := AdRequest.new()
	
	match format:
		AdFormat.BANNER:
			print("⏳ ADMOB: Solicitando carga de Banner...")
			if _banner_view:
				_banner_view.destroy()
			
			var poing_pos = _get_poing_position(position)
			_banner_view = AdView.new(ad_unit_id, AdSize.BANNER, poing_pos)
			
			_banner_view.on_ad_loaded.connect(func(): 
				print("✅ ADMOB: Banner cargado.")
				ad_loaded.emit(AdFormat.BANNER)
			)
			_banner_view.on_ad_failed_to_load.connect(func(error: LoadAdError): 
				print("❌ ADMOB: Error en Banner: ", error.message)
				ad_failed_to_load.emit(AdFormat.BANNER, error.message)
			)
			_banner_view.on_paid_event.connect(func(ad_value): _on_poing_paid_event(AdFormat.BANNER, ad_value))
			_banner_view.load_ad(request)
			
		AdFormat.INTERSTITIAL:
			print("⏳ ADMOB: Solicitando carga de Interstitial...")
			InterstitialAd.load(ad_unit_id, request, _on_interstitial_loaded, _on_generic_failed_to_load.bind(AdFormat.INTERSTITIAL))
			
		AdFormat.REWARDED:
			print("⏳ ADMOB: Solicitando carga de Rewarded...")
			RewardedAd.load(ad_unit_id, request, _on_rewarded_loaded, _on_generic_failed_to_load.bind(AdFormat.REWARDED))
			
		AdFormat.REWARDED_INTERSTITIAL:
			print("⏳ ADMOB: Solicitando carga de Rewarded Interstitial...")
			RewardedInterstitialAd.load(ad_unit_id, request, _on_rewarded_interstitial_loaded, _on_generic_failed_to_load.bind(AdFormat.REWARDED_INTERSTITIAL))
			
		AdFormat.APP_OPEN:
			print("⏳ ADMOB: Solicitando carga de App Open...")
			# Poing Studios usualmente requiere la orientación (1 = PORTRAIT, 2 = LANDSCAPE)
			AppOpenAd.load(ad_unit_id, request, 1, _on_app_open_loaded, _on_generic_failed_to_load.bind(AdFormat.APP_OPEN))
			
		AdFormat.NATIVE:
			push_warning("⚠️ ADMOB: La carga de Native Ads requiere instanciar un NativeAdView en tu UI. Solo se ha disparado el evento base.")
			# Aquí iría la lógica con AdLoader según la UI que hayas creado.
			
		_:
			push_error("ADMOB: Formato no soportado.")

# --- 2. Mostrar Anuncios ---

func show_ad(format: AdFormat) -> void:
	if not _is_initialized:
		ad_closed.emit(format)
		return

	match format:
		AdFormat.BANNER:
			if _banner_view:
				print("📺 ADMOB: Mostrando Banner.")
				_banner_view.show()
			else:
				push_warning("⚠️ ADMOB: Intentaste mostrar un Banner no cargado.")
		AdFormat.INTERSTITIAL:
			if _interstitial_ad:
				_interstitial_ad.show()
			else:
				_warn_not_loaded("Interstitial", format)
		AdFormat.REWARDED:
			if _rewarded_ad:
				_rewarded_ad.show()
			else:
				_warn_not_loaded("Rewarded", format)
		AdFormat.REWARDED_INTERSTITIAL:
			if _rewarded_interstitial_ad:
				_rewarded_interstitial_ad.show()
			else:
				_warn_not_loaded("Rewarded Interstitial", format)
		AdFormat.APP_OPEN:
			if _app_open_ad:
				_app_open_ad.show()
			else:
				_warn_not_loaded("App Open", format)
		AdFormat.NATIVE:
			push_warning("⚠️ ADMOB: Native Ads se muestran haciendo visible tu nodo NativeAdView.")

func hide_ad(format: AdFormat) -> void:
	if not _is_initialized: return
	if format == AdFormat.BANNER and _banner_view:
		_banner_view.hide()

func destroy_ad(format: AdFormat) -> void:
	if not _is_initialized: return
	if format == AdFormat.BANNER and _banner_view:
		_banner_view.destroy()
		_banner_view = null

func _warn_not_loaded(ad_name: String, format: AdFormat) -> void:
	push_warning("⚠️ ADMOB: Se intentó mostrar un " + ad_name + " pero no estaba cargado.")
	# Ya no emitimos ad_closed aquí para no confundir la lógica del juego.

# --- 3. Callbacks de Carga Exitosa ---

func _on_interstitial_loaded(ad: InterstitialAd) -> void:
	_interstitial_ad = ad
	_interstitial_ad.on_ad_dismissed_full_screen_content.connect(func(): ad_closed.emit(AdFormat.INTERSTITIAL))
	_interstitial_ad.on_paid_event.connect(func(val): _on_poing_paid_event(AdFormat.INTERSTITIAL, val))
	ad_loaded.emit(AdFormat.INTERSTITIAL)

func _on_rewarded_loaded(ad: RewardedAd) -> void:
	_rewarded_ad = ad
	_rewarded_ad.on_ad_dismissed_full_screen_content.connect(func(): ad_closed.emit(AdFormat.REWARDED))
	_rewarded_ad.on_user_earned_reward.connect(_on_poing_user_earned_reward.bind(AdFormat.REWARDED))
	_rewarded_ad.on_paid_event.connect(func(val): _on_poing_paid_event(AdFormat.REWARDED, val))
	ad_loaded.emit(AdFormat.REWARDED)

func _on_rewarded_interstitial_loaded(ad: RewardedInterstitialAd) -> void:
	_rewarded_interstitial_ad = ad
	_rewarded_interstitial_ad.on_ad_dismissed_full_screen_content.connect(func(): ad_closed.emit(AdFormat.REWARDED_INTERSTITIAL))
	_rewarded_interstitial_ad.on_user_earned_reward.connect(_on_poing_user_earned_reward.bind(AdFormat.REWARDED_INTERSTITIAL))
	_rewarded_interstitial_ad.on_paid_event.connect(func(val): _on_poing_paid_event(AdFormat.REWARDED_INTERSTITIAL, val))
	ad_loaded.emit(AdFormat.REWARDED_INTERSTITIAL)

func _on_app_open_loaded(ad: AppOpenAd) -> void:
	_app_open_ad = ad
	_app_open_ad.on_ad_dismissed_full_screen_content.connect(func(): ad_closed.emit(AdFormat.APP_OPEN))
	_app_open_ad.on_paid_event.connect(func(val): _on_poing_paid_event(AdFormat.APP_OPEN, val))
	ad_loaded.emit(AdFormat.APP_OPEN)

# Generador de errores de carga genérico
func _on_generic_failed_to_load(ad_error: LoadAdError, format: AdFormat) -> void:
	ad_failed_to_load.emit(format, ad_error.message)
	print("❌ ADMOB: Falló carga del formato ", format, ": ", ad_error.message)

# --- 4. Extracción de Datos y Utilidades ---

func _on_poing_user_earned_reward(reward_item: RewardItem, format: AdFormat) -> void:
	ad_rewarded.emit(format, reward_item.type, reward_item.amount)

func _on_poing_paid_event(format: AdFormat, ad_value: AdValue) -> void:
	var format_name = AdFormat.keys()[format].to_lower()
	var real_value = ad_value.value_micros / 1000000.0
	ad_impression_recorded.emit(format_name, "admob_unit", ad_value.currency_code, real_value)

func _get_poing_position(pos: BannerPosition) -> int:
	match pos:
		BannerPosition.TOP: return AdPosition.Values.TOP
		BannerPosition.BOTTOM: return AdPosition.Values.BOTTOM
		BannerPosition.LEFT: return AdPosition.Values.LEFT
		BannerPosition.RIGHT: return AdPosition.Values.RIGHT
		BannerPosition.TOP_LEFT: return AdPosition.Values.TOP_LEFT
		BannerPosition.TOP_RIGHT: return AdPosition.Values.TOP_RIGHT
		BannerPosition.BOTTOM_LEFT: return AdPosition.Values.BOTTOM_LEFT
		BannerPosition.BOTTOM_RIGHT: return AdPosition.Values.BOTTOM_RIGHT
		BannerPosition.CENTER: return AdPosition.Values.CENTER
		_: return AdPosition.Values.BOTTOM
