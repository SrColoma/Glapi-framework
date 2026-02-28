class_name IRemoteConfigAdapter extends GlapiAdapter

signal config_loaded

func initialize() -> void:
	push_error("IRemoteConfigAdapter: initialize() no implementado.")

func fetch_and_activate() -> void:
	push_error("IRemoteConfigAdapter: fetch_and_activate() no implementado.")

func get_string(key: String, default_value: String) -> String:
	return default_value

func get_int(key: String, default_value: int) -> int:
	return default_value

func get_bool(key: String, default_value: bool) -> bool:
	return default_value
	
func get_float(key: String, default_value: float) -> float:
	return default_value
