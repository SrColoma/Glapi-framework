class_name IIAPAdapter extends GlapiAdapter

# Señales
signal products_loaded(products: Array) # Devuelve un array de diccionarios con info de los items
signal purchase_successful(product_id: String, token: String)
signal purchase_failed(product_id: String, error_msg: String)
signal purchase_consumed(product_id: String)
signal purchases_restored(restored_product_ids: Array)

func initialize() -> void:
	push_error("IIAPAdapter: initialize() no implementado.")

# Pide a la tienda los precios locales (ej. "$0.99" o "€0.89")
func request_product_info(product_ids: Array) -> void:
	push_error("IIAPAdapter: request_product_info() no implementado.")

# Inicia el flujo de compra
func purchase(product_id: String) -> void:
	push_error("IIAPAdapter: purchase() no implementado.")

# Vital para items que se pueden comprar muchas veces (monedas, gemas)
func consume(purchase_token: String) -> void:
	push_error("IIAPAdapter: consume() no implementado.")

# Para recuperar compras "No Consumibles" (Ej: "Quitar Anuncios")
func restore_purchases() -> void:
	push_error("IIAPAdapter: restore_purchases() no implementado.")
