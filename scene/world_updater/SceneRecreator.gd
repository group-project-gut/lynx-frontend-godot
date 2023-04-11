extends Node

@onready var entity_deserializer = get_node("../EntityDeserializer")

@onready var objects_container = get_owner().objects_container

func recreate_scene(scene_json):
	for entity_json in scene_json["entities"]:
		var entity = entity_deserializer.deserialize(entity_json)
		
		if !entity:
			print("[ERROR] Could not deserialize Entity")
			continue
		
		# TODO: this could be done at beginning of the loop by checking type key value
		if !entity is LynxObject:
			print("[ERROR] Entity could not be recreated, because it is not an Object")
			continue
		
		objects_container.add_child(entity)
