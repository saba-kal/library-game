extends CharacterBody3D

@export_group("Movement Settings")
@export var move_speed:float = 5
@export var acceleration:float = 4
@export var decceleration:float = 5
@export var rotation_speed:float = 10

@export_group("StateMachine")
@export var initial_state:CharacterState

@onready var body: MeshInstance3D = $Body
@onready var state_machine: Node = $StateMachine
@onready var state:CharacterState = (func get_initial_state() -> CharacterState:
	return initial_state if initial_state else state_machine.get_child(0)
).call()

var direction:Vector3
var target_rotation:float

func _ready() -> void:
	for state_node:CharacterState in state_machine.find_children("*", "CharacterState"):
		state_node.finished.connect(_transition_to_next_state)
	
	state.enter("")
	
func _transition_to_next_state(target_state_path:String, data:Dictionary = {}) -> void:
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
	
	if direction:
		body.rotation.y = lerp_angle(body.rotation.y, target_rotation, rotation_speed * delta)
	if not direction:
		velocity.x = lerp(velocity.x, 0.0, decceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, decceleration * delta)
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)

func set_orientation_from_top_down_vector(vector:Vector2) -> void:
	direction = transform.basis * Vector3(vector.x, 0, vector.y).rotated(Vector3.UP, $CamRoot/SpringArm3D.rotation.y).normalized()
	target_rotation = atan2(direction.x, direction.z) - rotation.y

func adjust_body_velocity(delta:float, move_speed:float, acceleration:float) -> void:
	if direction:
		velocity.x = lerp(velocity.x, direction.x * move_speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * move_speed, acceleration * delta)
	
func constant_velocity(delta:float, speed:float) -> void:
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
