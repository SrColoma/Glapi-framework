@tool
extends EditorPlugin

# El nombre con el que lo llamarás en todo tu código
const AUTOLOAD_NAME = "Glapi" 

# La ruta exacta a tu script de Autoload dentro de la carpeta addons
const AUTOLOAD_PATH = "./auto_Glapi.gd"

func _enter_tree() -> void:
	# Esta función se ejecuta cuando activas el plugin en Configuración del Proyecto
	# Añade el Autoload automáticamente
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	print("🟢 Glapi Plugin: Autoload '" + AUTOLOAD_NAME + "' registrado correctamente.")

func _exit_tree() -> void:
	# Esta función se ejecuta si desactivas el plugin
	# Limpia el Autoload para no dejar basura en el proyecto
	remove_autoload_singleton(AUTOLOAD_NAME)
	print("🔴 Glapi Plugin: Autoload '" + AUTOLOAD_NAME + "' removido.")
