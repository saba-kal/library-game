extends Node3D
class_name RoomBase

func rotate_room(times:int):
	for x in times:
		rotation_degrees.y = times * -90
