class_name ObjectPoolService extends Node

## Servicio global de Object Pooling para Glapi.
## Previene caídas de rendimiento instanciando escenas complejas por adelantado (Prewarm)
## y reutilizándolas en lugar de destruirlas (queue_free).

var _pools: Dictionary = {}

func _ready() -> void:
	# Asegurarnos de que este nodo procese siempre o al menos de manera predecible.
	process_mode = Node.PROCESS_MODE_ALWAYS
	name = "ObjectPoolService"

## Obtiene la clave única para el diccionario basada en la ruta del recurso
func _get_pool_key(scene: PackedScene) -> String:
	if not scene: return ""
	return scene.resource_path

## Crea la estructura jerárquica interna (Nodo Carpeta) para organizar instancias del mismo tipo
func _ensure_pool_parent(key: String) -> Node:
	if not _pools.has(key):
		var pool_parent = Node.new()
		# Usar el nombre del archivo de la escena como nombre del nodo para claridad en el Remote Tree
		pool_parent.name = "Pool_" + key.get_file().get_basename()
		add_child(pool_parent)
		_pools[key] = {
			"parent": pool_parent,
			"available": [],
			"in_use": []
		}
	return _pools[key]["parent"]

## Reserva 'count' instancias de un PackedScene en memoria.
func prewarm(scene: PackedScene, count: int) -> void:
	if not scene:
		push_error("ObjectPoolService: Se intentó hacer prewarm con un PackedScene nulo.")
		return
		
	var key = _get_pool_key(scene)
	var pool_parent = _ensure_pool_parent(key)
	var available_list = _pools[key]["available"]
	
	for i in range(count):
		var instance = scene.instantiate()
		pool_parent.add_child(instance)
		_deactivate_node(instance)
		available_list.append(instance)

## Obtiene una instancia disponible. Si no hay, la crea en el momento (flexible).
## Devuelve el Nodo que luego debe ser añadido al árbol por el juego.
func acquire(scene: PackedScene) -> Node:
	if not scene:
		push_error("ObjectPoolService: Se intentó hacer acquire con un PackedScene nulo.")
		return null
		
	var key = _get_pool_key(scene)
	var pool_parent = _ensure_pool_parent(key)
	var pool_data = _pools[key]
	var instance: Node
	
	if pool_data["available"].is_empty():
		# Si ya gastamos el prewarm, instanciamos a demanda pero lo trackeamos
		instance = scene.instantiate()
		pool_parent.add_child(instance)
	else:
		instance = pool_data["available"].pop_back()
		
	pool_data["in_use"].append(instance)
	_activate_node(instance)
	return instance

## Devuelve el nodo al pool para ser reciclado. 
## Oculta el nodo y detiene su proceso sin destruirlo.
func release(node: Node) -> void:
	if not node: return
	
	# Usamos metadata o scene_file_path. scene_file_path es lo más seguro si fue instanciado desde archivo.
	var key = node.scene_file_path
	if key.is_empty() or not _pools.has(key):
		push_warning("ObjectPoolService: Nodo no pertenece al pool, usando queue_free() en " + str(node.name))
		node.queue_free()
		return
		
	var pool_data = _pools[key]
	
	if node in pool_data["in_use"]:
		pool_data["in_use"].erase(node)
		
	if node not in pool_data["available"]:
		_deactivate_node(node)
		pool_data["available"].append(node)
		
		# Asegurar que vuelve al padre del pool original (por si el dev lo reparentó al mundo)
		var pool_parent = pool_data["parent"]
		if node.get_parent() != pool_parent:
			if node.get_parent():
				node.get_parent().remove_child(node)
			pool_parent.add_child(node)

## Vacía completamente un pool o todos.
func clear_all() -> void:
	for key in _pools.keys():
		var pool_data = _pools[key]
		var parent_node = pool_data["parent"]
		if is_instance_valid(parent_node):
			parent_node.queue_free()
	_pools.clear()

# == MÉTODOS INTERNOS DE ESTADO ==

func _activate_node(node: Node) -> void:
	node.process_mode = Node.PROCESS_MODE_INHERIT
	if node is CanvasItem or node is Node3D:
		node.show()
	# Si quisieras resetear físicas, emitir señales, sería aquí.
	if node.has_method("_on_pool_acquire"):
		node.call("_on_pool_acquire")

func _deactivate_node(node: Node) -> void:
	node.process_mode = Node.PROCESS_MODE_DISABLED
	if node is CanvasItem or node is Node3D:
		node.hide()
	if node.has_method("_on_pool_release"):
		node.call("_on_pool_release")
