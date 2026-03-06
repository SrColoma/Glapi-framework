extends Control

@onready var btn_close: Button = %BtnClose

func _ready() -> void:
	# Dar focus inicial al botón para soporte de gamepad
	btn_close.grab_focus()
	btn_close.pressed.connect(_on_close_pressed)

func _on_close_pressed() -> void:
	# Llama al framework para que destruya el último overlay instanciado.
	Glapi.overlays.pop_overlay()
