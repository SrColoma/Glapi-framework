class_name GlapiState extends Node

## Clase base abstracta para los Estados de la Máquina de Estados Finita.
## Todos los estados locales del juego (ej: StateIdle) deben extender esta clase.

## Referencia a la Máquina que controla este estado
var machine: GlapiStateMachine
## Entidad a la que se le aplican las acciones de este estado
var actor: Node

## Inicializa configuración básica del estado
func setup(_machine: GlapiStateMachine, _actor: Node) -> void:
	machine = _machine
	actor = _actor

## Llamado justo cuando la máquina transiciona hacia este estado
func enter(msg: Dictionary = {}) -> void:
	pass

## Llamado justo antes de que la máquina transicione hacia otro estado
func exit() -> void:
	pass

## Equivalente a _process() llamado por la máquina
func update(_delta: float) -> void:
	pass

## Equivalente a _physics_process() llamado por la máquina
func physics_update(_delta: float) -> void:
	pass

## Función de conveniencia para pedirle a la máquina un cambio rápido
func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	machine.change_state(target_state_name, msg)
