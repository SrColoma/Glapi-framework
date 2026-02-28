class_name TutorialEvent extends GlapiEvent

# Paso 1: "begin", Paso 2: "complete"
func _init(is_complete: bool) -> void:
	var e_name = "tutorial_complete" if is_complete else "tutorial_begin"
	super(e_name, {})
