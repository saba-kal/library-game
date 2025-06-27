class_name Player extends CharacterBody3D

signal died

@export_group("Movement Settings")
@export var move_speed: float = 5
@export var acceleration: float = 4
@export var decceleration: float = 5
@export var rotation_speed: float = 10

@export_group("StateMachine")
@export var initial_state: CharacterState
@export var death_state: CharacterState
@export var hurt_state: CharacterState

@onready var body: Node3D = $LibrarianPlayer
@onready var health: Health = $Health
@onready var state_machine: Node = $StateMachine
@onready var state: CharacterState = (func get_initial_state() -> CharacterState:
	return initial_state if initial_state else state_machine.get_child(0)
).call()
@onready var speech_bubble: SpeechBubble = $SpeechBubble3D

var direction: Vector3
var target_rotation: float

func _ready() -> void:
	target_rotation = body.rotation.y
	for state_node: CharacterState in state_machine.find_children("*", "CharacterState"):
		state_node.finished.connect(_transition_to_next_state)
	state.enter("")
	SignalBus.player_entered_boss_door_area.connect(on_player_entered_boss_door_area)
	SignalBus.player_spawned.emit(self)
	health.changed.connect(health_changed)

func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not state_machine.has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it did not exist")
		return

	var previous_state_path := state.name
	state.exit()
	state = state_machine.get_node(target_state_path)
	state.enter(previous_state_path, data)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	state.physics_update(delta)

	body.rotation.y = lerp_angle(body.rotation.y, target_rotation, rotation_speed * delta)
	if not direction:
		velocity.x = lerp(velocity.x, 0.0, decceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, decceleration * delta)

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)

func set_orientation_from_top_down_vector(vector: Vector2) -> void:
	direction = transform.basis * Vector3(vector.x, 0, vector.y).rotated(Vector3.UP, $CamRoot/SpringArm3D.rotation.y).normalized()
	target_rotation = atan2(direction.x, direction.z) - rotation.y

func face_global_direction(dir: Vector2) -> void:
	target_rotation = atan2(dir.x, dir.y) - rotation.y

func adjust_body_velocity(delta: float, move_speed: float, acceleration: float) -> void:
	if direction:
		velocity.x = lerp(velocity.x, direction.x * move_speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * move_speed, acceleration * delta)

func constant_velocity(dir: Vector3, speed: float) -> void:
	if dir:
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed

func stop_moving() -> void:
	direction = Vector3.ZERO

func take_damage(damage: int) -> void:
	self.health.take_damage(damage)

func heal(heal_amount: int) -> void:
	self.health.heal(heal_amount)

func health_changed(new_health: int, damage: int, damage_sender) -> void:
	if (damage > 0):
		if new_health <= 0:
			_transition_to_next_state(death_state.get_path())
			died.emit()
		else:
			_transition_to_next_state(hurt_state.get_path())

func on_player_entered_boss_door_area() -> void:
	if Game.room_key_count <= 0:
		speech_bubble.display_text("I need a key")
