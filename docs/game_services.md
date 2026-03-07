# Módulo: Game Services (Play Games / Game Center)

El módulo `GameServicesService` abstrae las funcionalidades típicas que ofrecen los sistemas nativos de los sistemas operativos móviles, como Google Play Games Services en Android o Apple Game Center en iOS. 

Permite gestionar la identidad del jugador en la plataforma, manejar una "Puntuación Global" (Leaderboards) y llevar el registro de "Logros" (Achievements).

---

## 🚀 Uso en el Juego (`Service Layer`)

Interactúa con este servicio a través del Singleton global `Glapi.game_services`. 

### 1. Iniciar Sesión (Sign In)

La mayoría de los juegos modernos inician sesión en segundo plano al abrirse. Si falla, suelen mostrar un botón con el logo de "Google Play" para que el usuario fuerce el inicio manual.

```gdscript
func _ready():
	# Nos suscribimos a las señales de éxito/fracaso
	Glapi.game_services.sign_in_success.connect(_on_sign_in_success)
	Glapi.game_services.sign_in_failed.connect(_on_sign_in_failed)
	
	# Pedimos Iniciar Sesión Visualmente
	Glapi.game_services.sign_in()

func _on_sign_in_success(player_name: String):
	print("Bienvenido de nuevo, ", player_name)
```

### 2. Desbloquear Logros (Achievements)

Cuando el jugador cumple una meta, puedes ordenarle al sistema operativo nativo que lo registre. Esto habitualmente muestra el clásico banner en la parte superior de la pantalla del móvil.

```gdscript
func kill_dragon():
	# Desbloqueamos el logro pasándole la ID (usualmente provista por Google Console)
	Glapi.game_services.unlock_achievement("logro_dragon_slayer_01")
```

### 3. Enviar Puntaje a las Tablas de Clasificación (Leaderboards)

El envío del High Score suele hacerse de forma silenciosa cada vez que la partida termina o al romper el récord local.

```gdscript
func end_match(final_score: int):
	Glapi.game_services.submit_score("ranking_global_id", final_score)
```

### 4. Mostrar la UI Nativa de la Plataforma

Si tienes botones visuales en tu menú principal como "Ver Ranking" o "Ver Logros", no necesitas programar la interfaz. Puedes llamar directamente los popups nativos de Apple/Google.

```gdscript
func _on_btn_ranking_pressed():
	Glapi.game_services.show_leaderboards()

func _on_btn_achiev_pressed():
	Glapi.game_services.show_achievements()
```

---

## 🛠 Desarrollo de Adaptadores (Para Ingenieros)

Si tu equipo necesita implementar el bridge con otro plugin (o un backend personalizado como LootLocker o Epic Online Services), tu clase debe heredar de `IGameServicesAdapter`.

### Interfaz Requerida

El nuevo adaptador debe proveer implementación para:
- `initialize() -> void:` Opcional, reservada para pre-cargas SDK.
- `sign_in() -> void:` Inicia el proceso de autenticación.
- `unlock_achievement(achievement_id: String) -> void`
- `submit_score(leaderboard_id: String, score: int) -> void`
- `show_leaderboards() -> void`
- `show_achievements() -> void`

### Emisión de Señales
Es **vital** que el adaptador emita las señales asociadas al inicio de sesión para que el Front-end se entere si el usuario pudo loguearse o si debe mostrarle el botón manual.
* `sign_in_success.emit(player_name)`
* `sign_in_failed.emit(error_msg)`
