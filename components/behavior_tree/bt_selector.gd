class_name BTSelector extends BTNode

## El Composite Selector (o Fallback) actúa como un operador lógico "OR".
## Evalúa sus hijos uno tras otro de arriba a abajo.
## Su meta es que AL MENOS UN hijo termine con éxito.
## 
## - Si un hijo devuelve FAILURE: Sigue buscando y avanza al siguiente hijo.
## - Si un hijo devuelve SUCCESS: El Selector triunfa inmediatamente y retorna SUCCESS al padre.
## - Si un hijo devuelve RUNNING: Detiene la ejecución y retorna RUNNING.
## - Retorna FAILURE solo si TODOS los hijos fallan. (No hubieron planes de rescate).

var _active_child_index: int = 0

func tick(delta: float) -> int:
	var children = get_children()
	if children.is_empty():
		return FAILURE
		
	for i in range(_active_child_index, children.size()):
		var child = children[i] as BTNode
		if not child: continue
		
		var status = child.tick(delta)
		
		if status == RUNNING:
			_active_child_index = i
			return RUNNING
			
		elif status == SUCCESS:
			# Encontró una alternativa viable. Deja de iterar.
			_active_child_index = 0
			return SUCCESS
			
	# Si probó todos los hijos y todos dieron FAILURE
	_active_child_index = 0
	return FAILURE
