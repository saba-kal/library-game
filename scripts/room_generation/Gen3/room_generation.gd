extends Node3D

const CORNER = preload("res://scenes/room_generation/Gen2/Gen2_rooms/corner.tscn")
const DEADEND = preload("res://scenes/room_generation/Gen2/Gen2_rooms/deadend.tscn")
const FOURWAY = preload("res://scenes/room_generation/Gen2/Gen2_rooms/fourway.tscn")
const HALLWAY = preload("res://scenes/room_generation/Gen2/Gen2_rooms/hallway.tscn")
const THREEWAY = preload("res://scenes/room_generation/Gen2/Gen2_rooms/threeway.tscn")

@export var room_space:int = 10

@onready var _2d_map:_2DGeneration = %"2D_Map"
@onready var rooms: Node3D = $Rooms
@onready var sub_viewport_container: SubViewportContainer = $Overlay/SubViewportContainer

var populate_information:Array[Array]


func _ready() -> void:
	_2d_map.generation_complete.connect(spawn_rooms)
	_2d_map.generation_cleared.connect(clear_rooms)
	pass


func spawn_rooms():
	populate_information = _2d_map.generation_info()
	var room_instance:RoomBase
	for x in populate_information:
		match x[1]:
			Vector2i(0,0):
				room_instance = FOURWAY.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y) * room_space
				print("Fourway")
			Vector2i(1,0):
				room_instance = THREEWAY.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y) * room_space
				print("Threeway")
			Vector2i(2,0):
				room_instance = THREEWAY.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y)  * room_space
				room_instance.rotate_room(1)
				print("Threeway Rotate Once")
			Vector2i(3,0):
				room_instance = THREEWAY.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y)  * room_space
				room_instance.rotate_room(2)
				print("Threeway Rotate Twice")
			Vector2i(4,0):
				room_instance = THREEWAY.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y)  * room_space
				room_instance.rotate_room(3)
				print("Threeway Rotate Thrice")
			Vector2i(0,1):
				room_instance = HALLWAY.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y)  * room_space
				print("Hallway")
			Vector2i(1,1):
				room_instance = CORNER.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y)  * room_space
				print("Corner")
			Vector2i(2,1):
				room_instance = CORNER.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y)  * room_space
				room_instance.rotate_room(1)
				print("Corner Rotate Once")
			Vector2i(3,1):
				room_instance = CORNER.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y)  * room_space
				room_instance.rotate_room(2)
				print("Corner Rotate Twice")
			Vector2i(4,1):
				room_instance = CORNER.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y)  * room_space
				room_instance.rotate_room(3)
				print("Corner Rotate Thrice")
			Vector2i(0,2):
				room_instance = CORNER.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y)  * room_space
				room_instance.rotate_room(1)
				print("Hallway Rotate Once")
			Vector2i(1,2):
				room_instance = DEADEND.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y)  * room_space
				print("Deadend")
			Vector2i(2,2):
				room_instance = DEADEND.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y) * room_space
				room_instance.rotate_room(1)
				print("Deadend Rotate Once")
			Vector2i(3,2):
				room_instance = DEADEND.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y)  * room_space
				room_instance.rotate_room(2)
				print("Deadend Rotate Twice")
			Vector2i(4,2):
				room_instance = DEADEND.instantiate()
				rooms.add_child(room_instance)
				room_instance.global_position = Vector3(x[0].x, 0, x[0].y)  * room_space
				room_instance.rotate_room(3)
				print("Deadend Rotate Thrice")

func clear_rooms():
	populate_information.clear()
	for room in rooms.get_children():
		room.queue_free()


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		sub_viewport_container.visible = false
	else:
		sub_viewport_container.visible = true
