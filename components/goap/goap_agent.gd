class_name GlapiGoapAgent extends Node

## Agente autónomo GOAP.
## Instancia este nodo en tus entidades y añade Nodos `GlapiGoapAction` como hijos.

@export var tick_rate: float = 0.5
@export var actor: Node

var current_goal: Dictionary = {}
var world_state: Dictionary = {}

var _available_actions: Array[GlapiGoapAction] = []
var _current_plan: Array[GlapiGoapAction] = []
var _planner: GlapiGoapPlanner = GlapiGoapPlanner.new()
var _time_since_last_tick: float = 0.0

signal plan_finished()
signal plan_failed()
signal action_changed(action_name: String)

func _ready() -> void:
	if not actor:
		actor = get_parent()
		
	# Recolectar todas las acciones (Habilidades de este agente)
	for child in get_children():
		if child is GlapiGoapAction:
			_available_actions.append(child)

## Establece el objetivo primario actual del agente.
## Ej: set_goal({"has_wood": true})
func set_goal(goal: Dictionary) -> void:
	current_goal = goal
	_current_plan.clear()
	plan_forces_recalculation()

## Forza calcular un plan nuevo de Inmediato en el siguiente Process
func plan_forces_recalculation() -> void:
	_time_since_last_tick = tick_rate

func _process(delta: float) -> void:
	if current_goal.is_empty():
		return
		
	# Si tenemos un plan activo, ejecutamos el paso actual
	if _current_plan.size() > 0:
		var current_action = _current_plan[0]
		
		# Verificamos si seguimos cumpliendo los requisitos en tiempo real
		# Si un barril explota, tal vez ya no podamos usar esta acción
		if not _planner._conditions_met(current_action.preconditions, world_state):
			current_action.reset()
			_current_plan.clear()
			plan_failed.emit()
			return
			
		var is_finished = current_action.perform(actor, delta)
		
		if is_finished:
			# Aplicar los efectos permanentemente al mundo
			_planner._apply_effects(world_state, current_action.effects)
			_current_plan.pop_front()
			
			if _current_plan.is_empty():
				plan_finished.emit()
				current_goal.clear()
			else:
				action_changed.emit(_current_plan[0].action_name)
		return
		
	# Si NO tenemos plan, evaluamos de vez en cuando (ahorro de CPU)
	_time_since_last_tick += delta
	if _time_since_last_tick >= tick_rate:
		_time_since_last_tick = 0.0
		
		_current_plan = _planner.plan(_available_actions, world_state, current_goal)
		
		if _current_plan.size() > 0:
			action_changed.emit(_current_plan[0].action_name)
		else:
			plan_failed.emit()
