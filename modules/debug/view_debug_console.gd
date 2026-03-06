extends Control

@onready var line_edit_cmd: LineEdit = %LineEditCmd
@onready var rich_log_list: RichTextLabel = %RichLogList
@onready var btn_submit: Button = $PanelTop/VBox/HBoxInput/BtnSubmit

func _ready() -> void:
	line_edit_cmd.text_submitted.connect(_on_text_submitted)
	btn_submit.pressed.connect(func(): _on_text_submitted(line_edit_cmd.text))
	
	# Conectarse a las señales del servicio si está listo
	if Glapi.has_node("debug"):
		Glapi.debug.log_added.connect(_on_log_added)
		Glapi.debug.command_executed.connect(func(_cmd, _args): focus_input())
		
		for log_item in Glapi.debug._logs:
			_on_log_added(log_item.msg, log_item.type)

func focus_input() -> void:
	line_edit_cmd.grab_focus()

func _on_text_submitted(new_text: String) -> void:
	if new_text.strip_edges() == "":
		return
		
	line_edit_cmd.clear()
	
	if Glapi.has_node("debug"):
		Glapi.debug.execute(new_text)

func _on_log_added(message: String, type: int) -> void:
	var color = "white"
	if type == DebugConsoleService.LogType.WARNING:
		color = "yellow"
	elif type == DebugConsoleService.LogType.ERROR:
		color = "red"
		
	rich_log_list.append_text("[color=" + color + "]" + message + "[/color]\n")
