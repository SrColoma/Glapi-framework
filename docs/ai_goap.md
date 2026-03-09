# Componentes AI: GOAP (Goal-Oriented Action Planning)

El GOAP (Planificación de Acciones Orientada a Metas) es el cerebro definitivo para Inteligencia Artificial en juegos donde los NPCs tienen profesiones o tareas logísticas complejas (juegos de colonias, estrategia, recolección de recursos).

A diferencia de la **FSM** (tu dices exactamente qué hacer y cuándo) o el **Behavior Tree** (tu armas a mano la jerarquía de prioridades), en GOAP **el NPC razona por su cuenta**.

Tú solo le dices tu **Meta** *"Consigue Madera"*. El GOAP revisará todas las Acciones que le programaste, se dará cuenta de que para talar ocupa un Hacha que no tiene, así que automáticamente buscará e insertará la Acción "Buscar Hacha en Almacén" primero.

---

## 🚀 Uso en tu Juego

### 1. El Árbol de la Escena (Jerarquía)

El Agente GOAP es un nodo que controla al NPC y evalúa su diccionario `world_state`. Añade tu Agente y métele como hijos todas las Habilidades (`GlapiGoapAction`) que sepa hacer este Agente.

```text
EntWoodcutter (Node2D) -> Nuestro actor leñador
  ├── Sprite
  └── GlapiGoapAgent
      ├── ActChopWood (Node) -> Script extendiendo GlapiGoapAction
      ├── ActGetAxe (Node)
      └── ActSleep (Node)
```

### 2. Creando Acciones (Las herramientas del Agente)
Crea scripts que extiendan `GlapiGoapAction`. Aquí ocurre la magia de las matemáticas. Defines precondiciones y efectos usando `_init()`.

```gdscript
# act_chop_wood.gd
extends GlapiGoapAction

func _init() -> void:
    action_name = "Talar Árbol"
    cost = 2.0
    
    # Precondición: El agente debe tener "has_axe" en TRUE dentro de su world_state
    add_precondition("has_axe", true)
    
    # Efecto: Una vez terminada la acción, el world_state del agente ganará "has_wood = true"
    add_effect("has_wood", true)

# Lo que pasa MIENTRAS se ejecuta la acción en el juego. Retornar TRUE para decir "Ya terminé mi paso"
func perform(actor: Node, delta: float) -> bool:
    actor.play_animation("chopping")
    return true
```

### 3. Ejecutando el Plan (Dándole órdenes)
Desde el código de tu Leñador (`EntWoodcutter`), simplemente dicta el estado actual del universo en el que está parado y exígele una Misión.

```gdscript
# ent_woodcutter.gd
@onready var agent: GlapiGoapAgent = $GlapiGoapAgent

func _ready():
    # El leñador empieza sin hacha ni madera
    agent.world_state = {"has_axe": false, "has_wood": false}
    
    # LA ORDEN MÁGICA
    agent.set_goal({"has_wood": true})
```

Al darle esta orden, el componente GOAP aplicará recursividad de `Backwards Chaining`. 
En la consola podrás suscribirte a las señales de `action_changed` en el Agente y notarás como él solo planificó:
`[Buscar Hacha en Almacén] -> [Talar Árbol]`.

## 🛠 Costos Dinámicos
Cada Acción tiene la variable `cost`. Si le programas dos acciones que cumplan `"has_wood" = true` (por ejemplo: `Talar` y `Robar Madera`), el Planificador A* elegirá automáticamente la serie de acciones que le cuesten menos esfuerzo/tiempo.
