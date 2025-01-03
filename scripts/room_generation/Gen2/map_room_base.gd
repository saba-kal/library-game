extends Node3D
class_name RoomBase

@export var room_variations : Array[PackedScene]
@onready var door_detection: Node3D = %DoorDetection

## [Lowercase Name, Door ID]
var doorways : Array[Array]

func rotate_room(times:int):
	for x in times:
		rotation_degrees.y = times * -90

func populate_room_ids(doorway_id:int, exit_id:int):
	for child in door_detection.get_children():
			if child is DoorDetectionSetup:
				child.assign_id(doorway_id)
				child.door_exit.assign_id(exit_id)
				doorways.append([child.name.to_lower(), child.door_id])

func get_door_pairings(door_pairings:Array):
	for child in door_detection.get_children():
			if child is DoorDetectionSetup:
				if door_pairings.size() > 0:
					for pair in door_pairings:
						if (child.door_id == pair[0]) or (child.door_id == pair[1]):
							return null
						else:
							return [child.door_id, child.door_exit.door_id]
				else:
					[child.door_id, child.door_exit.door_id]

func setup_random_room(spacing:float):
	var new_pos: Vector3
	var room_instance: RoomVariation = room_variations.pick_random().instantiate()
	get_parent().add_child(room_instance)
	room_instance.global_position = global_position * spacing
	room_instance.rotation = rotation
	for doorway in room_instance.doors.get_children():
		for old_doorway in door_detection.get_children():
			if doorway.name == old_doorway.name:
				new_pos = doorway.global_position
				doorway.queue_free()
				old_doorway.reparent(room_instance.doors)
				old_doorway.global_position = new_pos
				print("yippy")
	
	return room_instance
