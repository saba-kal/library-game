extends Node3D

const CORNER = preload("res://scenes/room_generation/Gen2/Gen2_rooms/corner.tscn")
const DEADEND = preload("res://scenes/room_generation/Gen2/Gen2_rooms/deadend.tscn")
const FOURWAY = preload("res://scenes/room_generation/Gen2/Gen2_rooms/fourway.tscn")
const HALLWAY = preload("res://scenes/room_generation/Gen2/Gen2_rooms/hallway.tscn")
const THREEWAY = preload("res://scenes/room_generation/Gen2/Gen2_rooms/threeway.tscn")

@export var room_space:int = 7

@onready var _2d_map:_2DGeneration = %"2D_Map"
@onready var rooms: Node3D = $Rooms
@onready var sub_viewport_container: SubViewportContainer = $Overlay/SubViewportContainer
@onready var cycle_timer: Timer = $CycleTimer


var populate_information : Array[Array]
var room_array : Array[RoomBase]
var final_room_array : Array[RoomVariation]
var default_space : int = 10
var door_id_pairings : Array[Array]
var player_instance : Player


## Connects the 2D Generation to transfer the coordinates for 3D Placement.
func _ready() -> void:
	_2d_map.generation_complete.connect(spawn_rooms)
	_2d_map.generation_cleared.connect(clear_rooms)
	player_instance = get_tree().get_first_node_in_group("player")

## Instantiates some base created rooms that have a single parent called "map_room_base".
## Appends each of them to an array. "room_array"
func spawn_rooms():
	populate_information = _2d_map.generation_info()
	var room_instance:RoomBase
	for x in populate_information:
		match x[1]:
			Vector2i(0,0):
				room_instance = FOURWAY.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y) * default_space
				print("Fourway")
			Vector2i(1,0):
				room_instance = THREEWAY.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y) * default_space
				print("Threeway")
			Vector2i(2,0):
				room_instance = THREEWAY.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y) * default_space
				room_instance.rotate_room(1)
				print("Threeway Rotate Once")
			Vector2i(3,0):
				room_instance = THREEWAY.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y) * default_space
				room_instance.rotate_room(2)
				print("Threeway Rotate Twice")
			Vector2i(4,0):
				room_instance = THREEWAY.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y) * default_space
				room_instance.rotate_room(3)
				print("Threeway Rotate Thrice")
			Vector2i(0,1):
				room_instance = HALLWAY.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y) * default_space
				print("Hallway")
			Vector2i(1,1):
				room_instance = CORNER.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y) * default_space
				print("Corner")
			Vector2i(2,1):
				room_instance = CORNER.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y) * default_space
				room_instance.rotate_room(1)
				print("Corner Rotate Once")
			Vector2i(3,1):
				room_instance = CORNER.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y) * default_space
				room_instance.rotate_room(2)
				print("Corner Rotate Twice")
			Vector2i(4,1):
				room_instance = CORNER.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y) * default_space
				room_instance.rotate_room(3)
				print("Corner Rotate Thrice")
			Vector2i(0,2):
				room_instance = HALLWAY.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y) * default_space
				room_instance.rotate_room(1)
				print("Hallway Rotate Once")
			Vector2i(1,2):
				room_instance = DEADEND.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y) * default_space
				print("Deadend")
			Vector2i(2,2):
				room_instance = DEADEND.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y) * default_space
				room_instance.rotate_room(1)
				print("Deadend Rotate Once")
			Vector2i(3,2):
				room_instance = DEADEND.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y) * default_space
				room_instance.rotate_room(2)
				print("Deadend Rotate Twice")
			Vector2i(4,2):
				room_instance = DEADEND.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y) * default_space
				room_instance.rotate_room(3)
				print("Deadend Rotate Thrice")
		room_array.append(room_instance)
	
	cycle_timer.start()


## Cycles through the array of rooms, and calls a function to randomly pull a scene that's stored on the base room.
## Also stores the new rooms into an array for future use.
## Lastly spawns player.
func spawn_variations():
	for room in room_array:
		if is_instance_valid(room):
			final_room_array.append(room.setup_random_room(room_space))
			room.queue_free()
	
	spawn_player()

## Spawns player.
func spawn_player():
	player_instance.global_position = final_room_array.front().global_position


func clear_rooms():
	populate_information.clear()
	for room in rooms.get_children():
		room.queue_free()
	for more_rooms in final_room_array:
		more_rooms.queue_free()
	final_room_array.clear()
	room_array.clear()


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		sub_viewport_container.visible = false
	else:
		sub_viewport_container.visible = true
