class_name GooglePlayGamesAdapter extends IGameServicesAdapter

var _is_initialized: bool = false
var _play_games: Object

func initialize() -> void:
	if Engine.has_singleton("GodotPlayGamesServices"):
		_play_games = Engine.get_singleton("GodotPlayGamesServices")
		_is_initialized = true
		
		# Intentamos usar duck typing para conectarnos a las señales comunes de estos plugins
		if _play_games.has_signal("sign_in_successful"):
			_play_games.connect("sign_in_successful", func(account_info): sign_in_success.emit("Jugador Android"))
		if _play_games.has_signal("sign_in_failed"):
			_play_games.connect("sign_in_failed", func(error_code): sign_in_failed.emit(str(error_code)))
			
		print("🟢 GOOGLE PLAY GAMES: SDK Inicializado.")
	else:
		_is_initialized = false
		push_warning("⚠️ GOOGLE PLAY GAMES: Singleton no encontrado.")

func sign_in() -> void:
	if not _is_initialized: return
	if _play_games.has_method("signIn"):
		_play_games.signIn()

func unlock_achievement(achievement_id: String) -> void:
	if not _is_initialized: return
	if _play_games.has_method("unlockAchievement"):
		_play_games.unlockAchievement(achievement_id)

func submit_score(leaderboard_id: String, score: int) -> void:
	if not _is_initialized: return
	if _play_games.has_method("submitLeaderBoardScore"):
		_play_games.submitLeaderBoardScore(leaderboard_id, score)

func show_leaderboards() -> void:
	if not _is_initialized: return
	if _play_games.has_method("showAllLeaderBoards"):
		_play_games.showAllLeaderBoards()

func show_achievements() -> void:
	if not _is_initialized: return
	if _play_games.has_method("showAchievements"):
		_play_games.showAchievements()
