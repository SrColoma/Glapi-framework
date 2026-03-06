class_name OverlayManager extends Node

## Gestor de capas (Overlays) para menús, pop-ups y modales.
## Permite apilar interfaces sobre el juego actual sin cambiar la escena principal.

signal overlay_opened(overlay_node: Node)
signal overlay_closed(overlay_node: Node)
signal all_overlays_closed

var _overlay_stack: Array[CanvasLayer] = []
var base_z_index: int = 100

## Añade un overlay a la pantalla instanciando un PackedScene
## @param overlay_scene: PackedScene de la UI a mostrar
## @return Instancia creada del overlay
func push_overlay(overlay_scene: PackedScene) -> Node:
	if not overlay_scene:
		push_error("OverlayManager: PackedScene es nulo.")
		return null
		
	var layer = CanvasLayer.new()
	# Incrementamos el Z-Index para que siempre quede por encima del anterior
	layer.layer = base_z_index + _overlay_stack.size()
	
	var instance = overlay_scene.instantiate()
	layer.add_child(instance)
	
	# Lo añadimos al SceneTree global (root) para que sobreviva a los cambios de escena si es necesario,
	# pero comúnmente querremos limpiarlo. Para una Mesa de Control, root o Glapi autoload es mejor.
	Engine.get_main_loop().root.add_child(layer)
	
	_overlay_stack.push_back(layer)
	overlay_opened.emit(instance)
	
	return instance

## Elimina el último overlay abierto
func pop_overlay() -> void:
	if _overlay_stack.is_empty():
		return
		
	var layer = _overlay_stack.pop_back()
	var instance = layer.get_child(0) if layer.get_child_count() > 0 else null
	
	if instance:
		overlay_closed.emit(instance)
		
	layer.queue_free()
	
	if _overlay_stack.is_empty():
		all_overlays_closed.emit()

## Elimina todos los overlays
func clear_overlays() -> void:
	while not _overlay_stack.is_empty():
		pop_overlay()

## Devuelve true si hay algún overlay abierto
func has_overlays() -> bool:
	return not _overlay_stack.is_empty()

## Obtiene la instancia del overlay superior
func get_top_overlay() -> Node:
	if _overlay_stack.is_empty():
		return null
	var layer = _overlay_stack.back()
	return layer.get_child(0) if layer.get_child_count() > 0 else null
