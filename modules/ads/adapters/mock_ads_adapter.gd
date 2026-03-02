class_name MockAdsAdapter extends IAdsAdapter

var _mock_native_canvas: CanvasLayer
var _mock_banner_canvas: CanvasLayer
var _banner_rect: ColorRect
# 🌟 NUEVO: Canvas para los anuncios de pantalla completa
var _fullscreen_canvas: CanvasLayer 

# 🌟 NUEVO: Diccionario para rastrear qué anuncios están realmente "cargados"
var _loaded_ads: Dictionary = {
	AdFormat.BANNER: false,
	AdFormat.INTERSTITIAL: false,
	AdFormat.REWARDED: false,
	AdFormat.REWARDED_INTERSTITIAL: false,
	AdFormat.APP_OPEN: false,
	AdFormat.NATIVE: false
}

func initialize() -> void:
	print("🟡 MOCK ADS: SDK Inicializado.")

# --- 1. Carga de Anuncios ---
func load_ad(format: AdFormat, ad_unit_id: String = "", position: BannerPosition = BannerPosition.BOTTOM, size: BannerSize = BannerSize.BANNER) -> void:
	var format_name = AdFormat.keys()[format]
	print("⏳ MOCK ADS: Solicitando red para [", format_name, "]...")
	
	# Simulamos el retraso de internet (0.5 segundos)
	await Engine.get_main_loop().create_timer(0.5).timeout
	
	if format == AdFormat.BANNER:
		# 🌟 CORREGIDO: Ahora le pasamos la posición Y el tamaño
		_setup_visual_mock_banner(position, size)
	
	# Marcamos como cargado y avisamos al sistema
	_loaded_ads[format] = true
	ad_loaded.emit(format)
	print("✅ MOCK ADS: [", format_name, "] descargado y listo.")

# --- 2. Mostrar Anuncios ---

func show_ad(format: AdFormat) -> void:
	var format_name = AdFormat.keys()[format]
	
	# 🌟 Validamos el estado (Igual que AdMob real)
	if not _loaded_ads[format]:
		push_warning("⚠️ MOCK ADS: Se intentó mostrar un " + format_name + " pero no estaba cargado.")
		return
	
	# --- LÓGICA PARA BANNERS ---
	if format == AdFormat.BANNER:
		print("📺 MOCK ADS: Mostrando BANNER en pantalla.")
		if is_instance_valid(_mock_banner_canvas):
			_mock_banner_canvas.visible = true
		
		ad_impression_recorded.emit("banner", "mock_banner", "USD", 0.005)
		return 

	# --- LÓGICA PARA NATIVOS ---
	if format == AdFormat.NATIVE:
		print("📺 MOCK ADS: Mostrando NATIVE AD falso en pantalla.")
		_show_visual_mock_native()
		ad_impression_recorded.emit("native", "mock_native", "USD", 0.010)
		return

	# --- LÓGICA PARA FULLSCREEN (Interstitial, Rewarded, App Open) ---
	_show_visual_fullscreen_ad(format, format_name)

func hide_ad(format: AdFormat) -> void:
	if format == AdFormat.BANNER:
		print("🙈 MOCK ADS: Ocultando BANNER.")
		if is_instance_valid(_mock_banner_canvas):
			_mock_banner_canvas.visible = false

func destroy_ad(format: AdFormat) -> void:
	if format == AdFormat.BANNER:
		print("💥 MOCK ADS: Destruyendo BANNER.")
		if is_instance_valid(_mock_banner_canvas):
			_mock_banner_canvas.queue_free()
			_loaded_ads[AdFormat.BANNER] = false
	
	# 🌟 NUEVO: Destruir el Native Mock
	if format == AdFormat.NATIVE:
		print("💥 MOCK ADS: Destruyendo NATIVE AD.")
		if is_instance_valid(_mock_native_canvas):
			_mock_native_canvas.queue_free()
			_loaded_ads[AdFormat.NATIVE] = false
			
# --- 3. Simulación Visual de Anuncios Fullscreen ---

func _show_visual_fullscreen_ad(format: AdFormat, format_name: String) -> void:
	print("📺 MOCK ADS: Mostrando anuncio FULLSCREEN [", format_name, "]. Pausando juego...")
	ad_impression_recorded.emit(format_name.to_lower(), "mock_fullscreen", "USD", 0.025)
	
	# 1. Creamos la UI que tapa la pantalla
	_fullscreen_canvas = CanvasLayer.new()
	_fullscreen_canvas.layer = 128
	
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.1, 0.95)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	# Bloqueamos los clics del usuario mientras el anuncio está "reproduciéndose"
	bg.mouse_filter = Control.MOUSE_FILTER_STOP 
	
	var label = Label.new()
	label.text = "SIMULANDO ANUNCIO:\n" + format_name + "\n\n(Espera unos segundos...)"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	bg.add_child(label)
	_fullscreen_canvas.add_child(bg)
	Engine.get_main_loop().current_scene.add_child(_fullscreen_canvas)
	
	# 2. Simulamos la duración del video/intersticial
	var ad_duration = 1.0 if format == AdFormat.APP_OPEN else 2.5
	await Engine.get_main_loop().create_timer(ad_duration).timeout
	
	# 3. Entregamos recompensas si aplica
	if format in [AdFormat.REWARDED, AdFormat.REWARDED_INTERSTITIAL]:
		print("🎁 MOCK ADS: Video terminado. Entregando recompensa...")
		ad_rewarded.emit(format, "mock_coins", 50) 
		
	# 4. Cerramos el anuncio y limpiamos
	print("🚪 MOCK ADS: Anuncio cerrado. Reanudando juego...")
	_fullscreen_canvas.queue_free()
	
	# 🌟 MUY IMPORTANTE: Los anuncios de pantalla completa se consumen al usarse.
	_loaded_ads[format] = false 
	
	# 5. Avisamos al juego que ya se cerró
	ad_closed.emit(format)


# --- 4. Funciones Auxiliares para el Banner Visual ---

# --- 4. Funciones Auxiliares para el Banner Visual ---

# 🌟 CORREGIDO: Añadimos 'size: BannerSize' a los parámetros
func _setup_visual_mock_banner(pos: BannerPosition, size: BannerSize) -> void:
	if is_instance_valid(_mock_banner_canvas):
		_mock_banner_canvas.queue_free()
		
	_mock_banner_canvas = CanvasLayer.new()
	_mock_banner_canvas.layer = 128
	_mock_banner_canvas.visible = false
	
	var container = Control.new()
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	_mock_banner_canvas.add_child(container)
	
	# 🌟 NUEVO: Obtenemos el tamaño en píxeles
	var dimensions = _get_mock_size_vector(size)
	
	_banner_rect = ColorRect.new()
	_banner_rect.color = Color(0.15, 0.15, 0.15, 0.9)
	# 🌟 APLICAMOS LAS DIMENSIONES AQUÍ
	_banner_rect.custom_minimum_size = dimensions
	_banner_rect.size = dimensions
	_banner_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var label = Label.new()
	# 🌟 EXTRA: Hacemos que el texto muestre el nombre del tamaño para que sea más claro
	label.text = "TEST BANNER\n" + BannerSize.keys()[size]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_banner_rect.add_child(label)
	container.add_child(_banner_rect)
	Engine.get_main_loop().current_scene.add_child(_mock_banner_canvas)
	
	var preset = _get_godot_preset(pos)
	_banner_rect.set_anchors_and_offsets_preset(preset, Control.PRESET_MODE_KEEP_SIZE)
	_apply_grow_directions(_banner_rect, pos)

func _get_godot_preset(pos: BannerPosition) -> int:
	match pos:
		BannerPosition.TOP: return Control.PRESET_CENTER_TOP
		BannerPosition.BOTTOM: return Control.PRESET_CENTER_BOTTOM
		BannerPosition.LEFT: return Control.PRESET_CENTER_LEFT
		BannerPosition.RIGHT: return Control.PRESET_CENTER_RIGHT
		BannerPosition.TOP_LEFT: return Control.PRESET_TOP_LEFT
		BannerPosition.TOP_RIGHT: return Control.PRESET_TOP_RIGHT
		BannerPosition.BOTTOM_LEFT: return Control.PRESET_BOTTOM_LEFT
		BannerPosition.BOTTOM_RIGHT: return Control.PRESET_BOTTOM_RIGHT
		BannerPosition.CENTER: return Control.PRESET_CENTER
		_: return Control.PRESET_CENTER_BOTTOM

func _apply_grow_directions(control: Control, pos: BannerPosition) -> void:
	match pos:
		BannerPosition.TOP_LEFT:
			control.grow_horizontal = Control.GROW_DIRECTION_END
			control.grow_vertical = Control.GROW_DIRECTION_END
		BannerPosition.TOP:
			control.grow_horizontal = Control.GROW_DIRECTION_BOTH
			control.grow_vertical = Control.GROW_DIRECTION_END
		BannerPosition.TOP_RIGHT:
			control.grow_horizontal = Control.GROW_DIRECTION_BEGIN
			control.grow_vertical = Control.GROW_DIRECTION_END
		BannerPosition.BOTTOM_LEFT:
			control.grow_horizontal = Control.GROW_DIRECTION_END
			control.grow_vertical = Control.GROW_DIRECTION_BEGIN
		BannerPosition.BOTTOM:
			control.grow_horizontal = Control.GROW_DIRECTION_BOTH
			control.grow_vertical = Control.GROW_DIRECTION_BEGIN
		BannerPosition.BOTTOM_RIGHT:
			control.grow_horizontal = Control.GROW_DIRECTION_BEGIN
			control.grow_vertical = Control.GROW_DIRECTION_BEGIN
		BannerPosition.LEFT:
			control.grow_horizontal = Control.GROW_DIRECTION_END
			control.grow_vertical = Control.GROW_DIRECTION_BOTH
		BannerPosition.RIGHT:
			control.grow_horizontal = Control.GROW_DIRECTION_BEGIN
			control.grow_vertical = Control.GROW_DIRECTION_BOTH
		BannerPosition.CENTER:
			control.grow_horizontal = Control.GROW_DIRECTION_BOTH
			control.grow_vertical = Control.GROW_DIRECTION_BOTH


func _show_visual_mock_native() -> void:
	if is_instance_valid(_mock_native_canvas):
		_mock_native_canvas.queue_free()
		
	_mock_native_canvas = CanvasLayer.new()
	_mock_native_canvas.layer = 120
	
	# Contenedor principal (Tarjeta central)
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(300, 250)
	panel.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	
	# Hacemos que el panel tenga un color de fondo
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.95)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", style)
	
	# Etiqueta obligatoria de "Anuncio" arriba a la izquierda
	var ad_tag = Label.new()
	ad_tag.text = " Ad "
	ad_tag.add_theme_color_override("font_color", Color.BLACK)
	var tag_style = StyleBoxFlat.new()
	tag_style.bg_color = Color.GOLD
	tag_style.corner_radius_top_left = 5
	tag_style.corner_radius_bottom_right = 5
	ad_tag.add_theme_stylebox_override("normal", tag_style)
	ad_tag.position = Vector2(0, 0)
	
	# Imagen falsa (ColorRect)
	var img = ColorRect.new()
	img.color = Color(0.3, 0.5, 0.8)
	img.custom_minimum_size = Vector2(280, 120)
	img.position = Vector2(10, 25)
	
	# Título
	var title = Label.new()
	title.text = "Juego Épico de Estrategia"
	title.position = Vector2(10, 155)
	
	# Descripción
	var desc = Label.new()
	desc.text = "¡Descarga ahora y obtén 500 gemas gratis!"
	desc.add_theme_font_size_override("font_size", 12)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc.size = Vector2(280, 30)
	desc.position = Vector2(10, 180)
	
	# Botón de CTA (Call To Action)
	var btn_cta = Button.new()
	btn_cta.text = "INSTALAR"
	btn_cta.custom_minimum_size = Vector2(280, 35)
	btn_cta.position = Vector2(10, 210)
	
	# Agregamos todo al panel
	panel.add_child(ad_tag)
	panel.add_child(img)
	panel.add_child(title)
	panel.add_child(desc)
	panel.add_child(btn_cta)
	
	# Botón para cerrar el Mock Native (Para limpiar la pantalla de prueba)
	var btn_close = Button.new()
	btn_close.text = "X"
	btn_close.position = Vector2(275, 5)
	btn_close.pressed.connect(func(): destroy_ad(AdFormat.NATIVE))
	panel.add_child(btn_close)
	
	_mock_native_canvas.add_child(panel)
	Engine.get_main_loop().current_scene.add_child(_mock_native_canvas)


# 🌟 NUEVO: Traductor de Enum a Vector2 (píxeles reales de AdMob)
func _get_mock_size_vector(size: BannerSize) -> Vector2:
	match size:
		BannerSize.BANNER: return Vector2(320, 50)
		BannerSize.LARGE_BANNER: return Vector2(320, 100)
		BannerSize.MEDIUM_RECTANGLE: return Vector2(300, 250)
		BannerSize.FULL_BANNER: return Vector2(468, 60)
		BannerSize.LEADERBOARD: return Vector2(728, 90)
		_: return Vector2(320, 50)
