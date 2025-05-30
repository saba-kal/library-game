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
@export var rotation_offset: int = 0
@export var player_spawn_point: Marker3D
@onready var wall_checker: Node3D = %WallChecker
@onready var wall_north: GridMap = %Wall_North
@onready var wall_south: GridMap = %Wall_South
@onready var wall_east: GridMap = %Wall_East
@onready var wall_west: GridMap = %Wall_West
@onready var nav_region: NavigationRegion = $NavigationRegion

@onready var spawners: Node = $Spawners

var room_controller: RoomController
var is_player_inside_room: bool = false
var has_spawned: bool = false
var times_rotated: int = 0

## The doors array is always ordered such that north door is first,
## east door is second, south door is third, and west door is fourth.
## Basically, they are put in a clockwise position in the array.
var doors: Array[RoomDoor]
var tile_position: Vector2i

func _ready() -> void:
	times_rotated = rotation_offset
	doors = [
		north_door,
		east_door,
		south_door,
		west_door
	]
	update_door_directions()
	self.room_controller = Util.get_child_node_of_type(self, RoomController)
	SignalBus.player_moved_to_room.connect(self.on_player_moved_to_room)

## Rotates room <x amount> of times.
func rotate_room(times:int) -> void:
	times_rotated = (times + rotation_offset) % 4
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

func enter_room_spawn():
	if(!has_spawned):
		activate_spawners()

func activate_spawners():
	print("called spawner")
	has_spawned = true
	for child in spawners.get_children():
		if child is EnemySpawner:
			child.initialize_probabilities()

func despawn():
	print("called despawner")
	has_spawned = false
	for child in spawners.get_children():
		if child is EnemyBase:
			child.queue_free()

func bake_nav_mesh():
	print("Baking nav mesh")
	nav_region.bake_nav_mesh()

func get_player_spawn_position() -> Vector3:
	if is_instance_valid(player_spawn_point):
		return player_spawn_point.global_position
	return global_position

func on_player_moved_to_room(room: RoomVariation) -> void:
	if self.room_controller:
		if room == self:
			self.is_player_inside_room = true
			self.room_controller.on_player_enter()
		elif self.is_player_inside_room:
			self.is_player_inside_room = false
			self.room_controller.on_player_exit()
