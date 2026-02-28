class_name PoingStudiosAdMobAdapter extends IAdsAdapter

var _banner_view: AdView
var _interstitial_ad
var _rewarded_ad
var _rewarded_interstitial_ad

# 🌟 NUEVO: Callbacks (El patrón que exige tu versión del plugin)
var _interstitial_cb: InterstitialAdLoadCallback
var _rewarded_cb: RewardedAdLoadCallback
var _rewarded_interstitial_cb: RewardedInterstitialAdLoadCallback

var _is_initialized: bool = false

func initialize() -> void:
	if Engine.has_singleton("MobileAds"):
		MobileAds.initialize()
		_is_initialized = true
		_setup_callbacks()
		print("🟢 ADMOB: SDK de Poing Studios inicializado correctamente.")
	else:
		_is_initialized = false
		push_warning("⚠️ ADMOB: Singleton no encontrado. El provider está inactivo (Modo PC).")

func _setup_callbacks() -> void:
	# Preparamos los "receptores" que esperarán a que el anuncio se descargue
	_interstitial_cb = InterstitialAdLoadCallback.new()
	_interstitial_cb.on_ad_loaded = _on_interstitial_loaded
	_interstitial_cb.on_ad_failed_to_load = _on_generic_failed_to_load.bind(AdFormat.INTERSTITIAL)
	
	_rewarded_cb = RewardedAdLoadCallback.new()
	_rewarded_cb.on_ad_loaded = _on_rewarded_loaded
	_rewarded_cb.on_ad_failed_to_load = _on_generic_failed_to_load.bind(AdFormat.REWARDED)
	
	_rewarded_interstitial_cb = RewardedInterstitialAdLoadCallback.new()
	_rewarded_interstitial_cb.on_ad_loaded = _on_rewarded_interstitial_loaded
	_rewarded_interstitial_cb.on_ad_failed_to_load = _on_generic_failed_to_load.bind(AdFormat.REWARDED_INTERSTITIAL)

# --- 1. Carga de Anuncios ---

func load_ad(format: AdFormat, ad_unit_id: String = "", position: BannerPosition = BannerPosition.BOTTOM) -> void:
	if not _is_initialized: return
	var request := AdRequest.new()
	
	match format:
		AdFormat.BANNER:
			print("⏳ ADMOB: Solicitando carga de Banner...")
			if _banner_view: _banner_view.destroy()
			var poing_pos = _get_poing_position(position)
			_banner_view = AdView.new(ad_unit_id, AdSize.BANNER, poing_pos)
			
			# Usamos duck typing (sin tipado en el parámetro 'e') para evitar errores de clase
			_banner_view.on_ad_loaded.connect(func(): ad_loaded.emit(AdFormat.BANNER))
			_banner_view.on_ad_failed_to_load.connect(func(e): ad_failed_to_load.emit(AdFormat.BANNER, str(e)))
			_banner_view.load_ad(request)
			
		AdFormat.INTERSTITIAL:
			print("⏳ ADMOB: Solicitando carga de Interstitial...")
			InterstitialAdLoader.new().load(ad_unit_id, request, _interstitial_cb)
			
		AdFormat.REWARDED:
			print("⏳ ADMOB: Solicitando carga de Rewarded...")
			RewardedAdLoader.new().load(ad_unit_id, request, _rewarded_cb)
			
		AdFormat.REWARDED_INTERSTITIAL:
			print("⏳ ADMOB: Solicitando carga de Rewarded Interstitial...")
			RewardedInterstitialAdLoader.new().load(ad_unit_id, request, _rewarded_interstitial_cb)
			
		AdFormat.APP_OPEN, AdFormat.NATIVE:
			push_warning("⚠️ ADMOB: Formato no soportado nativamente por esta versión del plugin.")
			ad_failed_to_load.emit(format, "Formato no soportado.")
			
		_: push_error("ADMOB: Formato no reconocido.")

# --- 2. Mostrar Anuncios ---

func show_ad(format: AdFormat) -> void:
	if not _is_initialized:
		ad_closed.emit(format)
		return

	match format:
		AdFormat.BANNER:
			if _banner_view: _banner_view.show()
			else: push_warning("⚠️ ADMOB: Banner no cargado.")
		AdFormat.INTERSTITIAL:
			if _interstitial_ad: _interstitial_ad.show()
			else: _warn_not_loaded("Interstitial")
		AdFormat.REWARDED:
			if _rewarded_ad: _rewarded_ad.show()
			else: _warn_not_loaded("Rewarded")
		AdFormat.REWARDED_INTERSTITIAL:
			if _rewarded_interstitial_ad: _rewarded_interstitial_ad.show()
			else: _warn_not_loaded("Rewarded Interstitial")

func hide_ad(format: AdFormat) -> void:
	if not _is_initialized: return
	if format == AdFormat.BANNER and _banner_view:
		_banner_view.hide()

func destroy_ad(format: AdFormat) -> void:
	if not _is_initialized: return
	if format == AdFormat.BANNER and _banner_view:
		_banner_view.destroy()
		_banner_view = null

func _warn_not_loaded(ad_name: String) -> void:
	push_warning("⚠️ ADMOB: Se intentó mostrar un " + ad_name + " pero no estaba cargado.")

# --- 3. Callbacks de Carga Exitosa (Aquí el plugin nos "entrega" el anuncio) ---

func _on_interstitial_loaded(ad) -> void:
	_interstitial_ad = ad
	_interstitial_ad.full_screen_content_callback.on_ad_dismissed_full_screen_content = func(): ad_closed.emit(AdFormat.INTERSTITIAL)
	ad_loaded.emit(AdFormat.INTERSTITIAL)
	print("✅ ADMOB: Interstitial cargado exitosamente.")

func _on_rewarded_loaded(ad) -> void:
	_rewarded_ad = ad
	_rewarded_ad.full_screen_content_callback.on_ad_dismissed_full_screen_content = func(): ad_closed.emit(AdFormat.REWARDED)
	
	# Usamos asignación dinámica por si la propiedad cambia de nombre en versiones menores
	if "on_user_earned_reward" in _rewarded_ad:
		_rewarded_ad.on_user_earned_reward = func(reward): _on_poing_user_earned_reward(reward, AdFormat.REWARDED)
	
	ad_loaded.emit(AdFormat.REWARDED)
	print("✅ ADMOB: Rewarded cargado exitosamente.")

func _on_rewarded_interstitial_loaded(ad) -> void:
	_rewarded_interstitial_ad = ad
	_rewarded_interstitial_ad.full_screen_content_callback.on_ad_dismissed_full_screen_content = func(): ad_closed.emit(AdFormat.REWARDED_INTERSTITIAL)
	
	if "on_user_earned_reward" in _rewarded_interstitial_ad:
		_rewarded_interstitial_ad.on_user_earned_reward = func(reward): _on_poing_user_earned_reward(reward, AdFormat.REWARDED_INTERSTITIAL)
		
	ad_loaded.emit(AdFormat.REWARDED_INTERSTITIAL)
	print("✅ ADMOB: Rewarded Interstitial cargado exitosamente.")

# Funciones genéricas de error (sin tipado estricto en el parámetro ad_error)
func _on_generic_failed_to_load(ad_error, format: AdFormat) -> void:
	var error_msg = ad_error.message if "message" in ad_error else str(ad_error)
	ad_failed_to_load.emit(format, error_msg)
	print("❌ ADMOB: Falló carga del formato ", format, ": ", error_msg)

# --- 4. Extracción de Datos y Recompensas (Duck Typing) ---

func _on_poing_user_earned_reward(reward_item, format: AdFormat) -> void:
	# Extraemos la data de forma segura sin importar si reward_item es un Objeto, Diccionario, etc.
	var type = reward_item.type if "type" in reward_item else "unknown"
	var amount = reward_item.amount if "amount" in reward_item else 1
	ad_rewarded.emit(format, type, amount)

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
