class_name LocalHybridStorageAdapter extends IStorageAdapter

const SETTINGS_PATH = "user://settings.cfg"
const STATE_PATH = "user://player_data.save"
var _encryption_key: String = "Glapi_Default_Key"

func _init(secret_key: String = "") -> void:
	if secret_key != "":
		_encryption_key = secret_key

func initialize() -> void:
	print("💾 LOCAL STORAGE: Sistema de guardado híbrido inicializado.")


# ==========================================
# 🛡️ ESTADO DEL JUGADOR (JSON Encriptado)
# ==========================================
func save_state(data: Dictionary) -> void:
	var json_string = JSON.stringify(data)
	
	# Abrimos el archivo con encriptación nativa de Godot
	var file = FileAccess.open_encrypted_with_pass(STATE_PATH, FileAccess.WRITE, _encryption_key)
	if file:
		file.store_string(json_string)
		file.close()
	else:
		push_error("💾 STORAGE: Error al abrir archivo de estado para guardar.")

func load_state() -> Dictionary:
	var data = {}
	
	if FileAccess.file_exists(STATE_PATH):
		var file = FileAccess.open_encrypted_with_pass(STATE_PATH, FileAccess.READ, _encryption_key)
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
