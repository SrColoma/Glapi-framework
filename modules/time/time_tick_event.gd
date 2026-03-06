class_name TimeTickEvent extends GlapiEvent

## Evento emitido por el TimeManager indicando el tiempo transcurrido
## offline desde la última sesión.

var delta_offline: int

func _init(_delta_offline: int) -> void:
	event_name = "time_tick"
	delta_offline = _delta_offline

func to_dict() -> Dictionary:
	return {
		"delta_offline": delta_offline
	}
