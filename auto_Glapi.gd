# auto_Glapi.gd
extends Node

var ads: AdsService
var analytics: AnalyticsService
var storage: StorageService
var crashlytics: CrashlyticsService
var remote_config: RemoteConfigService

func _ready() -> void:
	initialize()

# 1. ANALÍTICA: Mantenemos el dispatch para el patrón Fire-and-Forget
func dispatch(event: GlapiEvent) -> void:
	if analytics:
		analytics.handle_event(event)
	else:
		push_warning("Glapi: Analytics no está listo.")

# Método principal de configuración que el programador llamará
func initialize(
	ads_prov: IAdsAdapter = null, 
	analytics_prov: IAnalyticsAdapter = null, 
	storage_prov: IStorageAdapter = null,
	crashlytics_prov: ICrashlyticsAdapter = null,
	remote_config_prov: IRemoteConfigAdapter = null
) -> void:
	
	_setup_ads(ads_prov if ads_prov else MockAdsAdapter.new())
	_setup_analytics(analytics_prov if analytics_prov else MockAnalyticsAdapter.new())
	_setup_storage(storage_prov if storage_prov else MockStorageAdapter.new())
	_setup_crashlytics(crashlytics_prov if crashlytics_prov else MockCrashlyticsAdapter.new())
	_setup_remote_config(remote_config_prov if remote_config_prov else MockRemoteConfigAdapter.new())
	
	print("⚙️ FRAMEWORK: Inicialización completada.")


func _setup_analytics(provider: IAnalyticsAdapter) -> void:
	analytics = AnalyticsService.new(provider)
	print("⚙️ FRAMEWORK: Analítica conectada usando ", provider.get_class())

func _setup_ads(provider: IAdsAdapter) -> void:
	ads = AdsService.new(provider)
	print("⚙️ FRAMEWORK: Anuncios conectado usando ", provider.get_class())

func _setup_storage(provider: IStorageAdapter) -> void:
	storage = StorageService.new(provider)
	print("⚙️ FRAMEWORK: Almacenamiento conectado usando ", provider.get_class())

func _setup_crashlytics(provider: ICrashlyticsAdapter) -> void:
	crashlytics = CrashlyticsService.new(provider)
	print("⚙️ FRAMEWORK: Crashlytics conectado usando ", provider.get_class())

func _setup_remote_config(provider: IRemoteConfigAdapter) -> void:
	remote_config = RemoteConfigService.new(provider)
	print("⚙️ FRAMEWORK: Remote Config conectado usando ", provider.get_class())
