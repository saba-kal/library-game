extends Node

@export var scene_change_duration: float = 3
@onready var timer: Timer = %Timer
@onready var load_cover: Control = %LoadCover

var next_scene:PackedScene
var current_scene:PackedScene
# Unable to export these as packed scenes due to cyclical reference errors.
# See https://github.com/godotengine/godot/issues/93258
var known_scenes: Dictionary = {
	"main_menu": preload("res://scenes/main_menu/main_menu.tscn"),
	"hub": preload("res://scenes/levels/hub.tscn"),
	"haunted_floor": preload("res://scenes/levels/haunted_floor.tscn"),
	"debug_area": preload("res://scenes/debug/debug.tscn"),
	"debug_generation": preload("res://scenes/room_generation/zoning_test.tscn"),
	"debug_generation_2": preload("res://scenes/room_generation/Gen2/2d_map.tscn")
	}

func to_main_menu() -> void:
	next_scene = known_scenes["main_menu"]
	current_scene = known_scenes["main_menu"]
	scene_change()

func to_game_start() -> void:
	next_scene = known_scenes["haunted_floor"]
	current_scene = known_scenes["haunted_floor"]
	scene_change()

func to_debug_area() -> void:
	next_scene = known_scenes["debug_area"]
	current_scene = known_scenes["debug_area"]
	scene_change()

func to_debug_generation_area() -> void:
	next_scene = known_scenes["debug_generation"]
	current_scene = known_scenes["debug_generation"]
	scene_change()

func to_generation_area_two() -> void:
	next_scene = known_scenes["debug_generation_2"]
	current_scene = known_scenes["debug_generation_2"]
	scene_change()

func to_scene(scene_name: String) -> void:
	next_scene = known_scenes[scene_name]
	current_scene = known_scenes[scene_name]
	scene_change()

func scene_change() -> void:
	if timer.is_stopped():
		load_cover.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		timer.start(scene_change_duration)
		SignalBus.scene_change_initiated.emit()
	else:
		return

func scene_change_finished() -> void:
	load_cover.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_packed(next_scene)
