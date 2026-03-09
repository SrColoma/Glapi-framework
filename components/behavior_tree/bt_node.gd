class_name BTNode extends Node

## Nodo base para el Árbol de Comportamientos (Behavior Tree).
## Todos los nodos (Leaves y Composites) deben extender de esta clase.

## Constantes Universales para los motores BT
const SUCCESS = 0
const FAILURE = 1
const RUNNING = 2

## Referencia a la entidad física del juego que este árbol controla
var actor: Node
## Diccionario global compartido por todo el árbol para pasar memoria/datos entre nodos
var blackboard: Dictionary = {}

## Inicialización llamada recursivamente desde el BehaviorTree Raíz
func setup(_actor: Node, _blackboard: Dictionary) -> void:
	actor = _actor
	blackboard = _blackboard
	
	# Propagar setup a los hijos que sean BTNodes
	for child in get_children():
		if child is BTNode:
			child.setup(actor, blackboard)

## El corazón algorítmico del nodo.
## Debe ser sobrescrito por las clases hijas y RETORNAR SIEMPRE un entero:
## SUCCESS, FAILURE o RUNNING.
func tick(_delta: float) -> int:
	push_error("BTNode: La función tick() debe ser sobreescrita por " + name)
	return FAILURE
