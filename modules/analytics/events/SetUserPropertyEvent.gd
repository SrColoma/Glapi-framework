class_name SetUserPropertyEvent extends GlapiEvent

var property_name: String
var property_value: String

func _init(p_name: String, p_value: String) -> void:
	event_name = "internal_set_user_property"
	property_name = p_name
	property_value = p_value

func to_dict() -> Dictionary:
	return {
		"property": property_name,
		"value": property_value
	}
