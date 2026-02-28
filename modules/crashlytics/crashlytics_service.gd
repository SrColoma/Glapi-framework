class_name CrashlyticsService extends GlapiService

func _init(provider: ICrashlyticsAdapter) -> void:
	_provider = provider
	_provider.initialize()

func record_exception(message: String) -> void:
	_provider.record_exception(message)

func log_message(message: String) -> void:
	_provider.log_message(message)

func set_custom_key(key: String, value: String) -> void:
	_provider.set_custom_key(key, value)
