class_name RemoteConfigService extends GlapiService

signal config_loaded

func _init(adapter: IRemoteConfigAdapter) -> void:
	_adapter = adapter
	_adapter.config_loaded.connect(func(): config_loaded.emit())
	_adapter.initialize()

func fetch_and_activate() -> void:
	_adapter.fetch_and_activate()

func get_string(key: String, default_value: String = "") -> String:
	return _adapter.get_string(key, default_value)

func get_int(key: String, default_value: int = 0) -> int:
	return _adapter.get_int(key, default_value)

func get_bool(key: String, default_value: bool = false) -> bool:
	return _adapter.get_bool(key, default_value)
	
func get_float(key: String, default_value: float = 0.0) -> float:
	return _adapter.get_float(key, default_value)
