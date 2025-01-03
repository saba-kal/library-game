extends Node3D
class_name RoomBase

@export var room_variations : Array[PackedScene]
@onready var door_detection: Node3D = %DoorDetection

## Rotates room <x amount> of times.
func rotate_room(times:int):
	for x in times:
		rotation_degrees.y = times * -90

## Instantiates a room from the variations stored in the packedscene array
## , and sets then up properly, and returns it back to the 3D Map Generation.
func setup_random_room(spacing:float) -> RoomVariation:
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
