class_name GlapiService extends RefCounted

var _provider: GlapiProvider

# Interfaz común para procesar eventos del dominio
func handle_event(_event: GlapiEvent) -> void:
	pass
