class_name LevelCompletedEvent extends GlapiEvent

var level_name: String
var success: bool
var score: int

func _init(_level_name: String, _success: bool, _score: int = 0) -> void:
	# Forzamos el nombre predefinido de Firebase internamente
	event_name = "level_end" 
	level_name = _level_name
	success = _success
	score = _score

func to_dict() -> Dictionary:
	return {
		"level_name": level_name,
		"success": success if "true" else "false", # A veces las analíticas prefieren strings
		"score": score
	}
