# Componentes AI: Árbol de Comportamiento (Behavior Tree)

El Behavior Tree (BT) de Glapi es un componente jerárquico diseñado para construir inteligencias artificiales complejas, ideal para NPCs, Enemigos o Sistemas Autónomos. 

A diferencia de la FSM (donde estás en un estado fijo), el BT **evalúa las condiciones cada frame**, recorriendo el árbol de arriba hacia abajo, de izquierda a derecha. Esto permite crear planes de emergencia dinámicos (Ej: *"Estaba atacando, pero me quedé a 5 HP, por prioridad máxima ahora huiré"*).

---

## 🚀 Conceptos Core (Los Nodos de Godot)

Para armar el cerebro de tu Enemigo, añade el componente raíz `GlapiBehaviorTree` y agrégale nodos "Composites" y "Leaves" como hijos.

### 1. Composites (Formadores de Ramas)
* **`BTSelector` (Nodo OR):** Prueba a sus hijos uno tras otro. Se detiene y "Triunfa" en el momento en el que **UNO** de sus hijos tenga éxito. Es perfecto para *Prioridades*.
* **`BTSequence` (Nodo AND):** Ejecuta a sus hijos lógicamente uno tras otro. Si **UNO** falla, toda la secuencia falla. Perfecto para *Procesos* (Ej: `CondEnemyNear` -> `ActDrawSword` -> `ActSlash`).

### 2. Leaves (Hojas Finales)
Las escribes tú en la carpeta `game/` extendiendo de `BTLeaf`.
* **Conditions:** Nodos que leen variables del actor y devuelven `SUCCESS` instantáneamente si es cierto, o `FAILURE` si es falso.
* **Actions:** Nodos que hacen que el actor actúe. Pueden devolver `RUNNING` durante varios frames si es una acción demorada (ej: caminar hasta un punto).

---

## 🌲 Ejemplo de Estructura de Cerebro (SceneTree)

Un cerebro funcional de un enemigo luciría así en el editor de Escenas:

```text
EntEnemy (Node2D) -> Nuestro actor con variables `hp`
  └── GlapiBehaviorTree -> El motor que hace tick
      └──  BTSelector (Root) -> Su meta: Lograr al menos 1 rama.
           ├── BTSequence (Rama 1: Supervivencia. Prioridad Alta)
           │    ├── CondIsHpLow (¿Mi vida es menor a 20?)
           │    └── ActFlee (Correr lejos del jugador)
           │
           └── BTSequence (Rama 2: Combate. Prioridad Normal)
                ├── CondIsPlayerNear (¿Jugador a < 10 mts?)
                └── ActAttack (Golpear)
                
           └── ActWander (Rama 3: Aburrimiento. Prioridad Baja)
                (Si no tiene poca vida y no hay jugador, pasear).
```

## 💻 Programando una Hoja Personalizada

Crea un script normal, pon que extienda de `BTLeaf` y sobrescribe la función `tick()`:

```gdscript
# act_flee.gd
extends BTLeaf

func tick(delta: float) -> int:
    var player_pos = blackboard.get("player_position", Vector2.ZERO)
    
    # 1. Ejecutar Lógica
    var dir_opuesta = (actor.global_position - player_pos).normalized()
    actor.velocity = dir_opuesta * 200
    actor.move_and_slide()
    
    # 2. Retornar Estado BT
    return RUNNING # Sigue ejecutándose el frame que viene (hasta estar a salvo).
```

### El Blackboard (Diccionario Global)
Todos los nodos del mismo árbol comparten el diccionario `blackboard`. Úsalo para que el nodo de `CondPlayerSeen` guarde la variable `player_position` y el nodo `ActAttack` la lea en el siguiente bloque.
