# auto_Glapi.gd
extends Node

signal _analytics_event_dispatched(event: GlapiEvent)

var ads: AdsService
var analytics: AnalyticsService
var storage: StorageService

# 1. ANALÍTICA: Mantenemos el dispatch para el patrón Fire-and-Forget
func dispatch(event: GlapiEvent) -> void:
	_analytics_event_dispatched.emit(event)

# Método principal de configuración que el programador llamará
func initialize(
	ads_prov: AdsProvider = null, 
	analytics_prov: AnalyticsProvider = null, 
	storage_prov: StorageProvider = null
) -> void:
	
	# Inyectamos el provider real o instanciamos el Mock por defecto
	_setup_ads(ads_prov if ads_prov else MockAds.new())
	_setup_analytics(analytics_prov if analytics_prov else MockAnalytics.new())
	_setup_storage(storage_prov if storage_prov else MockStorage.new())
	
	print("⚙️ FRAMEWORK: Inicialización completada.")


func _setup_analytics(provider: AnalyticsProvider) -> void:
	analytics = AnalyticsService.new(provider)
	_analytics_event_dispatched.connect(analytics.handle_event)
	print("⚙️ FRAMEWORK: Analítica conectada usando ", provider.get_class())

func _setup_ads(provider: AdsProvider) -> void:
	ads = AdsService.new(provider)
	print("⚙️ FRAMEWORK: Anuncios conectado usando ", provider.get_class())

func _setup_storage(provider: StorageProvider) -> void:
	storage = StorageService.new(provider)
	print("⚙️ FRAMEWORK: Almacenamiento conectado usando ", provider.get_class())
