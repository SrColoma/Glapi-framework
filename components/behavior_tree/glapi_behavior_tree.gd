class_name GlapiBehaviorTree extends Node

## Motor Raíz del Behavior Tree de Glapi.
## Instancia este nodo en cualquier entidad, y añade tus Sequences y Selectors como hijos de él.

@export var tick_rate: float = 0.1 # Evalúa cada décima de segundo (ahorra CPU)
@export var actor: Node
@export var is_active: bool = true

var blackboard: Dictionary = {}
var _time_since_last_tick: float = 0.0
var _root_node: BTNode

func _ready() -> void:
	call_deferred("_initialize_tree")

func _initialize_tree() -> void:
	if not actor:
		actor = get_parent()
		
	# Tomamos el primer hijo válido como nodo raíz del árbol (generalmente un Selector)
	for child in get_children():
		if child is BTNode:
			_root_node = child
			break
			
	if _root_node:
		_root_node.setup(actor, blackboard)
	else:
		push_warning("BehaviorTree: Árbol vacío o sin BTNodes hijos en " + name)

func _process(delta: float) -> void:
	if not is_active or not _root_node:
		return
		
	_time_since_last_tick += delta
	if _time_since_last_tick >= tick_rate:
		_time_since_last_tick = 0.0
		# Hacemos tick al árbol entero
		_root_node.tick(tick_rate)

## Pausar la evaluación entera del IA
func set_active(active: bool) -> void:
	is_active = active
