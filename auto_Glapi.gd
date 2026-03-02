# auto_Glapi.gd
extends Node

var ads: AdsService
var analytics: AnalyticsService
var storage: StorageService
var crashlytics: CrashlyticsService
var remote_config: RemoteConfigService
var iap: IAPService 
var game_services: GameServicesService 


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
	game_services_prov: IGameServicesAdapter = null # 🌟 NUEVO
) -> void:
	
	_setup_ads(ads_prov if ads_prov else MockAdsAdapter.new())
	_setup_analytics(analytics_prov if analytics_prov else MockAnalyticsAdapter.new())
	_setup_storage(storage_prov if storage_prov else MockStorageAdapter.new())
	_setup_crashlytics(crashlytics_prov if crashlytics_prov else MockCrashlyticsAdapter.new())
	_setup_remote_config(remote_config_prov if remote_config_prov else MockRemoteConfigAdapter.new())
	_setup_iap(iap_prov if iap_prov else MockIAPAdapter.new())
	_setup_game_services(game_services_prov if game_services_prov else MockGameServicesAdapter.new()) # 🌟 NUEVO
	
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

# 🌟 NUEVA FUNCIÓN
func _setup_game_services(adapter: IGameServicesAdapter) -> void:
	game_services = GameServicesService.new(adapter)
	print("⚙️ FRAMEWORK: Game Services conectado usando ", adapter.get_class())
