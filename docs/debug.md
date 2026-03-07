# Módulo: Debug (Consola In-Game)

El módulo `DebugConsoleService` provee una terminal clásica estilo Quake/Source engine directamente integrada en el juego. Es una herramienta invaluable para QA, testers y desarrolladores que necesitan ejecutar comandos rápidos o leer los logs en dispositivos móviles (donde no existe la consola estándar del editor de Godot).

> [!NOTE]
> Esta consola sobrevive a los cambios de escena porque se inyecta dinámicamente en el árbol principal (`root`) sobre un `CanvasLayer` con *Z-index* muy alto (999).

---

## 🚀 Uso en el Juego (`Service Layer`)

La consola de Glapi viene pre-configurada con un set de comandos que cubren todas las funciones abstractas del framework (ej: `ads_show`, `scene_change`, `lang`, `time_pause`, etc.).

### 1. Activar la Consola Visualmente

Por defecto, la consola está oculta. Durante la ejecución del juego (en PC, Editor o exportación), pulsa la **tecla de acento grave / comilla invertida (\`)** (usualmente ubicada a la izquierda del número 1) para abrir o cerrar el panel.

También puedes abrirla por código (útil si configuras un botón oculto en pantalla táctil para tus testers en móvil):

```gdscript
# Abre/Cierra la consola programáticamente
Glapi.debug.toggle_console()
```

### 2. Registrar Comandos Propios del Juego

Si tu juego tiene una mecánica específica (ej: modo Dios, dar dinero, matar a todos los enemigos), puedes registrar comandos personalizados temporal o permanentemente en tu `res://game/`.

```gdscript
func _ready():
	# Registrar un comando que da oro
	Glapi.debug.register_command(
		"dar_oro",                   # El texto que se escribirá en consola
		_cmd_dar_oro,                # El método a ejecutar (Callable)
		"Otorga oro: dar_oro <n>",   # Texto de ayuda
		"economia"                   # Módulo bajo el cual se agrupará
	)

func _cmd_dar_oro(args: Array) -> void:
	if args.size() > 0:
		var amount = int(args[0])
		# ...lógica para dar oro al jugador...
		Glapi.debug.add_log("Se han otorgado " + str(amount) + " monedas.", DebugConsoleService.LogType.INFO)
	else:
		Glapi.debug.add_log("Uso incorrecto. Faltan argumentos.", DebugConsoleService.LogType.ERROR)
```

> [!TIP]
> **Autolimpieza:** Si registras un comando en un nodo de tu juego (ej: en el jugador), asegúrate de des-registrarlo al morir o cambiar de nivel para no dejar callbacks huérfanos: `Glapi.debug.unregister_command("dar_oro")`

### 3. Escribir en el Visor de Logs

Siempre que ocurra algo importante en tu juego y quieras que quede plasmado en la consola visual.

```gdscript
# Log Normal (Blanco)
Glapi.debug.add_log("El jefe ha aparecido.")

# Log de Alerta (Amarillo)
Glapi.debug.add_log("Jugador con poca vida.", DebugConsoleService.LogType.WARNING)

# Log de Error (Rojo)
Glapi.debug.add_log("No se pudo conectar al servidor de matchmaking.", DebugConsoleService.LogType.ERROR)
```

### 4. Menú de Ayuda Automático

Si un QA escribe `help` en la consola, el servicio autogenerará y mostrará una lista organizada de los módulos. Si escriben `help economia`, imprimirá la lista de todos tus comandos personalizados.

---

## 🛠 Desarrollo de Adaptadores (Para Ingenieros)

El `DebugConsoleService` **NO UTILIZA** el patrón *Adapter*. Dado que se trata de un componente de UI y lógica que vive 100% dentro del entorno cerrado de Godot, no existen dependencias externas (SDKs) que necesiten ser inyectadas o abstraídas.

Su código fuente base reside directamente en `addons/glapi/modules/debug/`.
