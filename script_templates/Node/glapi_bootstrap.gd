# meta-description: Plantilla base para el Bootstrap de Glapi
# meta-default: true
extends Node

# 🌟 PON AQUÍ LA RUTA A LA ESCENA DE TUS PANELES DE PRUEBA (o a tu Menú Principal)
const MAIN_SCENE_PATH = "res://game/screens/main_menu/main_menu.tscn"

func _ready() -> void:
	print("🚀 BOOTSCREEN: Iniciando secuencia de arranque...")
	
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		_init_mobile_services()
	else:
		_inject_glapi(false)

func _init_mobile_services() -> void:
	# Lógica para inicializar Firebase/AdMob
	_inject_glapi(false)
	pass

func _inject_glapi(is_mobile_ready: bool) -> void:
	# Configurar adaptadores
	var adapters = {
		"ads": null,
		"analytics": null,
		"storage": null,
		"crashlytics": null,
		"remote_config": null,
		"iap": null,
		"game_services": null,
		"settings": null
	}
	
	Glapi.initialize(
		adapters.get("ads"),
		adapters.get("analytics"),
		adapters.get("storage"),
		adapters.get("crashlytics"),
		adapters.get("remote_config"),
		adapters.get("iap"),
		adapters.get("game_services"),
		adapters.get("settings")
	)
	
	print("🎮 BOOTSCREEN: Carga completada.")
	# Cambiar a la escena principal
	# Glapi.scene_transition.change_scene(MAIN_SCENE_PATH)
