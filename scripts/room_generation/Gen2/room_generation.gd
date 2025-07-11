extends Node3D

const CORNER = preload("res://scenes/room_generation/Gen2/Gen2_rooms/corner.tscn")
const DEADEND = preload("res://scenes/room_generation/Gen2/Gen2_rooms/deadend.tscn")
const FOURWAY = preload("res://scenes/room_generation/Gen2/Gen2_rooms/fourway.tscn")
const HALLWAY = preload("res://scenes/room_generation/Gen2/Gen2_rooms/hallway.tscn")
const THREEWAY = preload("res://scenes/room_generation/Gen2/Gen2_rooms/threeway.tscn")

@export var room_space: int = 100
@export var corner_room_variations:Array[PackedScene]
@export var deadend_room_variations:Array[PackedScene]
@export var fourway_room_variations:Array[PackedScene]
@export var hallway_room_variations:Array[PackedScene]
@export var threeway_room_variations:Array[PackedScene]
@export var boss_room_variations:Array[PackedScene]
@export var start_room:PackedScene
@export var player_scene:PackedScene
@export var room_key:PackedScene
@export var boss_door:PackedScene
@export var map:_2DGeneration

var rooms: Node3D
var first_room: RoomVariation = null
var boss_room: RoomVariation = null
var key_room: RoomVariation = null
var room_dictionary : Dictionary

## Connects the 2D Generation to transfer the coordinates for 3D Placement.
func _ready() -> void:
	# Create container node for all the generated rooms.
	rooms = Node3D.new()
	rooms.name = "Rooms"
	add_child(rooms)
	map.hide_debugging_overlay()
	map.generation_complete.connect(on_map_generation_complete)
	map.generate_rooms()

func on_map_generation_complete() -> void:
	spawn_rooms()
	connect_room_doors()
	remove_walls()
	spawn_player()
	spawn_key()
	spawn_boss_door()
	first_room.north_door.open_door()
	SignalBus.scene_change_completed.emit()

## Instantiates some base created rooms that have a single parent called "map_room_base".
## Appends each of them to an array. "room_array"
func spawn_rooms():
	var room_array = map.generation_info()
	for room_data: _2DGeneration.RoomData in room_array:

		if room_data.tile_map_position == Vector2i.ZERO:
			instantiate_room([start_room], room_data.tile_map_position, 0)
			continue

		match room_data.room_type:
			_2DGeneration.FOUR_WAY:
				instantiate_room(fourway_room_variations, room_data.tile_map_position, 0)
				print("Fourway")
			_2DGeneration.THREE_WAY:
				instantiate_room(threeway_room_variations, room_data.tile_map_position, 0)
				print("Threeway")
			_2DGeneration.THREE_WAY_ROTATED_1:
				instantiate_room(threeway_room_variations, room_data.tile_map_position, 1)
				print("Threeway Rotate Once")
			_2DGeneration.THREE_WAY_ROTATED_2:
				instantiate_room(threeway_room_variations, room_data.tile_map_position, 2)
				print("Threeway Rotate Twice")
			_2DGeneration.THREE_WAY_ROTATED_3:
				instantiate_room(threeway_room_variations, room_data.tile_map_position, 3)
				print("Threeway Rotate Thrice")
			_2DGeneration.HALLWAY:
				instantiate_room(hallway_room_variations, room_data.tile_map_position, 0)
				print("Hallway")
			_2DGeneration.CORNER:
				instantiate_room(corner_room_variations, room_data.tile_map_position, 0)
				print("Corner")
			_2DGeneration.CORNER_ROTATED_1:
				instantiate_room(corner_room_variations, room_data.tile_map_position, 1)
				print("Corner Rotate Once")
			_2DGeneration.CORNER_ROTATED_2:
				instantiate_room(corner_room_variations, room_data.tile_map_position, 2)
				print("Corner Rotate Twice")
			_2DGeneration.CORNER_ROTATED_3:
				instantiate_room(corner_room_variations, room_data.tile_map_position, 3)
				print("Corner Rotate Thrice")
			_2DGeneration.HALLWAY_ROTATED_1:
				instantiate_room(hallway_room_variations, room_data.tile_map_position, 1)
				print("Hallway Rotate Once")
			_2DGeneration.DEADEND:
				if room_data.is_boss_room:
					instantiate_room(boss_room_variations, room_data.tile_map_position, 0)
				else:
					instantiate_room(deadend_room_variations, room_data.tile_map_position, 0)
				print("Deadend")
			_2DGeneration.DEADEND_ROTATED_1:
				if room_data.is_boss_room:
					instantiate_room(boss_room_variations, room_data.tile_map_position, 1)
				else:
					instantiate_room(deadend_room_variations, room_data.tile_map_position, 1)
				print("Deadend Rotate Once")
			_2DGeneration.DEADEND_ROTATED_2:
				if room_data.is_boss_room:
					instantiate_room(boss_room_variations, room_data.tile_map_position, 2)
				else:
					instantiate_room(deadend_room_variations, room_data.tile_map_position, 2)
				print("Deadend Rotate Twice")
			_2DGeneration.DEADEND_ROTATED_3:
				if room_data.is_boss_room:
					instantiate_room(boss_room_variations, room_data.tile_map_position, 3)
				else:
					instantiate_room(deadend_room_variations, room_data.tile_map_position, 3)
				print("Deadend Rotate Thrice")

## Instantiates a random room using the provided list of room variations.
## Calculates the 3D position of the room based on the 2D grid position.
## rotate_count determines how often to rotate the room 90 degrees.
func instantiate_room(room_variations: Array[PackedScene], position_2d: Vector2i, rotate_count: int) -> void:
	var room_instance: RoomVariation = room_variations.pick_random().instantiate()
	room_instance.name = "Room (%d, %d)" % [position_2d.x, position_2d.y]
	rooms.add_child(room_instance)
	room_instance.global_position = Vector3(position_2d.x, 0, position_2d.y) * room_space
	room_instance.rotate_room(rotate_count)
	room_instance.tile_position = position_2d
	room_dictionary[position_2d] = room_instance
	if first_room == null:
		first_room = room_instance

func connect_room_doors() -> void:
	for room_pos: Vector2i in room_dictionary.keys():
		var room: RoomVariation = room_dictionary[room_pos]
		var north_pos: Vector2i = Vector2i(room_pos.x, room_pos.y - 1)
		var east_pos: Vector2i = Vector2i(room_pos.x + 1, room_pos.y)
		var south_pos: Vector2i = Vector2i(room_pos.x, room_pos.y + 1)
		var west_pos: Vector2i = Vector2i(room_pos.x - 1, room_pos.y)
		if room_dictionary.has(north_pos):
			room.connect_door(RoomVariation.ROOM_DIRECTION.NORTH, room_dictionary[north_pos])
		if room_dictionary.has(east_pos):
			room.connect_door(RoomVariation.ROOM_DIRECTION.EAST, room_dictionary[east_pos])
		if room_dictionary.has(south_pos):
			room.connect_door(RoomVariation.ROOM_DIRECTION.SOUTH, room_dictionary[south_pos])
		if room_dictionary.has(west_pos):
			room.connect_door(RoomVariation.ROOM_DIRECTION.WEST, room_dictionary[west_pos])

## Spawns player.
func spawn_player():
	var player_instance: Player = player_scene.instantiate()
	add_child(player_instance)
	player_instance.global_position = first_room.get_player_spawn_position()
	map.set_player_position(first_room.tile_position)
	print("Spawned player at " + str(first_room.tile_position))

## Uses a static Node3D in center of room, and checks x/z positions to determine which walls to hide regardless of room is rotated.
func remove_walls():
	for room in rooms.get_children():
		if not room is RoomVariation:
			continue
		match room.times_rotated:
			0: # Room was not rotated. Thus, eastern and southern walls will block player camera.
				room.wall_south.visible = false
				room.wall_east.visible = false
			1: # Room was rotated once (-90 degrees). Thus, eastern and northern walls will block player camera.
				room.wall_north.visible = false
				room.wall_east.visible = false
			2: # Room was rotated twice (-180 degrees). Thus, western and northern walls will block player camera.
				room.wall_north.visible = false
				room.wall_west.visible = false
			3: # Room was rotated thrice (-270 degrees). Thus, western and southern walls will block player camera.
				room.wall_south.visible = false
				room.wall_west.visible = false

## Spawns key
func spawn_key() -> void:
	var key_instance = room_key.instantiate()
	add_child(key_instance)
	key_instance.global_position = room_dictionary[map.key_location].global_position
	print("Spawned key at " + str(map.key_location))

func spawn_boss_door() -> void:
	var door_instance: Node3D = boss_door.instantiate()
	add_child(door_instance)
	var boss_room: RoomVariation = room_dictionary[map.boss_cell]
	var boss_door: RoomDoor = boss_room.south_door
	var opposite_direction =  (boss_door.direction + 2) % 4
	var pre_boss_room: RoomVariation = boss_door.connected_room
	if(pre_boss_room.north_door and
	 pre_boss_room.north_door.direction == opposite_direction):
		door_instance.global_position = pre_boss_room.north_door.global_position
		pre_boss_room.north_door.dissappear()
	if(pre_boss_room.east_door and
	 pre_boss_room.east_door.direction == opposite_direction):
		door_instance.global_position = pre_boss_room.east_door.global_position
		pre_boss_room.east_door.dissappear()
	if(pre_boss_room.south_door and
	 pre_boss_room.south_door.direction == opposite_direction):
		door_instance.global_position = pre_boss_room.south_door.global_position
		pre_boss_room.south_door.dissappear()
	if(pre_boss_room.west_door and
	 pre_boss_room.west_door.direction == opposite_direction):
		door_instance.global_position = pre_boss_room.west_door.global_position
		pre_boss_room.west_door.dissappear()
	var tr = 1
	match opposite_direction:
		0:
			door_instance.translate(Vector3(0, 0, tr))
		1:
			door_instance.translate(Vector3(-tr, 0, 0))
			door_instance.rotate_y(3*PI/2)
		2:
			door_instance.translate(Vector3(0, 0, -tr))
			door_instance.rotate_y(PI)
			pass
		3:
			door_instance.translate(Vector3(tr, 0, 0))
			door_instance.rotate_y(PI/2)
			pass
