class_name SceneTransitionManager extends Node

## Manager de transiciones de escenas.
## 
## Proporciona una forma sencilla de cambiar de escena con efectos visuales.
## Las transiciones son escenas separadas (.tscn) que se instancian dinámicamente.
##
## ### Uso:
## ```gdscript
## # Cambio básico (usa la transición por defecto)
## Glapi.scene_transition.change_scene("res://addons/Glapi/modules/scene_transition/transitions/fade_black.tscn")
##
## # Con await
## await Glapi.scene_transition.transition_finished
## print("¡Escena cargada!")
##
## # Con transición específica
## Glapi.scene_transition.change_scene_with_transition("res://game/level1.tscn", "res://addons/Glapi/modules/scene_transition/transitions/fade_white.tscn")
## ```

signal scene_changed(new_scene_path: String)
signal transition_started
signal transition_finished

const DEFAULT_TRANSITION := "res://addons/Glapi/modules/scene_transition/transitions/fade_black.tscn"

var _is_transitioning: bool = false
var _scene_stack: Array[String] = []

## Limpia el historial de navegación
func clear_stack() -> void:
	_scene_stack.clear()

## Devuelve la escena anterior, volviendo atrás en el historial
## @param transition_path: Ruta de la escena de transición (opcional)
func go_back(transition_path: String = DEFAULT_TRANSITION) -> void:
	if _scene_stack.is_empty():
		push_warning("SceneTransitionManager: No hay escenas en el stack para retroceder.")
		return
	
	var previous_scene = _scene_stack.pop_back()
	change_scene_with_transition(previous_scene, transition_path, false)

## Cambia a una nueva escena usando la transición por defecto
## @param scene_path: Ruta al archivo de escena (.tscn)
## @param push_to_stack: Si true, guarda la escena actual en el historial
func change_scene(scene_path: String, push_to_stack: bool = true) -> void:
	change_scene_with_transition(scene_path, DEFAULT_TRANSITION, push_to_stack)

## Cambia a una nueva escena con una transición específica
## @param scene_path: Ruta de la escena destino
## @param transition_path: Ruta de la escena de transición
## @param push_to_stack: Si true, guarda la escena actual en el historial
func change_scene_with_transition(scene_path: String, transition_path: String, push_to_stack: bool = true) -> void:
	if _is_transitioning:
		push_warning("SceneTransitionManager: Transición en progreso, ignorando cambio de escena.")
		return
	
	_is_transitioning = true
	transition_started.emit()
	
	# Iniciar la carga asíncrona en un hilo de fondo
	var loader_err = ResourceLoader.load_threaded_request(scene_path)
	if loader_err != OK:
		push_error("SceneTransitionManager: Error al iniciar carga asíncrona de " + scene_path)
		_change_scene_direct(scene_path, push_to_stack)
		return
	
	# Cargamos la transición
	var transition_res = load(transition_path)
	if not transition_res:
		push_error("SceneTransitionManager: No se pudo cargar la transición: " + transition_path)
		_change_scene_direct(scene_path, push_to_stack)
		return
	
	var transition_scene = transition_res.instantiate()
	
	# Añadimos al árbol antes de ejecutar (para que _ready() se llame)
	Engine.get_main_loop().root.add_child(transition_scene)
	
	transition_scene.transition_finished.connect(func(): 
		_on_transition_complete(scene_path)
	)
	
	var change_callback = func():
		# Esperar hasta que la escena cargue
		var status = ResourceLoader.load_threaded_get_status(scene_path)
		while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().process_frame
			status = ResourceLoader.load_threaded_get_status(scene_path)
			
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var packed_scene = ResourceLoader.load_threaded_get(scene_path)
			
			if push_to_stack:
				var root = Engine.get_main_loop().root
				# Guardamos la escena actual
				var current_scene = Engine.get_main_loop().current_scene
				if current_scene and current_scene.scene_file_path != "":
					_scene_stack.push_back(current_scene.scene_file_path)
					
			Engine.get_main_loop().change_scene_to_packed(packed_scene)
		else:
			push_error("SceneTransitionManager: Fallo en carga asíncrona de " + scene_path)
			_change_scene_direct(scene_path, push_to_stack)
			
	# Iniciamos la secuencia de la transición visual que luego invoca el callback
	transition_scene.perform_transition(change_callback)

## Cambia a una nueva escena usando PackedScene (Ya cargada en memoria)
## @param packed_scene: Escena empaquetada
## @param push_to_stack: Si true, guarda la escena actual
func change_scene_to(packed_scene: PackedScene, push_to_stack: bool = true) -> void:
	change_scene_to_with_transition(packed_scene, DEFAULT_TRANSITION, push_to_stack)

## Cambia a una nueva escena con PackedScene y transición específica
## @param packed_scene: Escena empaquetada
## @param transition_path: Ruta de la escena de transición
## @param push_to_stack: Si true, guarda la escena actual
func change_scene_to_with_transition(packed_scene: PackedScene, transition_path: String, push_to_stack: bool = true) -> void:
	if _is_transitioning:
		push_warning("SceneTransitionManager: Transición en progreso, ignorando cambio de escena.")
		return
	
	if not packed_scene:
		push_error("SceneTransitionManager: PackedScene es null")
		return
	
	_is_transitioning = true
	transition_started.emit()
	
	var transition_res = load(transition_path)
	if not transition_res:
		push_error("SceneTransitionManager: No se pudo cargar la transición: " + transition_path)
		_change_scene_to_direct(packed_scene, push_to_stack)
		return
	
	var transition_scene = transition_res.instantiate()
	Engine.get_main_loop().root.add_child(transition_scene)
	
	transition_scene.transition_finished.connect(func():
		_on_transition_complete("")
	)
	
	var change_callback = func():
		if push_to_stack:
			var current_scene = Engine.get_main_loop().current_scene
			if current_scene and current_scene.scene_file_path != "":
				_scene_stack.push_back(current_scene.scene_file_path)
		
		# Como es de un packed scene, la limpiamos explícitamente y añadimos la nueva
		Engine.get_main_loop().change_scene_to_packed(packed_scene)
		
	transition_scene.perform_transition(change_callback)

## Verifica si hay una transición en progreso
## @return true si hay transición en curso
func is_transitioning() -> bool:
	return _is_transitioning

func _on_transition_complete(scene_path: String) -> void:
	_is_transitioning = false
	transition_finished.emit()
	if scene_path:
		scene_changed.emit(scene_path)

func _change_scene_direct(scene_path: String, push_to_stack: bool = true) -> void:
	if push_to_stack:
		var current_scene = Engine.get_main_loop().current_scene
		if current_scene and current_scene.scene_file_path != "":
			_scene_stack.push_back(current_scene.scene_file_path)
			
	Engine.get_main_loop().change_scene_to_file(scene_path)
	_is_transitioning = false
	transition_finished.emit()

func _change_scene_to_direct(packed_scene: PackedScene, push_to_stack: bool = true) -> void:
	if push_to_stack:
		var current_scene = Engine.get_main_loop().current_scene
		if current_scene and current_scene.scene_file_path != "":
			_scene_stack.push_back(current_scene.scene_file_path)
	
	Engine.get_main_loop().change_scene_to_packed(packed_scene)
	_is_transitioning = false
	transition_finished.emit()
