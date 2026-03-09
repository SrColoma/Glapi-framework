class_name GlapiGoapAction extends Node

## Acción base para el Planificador Orientado a Metas (GOAP).
## Define qué necesita (preconditions), qué otorga (effects) y cuánto cuesta.

@export var action_name: String = "Action"
@export var cost: float = 1.0

# Formato: {"has_wood": true, "has_axe": true}
var preconditions: Dictionary = {}
var effects: Dictionary = {}

## Agrega una condición obligatoria para hacer esta acción
func add_precondition(key: String, value: Variant) -> void:
	preconditions[key] = value

## Agrega la consecuencia de finalizar esta acción con éxito
func add_effect(key: String, value: Variant) -> void:
	effects[key] = value

## Método sobrescrito por el desarrollador para dictar si esta acción es 
## lógicamente realizable AHORA MISMO (ej: estoy al lado del árbol)
func is_in_range(actor: Node) -> bool:
	return true

## Función temporal llamada MIENTRAS el actor realiza la acción.
## Debe retornar TRUE cuando termine la acción, y FALSE mientras siga trabajando.
func perform(actor: Node, delta: float) -> bool:
	return true

## Llamada al terminar la acción (o abortar). Útil para lógica de reset.
func reset() -> void:
	pass
