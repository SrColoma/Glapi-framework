class_name FadeWhite extends TransitionScene

## Transición de fundido a blanco.

var _color_rect: ColorRect = null

func _ready() -> void:
	_color_rect = $ColorRect as ColorRect
	if _color_rect:
		_color_rect.color.a = 0.0

func perform_transition(on_scene_change: Callable) -> void:
	if not _color_rect:
		push_error("FadeWhite: ColorRect no encontrado")
		on_scene_change.call()
		transition_finished.emit()
		return
	
	# Fade out (a blanco)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(_color_rect, "color:a", 1.0, _duration)
	
	await tween.finished
	
	# Cambio de escena
	await on_scene_change.call()
	
	# Pequeña pausa
	await Engine.get_main_loop().create_timer(0.1).timeout
	
	# Fade in (de blanco)
	var tween_in = create_tween()
	tween_in.set_ease(Tween.EASE_IN_OUT)
	tween_in.set_trans(Tween.TRANS_SINE)
	tween_in.tween_property(_color_rect, "color:a", 0.0, _duration)
	
	await tween_in.finished
	
	# Limpiar
	queue_free()
	transition_finished.emit()
