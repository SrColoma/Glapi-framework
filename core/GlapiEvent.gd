class_name GlapiEvent extends RefCounted

var event_name: String = "generic_event"

func to_dict() -> Dictionary:
	push_error("GlapiEvent: La función to_dict() debe ser sobrescrita por la clase hija.")
	return {}
