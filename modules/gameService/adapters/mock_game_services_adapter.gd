class_name MockGameServicesAdapter extends IGameServicesAdapter

var _is_signed_in: bool = false

func initialize() -> void:
	print("🟡 MOCK GAME SERVICES: Inicializado.")

func sign_in() -> void:
	print("⏳ MOCK GAME SERVICES: Simulando inicio de sesión (Google Play/Game Center)...")
	await Engine.get_main_loop().create_timer(1.5).timeout
	
	_is_signed_in = true
	print("✅ MOCK GAME SERVICES: ¡Sesión iniciada como 'Jugador de Prueba'!")
	sign_in_success.emit("Jugador de Prueba")

func unlock_achievement(achievement_id: String) -> void:
	if not _is_signed_in:
		push_warning("⚠️ MOCK GAME SERVICES: Intento de desbloquear logro sin iniciar sesión.")
		return
	print("🏆 MOCK GAME SERVICES: Logro desbloqueado -> [ ", achievement_id, " ]")

func submit_score(leaderboard_id: String, score: int) -> void:
	if not _is_signed_in:
		push_warning("⚠️ MOCK GAME SERVICES: Intento de subir puntuación sin iniciar sesión.")
		return
	print("📈 MOCK GAME SERVICES: Puntuación subida -> Ranking: ", leaderboard_id, " | Score: ", score)

func show_leaderboards() -> void:
	print("📱 MOCK GAME SERVICES: (Simulación) Abriendo UI nativa de Leaderboards...")

func show_achievements() -> void:
	print("📱 MOCK GAME SERVICES: (Simulación) Abriendo UI nativa de Logros...")
