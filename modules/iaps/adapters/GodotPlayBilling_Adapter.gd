class_name GodotPlayBillingAdapter extends IIAPAdapter

var _is_initialized: bool = false
var _billing: Object

func initialize() -> void:
	if Engine.has_singleton("GodotPlayBilling"):
		_billing = Engine.get_singleton("GodotPlayBilling")
		_is_initialized = true
		
		# Conectar señales del plugin de Google
		_billing.connected.connect(_on_billing_connected)
		_billing.sku_details_query_completed.connect(_on_sku_details_query_completed)
		_billing.purchases_updated.connect(_on_purchases_updated)
		_billing.purchase_consumed.connect(_on_purchase_consumed)
		_billing.purchase_error.connect(_on_purchase_error)
		
		# Iniciamos la conexión con la tienda
		_billing.startConnection()
		print("🟢 GOOGLE PLAY BILLING: SDK Inicializado.")
	else:
		_is_initialized = false
		push_warning("⚠️ GOOGLE PLAY BILLING: Singleton no encontrado.")

func _on_billing_connected() -> void:
	print("✅ GOOGLE PLAY BILLING: Conectado a la tienda de Android.")

func request_product_info(product_ids: Array) -> void:
	if not _is_initialized: return
	
	# Google Play Billing separa productos en "inapp" (consumibles) y "subs" (suscripciones)
	# Aquí pedimos consumibles básicos ("inapp")
	_billing.querySkuDetails(product_ids, "inapp")

func purchase(product_id: String) -> void:
	if not _is_initialized: return
	_billing.purchase(product_id)

func consume(purchase_token: String) -> void:
	if not _is_initialized: return
	_billing.consumePurchase(purchase_token)

func restore_purchases() -> void:
	if not _is_initialized: return
	# Consulta las compras que el usuario ya tiene asociadas a su cuenta de Google
	_billing.queryPurchases("inapp")

# --- Callbacks del Plugin de Google ---

func _on_sku_details_query_completed(sku_details: Array) -> void:
	# Mapeamos los datos de Google a un formato limpio para tu juego
	var clean_products = []
	for sku in sku_details:
		clean_products.append({
			"id": sku.sku,
			"title": sku.title,
			"price": sku.price,          # Ej: "$0.99"
			"description": sku.description
		})
	products_loaded.emit(clean_products)

func _on_purchases_updated(purchases: Array) -> void:
	# Se llama cuando el usuario completa el pago en la ventanita de Google Play
	for purchase in purchases:
		if purchase.purchase_state == 1: # 1 = PURCHASED (Comprado exitosamente)
			purchase_successful.emit(purchase.sku, purchase.purchase_token)

func _on_purchase_error(code: int, message: String) -> void:
	purchase_failed.emit("unknown_product", message)

func _on_purchase_consumed(purchase_token: String) -> void:
	# Avisamos que la poción/moneda fue consumida y se puede volver a comprar
	purchase_consumed.emit("consumed_item")
