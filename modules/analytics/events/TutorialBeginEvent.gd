class_name TutorialBeganEvent extends GlapiEvent

func _init() -> void:
	# Evento estándar de Firebase
	event_name = "tutorial_begin"

func to_dict() -> Dictionary:
	return {}
