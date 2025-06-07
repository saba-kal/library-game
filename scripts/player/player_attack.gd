extends CharacterState

signal started

@export var player: CharacterBody3D

@export_group("Target States")
@export var movement_state: CharacterState
@export var next_attack: CharacterState

@export_group("Attack Details")
@export var damage: int = 1
@export var distance: float = .4
@export var wind_up_period: float = 0.3
@export var swing_duration: float = .4
@export var wind_down_period: float = .3
@export var sound_effect_name: String
@export var animation_node_name: String

@onready var hit_area: Area3D = $"../../LibrarianPlayer/LibrarianArmature/Skeleton3D/BoneAttachment3D/Umbrella/Area"
@onready var movement_payback = animation_tree.get("parameters/Attack/playback")

var step_dir: Vector2
var last_dir: Vector2
var swing_timer: Timer
var wind_up_timer: Timer
var wind_down_timer: Timer
var queued_attack: bool
var hit_bodies: Dictionary
var can_damage: bool = false


func _ready() -> void:
	hit_area.body_entered.connect(on_body_entered)
	wind_up_timer = Timer.new()
	wind_up_timer.one_shot = true
	wind_up_timer.name = "wind up"
	wind_up_timer.timeout.connect(swing_start)
	add_child(wind_up_timer)
	swing_timer = Timer.new()
	swing_timer.one_shot = true
	swing_timer.name = "swing_timer"
	swing_timer.timeout.connect(swing_complete)
	add_child(swing_timer)
	wind_down_timer = Timer.new()
	wind_down_timer.one_shot = true
	wind_down_timer.name = "wind_down_timer"
	wind_down_timer.timeout.connect(done)
	add_child(wind_down_timer)


func handle_input(_event: InputEvent) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	last_dir = input_dir if input_dir else last_dir
	if _event.is_action_pressed("attack"):
		if next_attack and wind_up_timer.time_left + swing_timer.time_left == 0 and wind_down_timer.time_left > 0:
			finished.emit(next_attack.get_path(), {'direction': last_dir})
		else:
			queued_attack = true


func enter(_previous_state_path: String, data := {}) -> void:
	queued_attack = false
	if data.has('direction'):
		step_dir = data.direction
		last_dir = step_dir
		character.set_orientation_from_top_down_vector(step_dir)
	wind_up_timer.start(wind_up_period)
	animation_tree.set("parameters/Actions/transition_request", "Attack")
	movement_payback.travel(animation_node_name)


func exit() -> void:
	swing_timer.stop()
	wind_down_timer.stop()
	wind_up_timer.stop()


func swing_start() -> void:
	hit_bodies = {}
	character.constant_velocity(distance / swing_duration)
	swing_timer.start(swing_duration)
	can_damage = true
	AudioManager.play_3d(sound_effect_name, character.global_position)


func swing_complete() -> void:
	character.velocity *= 0.2
	wind_down_timer.start(wind_down_period)
	if queued_attack and next_attack:
		finished.emit(next_attack.get_path(), {'direction': last_dir})
	hit_bodies = {}
	can_damage = false


func done() -> void:
	finished.emit(movement_state.get_path())


func on_body_entered(body: Node3D) -> void:
	if not (can_damage &&
		is_instance_valid(body) &&
		body.is_in_group("enemy") &&
		body.has_meta("damageable") &&
		!hit_bodies.has(body)):
			return

	var health: Health = Util.get_child_node_of_type(body, Health)
	if is_instance_valid(health) && health.current > 0:
		health.take_damage(damage, player)
		hit_bodies.get_or_add(body)
		AudioManager.play_3d("enemy_hit", character.global_position)
		HitStopManager.frame_freeze(0.1, 0.2)
