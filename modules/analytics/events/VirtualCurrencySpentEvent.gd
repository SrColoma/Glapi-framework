class_name VirtualCurrencySpentEvent extends GlapiEvent

var currency_name: String
var value: int
var item_name: String # ej. "sword_upgrade", "extra_lives"

func _init(_currency_name: String, _value: int, _item_name: String) -> void:
	event_name = "spend_virtual_currency"
	currency_name = _currency_name
	value = _value
	item_name = _item_name

func to_dict() -> Dictionary:
	return {
		"virtual_currency_name": currency_name,
		"value": value,
		"item_name": item_name
	}
