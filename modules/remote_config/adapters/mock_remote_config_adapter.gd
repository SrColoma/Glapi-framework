class_name MockRemoteConfigAdapter extends IRemoteConfigAdapter

# Tus valores de prueba simulando la nube de Firebase
var _mock_cloud_data: Dictionary = {
	"dificultad_global": 2,
	"evento_navidad_activo": true,
	"mensaje_bienvenida": "¡Bienvenido a la versión de prueba!",
	"multiplicador_oro": 1.5
}

func initialize() -> void:
	print("🟡 MOCK REMOTE CONFIG: Inicializado.")

func fetch_and_activate() -> void:
	print("⏳ MOCK REMOTE CONFIG: Simulando descarga de datos...")
	# Simulamos el retraso de internet
	await Engine.get_main_loop().create_timer(1.0).timeout
	print("✅ MOCK REMOTE CONFIG: Datos cargados.")
	config_loaded.emit()

func get_string(key: String, default_value: String) -> String:
	return _mock_cloud_data.get(key, default_value)

func get_int(key: String, default_value: int) -> int:
	return _mock_cloud_data.get(key, default_value)

func get_bool(key: String, default_value: bool) -> bool:
	return _mock_cloud_data.get(key, default_value)
	
func get_float(key: String, default_value: float) -> float:
	return _mock_cloud_data.get(key, default_value)
