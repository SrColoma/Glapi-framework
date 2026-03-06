class_name TimeManager extends Node

## Gestor global de tiempo y pausa.
## Mantiene el control del ciclo de vida temporal (Idle ticks, Pausas seguras).

signal time_ticked(delta_offline: int)
signal game_paused(is_paused: bool)

const LAST_LOGIN_KEY = "app_last_login_sys_time"

var _is_paused: bool = false
var _storage_service: StorageService = null

func initialize(storage_service: StorageService) -> void:
	_storage_service = storage_service
	
	# Asegurarnos de que este nodo SIEMPRE procese, incluso cuando se pause el árbol
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	_calculate_offline_time()

## Calcula el tiempo transcurrido desde el último login y emite el evento correspondiente
func _calculate_offline_time() -> void:
	if not _storage_service:
		push_error("TimeManager: No se estableció ningún StorageService válido.")
		return
		
	var current_time = Time.get_unix_time_from_system()
	var last_login_time: float = _storage_service.get_state(LAST_LOGIN_KEY, 0.0)
	var delta_offline = 0
	
	# Calcular la diferencia en segundos si el tiempo base existía y es válido
	if last_login_time > 0 and current_time >= last_login_time:
		delta_offline = int(current_time - last_login_time)
	
	print("🕰️ TIME MANAGER: Tiempo offline calculado: ", delta_offline, " segundos.")
	
	# Actualizar el último tiempo de login para la siguiente vez
	_storage_service.set_state(LAST_LOGIN_KEY, current_time, true)
	
	# Reaccionar si hubo tiempo muerto
	if delta_offline > 0:
		time_ticked.emit(delta_offline)
		Glapi.dispatch(TimeTickEvent.new(delta_offline))

## Pausa el juego completo (_process_mode del SCENE TREE global) sin afectar Framework UI
func pause_game() -> void:
	if _is_paused:
		return
		
	_is_paused = true
	get_tree().paused = true
	game_paused.emit(true)
	print("🕰️ TIME MANAGER: Juego globalmente PAUSADO.")

## Reanuda el juego completo
func resume_game() -> void:
	if not _is_paused:
		return
		
	_is_paused = false
	get_tree().paused = false
	game_paused.emit(false)
	print("🕰️ TIME MANAGER: Juego globalmente REANUDADO.")

## Consulta si el juego está pausado a través de este manager
func is_paused() -> bool:
	return _is_paused
