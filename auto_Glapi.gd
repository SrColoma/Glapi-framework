# res://framework/auto_Glapi.gd
extends Node

signal event_dispatched(event: GlapiEvent)

var ads_service: AdsService
var analytics_service: AnalyticsService
var storage_service: StorageService

func dispatch(event: GlapiEvent) -> void:
	# TODO: Add any event validation or logging here.
	event_dispatched.emit(event)

# Método principal de configuración que el programador llamará
func initialize(
	ads_prov: AdsProvider = null, 
	analytics_prov: AnalyticsProvider = null, 
	storage_prov: StorageProvider = null
	) -> void:
	# Si recibe un provider, lo usa. Si no, instancia su propio Mock.
	setup_ads(ads_prov if ads_prov else MockAds.new())
	setup_analytics(analytics_prov if analytics_prov else MockAnalytics.new())
	setup_storage(storage_prov if storage_prov else MockStorage.new())
	
	print("⚙️ FRAMEWORK: Inicialización completada.")

func setup_ads(provider: AdsProvider) -> void:
	ads_service = AdsService.new(provider)
	event_dispatched.connect(ads_service.handle_event)
	print("⚙️ FRAMEWORK: Anuncios conectado usando ", provider.get_class())

func setup_analytics(provider: AnalyticsProvider) -> void:
	analytics_service = AnalyticsService.new(provider)
	event_dispatched.connect(analytics_service.handle_event)
	print("⚙️ FRAMEWORK: Analítica conectada usando ", provider.get_class())

func setup_storage(provider: StorageProvider) -> void:
	storage_service = StorageService.new(provider)
	event_dispatched.connect(storage_service.handle_event)
	print("⚙️ FRAMEWORK: Almacenamiento conectado usando ", provider.get_class())
