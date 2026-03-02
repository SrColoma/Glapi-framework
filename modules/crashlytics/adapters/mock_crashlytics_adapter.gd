class_name MockCrashlyticsAdapter extends ICrashlyticsAdapter

func initialize() -> void:
	print("🟡 MOCK CRASHLYTICS: Inicializado.")

func record_exception(message: String, description: String) -> void:
	push_error("🔥 MOCK CRASHLYTICS EXCEPCIÓN: " + message)

func log_message(message: String) -> void:
	print("📝 MOCK CRASHLYTICS LOG: ", message)

func set_custom_key(key: String, value: String) -> void:
	print("🔑 MOCK CRASHLYTICS KEY: [", key, "] = ", value)
