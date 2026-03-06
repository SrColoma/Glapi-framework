class_name SerializationUtils extends RefCounted

## Utilidad para convertir automáticamente Objetos (Entidades, Resources, Eventos)
## a Diccionarios exportables usando la API de Reflexión de Godot 4.x.

## Convierte un Objeto o Resource a Diccionario dinámicamente.
## @param obj: El objeto a inspeccionar.
## @return Un diccionario serializable en JSON/Binario.
static func object_to_dict(obj: Object) -> Dictionary:
	var result = {}
	
	if not obj:
		return result
		
	# Obtenemos la lista de propiedades nativas del objeto
	var props = obj.get_property_list()
	
	for prop in props:
		var name = prop["name"]
		var usage = prop["usage"]
		
		# Solo exportar variables marcadas como almacenables (o parte del script local)
		if (usage & PROPERTY_USAGE_STORAGE) or (usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
			# Filtrar propiedades de script internas o indeseadas comunes
			if name == "script" or name.begins_with("metadata/"):
				continue
				
			var val = obj.get(name)
			
			# Manejar recursividad de forma segura
			if val is Object and not val is Resource:
				# Tratar los sub-objetos propios
				result[name] = SerializationUtils.object_to_dict(val)
			elif val is Array:
				result[name] = SerializationUtils._serialize_array(val)
			elif val is Dictionary:
				result[name] = SerializationUtils._serialize_dict(val)
			else:
				# Tipos base directos (int, bool, string, Vector2, etc)
				# Ojo: Para JSON plano, tipos como Vector2 deberían parsearse, 
				# pero para el FileAccess.open_encrypted de godot nativo funcionan directamente.
				result[name] = val
				
	return result

static func _serialize_array(arr: Array) -> Array:
	var parsed_arr = []
	for item in arr:
		if item is Object:
			parsed_arr.append(SerializationUtils.object_to_dict(item))
		elif item is Array:
			parsed_arr.append(SerializationUtils._serialize_array(item))
		elif item is Dictionary:
			parsed_arr.append(SerializationUtils._serialize_dict(item))
		else:
			parsed_arr.append(item)
	return parsed_arr

static func _serialize_dict(dict: Dictionary) -> Dictionary:
	var parsed_dict = {}
	for key in dict.keys():
		var val = dict[key]
		if val is Object:
			parsed_dict[key] = SerializationUtils.object_to_dict(val)
		elif val is Array:
			parsed_dict[key] = SerializationUtils._serialize_array(val)
		elif val is Dictionary:
			parsed_dict[key] = SerializationUtils._serialize_dict(val)
		else:
			parsed_dict[key] = val
	return parsed_dict
