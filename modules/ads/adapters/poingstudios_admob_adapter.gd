class_name PoingStudiosAdMobAdapter extends IAdsAdapter

var _banner_view: AdView
var _banner_wants_to_show: bool = false
var _interstitial_ad
var _rewarded_ad
var _rewarded_interstitial_ad

# 🌟 NUEVO: Callbacks (El patrón que exige tu versión del plugin)
var _interstitial_cb: InterstitialAdLoadCallback
var _rewarded_cb: RewardedAdLoadCallback
var _rewarded_interstitial_cb: RewardedInterstitialAdLoadCallback

var _is_initialized: bool = false

func initialize() -> void:
	if MobileAds:
		MobileAds.initialize()
		_is_initialized = true
		_setup_callbacks()
		print("🟢 ADMOB: SDK de Poing Studios inicializado correctamente.")
	else:
		_is_initialized = false
		push_warning("⚠️ ADMOB: Singleton no encontrado. El adapter está inactivo (Modo PC).")

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

func load_ad(format: AdFormat, ad_unit_id: String = "", position: BannerPosition = BannerPosition.BOTTOM, size: BannerSize = BannerSize.BANNER) -> void:
	if not _is_initialized: return
	var request := AdRequest.new()
	
	match format:
		AdFormat.BANNER:
			print("⏳ ADMOB: Solicitando carga de Banner...")
			if _banner_view: 
				_banner_view.destroy()
				
			_banner_wants_to_show = false # 🌟 Aseguramos que empiece oculto
			
			var poing_pos = _get_poing_position(position)
			var poing_size = _get_poing_size(size)
			
			_banner_view = AdView.new(ad_unit_id, poing_size, poing_pos)
			_banner_view.hide() # 🌟 Ocultamos el contenedor apenas nace
			
			var ad_listener := AdListener.new()
			
			ad_listener.on_ad_loaded = func() -> void: 
				print("✅ ADMOB: Banner cargado.")
				# 🌟 Si terminó de cargar pero no hemos llamado a "show", lo mantenemos oculto
				if _banner_view and not _banner_wants_to_show:
					_banner_view.hide()
				ad_loaded.emit(AdFormat.BANNER)
				
			ad_listener.on_ad_failed_to_load = func(load_ad_error) -> void: 
				var err_msg = load_ad_error.message if "message" in load_ad_error else str(load_ad_error)
				print("❌ ADMOB: Error en Banner: ", err_msg)
				ad_failed_to_load.emit(AdFormat.BANNER, err_msg)
				
			ad_listener.on_ad_closed = func() -> void:
				ad_closed.emit(AdFormat.BANNER)
			
			_banner_view.ad_listener = ad_listener
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
			_banner_wants_to_show = true 
			if _banner_view: 
				print("📺 ADMOB: Mostrando Banner.")
				_banner_view.show()
			else: 
				push_warning("⚠️ ADMOB: Intentaste mostrar un Banner no cargado.")
				
		AdFormat.INTERSTITIAL:
			if _interstitial_ad: 
				_interstitial_ad.show()
			else: _warn_not_loaded("Interstitial")
			
		AdFormat.REWARDED:
			if _rewarded_ad:
				# 🌟 NUEVO: Creamos el Listener de recompensa y lo pasamos al show()
				var reward_listener := OnUserEarnedRewardListener.new()
				reward_listener.on_user_earned_reward = func(reward): 
					_on_poing_user_earned_reward(reward, AdFormat.REWARDED)
				_rewarded_ad.show(reward_listener)
			else: _warn_not_loaded("Rewarded")
			
		AdFormat.REWARDED_INTERSTITIAL:
			if _rewarded_interstitial_ad:
				# 🌟 NUEVO: Lo mismo para el formato mixto
				var reward_listener := OnUserEarnedRewardListener.new()
				reward_listener.on_user_earned_reward = func(reward): 
					_on_poing_user_earned_reward(reward, AdFormat.REWARDED_INTERSTITIAL)
				_rewarded_interstitial_ad.show(reward_listener)
			else: _warn_not_loaded("Rewarded Interstitial")

func hide_ad(format: AdFormat) -> void:
	if not _is_initialized: return
	if format == AdFormat.BANNER:
		_banner_wants_to_show = false 
		if _banner_view:
			_banner_view.hide()

func destroy_ad(format: AdFormat) -> void:
	if not _is_initialized: return
	
	match format:
		AdFormat.BANNER:
			_banner_wants_to_show = false
			if _banner_view:
				_banner_view.destroy()
				_banner_view = null
		AdFormat.INTERSTITIAL:
			if _interstitial_ad:
				if _interstitial_ad.has_method("destroy"): _interstitial_ad.destroy()
				_interstitial_ad = null
		AdFormat.REWARDED:
			if _rewarded_ad:
				if _rewarded_ad.has_method("destroy"): _rewarded_ad.destroy()
				_rewarded_ad = null
		AdFormat.REWARDED_INTERSTITIAL:
			if _rewarded_interstitial_ad:
				if _rewarded_interstitial_ad.has_method("destroy"): _rewarded_interstitial_ad.destroy()
				_rewarded_interstitial_ad = null

func _warn_not_loaded(ad_name: String) -> void:
	push_warning("⚠️ ADMOB: Se intentó mostrar un " + ad_name + " pero no estaba cargado.")

# --- 3. Callbacks de Carga Exitosa (Aquí el plugin nos "entrega" el anuncio) ---

func _on_interstitial_loaded(ad) -> void:
	_interstitial_ad = ad
	var fs_callback := FullScreenContentCallback.new()
	fs_callback.on_ad_dismissed_full_screen_content = func() -> void: ad_closed.emit(AdFormat.INTERSTITIAL)
	_interstitial_ad.full_screen_content_callback = fs_callback
	
	ad_loaded.emit(AdFormat.INTERSTITIAL)
	print("✅ ADMOB: Interstitial cargado exitosamente.")

func _on_rewarded_loaded(ad) -> void:
	_rewarded_ad = ad
	var fs_callback := FullScreenContentCallback.new()
	fs_callback.on_ad_dismissed_full_screen_content = func() -> void: ad_closed.emit(AdFormat.REWARDED)
	_rewarded_ad.full_screen_content_callback = fs_callback
	
	# 🌟 NOTA: Ya no configuramos la recompensa aquí. Lo haremos en el show().
	
	ad_loaded.emit(AdFormat.REWARDED)
	print("✅ ADMOB: Rewarded cargado exitosamente.")

func _on_rewarded_interstitial_loaded(ad) -> void:
	_rewarded_interstitial_ad = ad
	var fs_callback := FullScreenContentCallback.new()
	fs_callback.on_ad_dismissed_full_screen_content = func() -> void: ad_closed.emit(AdFormat.REWARDED_INTERSTITIAL)
	_rewarded_interstitial_ad.full_screen_content_callback = fs_callback
		
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

func _get_poing_size(size: BannerSize):
	match size:
		BannerSize.BANNER: return AdSize.BANNER
		BannerSize.LARGE_BANNER: return AdSize.LARGE_BANNER
		BannerSize.MEDIUM_RECTANGLE: return AdSize.MEDIUM_RECTANGLE
		BannerSize.FULL_BANNER: return AdSize.FULL_BANNER
		BannerSize.LEADERBOARD: return AdSize.LEADERBOARD
		_: return AdSize.BANNER
