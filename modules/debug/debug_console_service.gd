class_name DebugConsoleService extends Node

## Servicio global de consola de depuración en el juego.
## Permite registrar comandos y ver logs en tiempo de ejecución (útil en móviles).

signal command_executed(command_name: String, args: Array)
signal log_added(message: String, type: int)

enum LogType { INFO, WARNING, ERROR }

var _commands: Dictionary = {}
var _logs: Array[Dictionary] = []
var _pending_ads: Dictionary = {}
var _ui_instance: Node = null
var _ui_scene: PackedScene = preload("res://addons/glapi/modules/debug/view_debug_console.tscn")

func _ready() -> void:
	# Podríamos instanciarla inactiva e inyectarla al OverlayManager,
	# pero como es solo dev/QA, mejor la manejamos directamente.
	if OS.is_debug_build():
		_ui_instance = _ui_scene.instantiate()
		_ui_instance.visible = false
		
		var canvas = CanvasLayer.new()
		canvas.layer = 999  # Encima de todo, incluyendo modales y transiciones
		canvas.add_child(_ui_instance)
		
		# Asegurarnos de que no se muera al cambiar de escena
		Engine.get_main_loop().root.call_deferred("add_child", canvas)
	
	# Comandos por defecto
	register_command("help", _cmd_help, "Muestra esta ayuda.")
	register_command("clear_save", _cmd_clear_save, "Borra los datos guardados del jugador.")
	
	setup_glapi_commands()
	
	# Escribimos el menú de ayuda en el log al iniciar
	_cmd_help([])
	
	# Usar call_deferred para asegurar que Glapi.ads esté listo al 100%
	call_deferred("_connect_ads_signals")

func _connect_ads_signals() -> void:
	if Glapi.ads != null:
		Glapi.ads.ad_loaded.connect(_on_ad_loaded)
		Glapi.ads.ad_failed_to_load.connect(_on_ad_failed)

func setup_glapi_commands() -> void:
	# Scenes / Nav
	register_command("scene_change", func(args): if args.size() > 0: Glapi.scene_transition.change_scene(args[0]), "Cambia escena: scene_change <path>", "scene")
	register_command("scene_back", func(args): Glapi.scene_transition.go_back(), "Vuelve a la escena anterior.", "scene")
	register_command("scene_demo", func(args): Glapi.scene_transition.change_scene(get_tree().current_scene.scene_file_path), "Demo de transición de escenas recargando la actual.", "scene")
	register_command("overlay_clear", func(args): Glapi.overlays.clear_overlays(), "Cierra todos los overlays.", "scene")
	register_command("overlay_demo", func(args): Glapi.overlays.push_overlay(load("res://addons/glapi/modules/scene_transition/overlays/view_example_overlay.tscn")), "Prueba el sistema de capas.", "scene")
	
	# Time
	register_command("time_pause", func(args): Glapi.time.pause_game(), "Pausa el juego.", "time")
	register_command("time_resume", func(args): Glapi.time.resume_game(), "Reanuda el juego.", "time")
	
	# Settings
	register_command("lang", func(args): if args.size() > 0: Glapi.settings.set_language(args[0]), "Cambia idioma: lang <locale>", "settings")
	register_command("vol", func(args): 
		if args.size() > 1: 
			var vol = float(args[1])
			match args[0].to_lower():
				"master": Glapi.settings.set_master_volume(vol)
				"sfx": Glapi.settings.set_sfx_volume(vol)
				"music": Glapi.settings.set_music_volume(vol)
		, "Cambia volumen: vol <master|sfx|music> <0.0-1.0>", "settings")
	register_command("fullscreen", func(args): if args.size() > 0: Glapi.settings.set_fullscreen(args[0] == "1" or args[0] == "true"), "Fullscreen: fullscreen <1|0>", "settings")
	
	# Monetization
	register_command("iap_buy", func(args): if args.size() > 0: Glapi.iap.purchase(args[0]), "Compra IAP.", "monetization")
	register_command("iap_restore", func(args): Glapi.iap.restore_purchases(), "Restaura compras.", "monetization")
	register_command("ads_show", _cmd_ads_show, "Carga y muestra anuncio: ads_show <banner|interstitial|rewarded|native>", "monetization")
	register_command("ads_hide", func(args): if args.size() > 0: Glapi.ads.hide_ad(args[0]), "Oculta anuncio: ads_hide <banner|native>", "monetization")
		
	# Telemetry
	register_command("track", func(args): if args.size() > 0: Glapi.dispatch(ScreenViewEvent.new(args[0])), "Rastrea pantalla: track <name>", "telemetry")
	register_command("crash_log", func(args): if args.size() > 0: Glapi.crashlytics.log_message(" ".join(args)), "Anota en Crashlytics: crash_log <msg>", "telemetry")
	register_command("crash_error", func(args): if args.size() > 1: Glapi.crashlytics.record_exception(args[0], " ".join(args.slice(1))), "Exception log: crash_error <name> <desc>", "telemetry")
	register_command("rc_fetch", func(args): Glapi.remote_config.fetch_and_activate(), "Forzar carga de RemoteConfig.", "telemetry")
	
	# Social/GS
	register_command("gs_signin", func(args): Glapi.game_services.sign_in(), "Inicia sesión en Play Games.", "social")
	register_command("gs_achieve", func(args): if args.size() > 0: Glapi.game_services.unlock_achievement(args[0]), "Desbloquea logro: gs_achieve <id>", "social")
	register_command("gs_score", func(args): if args.size() > 1: Glapi.game_services.submit_score(args[0], int(args[1])), "Sube puntaje: gs_score <id> <score>", "social")
	register_command("gs_leaderboards", func(args): Glapi.game_services.show_leaderboards(), "Muestra Leaderboards nativos.", "social")
	register_command("gs_achievements", func(args): Glapi.game_services.show_achievements(), "Muestra Logros nativos.", "social")

func _input(event: InputEvent) -> void:
	# Abrir con la tecla que suele estar debajo de ESC (Backquote/Tile)
	if OS.is_debug_build() and event is InputEventKey and event.pressed and event.keycode == KEY_QUOTELEFT:
		toggle_console()
		get_viewport().set_input_as_handled()

## Registra un nuevo comando que se puede escribir en la consola.
## @param cmd_name: Nombre del comando (ej: "give_gold")
## @param callback: Función a llamar, que reciba un Array de argumentos
## @param help_text: Descripción de lo que hace (opcional)
func register_command(cmd_name: String, callback: Callable, help_text: String = "", module: String = "general") -> void:
	_commands[cmd_name.to_lower()] = {
		"callback": callback,
		"help": help_text,
		"module": module.to_lower()
	}

## Desregistra un comando previamente registrado
func unregister_command(cmd_name: String) -> void:
	_commands.erase(cmd_name.to_lower())

## Ejecuta un texto entero ingresado por el usuario
func execute(input_string: String) -> void:
	var parts = input_string.strip_edges().split(" ", false)
	if parts.size() == 0:
		return
		
	var cmd = parts[0].to_lower()
	var args = []
	for i in range(1, parts.size()):
		args.append(parts[i])
		
	add_log("> " + input_string, LogType.INFO)
		
	if _commands.has(cmd):
		var callback = _commands[cmd].callback
		callback.call(args)
		command_executed.emit(cmd, args)
	else:
		add_log("Comando desconocido: " + cmd + ". Escribe 'help'.", LogType.ERROR)

## Muestra u oculta la UI de la consola
func toggle_console() -> void:
	if _ui_instance:
		_ui_instance.visible = not _ui_instance.visible
		if _ui_instance.visible and _ui_instance.has_method("focus_input"):
			_ui_instance.focus_input()

## Registra un mensaje en el visor de la consola
func add_log(message: String, type: LogType = LogType.INFO) -> void:
	var entry = {"msg": message, "type": type}
	_logs.append(entry)
	
	# Mantener límite de memoria
	if _logs.size() > 100:
		_logs.pop_front()
		
	log_added.emit(message, type)

# --- Comandos por Defecto ---
func _cmd_help(args: Array) -> void:
	if args.size() == 0:
		var modules = {}
		for cmd in _commands.values():
			modules[cmd.module] = true
		add_log("--- Módulos Disponibles ---", LogType.INFO)
		add_log("Escribe 'help <modulo>' para ver comandos.", LogType.INFO)
		var mods_str = ""
		for m in modules.keys():
			mods_str += "- " + m + " "
		add_log(mods_str, LogType.INFO)
	else:
		var target_module = args[0].to_lower()
		add_log("--- Comandos: " + target_module + " ---", LogType.INFO)
		var found = false
		for cmd in _commands.keys():
			var data = _commands[cmd]
			if data.module == target_module:
				add_log(cmd + (" - " + data.help if data.help != "" else ""), LogType.INFO)
				found = true
		if not found:
			add_log("Módulo no encontrado: " + target_module, LogType.WARNING)

func _cmd_clear_save(_args: Array) -> void:
	if Glapi.storage:
		Glapi.storage.state.clear()
		Glapi.storage.save_all_state()
		add_log("Partida borrada. Reinicia el juego.", LogType.WARNING)
	else:
		add_log("StorageService no disponible.", LogType.ERROR)

# --- Callbacks Asíncronos Ads ---
func _cmd_ads_show(args: Array) -> void:
	if args.size() == 0:
		add_log("Falta formato: ads_show <banner|interstitial|rewarded|native>", LogType.ERROR)
		return
		
	var format_str = args[0].to_lower()
	if not format_str in ["banner", "interstitial", "rewarded", "app_open", "rewarded_interstitial", "native"]:
		add_log("Formato '" + format_str + "' inválido.", LogType.ERROR)
		return
		
	add_log("⏳ Cargando anuncio (" + format_str + ")...", LogType.INFO)
	_pending_ads[format_str] = true
	Glapi.ads.load_ad(format_str)

func _on_ad_loaded(format: int) -> void:
	var format_str = _enum_to_ad_string(format)
	if _pending_ads.get(format_str, false):
		_pending_ads[format_str] = false
		add_log("✅ " + format_str + " cargado. Mostrando...", LogType.INFO)
		Glapi.ads.show_ad(format_str)

func _on_ad_failed(format: int, msg: String) -> void:
	var format_str = _enum_to_ad_string(format)
	if _pending_ads.get(format_str, false):
		_pending_ads[format_str] = false
		add_log("❌ Error cargando " + format_str + ": " + msg, LogType.ERROR)

func _enum_to_ad_string(val: int) -> String:
	match val:
		IAdsAdapter.AdFormat.BANNER: return "banner"
		IAdsAdapter.AdFormat.INTERSTITIAL: return "interstitial"
		IAdsAdapter.AdFormat.REWARDED: return "rewarded"
		IAdsAdapter.AdFormat.REWARDED_INTERSTITIAL: return "rewarded_interstitial"
		IAdsAdapter.AdFormat.NATIVE: return "native"
		IAdsAdapter.AdFormat.APP_OPEN: return "app_open"
	return "unknown"
