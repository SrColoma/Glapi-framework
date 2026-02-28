class_name VirtualCurrencyEvent extends GlapiEvent

# action: "earn" (ganar) o "spend" (gastar)
# item_name: "espada_fuego", "revivir", "recompensa_anuncio"
func _init(action: String, currency_name: String, value: int, item_name: String) -> void:
	var e_name = "earn_virtual_currency" if action == "earn" else "spend_virtual_currency"
	
	super(e_name, {
		"virtual_currency_name": currency_name,
		"value": value,
		"item_name": item_name
	})
