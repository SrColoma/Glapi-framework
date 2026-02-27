class_name AdRewardedEvent extends GlapiEvent

var reward_type: String
var reward_amount: int

func _init(_reward_type: String, _reward_amount: int) -> void:
	event_name = "internal_ad_rewarded"
	reward_type = _reward_type
	reward_amount = _reward_amount

func to_dict() -> Dictionary:
	return {
		"reward_type": reward_type,
		"reward_amount": reward_amount
	}
