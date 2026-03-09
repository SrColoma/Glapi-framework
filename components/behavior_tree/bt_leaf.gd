class_name BTLeaf extends BTNode

## Nodo base para las Hojas ("Leaves") en un Árbol de Comportamiento.
## Representan Condiciones estáticas o Acciones atómicas reales que el actor debe hacer.
## No pueden tener hijos (a diferencia de Sequences o Selectors).

func 	_ready() -> void:
	if get_child_count() > 0:
		push_warning("BTLeaf: Una hoja no debería tener nodos hijos: " + name)

## Ejemplo visual para el usuario:
## func tick(_delta) -> int:
##     if actor.is_enemy_near(): 
##         return SUCCESS
##     return FAILURE
func tick(_delta: float) -> int:
	return FAILURE
