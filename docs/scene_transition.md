# Módulo: Transiciones y Overlays (Scene Transition)

El módulo de transiciones (`SceneTransitionManager` y `OverlayManager`) resuelve dos de los problemas más comunes en el desarrollo de videojuegos móviles: 
1. Cambiar de pantalla sin que el juego se congele (usando pantallas de carga o fundidos asíncronos).
2. Mostrar ventanas emergentes (Pop-ups, menús de pausa) apiladas unas sobre otras sin perder el estado del juego que corre de fondo.

---

## 🚀 Uso en el Juego (`Service Layer`)

Tienes acceso a dos gestores distintos inyectados en el Singleton global interactuando en las capas superiores del árbol.

### 1. Scene Transition Manager (`Glapi.scene_transition`)

Se encarga de reemplazar la escena actual (`get_tree().current_scene`) por una nueva, mostrando una cortina de humo en el medio.

#### A. Cambio Básico (Fundido a Negro)
Por defecto, Glapi usa una transición de fundido que oculta la escena A, carga la B de fondo y luego se desvanece.

```gdscript
# Cambiar de Menú Principal a Nivel 1
Glapi.scene_transition.change_scene("res://game/levels/level_01.tscn")
```

#### B. Cambio asíncrono con Await
Si necesitas esperar a que termine toda la animación de entrada de la nueva escena antes de instanciar enemigos.

```gdscript
func start_game():
	Glapi.scene_transition.change_scene("res://game/levels/level_01.tscn")
	await Glapi.scene_transition.transition_finished
	print("¡El nivel está visible y listo para jugarse!")
```

#### C. Usar Transiciones Personalizadas
Glapi te permite crear tus propias animaciones (Ej: cortinillas laterales, formas de estrella). Debes proveer la ruta hacia tu cortina.

```gdscript
# Usa una escena específica para esta transición
var my_wipe = "res://game/ui/transitions/star_wipe.tscn"
Glapi.scene_transition.change_scene_with_transition("res://game/levels/level_01.tscn", my_wipe)
```

#### D. Historial de Navegación (Ir a la pantalla anterior)
El framework guarda una *"Traza de Migas"* si usas `push_to_stack=true` (Activado por defecto). Esto te permite retroceder a la pantalla anterior sin saber cómo se llamaba.

```gdscript
func _on_btn_back_pressed():
	# Te devolverá de (Opciones -> a -> Menú Principal) automáticamente
	Glapi.scene_transition.go_back()
```

---

### 2. Overlay Manager (`Glapi.overlays`)

Se encarga de instanciar UIs (PackedScenes) flotantes, asignándoles automáticamente un `Z-Index` sobre el nivel 100 y apilándolas. Ideal para Confirmaciones, Recompensas y Tiendas In-Game.

#### A. Mostrar un Menú Flotante (Push)

```gdscript
@export var pause_menu_scene: PackedScene

func show_pause():
	# El menú aparecerá por encima de tu personaje y nivel
	Glapi.overlays.push_overlay(pause_menu_scene)
```

#### B. Cerrar el Menú Actual (Pop)

Si el usuario apreta el botón "X" o el botón "Atrás" de Android, puedes descartar el overlay que está más arriba en la pila.

```gdscript
func _on_btn_close_pressed():
	Glapi.overlays.pop_overlay()
```

#### C. Cerrar todo de Golpe

Si estabas en `Pausa -> Opciones -> Gráficos` (3 capas apiladas) y el usuario decide abandonar la partida.

```gdscript
# Destruye todas las ventanas flotantes simultáneamente
Glapi.overlays.clear_overlays()
```

---

## 🛠 Desarrollo de Adaptadores (Para Ingenieros)

El ecosistema de Transiciones y Overlays **NO UTILIZA** el patrón *Adapter*.

Si deseas fabricar tus propios efectos visuales de cambio de escena, basta con que crees una escena cualquiera de interfaz en tu carpeta de juego local y te asegures de que herede el script principal:
`class_name TransitionScene extends CanvasLayer`
