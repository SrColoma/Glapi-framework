class_name ShowAdRequestedEvent extends GlapiEvent

# Usamos un int para evitar dependencia directa del enum del Provider en la capa del juego,
# o podemos pasar un String (ej. "rewarded")
var format_requested: String 
var ad_unit_id: String

func _init(_format: String, _ad_unit_id: String = "") -> void:
	event_name = "internal_show_ad" # Este evento es interno, el AnalyticsService lo ignorará
	format_requested = _format
	ad_unit_id = _ad_unit_id

func to_dict() -> Dictionary:
	return {
		"format": format_requested,
		"ad_unit_id": ad_unit_id
	}
