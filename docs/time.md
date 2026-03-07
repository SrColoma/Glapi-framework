# Módulo: Time (Manejo de Tiempo y Pausa)

El módulo `TimeManager` resuelve el problema abstracto del paso del tiempo y la pausa global. Garantiza que puedas calcular cuánto tiempo estuvo un jugador *"desconectado"* (offline time) para otorgarle recompensas inactivas, vidas regeneradas o recolectar oro (estilo Idle Games). Además, centraliza la lógica para pausar tu árbol de nodos (`SceneTree`) sin congelar la Mesa de Control.

---

## 🚀 Uso en el Juego (`Service Layer`)

El Singleton global `Glapi.time` contiene los métodos y señales necesarios para suscribir tus granjas, energía, o temporizadores in-game.

### 1. Sistema de Tiempo Inactivo (Offline Time / Idle / AFK)

Inmediatamente al arrancar el juego, e instantáneamente después de cargar los datos de Storage, el módulo de Tiempo calcula la diferencia de UNIX Timestamp contra la última vez que el jugador tuvo el juego abierto.

Tienes dos formas de reaccionar a esto en tu código:

#### A. Por Señal Directa (Para Interfaces Rápidas)
Si tienes un nodo visual que necesita actualizar cuántos minutos pasaron y dibujar moneditas.
```gdscript
func _ready():
	Glapi.time.time_ticked.connect(_on_time_ticked)

func _on_time_ticked(delta_seconds: int):
	print("El jugador estuvo ausente durante ", delta_seconds, " segundos.")
	# Ejemplo: Dar 1 moneda por cada 60 segundos ausente
	var gold_earned = delta_seconds / 60
	grant_gold(gold_earned)
```

#### B. A través de Analíticas Limpias (Framework Core)
Al igual que las Compras, el Framework despacha un evento `TimeTickEvent` al flujo general, permitiéndote rastrear en tus paneles (ej. Google Analytics) cuánto tiempo promedio tardan tus jugadores en volver a abrir la App.

### 2. Sistema de Pausa Segura

Cuando quieres pausar todos los enemigos, las físicas y la lógica del mapa actual sin que se congele tu menú de opciones ni la consola de depuración del Framework.

> [!IMPORTANT]
> A diferencia de pausar mediante el *SceneTree* (`get_tree().paused`), los nodos del Framework aseguran que su _Process Mode_ sea `ALWAYS`, garantizando que la música de UI y los botones del motor interno sigan reaccionando a pesar del congelamiento mundial.

```gdscript
# Detiene todos los nodos cuyo "Process Mode" sea INHERIT (Nodos normales)
Glapi.time.pause_game()

# Devuelve la vida al mapa
Glapi.time.resume_game()
```

También puedes suscribirte para saber si alguien (ej. otro UI Pop-up) pausó el juego, ideal para silenciar algunos sonidos ambientales:
`Glapi.time.game_paused.connect(_on_game_paused_state_changed)`

---

## 🛠 Desarrollo de Adaptadores (Para Ingenieros)

El `TimeManager` **NO UTILIZA** el patrón *Adapter*. Depende de la clase nativa de Godot `Time.get_unix_time_from_system()` y lee internamente llaves seguras desde tu `StorageService` para persistir su memoria delta.

No se requieren implementaciones externas, pero asegúrate de que **nunca se inicialice un nodo hijo de tipo Idle Simulator** hasta que el `StorageService` esté completamente en RAM, dado que el `TimeManager` se inyecta y auto-dispara en el Composition Root (usualmente `auto_Glapi.gd`).
