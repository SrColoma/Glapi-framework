# Módulo: Compras Integradas (IAP - In App Purchases)

El módulo `IAPService` gestiona las compras con dinero real dentro de tu juego (como comprar gemas, desbloquear niveles extra o eliminar anuncios). Funciona como un puente entre la lógica del juego y la tienda de aplicaciones (Google Play Billing, Apple App Store).

> [!TIP]
> **Analítica Automática para Monetización:** Al igual que el módulo de Anuncios, el `IAPService` de Glapi genera eventos silenciosos hacia tu módulo de Analítica (`Glapi.dispatch(IAPEvent.new(...))`) cada vez que una compra se completa con éxito, registrando automáticamente los ingresos sin código repetitivo.

---

## 🚀 Uso en el Juego (`Service Layer`)

Para interactuar con la tienda de la plataforma, usa el Singleton global `Glapi.iap`.

### 1. Cargar el Catálogo de Productos

Antes de mostrar la tienda visual, debes pedirle a Google o Apple que te envíe los precios localizados para el país del jugador (ej. "0.99$" o "1.15€").

```gdscript
func _ready():
	Glapi.iap.products_loaded.connect(_on_products_loaded)
	
	# Le pasamos un Array con los "Product IDs" definidos en la consola de Google/Apple
	Glapi.iap.request_product_info(["100_gemas", "no_ads_pack"])

func _on_products_loaded(products: Array):
	# Dibuja la UI de la tienda usando la info (precios locales, descripciones)
	for p in products:
		print("Producto: ", p.id, " - Precio: ", p.price)
```

### 2. Comprar un Producto

Cuando el jugador toca el botón de comprar.

```gdscript
func btn_comprar_100_gemas_pressed():
	Glapi.iap.purchase_successful.connect(_on_purchase_success)
	Glapi.iap.purchase_failed.connect(_on_purchase_failed)
	
	Glapi.iap.purchase("100_gemas")

func _on_purchase_success(product_id: String, token: String):
	print("¡Compra Exitosa!")
	give_gems_to_player()
	
	# IMPORTANTE: Si es un item consumible (gemas, oro), DEBES consumirlo
	if product_id == "100_gemas":
		Glapi.iap.consume(token)
```

### 3. Consumir Compras Repetibles (Consumables)

Pociones, oro, gemas... Todo aquello que se puede comprar más de 1 vez requiere ser "Consumido" (eliminado del inventario de la tienda). Si el jugador compra "100 gemas" y tú no llamas a `.consume()`, la tienda le dirá *"Ya tienes este artículo, no puedes comprarlo de nuevo"* en su próximo intento.

```gdscript
# Usamos el token que nos llegó en la señal de "purchase_successful"
Glapi.iap.consume(purchase_token)
```

### 4. Restaurar Compras No Consumibles (Restore Purchases)

Para artículos que se compran una sola vez y se guardan para siempre (ej: "Desbloquear Nivel 2" o "Quitar Anuncios"). Si el jugador cambia de teléfono o desinstala el juego, debes darle un botón de restaurar compras.

```gdscript
func _on_restore_pressed():
	Glapi.iap.purchases_restored.connect(_on_purchases_restored)
	Glapi.iap.restore_purchases()

func _on_purchases_restored(restored_product_ids: Array):
	for p_id in restored_product_ids:
		if p_id == "no_ads_pack":
			remove_ads_forever()
```

---

## 🛠 Desarrollo de Adaptadores (Para Ingenieros)

Si estás escribiendo el código puente (ej: usando GodotX, RevenueCat o el plugin oficial de Godot Android), tu adaptador debe extender `IIAPAdapter`.

### Interfaz Requerida

- `initialize() -> void:` Iniciar la conexión de Billing.
- `request_product_info(product_ids: Array) -> void:` Enviar la consulta de precios asíncrona a la tienda.
- `purchase(product_id: String) -> void:` Llamar al popup nativo de pago de Google/Apple.
- `consume(purchase_token: String) -> void:` Autorizar el consumo mediante el token único de recibo.
- `restore_purchases() -> void:` Pedir a la tienda el historial de recibos permanentes activos.

### Emisión de Señales
- `products_loaded.emit(array_products_dict)`
- `purchase_successful.emit(product_id, receipt_token)`
- `purchase_failed.emit(product_id, error_string)`
- `purchase_consumed.emit(product_id)`
- `purchases_restored.emit(array_of_product_ids)`
