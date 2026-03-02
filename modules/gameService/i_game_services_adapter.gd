class_name IGameServicesAdapter extends GlapiAdapter

# Señales para saber si el jugador se conectó exitosamente
signal sign_in_success(player_name: String)
signal sign_in_failed(error_msg: String)

func initialize() -> void:
	push_error("IGameServicesAdapter: initialize() no implementado.")

# Muestra el popup de inicio de sesión de Google/Apple
func sign_in() -> void:
	push_error("IGameServicesAdapter: sign_in() no implementado.")

# Desbloquea un logro (ej. "Mata 100 enemigos")
func unlock_achievement(achievement_id: String) -> void:
	push_error("IGameServicesAdapter: unlock_achievement() no implementado.")

# Sube una puntuación a una tabla de clasificación
func submit_score(leaderboard_id: String, score: int) -> void:
	push_error("IGameServicesAdapter: submit_score() no implementado.")

# Abre las interfaces nativas del teléfono para ver los rankings y logros
func show_leaderboards() -> void:
	push_error("IGameServicesAdapter: show_leaderboards() no implementado.")

func show_achievements() -> void:
	push_error("IGameServicesAdapter: show_achievements() no implementado.")
