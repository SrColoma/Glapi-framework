class_name LocalHybridStorageAdapter extends IStorageAdapter

const SETTINGS_PATH = "user://settings.cfg"
const STATE_PATH = "user://player_data.save"
const ENCRYPTION_KEY = "Tatara_Super_Secret_Key_2026!" # ¡Cambia esto en producción!

func initialize() -> void:
	print("💾 LOCAL STORAGE: Sistema de guardado híbrido inicializado.")

# ==========================================
# ⚙️ CONFIGURACIÓN (Texto Plano / CFG)
# ==========================================
func save_settings(data: Dictionary) -> void:
	var config = ConfigFile.new()
	for key in data:
		config.set_value("General", key, data[key])
	
	var err = config.save(SETTINGS_PATH)
	if err != OK:
		push_error("💾 STORAGE: Error al guardar settings.cfg")

func load_settings() -> Dictionary:
	var data = {}
	var config = ConfigFile.new()
	
	if config.load(SETTINGS_PATH) == OK:
		for key in config.get_section_keys("General"):
			data[key] = config.get_value("General", key)
	else:
		print("💾 STORAGE: No se encontró settings.cfg, se usarán defaults.")
		
	return data

# ==========================================
# 🛡️ ESTADO DEL JUGADOR (JSON Encriptado)
# ==========================================
func save_state(data: Dictionary) -> void:
	var json_string = JSON.stringify(data)
	
	# Abrimos el archivo con encriptación nativa de Godot
	var file = FileAccess.open_encrypted_with_pass(STATE_PATH, FileAccess.WRITE, ENCRYPTION_KEY)
	if file:
		file.store_string(json_string)
		file.close()
	else:
		push_error("💾 STORAGE: Error al abrir archivo de estado para guardar.")

func load_state() -> Dictionary:
	var data = {}
	
	if FileAccess.file_exists(STATE_PATH):
		var file = FileAccess.open_encrypted_with_pass(STATE_PATH, FileAccess.READ, ENCRYPTION_KEY)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var error = json.parse(json_string)
			if error == OK:
				data = json.data
			else:
				push_error("💾 STORAGE: Error al parsear JSON del jugador: ", json.get_error_message())
		else:
			push_error("💾 STORAGE: Archivo corrupto o clave de encriptación incorrecta.")
	else:
		print("💾 STORAGE: No se encontró player_data.save, es un jugador nuevo.")
		
	return data
