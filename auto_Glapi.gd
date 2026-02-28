# auto_Glapi.gd
extends Node

signal _analytics_event_dispatched(event: GlapiEvent)

var ads: AdsService
var analytics: AnalyticsService
var storage: StorageService

func _ready() -> void:
	initialize()

# 1. ANALÍTICA: Mantenemos el dispatch para el patrón Fire-and-Forget
func dispatch(event: GlapiEvent) -> void:
	_analytics_event_dispatched.emit(event)

# Método principal de configuración que el programador llamará
func initialize(
	ads_prov: IAdsProvider = null, 
	analytics_prov: IAnalyticsProvider = null, 
	storage_prov: IStorageProvider = null
) -> void:
	
	# Inyectamos el provider real o instanciamos el Mock por defecto
	_setup_ads(ads_prov if ads_prov else MockAdsProvider.new())
	_setup_analytics(analytics_prov if analytics_prov else MockAnalyticsProvider.new())
	_setup_storage(storage_prov if storage_prov else MockStorageProvider.new())
	
	print("⚙️ FRAMEWORK: Inicialización completada.")


func _setup_analytics(provider: IAnalyticsProvider) -> void:
	analytics = AnalyticsService.new(provider)
	_analytics_event_dispatched.connect(analytics.handle_event)
	print("⚙️ FRAMEWORK: Analítica conectada usando ", provider.get_class())

func _setup_ads(provider: IAdsProvider) -> void:
	ads = AdsService.new(provider)
	print("⚙️ FRAMEWORK: Anuncios conectado usando ", provider.get_class())

func _setup_storage(provider: IStorageProvider) -> void:
	storage = StorageService.new(provider)
	print("⚙️ FRAMEWORK: Almacenamiento conectado usando ", provider.get_class())
