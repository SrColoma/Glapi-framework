# Módulo: Object Pooling (Gestión de Memoria y Nodos)

El módulo `ObjectPoolService` de Glapi está diseñado para evitar los picos de LAG originados por el Garbage Collector y el disco al usar `instantiate()` y `queue_free()` masivamente durante el gameplay en juegos móviles. 

En lugar de crear y destruir objetos (ej: balas, monedas, enemigos, efectos visuales), este módulo los **reutiliza**, manteniéndolos en RAM inactivos y despertándolos cuando se requieren.

---

## 🚀 Uso en el Juego (`Service Layer`)

El servicio vive globalmente en `Glapi.pooling`.

### 1. Prearmado (Prewarming) en Pantallas de Carga
Para evitar que el juego se congele durante el Gameplay, es vital "pre-instanciar" los objetos pesados en un momento seguro, como una pantalla de carga o un menú principal.

```gdscript
# view_main_menu.gd
var enemy_scene = preload("res://game/core/ent_enemy.tscn")
var arrow_scene = preload("res://game/core/ent_arrow.tscn")

func _ready():
	# Glapi reservará 20 naves y 100 flechas ocultas en RAM
	Glapi.pooling.prewarm(enemy_scene, 20)
	Glapi.pooling.prewarm(arrow_scene, 100)
```

### 2. Adquirir Nodos (Gameplay Diario)
Cuando el juego está andando, nunca llamas a `scene.instantiate()`. Llamas a `acquire()`. 

> [!TIP]
> **Expansión Dinámica:** Si precalentaste 10 flechas pero necesitas la flecha 11, Glapi creará una nueva automáticamente sin romper tu código y la sumará al Pool Permanente.

```gdscript
# ent_player.gd
var arrow_scene = preload("res://game/core/ent_arrow.tscn")

func shoot():
	# Obtiene un nodo disponible de la caché rápida
	var arrow: Node2D = Glapi.pooling.acquire(arrow_scene)
	
	if arrow:
		# Glapi no asume dónde quieres poner el nodo en el árbol, es TU trabajo añadirlo
		add_child(arrow)
		arrow.global_position = self.global_position
```

### 3. Liberar y Reciclar (Muerte del Objeto)
Cuando un proyectil impacta o un enemigo muere, **NUNCA DEBES USAR `queue_free()`**. Debes devolverlo suavemente al framework usando `release()`.

```gdscript
# ent_arrow.gd
func _on_body_entered(body: Node):
	if body.is_in_group("enemy"):
		body.take_damage(10)
		
		# Devolver a Glapi (él hará hide(), PROCESS_MODE_DISABLED, y se lo guardará)
		Glapi.pooling.release(self)
```

---

## ⚙️ Métodos Avanzados y Ciclo de Vida (Callbacks)

Cuando el _Pool_ despierte tu nodo o lo duerma, Glapi buscará si tu script tiene funciones mágicas implementadas para permitirte restaurar salud, rotaciones o variables sucias.

### `_on_pool_acquire()`
Se llama automáticamente justo después de que Glapi revive tu nodo. Ideal para resetear timers o vida.

```gdscript
func _on_pool_acquire() -> void:
    health = 100
    $CollisionShape2D.disabled = false
    show()
```

### `_on_pool_release()`
Se llama automáticamente justo antes de ser dormido. Ideal para cortar audios, partículas, etc.

```gdscript
func _on_pool_release() -> void:
    $EngineSound.stop()
    _velocity = Vector2.ZERO
```

### Limpieza de Escena Activa (`clear_all`)
Cuando tu aventura principal o nivel gigante finalice y regreses a la escena del Menú Principal vacío, querrás vaciar todos los Pools masivos para recuperar la RAM del teléfono.

```gdscript
func return_to_main_menu():
	Glapi.pooling.clear_all()
	Glapi.scene_transition.change_scene("res://game/view_main_menu.tscn")
```
