class_name CrashlyticsService extends GlapiService

func _init(adapter: ICrashlyticsAdapter) -> void:
	_adapter = adapter
	_adapter.initialize()

func record_exception(error_name: String, description: String) -> void:
	_adapter.record_exception(error_name, description)

func log_message(message: String) -> void:
	_adapter.log_message(message)

func set_custom_key(key: String, value: String) -> void:
	_adapter.set_custom_key(key, value)

func set_user_id(user_id: String) -> void:
	if _adapter.has_method("set_user_id"):
		_adapter.set_user_id(user_id)
