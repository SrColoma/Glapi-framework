class_name ScreenViewEvent extends GlapiEvent

# screen_name: ej. "TiendaPrincipal", "MenuAjustes", "SelectorNiveles"
# screen_class: ej. "Control", "CanvasLayer", "Node2D" (opcional, ayuda a agrupar en Firebase)
func _init(screen_name: String, screen_class: String = "Control") -> void:
	super("screen_view", {
		"screen_name": screen_name,
		"screen_class": screen_class
	})
