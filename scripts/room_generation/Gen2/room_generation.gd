extends Node3D

const CORNER = preload("res://scenes/room_generation/Gen2/Gen2_rooms/corner.tscn")
const DEADEND = preload("res://scenes/room_generation/Gen2/Gen2_rooms/deadend.tscn")
const FOURWAY = preload("res://scenes/room_generation/Gen2/Gen2_rooms/fourway.tscn")
const HALLWAY = preload("res://scenes/room_generation/Gen2/Gen2_rooms/hallway.tscn")
const THREEWAY = preload("res://scenes/room_generation/Gen2/Gen2_rooms/threeway.tscn")

@export var room_space:int = 7
@export var corner_room_variations:Array[PackedScene]
@export var deadend_room_variations:Array[PackedScene]
@export var fourway_room_variations:Array[PackedScene]
@export var hallway_room_variations:Array[PackedScene]
@export var threeway_room_variations:Array[PackedScene]
@export var player_scene:PackedScene
@export var map:_2DGeneration

var rooms: Node3D
var populate_information : Array[Array]
var room_array : Array[RoomVariation]
var default_space : int = 10
var door_id_pairings : Array[Array]

## Connects the 2D Generation to transfer the coordinates for 3D Placement.
func _ready() -> void:
	# Create container node for all the generated rooms.
	rooms = Node3D.new()
	rooms.name = "Rooms"
	add_child(rooms)
	map.generate_rooms()
	map.generation_complete.connect(on_map_generation_complete)
	map.generation_cleared.connect(clear_rooms)

func on_map_generation_complete() -> void:
	spawn_rooms()
	spawn_player()

## Instantiates some base created rooms that have a single parent called "map_room_base".
## Appends each of them to an array. "room_array"
func spawn_rooms():
	populate_information = map.generation_info()
	for x in populate_information:
		match x[1]:
			Vector2i(0,0):
				instantiate_room(fourway_room_variations, x[0], 0)
				print("Fourway")
			Vector2i(1,0):
				instantiate_room(threeway_room_variations, x[0], 0)
				print("Threeway")
			Vector2i(2,0):
				instantiate_room(threeway_room_variations, x[0], 1)
				print("Threeway Rotate Once")
			Vector2i(3,0):
				instantiate_room(threeway_room_variations, x[0], 2)
				print("Threeway Rotate Twice")
			Vector2i(4,0):
				instantiate_room(threeway_room_variations, x[0], 3)
				print("Threeway Rotate Thrice")
			Vector2i(0,1):
				instantiate_room(hallway_room_variations, x[0], 0)
				print("Hallway")
			Vector2i(1,1):
				instantiate_room(corner_room_variations, x[0], 0)
				print("Corner")
			Vector2i(2,1):
				instantiate_room(corner_room_variations, x[0], 1)
				print("Corner Rotate Once")
			Vector2i(3,1):
				instantiate_room(corner_room_variations, x[0], 2)
				print("Corner Rotate Twice")
			Vector2i(4,1):
				instantiate_room(corner_room_variations, x[0], 3)
				print("Corner Rotate Thrice")
			Vector2i(0,2):
				instantiate_room(hallway_room_variations, x[0], 1)
				print("Hallway Rotate Once")
			Vector2i(1,2):
				instantiate_room(deadend_room_variations, x[0], 0)
				print("Deadend")
			Vector2i(2,2):
				instantiate_room(deadend_room_variations, x[0], 1)
				print("Deadend Rotate Once")
			Vector2i(3,2):
				instantiate_room(deadend_room_variations, x[0], 2)
				print("Deadend Rotate Twice")
			Vector2i(4,2):
				instantiate_room(deadend_room_variations, x[0], 3)
				print("Deadend Rotate Thrice")

## Instantiates a random room using the provided list of room variations.
## Calculates the 3D position of the room based on the 2D grid position.
## rotate_count determines how often to rotate the room 90 degrees.
func instantiate_room(room_variations: Array[PackedScene], position_2d: Vector2i, rotate_count: int) -> void:
	var room_instance: RoomVariation = room_variations.pick_random().instantiate()
	rooms.add_child(room_instance)
	room_instance.global_position = Vector3(position_2d.x, 0, position_2d.y) * default_space
	room_instance.rotate_room(rotate_count)
	room_array.append(room_instance)

## Spawns player.
func spawn_player():
	var player_instance: Player = player_scene.instantiate()
	add_child(player_instance)
	player_instance.global_position = room_array.front().global_position

func clear_rooms():
	populate_information.clear()
	for room in room_array:
		room.queue_free()
	room_array.clear()
