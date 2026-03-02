class_name IAPService extends GlapiService

signal products_loaded(products: Array)
signal purchase_successful(product_id: String, token: String)
signal purchase_failed(product_id: String, error_msg: String)
signal purchase_consumed(product_id: String)
signal purchases_restored(restored_product_ids: Array)

func _init(adapter: IIAPAdapter) -> void:
	_adapter = adapter
	
	# Conectamos las señales hacia arriba
	_adapter.products_loaded.connect(func(p): products_loaded.emit(p))
	_adapter.purchase_failed.connect(func(id, err): purchase_failed.emit(id, err))
	_adapter.purchase_consumed.connect(func(id): purchase_consumed.emit(id))
	_adapter.purchases_restored.connect(func(ids): purchases_restored.emit(ids))
	
	# Conexión especial: Cuando la compra es exitosa, avisamos a Analytics
	_adapter.purchase_successful.connect(_on_purchase_successful)
	
	_adapter.initialize()

func request_product_info(product_ids: Array) -> void:
	_adapter.request_product_info(product_ids)

func purchase(product_id: String) -> void:
	_adapter.purchase(product_id)

func consume(purchase_token: String) -> void:
	_adapter.consume(purchase_token)

func restore_purchases() -> void:
	_adapter.restore_purchases()

# --- Magia de la Arquitectura Limpia ---
func _on_purchase_successful(product_id: String, token: String) -> void:
	# 1. Avisamos al juego para que le dé las gemas al jugador
	purchase_successful.emit(product_id, token)
	
	# 2. Despachamos el evento a Firebase de forma automática
	# (Asumimos USD temporalmente, en el adaptador real extraeríamos la moneda real)
	Glapi.dispatch(IAPEvent.new(product_id, "USD", 0.99)) 
	print("🛒 IAP Service: Compra exitosa. Evento de analítica despachado.")
