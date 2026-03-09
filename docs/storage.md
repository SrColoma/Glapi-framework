# Módulo: Storage (Guardado de Estado e Inventario)

El módulo `StorageService` es la única fuente de verdad (Single Source of Truth) para la persistencia del estado del juego de tu usuario (Monedas, Nivel Actual, Inventario de Armas, Vidas). 

Este servicio garantiza que el *"estado vivo"* del jugador resida en RAM (`Glapi.storage.state`), y que se sincronice con el disco o la nube de forma segura (encriptada) sin bloquear el hilo principal.

---

## 🚀 Uso en el Juego (`Service Layer`)

El Singleton global `Glapi.storage` contiene un diccionario masivo llamado `state`. Es responsabilidad del Core de Juego inicializar este diccionario si el usuario es nuevo.

### 1. Lectura del Estado (Getters)

Cuando tu juego necesita saber cuántas monedas tiene el jugador, siempre debe consultar al servicio Storage. 
Es una gran práctica **siempre** usar el parámetro `default_value` por si el campo es consultado por primera vez en la historia de la cuenta.

```gdscript
func update_ui():
	# Si "gold" no existe en el savefile actual, devolverá 0
	var gold: int = Glapi.storage.get_state("gold", 0)
	var current_level: int = Glapi.storage.get_state("current_level", 1)
	
	$LabelGold.text = str(gold)
```

### 2. Escritura del Estado (Setters y Auto-Save)

Al modificar variables, el módulo guarda automáticamente los cambios en el disco duro o la nube gracias al flag `auto_save = true`.

```gdscript
func grant_gold(amount: int):
	var current_gold = Glapi.storage.get_state("gold", 0)
	
	# Esto actualiza el hash en RAM y al mismo tiempo ordena a la capa de I/O escribir el disco
	Glapi.storage.set_state("gold", current_gold + amount)

func change_character_name(new_name: String):
	Glapi.storage.set_state("player_name", new_name)
```

### 3. Operaciones Por Lotes (Bulk Operations)

Si estás actualizando 50 variables a la vez (por ejemplo, cargar el inventario entero de un cofre), es terriblemente ineficiente que el archivo se guarde 50 veces seguidas. 

Para esos casos de alto tráfico, apagas el `auto_save` y fuerzas un Commit manual al final:

```gdscript
func equip_full_armor_set(helmet: String, chest: String, boots: String):
	# Cambia la Data en RAM (Operación que no cuesta nada)
	Glapi.storage.set_state("equipped_helmet", helmet, false)
	Glapi.storage.set_state("equipped_chest", chest, false)
	Glapi.storage.set_state("equipped_boots", boots, false)
	
	# Fuerza físicamente la escritura del JSON / SQL a disco una sola vez
	Glapi.storage.save_all_state()
```

---

## 🏗️ Arquitectura de Repositorios (El Juego vs El Framework)

**Regla de Oro:** El código de tu juego (`res://game/`) NUNCA debe conectarse directamente con la base de datos (Firebase, SQLite, etc). En su lugar, el juego debe usar el patrón **Repository** para comunicarse con `Glapi.storage`.

Esto garantiza que el módulo de Storage se mantenga ciego al tipo de juego actual, y que si decides cambiar el motor de persistencia, tu lógica de juego quede intacta.

### 1. El Dilema de los Queries (SQL vs Caché en RAM)

Dado que Glapi puede usar adaptadores muy diferentes (desde SQL puro hasta JSON o Mock), tienes dos enfoques para diseñar tus repositorios:

#### Enfoque A: Agnóstico y Recomendado (Filtrado en RAM)
Ideal para experimentos casuales donde toda la data del jugador cabe en memoria. En lugar de mandar strings SQL al Storage, descargas el array completo desde la memoria ultrarrápida de Glapi y usas las funciones nativas de GDScript.

```gdscript
# res://game/core/repositories/inventory_repository.gd
class_name InventoryRepository extends RefCounted

## Funciona perfecto sin importar si el Adaptador debajo es JSON, SQLite o un Mock vacío
func get_highest_rarity_items() -> Array:
    # 1. Obtienes TODOS los items desde la caché agnóstica de Glapi
    var all_items: Array = Glapi.storage.get_state("inventory", [])
    
    # 2. Tu repositorio hace la "query" usando GDScript en RAM (Súper rápido)
    var filtered = all_items.filter(func(item): return item.get("rareza", 0) > 3)
    filtered.sort_custom(func(a, b): return a.get("rareza", 0) > b.get("rareza", 0))
    
    # 3. Transformas los diccionarios a entidades de negocio (Opcional pero recomendado)
    return filtered.slice(0, 5)
```

#### Enfoque B: Consultas Crudas a Base de Datos (Para datos masivos)
Si tu juego maneja miles de registros que no caben en memoria, debes usar la función `execute_query` de Storage. **Advertencia:** Esto acopla tu experimento actual a que el Adaptador soporte SQL (o el lenguaje que envíes).

```gdscript
# res://game/core/repositories/inventory_repository.gd
class_name InventoryRepository extends RefCounted

func get_highest_rarity_items() -> Array:
    var sql: String = "SELECT * FROM inventory ORDER BY rareza DESC LIMIT 5"
    
    # Glapi simplemente pasa el string al Adaptador (ej. SQLite) y devuelve el resultado
    var raw_results = Glapi.storage._adapter.execute_query(sql)
    return raw_results
```

> [!TIP]
> **Robustez de Glapi:** Si usas el Enfoque B (`execute_query`) pero tienes activo el `MockStorageAdapter` (el cual no entiende SQL), **tu juego no hará crash**. El adaptador Mock interceptará la llamada, avisará por consola que no soporta queries, y devolverá un Array vacío `[]` para que tu juego siga funcionando de forma segura durante las pruebas.

---

## 🛠 Desarrollo de Adaptadores (Para Ingenieros)

El ecosistema `IStorageAdapter` es el único responsable de la persistencia real (Cloud Save, Local LocalStorage, SQLite). 

### Interfaz Requerida:
- `initialize() -> void:` Aquí se debería realizar la validación de archivos o cargar la clave AES estática antes de intentar leer.
- `save_state(data: Dictionary) -> void:` Enviar los datos del juego al disco físico o al backend en la nube.
- `load_state() -> Dictionary:` Recibe un objeto Diccionario vacío o ya cargado.
- `execute_query(sql: String, args: Array) -> Array:` *(Opcional)* Si nuestro Provider es relacional (como un Plugin de SQLite).

> [!WARNING]
> **Seguridad (Inyección de Clave):** Si escribes un proveedor de LocalStorage, **NUNCA** coloques la clave de encriptación dentro de la clase ni la quemes en el script. Exígela por constructor (`_init(secret_key: String)`) y oblígale al Game Developer inyectarla desde su `res://game/bootstrap.gd` (Composition Root), garantizando que las llaves nunca terminen colgadas en repositorios del motor público genérico.
