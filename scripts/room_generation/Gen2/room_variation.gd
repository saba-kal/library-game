extends Node3D
class_name RoomVariation

enum ROOM_DIRECTION{
	NORTH = 0,
	EAST = 1,
	SOUTH = 2,
	WEST = 3
}

@export var north_door: RoomDoor
@export var east_door: RoomDoor
@export var south_door: RoomDoor
@export var west_door: RoomDoor

@onready var wall_checker: Node3D = %WallChecker
@onready var wall_north: GridMap = %Wall_North
@onready var wall_south: GridMap = %Wall_South
@onready var wall_east: GridMap = %Wall_East
@onready var wall_west: GridMap = %Wall_West


## The doors array is always ordered such that north door is first,
## east door is second, south door is third, and west door is fourth.
## Basically, they are put in a clockwise position in the array.
var doors: Array[RoomDoor]
var tile_position: Vector2i

func _ready() -> void:
	doors = [
		north_door,
		east_door,
		south_door,
		west_door
	]
	update_door_directions()

## Rotates room <x amount> of times.
func rotate_room(times:int) -> void:
	for x in times:
		rotation_degrees.y = times * -90

		# Rotate the doors. Door position in the array determines their true direction.
		var current_west_door = doors.pop_back()
		doors.push_front(current_west_door)
	update_door_directions()


func get_opposite_door(direction: ROOM_DIRECTION) -> RoomDoor:
	return doors[(direction + 2) % 4]


func connect_door(direction: ROOM_DIRECTION, room: RoomVariation):
	var door: RoomDoor = doors[direction]
	if is_instance_valid(door):
		door.connected_room = room
	else:
		printerr(self.name + " is missing a door for direction " + str(direction))


func update_door_directions():
	for i in range(0, 4):
		if doors[i] != null:
			doors[i].direction = i
