class_name GameServicesService extends GlapiService

signal sign_in_success(player_name: String)
signal sign_in_failed(error_msg: String)

func _init(adapter: IGameServicesAdapter) -> void:
	_adapter = adapter
	
	# Conectamos las señales del adapter
	_adapter.sign_in_success.connect(func(name): sign_in_success.emit(name))
	_adapter.sign_in_failed.connect(func(err): sign_in_failed.emit(err))
	
	_adapter.initialize()

func sign_in() -> void:
	_adapter.sign_in()

func unlock_achievement(achievement_id: String) -> void:
	_adapter.unlock_achievement(achievement_id)

func submit_score(leaderboard_id: String, score: int) -> void:
	_adapter.submit_score(leaderboard_id, score)

func show_leaderboards() -> void:
	if _adapter.has_method("show_leaderboards"):
		_adapter.show_leaderboards()

func show_achievements() -> void:
	if _adapter.has_method("show_achievements"):
		_adapter.show_achievements()
