class_name VirtualCurrencyEarnedEvent extends GlapiEvent

var currency_name: String
var value: int
var source: String # ej. "level_reward", "daily_quest"

func _init(_currency_name: String, _value: int, _source: String = "unknown") -> void:
	event_name = "earn_virtual_currency"
	currency_name = _currency_name
	value = _value
	source = _source

func to_dict() -> Dictionary:
	return {
		"virtual_currency_name": currency_name,
		"value": value,
		"source": source
	}
