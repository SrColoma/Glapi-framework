class_name MockIAPAdapter extends IIAPAdapter

var _mock_catalog: Dictionary = {
	"gemas_100": {"title": "Montón de Gemas", "price": "$0.99", "desc": "100 Gemas brillantes."},
	"gemas_500": {"title": "Cofre de Gemas", "price": "$4.99", "desc": "500 Gemas. ¡Mejor valor!"},
	"no_ads": {"title": "Quitar Anuncios", "price": "$2.99", "desc": "Juega sin interrupciones."}
}

func initialize() -> void:
	print("🟡 MOCK IAP: Inicializado.")

func request_product_info(product_ids: Array) -> void:
	print("⏳ MOCK IAP: Solicitando precios de la tienda falsa...")
	await Engine.get_main_loop().create_timer(1.0).timeout
	
	var results = []
	for id in product_ids:
		if _mock_catalog.has(id):
			var data = _mock_catalog[id].duplicate()
			data["id"] = id
			results.append(data)
			
	print("✅ MOCK IAP: Precios cargados.")
	products_loaded.emit(results)

func purchase(product_id: String) -> void:
	print("💸 MOCK IAP: Simulando flujo de pago de Google Play para: ", product_id)
	await Engine.get_main_loop().create_timer(1.5).timeout
	
	if _mock_catalog.has(product_id):
		var fake_token = "mock_token_" + str(randi())
		print("✅ MOCK IAP: ¡Pago completado!")
		purchase_successful.emit(product_id, fake_token)
	else:
		print("❌ MOCK IAP: El producto no existe en el catálogo falso.")
		purchase_failed.emit(product_id, "Item no encontrado.")

func consume(purchase_token: String) -> void:
	print("🍔 MOCK IAP: Consumiendo token [", purchase_token, "] para permitir nueva compra.")
	await Engine.get_main_loop().create_timer(0.5).timeout
	purchase_consumed.emit("mock_item_consumed")

func restore_purchases() -> void:
	print("🔄 MOCK IAP: Buscando compras previas en la cuenta...")
	await Engine.get_main_loop().create_timer(1.0).timeout
	purchases_restored.emit(["no_ads"]) # Simulamos que ya había comprado "Quitar Anuncios"
