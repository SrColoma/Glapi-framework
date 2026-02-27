class_name AdImpressionEvent extends GlapiEvent

var ad_format: String # "banner", "interstitial", "rewarded"
var ad_unit_name: String
var currency: String
var value: float # El eCPM o revenue estimado que te devuelve el SDK de AdMob

func _init(_ad_format: String, _ad_unit_name: String, _currency: String = "USD", _value: float = 0.0) -> void:
	event_name = "ad_impression"
	ad_format = _ad_format
	ad_unit_name = _ad_unit_name
	currency = _currency
	value = _value

func to_dict() -> Dictionary:
	# Parámetros estándar de Firebase para ingresos por anuncios
	return {
		"ad_format": ad_format,
		"ad_unit_name": ad_unit_name,
		"currency": currency,
		"value": value
	}
