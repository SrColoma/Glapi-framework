class_name GlapiEvent extends RefCounted

var event_name: String
var parameters: Dictionary

func _init(name: String = "", params: Dictionary = {}) -> void:
	if name != "":
		event_name = name
	parameters = params

func to_dict() -> Dictionary:
	return SerializationUtils.object_to_dict(self)
