extends CharacterState

@export var dash_state: CharacterState
@export var attack_state: CharacterState
@export var parry_state: CharacterState

@export var move_speed: float = 5
@export var acceleration: float = 4
@export var idle_speed: float = 0.5
@export var dash_cooldown: float = 0.5

var input_dir: Vector2
var last_dir: Vector2
var idle: bool
var idling: bool
var time_since_last_dash: float = 0
var is_controls_disabled: bool = false


@onready var movement_payback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/Movement/playback")

func _ready() -> void:
	SignalBus.set_player_controls_disabled.connect(on_player_controls_disabled)

func enter(previous_state_path: String, data := {}) -> void:
	# Global movement input mapping that checks for all of the movement inputs combined.
	# So player can probably start at moving, or idle after actions.
	if Input.is_action_pressed("movement"):
		idle = false
	else:
		idle = true
	
	animation_tree.set("parameters/Actions/transition_request", "Movement")

func handle_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("dash") && time_since_last_dash >= dash_cooldown:
		time_since_last_dash = 0
		finished.emit(dash_state.get_path(), {'vector': last_dir})
	if _event.is_action_pressed("attack"):
		finished.emit(attack_state.get_path(), {'direction': last_dir})
	if _event.is_action_pressed("parry"):
		finished.emit(parry_state.get_path(), {'direction': last_dir})

func physics_update(delta: float) -> void:
	if is_controls_disabled:
		return
	input_dir = Input.get_vector("left", "right", "up", "down")
	last_dir = input_dir if input_dir else last_dir
	if input_dir != Vector2.ZERO:
		character.set_orientation_from_top_down_vector(last_dir)
		character.adjust_body_velocity(delta, move_speed, acceleration)
	else:
		character.stop_moving()
	
	# Sets proper travel path for animation start.
	if !idle:
		movement_payback.travel("Walk")
	else:
		if !idling:
				movement_payback.travel("Idle")
				idling = true
	
	# Checks for input and low velocity; If none, player is able to idle.
	if (input_dir == Vector2.ZERO) and (Vector2(character.velocity.x, character.velocity.z).length() < 0.1):
		character.velocity.x = 0
		character.velocity.z = 0
		idle = true
	else:
		idle = false
		idling = false

	# Blends between walk/run based on velocity.
	animation_tree.set("parameters/Movement/Walk/blend_position", Vector2(character.velocity.x, character.velocity.z).length())
	time_since_last_dash += delta

func on_player_controls_disabled(is_disabled: bool) -> void:
	is_controls_disabled = is_disabled
	animation_tree.set("parameters/Movement/Walk/blend_position", 0)
	character.stop_moving()
