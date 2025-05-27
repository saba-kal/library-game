extends Node
class_name _2DGeneration

signal generation_complete
signal generation_cleared

const FOUR_WAY := Vector2i(0, 0)
const THREE_WAY := Vector2i(1, 0)
const THREE_WAY_ROTATED_1 := Vector2i(2, 0)
const THREE_WAY_ROTATED_2 := Vector2i(3, 0)
const THREE_WAY_ROTATED_3 := Vector2i(4, 0)
const HALLWAY := Vector2i(0, 1)
const HALLWAY_ROTATED_1 := Vector2i(0, 2)
const CORNER := Vector2i(1, 1)
const CORNER_ROTATED_1 := Vector2i(2, 1)
const CORNER_ROTATED_2 := Vector2i(3, 1)
const CORNER_ROTATED_3 := Vector2i(4, 1)
const DEADEND := Vector2i(1, 2)
const DEADEND_ROTATED_1 := Vector2i(2, 2)
const DEADEND_ROTATED_2 := Vector2i(3, 2)
const DEADEND_ROTATED_3 := Vector2i(4, 2)

class RoomData:
	var room_type: Vector2i
	var tile_map_position: Vector2i
	var is_boss_room: bool

@export var max_width_allowed:int = 10
@export var max_height_allowed:int = 10
@export var minimum_room_amount:int = 10
@onready var tile_map_layer: TileMapLayer = %TileMapLayer
@onready var failsafe_timer: Timer = $FailsafeTimer
@onready var player_location_sprite: Node2D = $PlayerLocationSprite
@onready var boss_location_sprite: Node2D = $BossLocationSprite
@onready var key_location_sprite: Node2D = $KeyLocationSprite

var currently_generating:bool = false
var failsafe_activated:bool = true
var valid_cell_count:int = 0
var boss_cell:Vector2i
var player_location:Vector2i
var key_location:Vector2i

func _ready() -> void:
	player_location_sprite.visible = false
	boss_location_sprite.visible = false
	key_location_sprite.visible = false
	SignalBus.player_moved_to_room.connect(on_player_moved_to_room)
	SignalBus.room_key_collected.connect(on_key_collected)

func generate_rooms():
	currently_generating = true
	var starting_position:Vector2i = Vector2i(0,0)
	var current_position:Vector2i = starting_position
	for x in minimum_room_amount:
		var spot_check:Vector2i = tile_map_layer.get_surrounding_cells(current_position).pick_random()
		var data = tile_map_layer.get_cell_tile_data(spot_check)
		if data == null:
				tile_map_layer.set_cell(spot_check,0,Vector2(5,0))
		else:
			failsafe_timer.start(1.0)
			while data != null or spot_check.x > max_width_allowed or spot_check.y > max_height_allowed:
				await get_tree().create_timer(0.05).timeout
				spot_check = tile_map_layer.get_surrounding_cells(current_position).pick_random()
				data = tile_map_layer.get_cell_tile_data(spot_check)
				if failsafe_activated:
					failsafe_activated = false
					for cell in tile_map_layer.get_used_cells():
						for sur_cell in tile_map_layer.get_surrounding_cells(cell):
							if tile_map_layer.get_cell_tile_data(sur_cell) == null:
								current_position = sur_cell
								break
					break
			tile_map_layer.set_cell(spot_check,0,Vector2(5,0))
		current_position = spot_check
	print("Done Generatoring")

	await get_tree().create_timer(0.5).timeout

	## Bulks up rooms, with small chance of dead-end created.
	for tile in tile_map_layer.get_used_cells():
		for sur_tile in tile_map_layer.get_surrounding_cells(tile):
			if tile_map_layer.get_cell_tile_data(sur_tile) == null:
				var chance:int = randi_range(1,3)
				match chance:
					1:
						tile_map_layer.set_cell(sur_tile,0,Vector2(5,0))

	## Sets rooms to their appropriate tile-type based on their locations, and neighbors.
	tie_up_rooms()
	add_boss_room()
	add_key()
	currently_generating = false
	generation_complete.emit()

func tie_up_rooms():
	print("Tidying rooms.")
	tile_map_layer.set_cells_terrain_connect(tile_map_layer.get_used_cells(), 0, 0, false)

func add_boss_room() -> void:
	var used_cells: Array[Vector2i] = tile_map_layer.get_used_cells()
	var first_cell: Vector2i = used_cells.front() # First cell is where the player spawns.
	var furthest_cell: Vector2i = used_cells.back()
	var max_distance_sqr: int = 0
	# Find the furthest cell, which will connect to the boss room.
	# Not the most ideal method of finding distance, but good enough for now.
	# Ideal solution would be to calculate the path distance rather than bird's eye view.
	for cell_coord: Vector2i in used_cells:
		var distance_sqr: int = first_cell.distance_squared_to(cell_coord)
		if distance_sqr > max_distance_sqr:
			max_distance_sqr = distance_sqr
			furthest_cell = cell_coord

	boss_cell = add_deadend_room_to_tile_pos(furthest_cell)
	boss_location_sprite.position = tile_map_layer.map_to_local(boss_cell)
	boss_location_sprite.visible = true

func add_key() -> void:
	var used_cells: Array[Vector2i] = tile_map_layer.get_used_cells()
	var player_cell: Vector2i = used_cells.front() # First cell is where the player spawns.
	var furthest_cell: Vector2i = used_cells.back()
	var max_combined_distance: int = 0
	# Find the cell with most combined distance between boss room and player spaw
	# so the key will be out of the way
	for cell_coord: Vector2i in used_cells:
		var combined_distance: int = manhattan_distance(player_cell, cell_coord)
		if combined_distance == 0:
			continue
		combined_distance += manhattan_distance(boss_cell, cell_coord)
		if combined_distance > max_combined_distance:
			max_combined_distance = combined_distance
			furthest_cell = cell_coord

	key_location = furthest_cell
	key_location_sprite.position = tile_map_layer.map_to_local(key_location)
	key_location_sprite.visible = true
	print("key at " + str(key_location))

func manhattan_distance(v1: Vector2i, v2: Vector2i) -> int:
	var diff: Vector2i = v1 - v2
	return abs(diff.x) + abs(diff.y)

func generation_info() -> Array[RoomData]:
	var generation_array_info:Array[RoomData] = []
	for x: Vector2i in tile_map_layer.get_used_cells():
		var room_data: RoomData = RoomData.new()
		room_data.room_type = tile_map_layer.get_cell_atlas_coords(x)
		room_data.tile_map_position = x
		room_data.is_boss_room = x == boss_cell
		generation_array_info.append(room_data)
	return generation_array_info

func set_player_position(tile_map_pos: Vector2i):
	player_location_sprite.position = tile_map_layer.map_to_local(tile_map_pos)
	player_location_sprite.visible = true
	player_location = tile_map_pos

func add_deadend_room_to_tile_pos(tile_map_pos: Vector2i) -> Vector2i:
	var north_offset: Vector2i = Vector2i(0, -1)
	var east_offset: Vector2i = Vector2i(1, 0)
	var south_offset: Vector2i = Vector2i(0, 1)
	var west_offset: Vector2i = Vector2i(-1, 0)
	var new_cell: Vector2i
	match tile_map_layer.get_cell_atlas_coords(tile_map_pos):
		FOUR_WAY:
			# IDK how to handle this case.
			printerr("Unable to connect an additional room to a fourway cell. Unable to spawn boss.")
		THREE_WAY:
			new_cell = tile_map_pos + south_offset
			tile_map_layer.set_cell(tile_map_pos, 0, FOUR_WAY)
			tile_map_layer.set_cell(new_cell, 0, DEADEND_ROTATED_2)
		THREE_WAY_ROTATED_1:
			new_cell = tile_map_pos + west_offset
			tile_map_layer.set_cell(tile_map_pos, 0, FOUR_WAY)
			tile_map_layer.set_cell(new_cell, 0, DEADEND_ROTATED_3)
		THREE_WAY_ROTATED_2:
			new_cell = tile_map_pos + north_offset
			tile_map_layer.set_cell(tile_map_pos, 0, FOUR_WAY)
			tile_map_layer.set_cell(new_cell, 0, DEADEND)
		THREE_WAY_ROTATED_3:
			new_cell = tile_map_pos + east_offset
			tile_map_layer.set_cell(tile_map_pos, 0, FOUR_WAY)
			tile_map_layer.set_cell(new_cell, 0, DEADEND_ROTATED_1)
		HALLWAY:
			new_cell = tile_map_pos + north_offset
			tile_map_layer.set_cell(tile_map_pos, 0, THREE_WAY)
			tile_map_layer.set_cell(new_cell, 0, DEADEND)
		CORNER:
			new_cell = tile_map_pos + east_offset
			tile_map_layer.set_cell(tile_map_pos, 0, THREE_WAY)
			tile_map_layer.set_cell(new_cell, 0, DEADEND_ROTATED_1)
		CORNER_ROTATED_1:
			new_cell = tile_map_pos + west_offset
			tile_map_layer.set_cell(tile_map_pos, 0, THREE_WAY)
			tile_map_layer.set_cell(new_cell, 0, DEADEND_ROTATED_3)
		CORNER_ROTATED_2:
			new_cell = tile_map_pos + north_offset
			tile_map_layer.set_cell(tile_map_pos, 0, THREE_WAY_ROTATED_1)
			tile_map_layer.set_cell(new_cell, 0, DEADEND)
		CORNER_ROTATED_3:
			new_cell = tile_map_pos + east_offset
			tile_map_layer.set_cell(tile_map_pos, 0, THREE_WAY_ROTATED_2)
			tile_map_layer.set_cell(new_cell, 0, DEADEND_ROTATED_1)
		HALLWAY_ROTATED_1:
			new_cell = tile_map_pos + east_offset
			tile_map_layer.set_cell(tile_map_pos, 0, THREE_WAY_ROTATED_1)
			tile_map_layer.set_cell(new_cell, 0, DEADEND_ROTATED_1)
		DEADEND:
			new_cell = tile_map_pos + north_offset
			tile_map_layer.set_cell(tile_map_pos, 0, HALLWAY_ROTATED_1)
			tile_map_layer.set_cell(new_cell, 0, DEADEND)
		DEADEND_ROTATED_1:
			new_cell = tile_map_pos + east_offset
			tile_map_layer.set_cell(tile_map_pos, 0, HALLWAY)
			tile_map_layer.set_cell(new_cell, 0, DEADEND_ROTATED_1)
		DEADEND_ROTATED_2:
			new_cell = tile_map_pos + south_offset
			tile_map_layer.set_cell(tile_map_pos, 0, HALLWAY_ROTATED_1)
			tile_map_layer.set_cell(new_cell, 0, DEADEND_ROTATED_2)
		DEADEND_ROTATED_3:
			new_cell = tile_map_pos + west_offset
			tile_map_layer.set_cell(tile_map_pos, 0, HALLWAY)
			tile_map_layer.set_cell(new_cell, 0, DEADEND_ROTATED_3)
	return new_cell

func on_player_moved_to_room(room: RoomVariation):
	set_player_position(room.tile_position)
	room.enter_room_spawn()

func _on_failsafe_timer_timeout() -> void:
	failsafe_activated = true

func _on_line_edit_focus_entered() -> void:
	pass # Replace with function body.

func _on_button_generate_pressed() -> void:
	if !currently_generating:
		tile_map_layer.clear()
		generate_rooms()

func _on_button_clear_pressed() -> void:
	if !currently_generating:
		tile_map_layer.clear()
		generation_cleared.emit()

func _on_line_edit_text_changed(new_text: String) -> void:
	minimum_room_amount = int(float(new_text))

func on_key_collected() -> void:
	key_location_sprite.visible = false

func hide_debugging_overlay() -> void:
	$DebuggingOverlay.visible = false
	$DebuggingOverlay.process_mode = Node.PROCESS_MODE_DISABLED
