class_name MockAds extends AdsProvider

func initialize() -> void:
	print("🟡 MOCK ADS: SDK Inicializado.")

func load_ad(format: AdFormat, ad_unit_id: String = "mock_unit_id") -> void:
	var format_name = AdFormat.keys()[format]
	print("🟡 MOCK ADS: Cargando anuncio [", format_name, "]...")
	# Simulamos carga instantánea
	ad_loaded.emit(format)

func show_ad(format: AdFormat) -> void:
	var format_name = AdFormat.keys()[format]
	print("🟡 MOCK ADS: Mostrando anuncio [", format_name, "]. Pausando juego...")
	
	# Simulamos el callback de ingresos (eCPM) que los SDK reales disparan al mostrar un ad.
	# Esto alimentará tu dashboard de ARPDAU.
	ad_impression_recorded.emit(format_name.to_lower(), "mock_unit_01", "USD", 0.015)
	
	# Simulamos que el jugador ve el anuncio por 2 segundos.
	# Usamos el SceneTree para crear un timer asíncrono sin necesidad de añadir un Nodo.
	await Engine.get_main_loop().create_timer(2.0).timeout
	
	# Si es un anuncio recompensado, disparamos la señal de recompensa antes de cerrar
	if format == AdFormat.REWARDED or format == AdFormat.REWARDED_INTERSTITIAL:
		print("🟡 MOCK ADS: Video terminado. Entregando recompensa...")
		ad_rewarded.emit(format, "coins", 50) # Valores de ejemplo
		
	print("🟡 MOCK ADS: Anuncio cerrado. Reanudando juego...")
	ad_closed.emit(format)
