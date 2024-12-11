extends Node

@export var scene_change_duration:float = 3
@export var main_menu:PackedScene
@export var debug_area:PackedScene
@export var debug_generation_area: PackedScene
@onready var timer: Timer = %Timer
@onready var load_cover: Control = %LoadCover

var next_scene:PackedScene
var current_scene:PackedScene

func to_main_menu() -> void:
    next_scene = main_menu
    current_scene = main_menu
    scene_change()

func to_debug_area() -> void:
    next_scene = debug_area
    current_scene = debug_area
    scene_change()

func to_debug_generation_area() -> void:
    next_scene = debug_generation_area
    current_scene = debug_generation_area
    scene_change()


func scene_change() -> void:
    if timer.is_stopped():
        load_cover.visible = true
        Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
        timer.start(scene_change_duration)
    else:
        return

func scene_change_finished() -> void:
    load_cover.visible = false
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    get_tree().change_scene_to_packed(next_scene)
