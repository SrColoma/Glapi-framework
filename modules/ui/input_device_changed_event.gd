class_name InputDeviceChangedEvent extends GlapiEvent

## Evento emitido cuando el jugador cambia su método de entrada primario.
## Útil para cambiar iconos de UI (ej. mostrar 'Espacio' vs icono táctil).

enum InputType {
	KEYBOARD,
	GAMEPAD,
	TOUCH
}

var current_input_type: InputType

func _init(_input_type: InputType) -> void:
	event_name = "input_device_changed"
	current_input_type = _input_type

func to_dict() -> Dictionary:
	return {
		"current_input_type": current_input_type
	}
