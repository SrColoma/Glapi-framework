class_name RemoteConfigService extends GlapiService

signal config_loaded

func _init(provider: IRemoteConfigAdapter) -> void:
	_provider = provider
	_provider.config_loaded.connect(func(): config_loaded.emit())
	_provider.initialize()

func fetch_and_activate() -> void:
	_provider.fetch_and_activate()

func get_string(key: String, default_value: String = "") -> String:
	return _provider.get_string(key, default_value)

func get_int(key: String, default_value: int = 0) -> int:
	return _provider.get_int(key, default_value)

func get_bool(key: String, default_value: bool = false) -> bool:
	return _provider.get_bool(key, default_value)
	
func get_float(key: String, default_value: float = 0.0) -> float:
	return _provider.get_float(key, default_value)
