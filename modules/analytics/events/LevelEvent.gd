class_name LevelEvent extends GlapiEvent

enum Tipo { START, END, UP }

# level_name ej: "Mundo 1-1", status ej: "victory", "game_over", "quit"
func _init(tipo: Tipo, level_name: String, status: String = "none", score: int = 0) -> void:
	var e_name = ""
	match tipo:
		Tipo.START: e_name = "level_start"
		Tipo.END: e_name = "level_end"
		Tipo.UP: e_name = "level_up"
		
	super(e_name, {
		"level_name": level_name,
		"success": status,
		"score": score
	})
