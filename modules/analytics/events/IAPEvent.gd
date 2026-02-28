class_name IAPEvent extends GlapiEvent

# Cuando te compran algo con dinero real a través de Google Play / App Store
func _init(product_id: String, currency: String, value: float) -> void:
	super("in_app_purchase", {
		"item_id": product_id,
		"currency": currency, # ej: "USD", "EUR"
		"value": value
	})
