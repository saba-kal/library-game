extends CharacterState

signal started

@export_group("Target States")
@export var movement_state:CharacterState

@export_group("Attack Details")
@export var parry_duration:float = .3
@export var wind_down_period:float = .01
@export var placeholder_fx:Node3D

@onready var transform: Node3D = $Transform
@onready var hit_area: Area3D = $Transform/HitArea

var step_dir:Vector2
var last_dir:Vector2
var parry_timer:Timer
var wind_down_timer:Timer
var queued_attack:bool

func _ready() -> void:
	parry_timer = Timer.new()
	parry_timer.one_shot = true
	parry_timer.name = "parry_timer"
	parry_timer.timeout.connect(parry_complete)
	add_child(parry_timer)
	wind_down_timer = Timer.new()
	wind_down_timer.one_shot = true
	wind_down_timer.name = "wind_down_timer"
	wind_down_timer.timeout.connect(done)
	add_child(wind_down_timer)
	placeholder_fx.visible = false

func handle_input(_event: InputEvent) -> void:
	pass

func physics_update(_delta: float) -> void:
	transform.global_position = character.global_position
	if parry_timer.time_left > 0:
		detect_parry()

func enter(previous_state_path: String, data := {}) -> void:
	queued_attack = false
	if data.has('direction'):
		step_dir = data.direction
		last_dir = step_dir
		character.set_orientation_from_top_down_vector(step_dir)
		transform.global_position = character.global_position
		transform.global_basis = Basis.looking_at(character.direction, Vector3.UP, true)
	parry_timer.start(parry_duration)
	placeholder_fx.visible = true
	AudioManager.play_3d("player_attack", character.global_position)
	animation_tree.set("parameters/Actions/transition_request", "Block")
	detect_parry()

func exit() -> void:
	placeholder_fx.visible = false
	parry_timer.stop()
	wind_down_timer.stop()

func parry_complete() -> void:
	detect_parry()
	wind_down_timer.start(wind_down_period)
	placeholder_fx.visible = false


func done() -> void:
	finished.emit(movement_state.get_path())

func detect_parry() -> void:
	for area in hit_area.get_overlapping_areas():
		if area.has_meta("parryable"):
			if area.has_method("get_parried"):
				area.get_parried(hit_area)
