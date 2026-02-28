@tool
extends EditorPlugin

# El nombre con el que lo llamarás en todo tu código
const AUTOLOAD_NAME = "Glapi" 

func _enter_tree() -> void:
	# Obtenemos la ruta dinámica de la carpeta donde está guardado este plugin.gd
	#var executable_path = OS.get_executable_path()
	#var base_dir = executable_path.get_base_dir()
	var base_dir = get_script().get_base_dir()
	
	# Construimos la ruta exacta al Autoload concatenando el nombre del archivo
	var autoload_path = base_dir + "/auto_Glapi.gd"

	# Añade el Autoload automáticamente usando la ruta segura
	add_autoload_singleton(AUTOLOAD_NAME, autoload_path)
	print("🟢 Glapi Plugin: Autoload '" + AUTOLOAD_NAME + "' registrado correctamente en: ", autoload_path)

func _exit_tree() -> void:
	# Limpia el Autoload para no dejar basura en el proyecto al desactivar el plugin
	remove_autoload_singleton(AUTOLOAD_NAME)
	print("🔴 Glapi Plugin: Autoload '" + AUTOLOAD_NAME + "' removido.")
