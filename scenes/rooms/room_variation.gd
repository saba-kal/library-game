extends Node3D
class_name RoomVariation

@onready var doors: Node3D = $Doors

## Rotates room <x amount> of times.
func rotate_room(times:int):
	for x in times:
		rotation_degrees.y = times * -90
