class_name GlapiEvent extends RefCounted

var event_name: String
var parameters: Dictionary

func _init(name: String, params: Dictionary = {}) -> void:
	event_name = name
	parameters = params
