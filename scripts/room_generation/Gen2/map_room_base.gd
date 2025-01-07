extends Node3D
class_name RoomBase

@export var room_variations : Array[PackedScene]
@onready var door_detection: Node3D = %DoorDetection

## Rotates room <x amount> of times.
func rotate_room(times:int):
	for x in times:
		rotation_degrees.y = times * -90
