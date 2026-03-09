class_name GlapiGoapPlanner extends RefCounted

## El cerebro lógico (Matemático) de GOAP.
## Toma un estado actual del mundo, una meta, y una lista de acciones disponibles,
## y devuelve un Array ordenado con los pasos a seguir usando Backwards Chaining (A* Simplificado).

## Construye un plan secuencial de acciones para alcanzar el "goal".
## Retorna Array vacío si no es posible lograr la meta con las acciones proveídas.
func plan(usable_actions: Array[GlapiGoapAction], current_state: Dictionary, goal: Dictionary) -> Array[GlapiGoapAction]:
	var leaves = []
	var start_node = _build_graph_node(null, 0.0, current_state, null)
	
	var success = _build_graph(start_node, leaves, usable_actions, goal)
	
	if not success:
		return [] # Inviable
		
	# Encontrar la rama más barata
	var cheapest_idx = 0
	for i in range(leaves.size()):
		if leaves[i]["cost"] < leaves[cheapest_idx]["cost"]:
			cheapest_idx = i
			
	var cheapest_node = leaves[cheapest_idx]
	var result_plan: Array[GlapiGoapAction] = []
	
	# Subimos por los padres hasta armar el array completo al revés
	var n = cheapest_node
	while n != null:
		if n["action"]:
			result_plan.push_front(n["action"])
		n = n["parent"]
		
	return result_plan

## Búsqueda Recursiva 
func _build_graph(parent_node: Dictionary, leaves: Array, usable_actions: Array, goal: Dictionary) -> bool:
	var found_one = false
	
	for action in usable_actions:
		# ¿Esta acción se puede usar con el estado simulado actual?
		if _conditions_met(action.preconditions, parent_node["state"]):
			# Simular este paso: Aplicamos los efectos
			var current_simulated_state = parent_node["state"].duplicate()
			_apply_effects(current_simulated_state, action.effects)
			
			var node = _build_graph_node(parent_node, parent_node["cost"] + action.cost, current_simulated_state, action)
			
			# ¿Llegamos al objetivo final con este estado simulado?
			if _conditions_met(goal, current_simulated_state):
				leaves.append(node)
				found_one = true
			else:
				# Si no, clonamos las acciones, sacamos esta que ya se usó, y seguimos bajando
				var subset = usable_actions.duplicate()
				subset.erase(action)
				var found = _build_graph(node, leaves, subset, goal)
				if found:
					found_one = true
					
	return found_one

func _build_graph_node(parent, cost: float, state: Dictionary, action: GlapiGoapAction) -> Dictionary:
	return {
		"parent": parent,
		"cost": cost,
		"state": state,
		"action": action
	}

func _conditions_met(conditions: Dictionary, state: Dictionary) -> bool:
	for key in conditions.keys():
		if not state.has(key) or state[key] != conditions[key]:
			return false
	return true

func _apply_effects(state: Dictionary, effects: Dictionary) -> void:
	for key in effects.keys():
		state[key] = effects[key]
