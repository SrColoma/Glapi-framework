class_name ISettingsAdapter extends GlapiAdapter

signal setting_changed(section: String, key: String, value: Variant)

func initialize() -> void:
	pass

func set_value(section: String, key: String, value: Variant) -> void:
	push_error("ISettingsAdapter: set_value() not implemented.")

func get_value(section: String, key: String, default_val: Variant = null) -> Variant:
	push_error("ISettingsAdapter: get_value() not implemented.")
	return default_val

func save() -> void:
	push_error("ISettingsAdapter: save() not implemented.")
