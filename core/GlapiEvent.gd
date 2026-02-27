# Base class for all domain events.
# All events that are dispatched through the event bus must inherit from this class.
class_name GlapiEvent extends RefCounted

# Nombre identificador del evento (ej. "enemy_killed")
var event_name: String = "generic_event"


# Converts the event to a dictionary for serialization.
# This is required for services that need to process event data, like analytics.
func to_dict() -> Dictionary:
	# This method should be overridden by subclasses to provide a dictionary
	# representation of the event.
	push_error("GlapiEvent: La función to_dict() debe ser sobrescrita por la clase hija.")
	return {}
