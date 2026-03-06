@tool
class_name SafeAreaMarginContainer extends MarginContainer

## Componente UI de Glapi.
## Ajusta automáticamente sus márgenes para respetar el "notch" y barras de navegación
## en dispositivos móviles según el SO. Ignora el ajuste en PC u otras plataformas.

@export var apply_to_top: bool = true
@export var apply_to_bottom: bool = true
@export var apply_to_left: bool = true
@export var apply_to_right: bool = true

# Mantener registro de los márgenes base definidos por el usuario en el inspector
var _base_margin_top: int = 0
var _base_margin_bottom: int = 0
var _base_margin_left: int = 0
var _base_margin_right: int = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	# Guardamos los márgenes configurados inicialmente en los overrides
	if has_theme_constant_override("margin_top"):
		_base_margin_top = get_theme_constant("margin_top")
	if has_theme_constant_override("margin_bottom"):
		_base_margin_bottom = get_theme_constant("margin_bottom")
	if has_theme_constant_override("margin_left"):
		_base_margin_left = get_theme_constant("margin_left")
	if has_theme_constant_override("margin_right"):
		_base_margin_right = get_theme_constant("margin_right")
		
	_apply_safe_area()

func _notification(what: int) -> void:
	if Engine.is_editor_hint():
		return
		
	# Si se redimensiona la ventana, rotación u otros cambios de foco, recalcúlalo
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN or what == NOTIFICATION_RESIZED:
		_apply_safe_area()

func _apply_safe_area() -> void:
	var is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
	if not is_mobile:
		return
		
	# Obtenemos el rectángulo de pantalla total
	var window_size = DisplayServer.window_get_size()
	# Obtenemos el rectángulo libre de 'notches' y bordes de hardware
	var safe_area = DisplayServer.get_display_safe_area()
	
	if safe_area.size.x == 0 or safe_area.size.y == 0:
		return # Area de seguridad desconocida o ventana es demasiado pequeña

	# Calcular el offset físico
	var notch_top = safe_area.position.y
	var notch_left = safe_area.position.x
	var nav_bottom = window_size.y - (safe_area.position.y + safe_area.size.y)
	var nav_right = window_size.x - (safe_area.position.x + safe_area.size.x)

	if apply_to_top:
		add_theme_constant_override("margin_top", _base_margin_top + notch_top)
		
	if apply_to_bottom:
		add_theme_constant_override("margin_bottom", _base_margin_bottom + nav_bottom)
		
	if apply_to_left:
		add_theme_constant_override("margin_left", _base_margin_left + notch_left)
		
	if apply_to_right:
		add_theme_constant_override("margin_right", _base_margin_right + nav_right)
