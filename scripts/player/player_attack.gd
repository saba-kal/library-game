extends CharacterState

signal started

@export_group("Target States")
@export var movement_state:CharacterState
@export var next_attack:CharacterState

@export_group("Attack Details")
@export var damage:int = 1
@export var distance:float = .4
@export var wind_up_period:float = 0.3
@export var swing_duration:float = .4
@export var wind_down_period:float = .3
@export var placeholder_fx:Node3D

@export var animation_node_name: String

@onready var transform: Node3D = $Transform
@onready var hit_area: Area3D = $Transform/HitArea
@onready var movement_payback = animation_tree.get("parameters/Attack/playback")

var step_dir:Vector2
var last_dir:Vector2
var swing_timer:Timer
var wind_up_timer:Timer
var wind_down_timer:Timer
var queued_attack:bool
var hit_bodies:Dictionary

func _ready() -> void:
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
	placeholder_fx.visible = false

func handle_input(_event: InputEvent) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	last_dir = input_dir if input_dir else last_dir
	if _event.is_action_pressed("attack"):
		if next_attack and wind_up_timer.time_left + swing_timer.time_left == 0 and wind_down_timer.time_left > 0:
			finished.emit(next_attack.get_path(), {'direction': last_dir})
		else:
			queued_attack = true

func physics_update(_delta: float) -> void:
	transform.global_position = character.global_position
	if swing_timer.time_left > 0:
		add_hit_bodies()
	
func enter(previous_state_path: String, data := {}) -> void:
	print("entered attack \"" + name + "\" with data: " + str(data))
	queued_attack = false
	if data.has('direction'):
		step_dir = data.direction
		last_dir = step_dir
		character.set_orientation_from_top_down_vector(step_dir)
		transform.global_position = character.global_position
		transform.global_basis = Basis.looking_at(character.direction, Vector3.UP, true)
	wind_up_timer.start(wind_up_period)
	animation_tree.set("parameters/Actions/transition_request", "Attack")
	movement_payback.travel(animation_node_name)

func exit() -> void:
	placeholder_fx.visible = false
	swing_timer.stop()
	wind_down_timer.stop()
	wind_up_timer.stop()

func swing_complete() -> void:
	add_hit_bodies()
	print("hitting " + str(hit_bodies.size()) + " bodies")
	character.constant_velocity(0)
	for body in hit_bodies:
		if !is_instance_valid(body):
			continue
		for component in body.get_children():
			if not component.has_method("take_damage"):
				continue
			print("damaging " + body.name)
			component.take_damage(damage)
	wind_down_timer.start(wind_down_period)
	placeholder_fx.visible = false
	if queued_attack and next_attack:
		finished.emit(next_attack.get_path(), {'direction': last_dir})

func swing_start() -> void:
	character.constant_velocity(distance / swing_duration)
	swing_timer.start(swing_duration)
	placeholder_fx.visible = true
	AudioManager.play_3d("player_attack", character.global_position)
	add_hit_bodies()

func done() -> void:
	finished.emit(movement_state.get_path())

func add_hit_bodies() -> void:
	for body in hit_area.get_overlapping_bodies():
		if body.has_meta("damageable"):
			hit_bodies.get_or_add(body)
