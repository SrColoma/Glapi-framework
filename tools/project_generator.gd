@tool
extends RefCounted
class_name GlapiProjectGenerator

const GAME_DIR = "res://game/"
const DIRS_TO_CREATE = [
	"core",
	"screens"
]

static func generate_base_structure() -> void:
	print("🛠️ Iniciando Generación de Estructura Base de Glapi...")
	
	_create_directories()
	_create_prd_file()
	_create_splash_screen()
	
	print("✅ ¡Generación de Estructura Base completada! Revisa res://game/")
	
	# Forzamos al editor a recargar el FileSystem para que el archivo aparezca
	EditorInterface.get_resource_filesystem().scan()

static func _create_directories() -> void:
	var dir = DirAccess.open("res://")
	if not dir.dir_exists(GAME_DIR):
		dir.make_dir(GAME_DIR)
		print("📂 Creado directorio raíz del juego: ", GAME_DIR)
		
	var game_dir = DirAccess.open(GAME_DIR)
	for d in DIRS_TO_CREATE:
		if not game_dir.dir_exists(d):
			game_dir.make_dir_recursive(d)
			print("📂 Creado subdirectorio: ", GAME_DIR + d)

static func _create_prd_file() -> void:
	var target_path = "res://PRD.md"
	var template_path = "res://addons/glapi/templates/PRD.md"
	
	if FileAccess.file_exists(target_path):
		print("⚠️ PRD.md ya existe en la raíz, omitiendo.")
		return
		
	if FileAccess.file_exists(template_path):
		var template_file = FileAccess.open(template_path, FileAccess.READ)
		var content = template_file.get_as_text()
		template_file.close()
		
		var new_file = FileAccess.open(target_path, FileAccess.WRITE)
		new_file.store_string(content)
		new_file.close()
		print("📄 PRD.md generado en la raíz del proyecto.")
	else:
		printerr("❌ No se encontró la plantilla de PRD en: ", template_path)

static func _create_splash_screen() -> void:
	var splash_dir = GAME_DIR + "screens/splash/"
	var scene_path = splash_dir + "splash_screen.tscn"
	var script_path = splash_dir + "splash_screen.gd"
	var template_script_path = "res://addons/glapi/script_templates/Node/glapi_bootstrap.gd"
	
	var dir = DirAccess.open(GAME_DIR)
	if not dir.dir_exists("screens/splash"):
		dir.make_dir_recursive("screens/splash")
		
	if FileAccess.file_exists(scene_path) or FileAccess.file_exists(script_path):
		print("⚠️ splash_screen ya existe, omitiendo.")
		return
		
	# 1. Crear el Script a partir de la plantilla
	var script_content = _load_template_content(template_script_path)
	if script_content == "":
		script_content = "extends Control\n\nfunc _ready():\n\tprint(\"Glapi Bootstrap\")\n"
	else:
		script_content = script_content.replace("extends _BASE_", "extends Control")
		
	var script_file = FileAccess.open(script_path, FileAccess.WRITE)
	script_file.store_string(script_content)
	script_file.close()
	print("📄 Creado script: ", script_path)
	
	# 2. Crear la Escena (tscn)
	var scene_content = """[gd_scene load_steps=2 format=3 uid="uid://splashuid1234"]

[ext_resource type="Script" path="res://game/screens/splash/splash_screen.gd" id="1_splash"]

[node name="SplashScreen" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1_splash")

[node name="ColorRect" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0.121569, 0.121569, 0.121569, 1)

[node name="Label" type="Label" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -118.0
offset_top = -11.5
offset_right = 118.0
offset_bottom = 11.5
grow_horizontal = 2
grow_vertical = 2
text = "🚀 Iniciando Glapi Framework..."
horizontal_alignment = 1
vertical_alignment = 1
"""
	
	var scene_file = FileAccess.open(scene_path, FileAccess.WRITE)
	scene_file.store_string(scene_content)
	scene_file.close()
	print("🎬 Creada escena: ", scene_path)
	
	# 3. Setear como escena principal
	ProjectSettings.set_setting("application/run/main_scene", scene_path)
	ProjectSettings.save()
	print("🎯 Scene principal configurada a: ", scene_path)

static func _load_template_content(path: String) -> String:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		return content
	printerr("❌ No se encontró la plantilla en: ", path)
	return ""
