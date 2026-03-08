@tool
extends EditorPlugin

const AUTOLOAD_NAME = "Glapi"

var _autoload_registered_by_plugin: bool = false

func _enter_tree() -> void:
	var autoload_path = "res://addons/glapi/auto_glapi.gd"
	
	if ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
		print("🟡 Glapi Plugin: Autoload '" + AUTOLOAD_NAME + "' ya existe en project.godot.")
	else:
		add_autoload_singleton(AUTOLOAD_NAME, autoload_path)
		_autoload_registered_by_plugin = true
		print("🟢 Glapi Plugin: Autoload '" + AUTOLOAD_NAME + "' registrado correctamente.")
		
	add_tool_menu_item("⚙️ Generar Estructura Base (Glapi)", _generate_base_structure)

func _exit_tree() -> void:
	if _autoload_registered_by_plugin:
		remove_autoload_singleton(AUTOLOAD_NAME)
		_autoload_registered_by_plugin = false
		print("🔴 Glapi Plugin: Autoload '" + AUTOLOAD_NAME + "' removido.")
	else:
		print("🟡 Glapi Plugin: Autoload '" + AUTOLOAD_NAME + "' se mantiene (definido en project.godot).")
	
	remove_tool_menu_item("⚙️ Generar Estructura Base (Glapi)")

func _generate_base_structure() -> void:
	var generator = preload("res://addons/glapi/tools/project_generator.gd").new()
	generator.generate_base_structure()
