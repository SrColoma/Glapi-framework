class_name InputDeviceDetector extends Node

## Detector global del último tipo de entrada usado por el jugador.
## Avisa a toda la aplicación si el jugador cambió de Táctil a Mando, o a Teclado.

signal device_changed(new_device: InputDeviceChangedEvent.InputType)

var current_device: InputDeviceChangedEvent.InputType = InputDeviceChangedEvent.InputType.KEYBOARD

func _ready() -> void:
	# Por defecto, si es móvil, asumimos Touch inicial
	var is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
	if is_mobile:
		current_device = InputDeviceChangedEvent.InputType.TOUCH
		
	# Necesitamos procesar los inputs globales (antes que cualquier nodo UI pueda consumirlos)
	set_process_input(true)

func _input(event: InputEvent) -> void:
	var detected_device = current_device
	
	if event is InputEventKey or event is InputEventMouse:
		detected_device = InputDeviceChangedEvent.InputType.KEYBOARD
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		detected_device = InputDeviceChangedEvent.InputType.GAMEPAD
	elif event is InputEventScreenTouch or event is InputEventScreenDrag:
		detected_device = InputDeviceChangedEvent.InputType.TOUCH
		
	if detected_device != current_device:
		current_device = detected_device
		device_changed.emit(current_device)
		# Emitimos el Domain Event a través del Glapi Event Bus
		Glapi.dispatch(InputDeviceChangedEvent.new(current_device))
		print("🎮 INPUT DETECTOR: Dispositivo cambiado a ", InputDeviceChangedEvent.InputType.keys()[current_device])
