extends CharacterState

@export var dash_state: CharacterState
@export var attack_state: CharacterState

@export var move_speed:float = 5
@export var acceleration:float = 4

var input_dir:Vector2
var last_dir:Vector2

func handle_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("dash"):
		finished.emit(dash_state.get_path(), {'vector': last_dir})
	if _event.is_action_pressed("attack"):
		finished.emit(attack_state.get_path(), {'direction': last_dir})

func physics_update(_delta: float) -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")
	last_dir = input_dir if input_dir else last_dir
	character.set_orientation_from_top_down_vector(input_dir)
	character.adjust_body_velocity(_delta, move_speed, acceleration)
