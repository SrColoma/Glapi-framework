# Componentes AI: Máquina de Estados Finita (FSM)

El patrón FSM (Finite State Machine) te permite controlar Entidades que solo pueden hacer **una acción a la vez** y necesitan hacer transiciones limpias y ordenadas entre ellas (ej: el Jugador no puede Caminar, Atacar y Morir al mismo tiempo).

En lugar de tener un código espagueti masivo lleno de `if is_attacking: ... elif is_moving: ...` en el jugador, Glapi te da bloques limpios para separar el código en Nodos individuales.

---

## 🚀 Uso en tu Juego

### 1. El Árbol de la Escena (Jerarquía)

Añade un nodo `GlapiStateMachine` a tu entidad y ponle tantos nodos hijos como estados posea tu entidad, agregándoles a cada uno un script que extienda de `GlapiState`:

```text
Player (Node2D) -> actor
  ├── Sprite
  └── GlapiStateMachine -> initial_state: StateIdle
      ├── StateIdle (Node) -> Script extendiendo GlapiState
      ├── StateMove (Node)
      └── StateAttack (Node)
```

### 2. El código del Estado Local (`glapi_state.gd`)
Sencillamente extiende de `GlapiState`. Tendrás a tu disposición las variables pre-inyectadas `actor` (El Nodo Padre dueño de la máquina) y `machine`.

```gdscript
# state_move.gd
extends GlapiState

var speed = 300.0

# Se llama cuando el actor ENTRA en este estado
func enter(msg: Dictionary = {}) -> void:
    actor.play_animation("run")
    
# Se llama cada Frame MIENTRAS esté en este estado
func update(delta: float) -> void:
    var input_x = Input.get_axis("ui_left", "ui_right")
    
    if input_x == 0:
        # Transición limpia hacia otro nodo hijo
        transition_to("StateIdle")
        return
        
    actor.position.x += input_x * speed * delta
    
    if Input.is_action_just_pressed("jump"):
        # Puedes pasar diccionarios si lo necesitas
        transition_to("StateJump", {"jump_force": 500})
```

---

## 🛠 Ventajas Arquitectónicas

1. **Aislación de Lógica:** Si el ataque del enemigo tiene un bug, solo abres `state_attack.gd`. El código de movimiento o reposo está 100% a salvo y limpio en otro lado.
2. **Componentes Puros:** El `GlapiStateMachine` no es un Autoload inyectado desde `auto_glapi.gd`. Es un nodo local, el jugador y el enemigo pueden usar el FSM exactamente al mismo tiempo y ninguno sabrá de la existencia del otro.
3. **Pausas Seguras:** Al ser un nodo dentro de tu entidad en la carpeta `game/`, si pausas el juego globalmente, la máquina de estados obedece automáticamente el ciclo normal de nodos de Godot y se detiene.
