class_name GlapiStateMachine extends Node

## Máquina de Estados Finita (FSM) de Glapi.
## Instancia este nodo dentro de cualquier entidad de tu juego (Ej: Player).
## Añade nodos GlapiState como hijos de este nodo.

signal state_changed(old_state: String, new_state: String)

@export var initial_state: GlapiState
@export var actor: Node

var current_state: GlapiState
var _states: Dictionary = {}

func _ready() -> void:
	# Retrasamos un frame para que los hijos estén listos antes de inicializar
	call_deferred("_initialize_machine")

func _initialize_machine() -> void:
	# Si no se define el actor por export, asumimos que es el padre directo
	if not actor:
		actor = get_parent()
		
	# Recolectar e inicializar todos los estados hijos
	for child in get_children():
		if child is GlapiState:
			_states[child.name] = child
			child.setup(self, actor)
	
	# Arrancar en el estado inicial
	if initial_state and _states.has(initial_state.name):
		current_state = initial_state
		current_state.enter()
	elif _states.size() > 0:
		# Fallback: Usar el primer hijo como estado inicial
		current_state = get_child(0)
		current_state.enter()
	else:
		push_warning("FSM: No hay estados hijos en " + name)

## Ejecutar ticks solo del estado activo
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

## Transiciona a un nuevo estado si existe y no es el actual
func change_state(target_state_name: String, msg: Dictionary = {}) -> void:
	if not _states.has(target_state_name):
		push_error("FSM: Intentó transicionar a estado inexistente: " + target_state_name)
		return
		
	if current_state and current_state.name == target_state_name:
		# Ignorar transición al mismo estado
		return
		
	var previous_state_name = ""
	
	if current_state:
		previous_state_name = current_state.name
		current_state.exit()
		
	current_state = _states[target_state_name]
	current_state.enter(msg)
	
	state_changed.emit(previous_state_name, target_state_name)

## Forzar actualización del actor exterior en caso sea necesario inyectarlo post-_ready
func set_actor(new_actor: Node) -> void:
	actor = new_actor
	for state in _states.values():
		state.actor = new_actor
