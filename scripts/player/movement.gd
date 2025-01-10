extends CharacterState

@export var dash_state: CharacterState
@export var attack_state: CharacterState
@export var parry_state: CharacterState

@export var move_speed:float = 5
@export var acceleration:float = 4
@export var footstep_sounds: FootstepSounds
@export var idle_speed:float = 0.5

var input_dir:Vector2
var last_dir:Vector2
var idle:bool
@onready var movement_payback = animation_tree.get("parameters/Movement/playback")

func enter(previous_state_path: String, data := {}) -> void:
	animation_tree.set("parameters/Actions/transition_request", "Movement")
	idle = true

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
	var updated_idle = input_dir.is_zero_approx()
	if idle and not updated_idle:
		movement_payback.travel("Walk")
	elif not idle and updated_idle:
		movement_payback.travel("Idle")
		print(movement_payback.get_current_node())
	idle = updated_idle
