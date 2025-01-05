extends Node

@export var scene_change_duration: float = 3
@export var main_menu: PackedScene
@export var game_start_area: PackedScene
@export var debug_area: PackedScene
@export var debug_generation_area: PackedScene
@export var generation_area_two: PackedScene
@onready var timer: Timer = %Timer
@onready var load_cover: Control = %LoadCover

var next_scene:PackedScene
var current_scene:PackedScene

func to_main_menu() -> void:
	next_scene = main_menu
	current_scene = main_menu
	scene_change()

func to_game_start() -> void:
	next_scene = game_start_area
	current_scene = game_start_area
	scene_change()

func to_debug_area() -> void:
	next_scene = debug_area
	current_scene = debug_area
	scene_change()

func to_debug_generation_area() -> void:
	next_scene = debug_generation_area
	current_scene = debug_generation_area
	scene_change()

func to_generation_area_two() -> void:
	next_scene = generation_area_two
	current_scene = generation_area_two
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
