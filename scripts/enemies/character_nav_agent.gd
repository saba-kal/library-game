class_name CharacterNavAgent extends NavigationAgent3D

@export var movement_speed: float = 5.0

var character: CharacterBody3D
var is_disabled: bool:
	set(value):
		is_disabled = value
		if value:
			set_target_position(character.global_position)


func _ready() -> void:
	character = get_parent()
	velocity_computed.connect(on_velocity_computed)


func set_movement_target(movement_target: Vector3) -> void:
	set_target_position(movement_target)


func _physics_process(_delta: float) -> void:
	if is_disabled || is_navigation_finished():
		velocity = Vector3.ZERO
		set_target_position(character.global_position)
		return

	max_speed = movement_speed
	var next_path_position: Vector3 = get_next_path_position()
	var current_agent_position: Vector3 = character.global_position
	var new_velocity: Vector3 = next_path_position - current_agent_position
	if avoidance_enabled:
		set_velocity(new_velocity)
	else:
		on_velocity_computed(new_velocity)


func on_velocity_computed(safe_velocity: Vector3) -> void:
	if is_disabled:
		return
	character.velocity = safe_velocity.normalized() * movement_speed
	character.move_and_slide()
