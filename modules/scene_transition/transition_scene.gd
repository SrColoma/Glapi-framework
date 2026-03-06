class_name TransitionScene extends CanvasLayer

## Clase base para escenas de transición.
## Las transiciones heredan de esta clase y implementan el efecto visual.

signal transition_finished

var _duration: float = 0.5

func change_scene(scene_path: String) -> void:
	perform_transition(func(): 
		Engine.get_main_loop().change_scene_to_file(scene_path)
	)

func change_scene_to(packed_scene: PackedScene) -> void:
	perform_transition(func(): 
		var root = Engine.get_main_loop().root
		root.add_child(packed_scene)
		packed_scene.set_owner(root)
	)

func perform_transition(on_scene_change: Callable) -> void:
	# Override en clases hijos
	pass
