@tool
extends EditorPlugin

const AUTOLOAD_NAME = "Glapi"

var _autoload_registered_by_plugin: bool = false

func _enter_tree() -> void:
	var autoload_path = "res://addons/Glapi/auto_Glapi.gd"
	
	if ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
		print("🟡 Glapi Plugin: Autoload '" + AUTOLOAD_NAME + "' ya existe en project.godot.")
	else:
		add_autoload_singleton(AUTOLOAD_NAME, autoload_path)
		_autoload_registered_by_plugin = true
		print("🟢 Glapi Plugin: Autoload '" + AUTOLOAD_NAME + "' registrado correctamente.")

func _exit_tree() -> void:
	if _autoload_registered_by_plugin:
		remove_autoload_singleton(AUTOLOAD_NAME)
		_autoload_registered_by_plugin = false
		print("🔴 Glapi Plugin: Autoload '" + AUTOLOAD_NAME + "' removido.")
	else:
		print("🟡 Glapi Plugin: Autoload '" + AUTOLOAD_NAME + "' se mantiene (definido en project.godot).")
