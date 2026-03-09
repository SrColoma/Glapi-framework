# auto_Glapi.gd
extends Node

var ads: AdsService
var analytics: AnalyticsService
var storage: StorageService
var crashlytics: CrashlyticsService
var remote_config: RemoteConfigService
var iap: IAPService 
var game_services: GameServicesService 
var scene_transition: SceneTransitionManager
var overlays: OverlayManager
var time: TimeManager
var input: InputDeviceDetector
var debug: DebugConsoleService
var settings: SettingsService
var pooling: ObjectPoolService
var audio: AudioService

# 1. ANALÍTICA
func dispatch(event: GlapiEvent) -> void:
	if analytics:
		analytics.handle_event(event)
	else:
		push_warning("Glapi: Analytics no está listo.")

# Método principal de configuración
func initialize(
	ads_prov: IAdsAdapter = null, 
	analytics_prov: IAnalyticsAdapter = null, 
	storage_prov: IStorageAdapter = null,
	crashlytics_prov: ICrashlyticsAdapter = null,
	remote_config_prov: IRemoteConfigAdapter = null,
	iap_prov: IIAPAdapter = null,
	game_services_prov: IGameServicesAdapter = null,
	settings_prov: ISettingsAdapter = null,
	audio_prov: IAudioAdapter = null
) -> void:
	
	_setup_ads(ads_prov if ads_prov else MockAdsAdapter.new())
	_setup_analytics(analytics_prov if analytics_prov else MockAnalyticsAdapter.new())
	_setup_storage(storage_prov if storage_prov else MockStorageAdapter.new())
	_setup_crashlytics(crashlytics_prov if crashlytics_prov else MockCrashlyticsAdapter.new())
	_setup_remote_config(remote_config_prov if remote_config_prov else MockRemoteConfigAdapter.new())
	_setup_iap(iap_prov if iap_prov else MockIAPAdapter.new())
	_setup_game_services(game_services_prov if game_services_prov else MockGameServicesAdapter.new())
	_setup_scene_transition()
	_setup_input_detector()
	_setup_debug_console()
	_setup_settings(settings_prov if settings_prov else MockSettingsAdapter.new())
	_setup_audio(audio_prov if audio_prov else GodotAudioAdapter.new())
	
	print("⚙️ GLAPI: FRAMEWORK DE PRODUCCIÓN INICIALIZADO AL 100%.")

func _setup_analytics(adapter: IAnalyticsAdapter) -> void:
	analytics = AnalyticsService.new(adapter)
	print("⚙️ FRAMEWORK: Analítica conectada usando ", adapter.get_class())

func _setup_ads(adapter: IAdsAdapter) -> void:
	ads = AdsService.new(adapter)
	print("⚙️ FRAMEWORK: Anuncios conectado usando ", adapter.get_class())

func _setup_storage(adapter: IStorageAdapter) -> void:
	storage = StorageService.new(adapter)
	print("⚙️ FRAMEWORK: Almacenamiento conectado usando ", adapter.get_class())

func _setup_crashlytics(adapter: ICrashlyticsAdapter) -> void:
	crashlytics = CrashlyticsService.new(adapter)
	print("⚙️ FRAMEWORK: Crashlytics conectado usando ", adapter.get_class())

func _setup_remote_config(adapter: IRemoteConfigAdapter) -> void:
	remote_config = RemoteConfigService.new(adapter)
	print("⚙️ FRAMEWORK: Remote Config conectado usando ", adapter.get_class())

func _setup_iap(adapter: IIAPAdapter) -> void:
	iap = IAPService.new(adapter)
	print("⚙️ FRAMEWORK: IAP conectado usando ", adapter.get_class())

func _setup_game_services(adapter: IGameServicesAdapter) -> void:
	game_services = GameServicesService.new(adapter)
	print("⚙️ FRAMEWORK: Game Services conectado usando ", adapter.get_class())

func _setup_scene_transition() -> void:
	# SceneTransitionManager no requiere inicialización, es un manager simple
	scene_transition = SceneTransitionManager.new()
	add_child(scene_transition)
	
	overlays = OverlayManager.new()
	add_child(overlays)
	
	time = TimeManager.new()
	add_child(time)
	# TimeManager requiere el storage service pero Glapi lo asegura arriba
	time.initialize(storage)
	
	pooling = ObjectPoolService.new()
	add_child(pooling)
	
	print("⚙️ FRAMEWORK: Scene Transition, Overlays, Time & Object Pooling inicializados")

func _setup_input_detector() -> void:
	input = InputDeviceDetector.new()
	add_child(input)
	print("⚙️ FRAMEWORK: Input Detector inicializado")

func _setup_debug_console() -> void:
	debug = DebugConsoleService.new()
	# Forzamos el nombre explícito para poder buscar con has_node("debug")
	debug.name = "debug"
	add_child(debug)
	print("⚙️ FRAMEWORK: Debug Console inicializada")

func _setup_settings(adapter: ISettingsAdapter) -> void:
	settings = SettingsService.new(adapter)
	print("⚙️ FRAMEWORK: Settings conectado usando ", adapter.get_class())

func _setup_audio(adapter: IAudioAdapter) -> void:
	audio = AudioService.new(adapter)
	print("⚙️ FRAMEWORK: Audio conectado usando ", adapter.get_class())
