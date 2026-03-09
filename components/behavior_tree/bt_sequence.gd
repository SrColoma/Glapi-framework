class_name BTSequence extends BTNode

## El Composite Sequence actúa como un operador lógico "AND".
## Evalúa sus hijos uno tras otro de arriba a abajo.
## - Si un hijo devuelve SUCCESS: Avanza al siguiente hijo.
## - Si un hijo devuelve FAILURE: La secuencia entera falla de inmediato y retorna FAILURE al padre.
## - Si un hijo devuelve RUNNING: Detiene la ejecución en ese nodo y retorna RUNNING (ideal para acciones largas).
## - Retorna SUCCESS solo si TODOS sus hijos retornan SUCCESS.

var _active_child_index: int = 0

func tick(delta: float) -> int:
	var children = get_children()
	if children.is_empty():
		return SUCCESS
		
	# Iteramos desde el último hijo activo (para no perder el progreso si devolvió RUNNING antes)
	for i in range(_active_child_index, children.size()):
		var child = children[i] as BTNode
		if not child: continue
		
		var status = child.tick(delta)
		
		if status == RUNNING:
			# El hijo sigue procesando (ej. caminando), recordamos por dónde íbamos
			_active_child_index = i
			return RUNNING
			
		elif status == FAILURE:
			# Si un paso falla (ej. puerta cerrada), todo este plan falla
			_active_child_index = 0
			return FAILURE
			
	# Si llega hasta aquí, todos los hijos devolvieron SUCCESS en cadena
	_active_child_index = 0
	return SUCCESS
