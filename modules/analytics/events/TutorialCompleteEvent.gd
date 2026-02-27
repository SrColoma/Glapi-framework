class_name TutorialCompletedEvent extends GlapiEvent

func _init() -> void:
	# Evento estándar de Firebase
	event_name = "tutorial_complete"

func to_dict() -> Dictionary:
	return {}
