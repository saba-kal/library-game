extends CharacterState

@export var dash_state: CharacterState
@export var attack_state: CharacterState
@export var parry_state: CharacterState

@export var move_speed:float = 5
@export var acceleration:float = 4
@export var footstep_sounds: FootstepSounds

var input_dir:Vector2
var last_dir:Vector2

func handle_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("dash"):
		finished.emit(dash_state.get_path(), {'vector': last_dir})
		self.footstep_sounds.enabled = false
	if _event.is_action_pressed("attack"):
		finished.emit(attack_state.get_path(), {'direction': last_dir})
		self.footstep_sounds.enabled = false
	if _event.is_action_pressed("parry"):
		finished.emit(parry_state.get_path(), {'direction': last_dir})
		self.footstep_sounds.enabled = false

func physics_update(_delta: float) -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")
	last_dir = input_dir if input_dir else last_dir
	character.set_orientation_from_top_down_vector(input_dir)
	character.adjust_body_velocity(_delta, move_speed, acceleration)
	self.footstep_sounds.enabled = input_dir.length_squared() > 0.1
