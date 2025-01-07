extends Node
class_name _2DGeneration

signal generation_complete
signal generation_cleared

@export var max_width_allowed:int = 10
@export var max_height_allowed:int = 10
@export var minimum_room_amount:int = 10
@onready var tile_map_layer: TileMapLayer = %TileMapLayer
@onready var failsafe_timer: Timer = $FailsafeTimer
@onready var player_location_sprite: Node2D = $PlayerLocationSprite

var currently_generating:bool = false
var failsafe_activated:bool = true
var valid_cell_count:int = 0

var generation_array_info:Array[Array]

func _ready() -> void:
	SignalBus.player_moved_to_room.connect(on_player_moved_to_room)

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

func tie_up_rooms():
	print("Tidying rooms.")
	tile_map_layer.set_cells_terrain_connect(tile_map_layer.get_used_cells(), 0, 0, false)
	currently_generating = false
	generation_complete.emit()

func generation_info():
	for x in tile_map_layer.get_used_cells():
		generation_array_info.append([x,tile_map_layer.get_cell_atlas_coords(x)])
	
	return generation_array_info

func set_player_position(tile_map_pos: Vector2i):
	player_location_sprite.position = tile_map_layer.map_to_local(tile_map_pos)

func on_player_moved_to_room(room: RoomVariation):
	set_player_position(room.tile_position)

func _on_failsafe_timer_timeout() -> void:
	failsafe_activated = true

func _on_line_edit_focus_entered() -> void:
	pass # Replace with function body.

func _on_button_generate_pressed() -> void:
	if !currently_generating:
		generate_rooms()

func _on_button_clear_pressed() -> void:
	if !currently_generating:
		tile_map_layer.clear()
		generation_cleared.emit()

func _on_line_edit_text_changed(new_text: String) -> void:
	minimum_room_amount = int(float(new_text))
