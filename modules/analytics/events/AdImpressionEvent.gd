class_name AdImpressionEvent extends GlapiEvent

func _init(format_name: String, ad_unit_name: String, currency: String, value: float) -> void:
	super("ad_impression", {
		"ad_format": format_name,
		"ad_unit_name": ad_unit_name,
		"currency": currency,
		"value": value
	})
