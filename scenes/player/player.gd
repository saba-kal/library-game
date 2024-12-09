extends CharacterBody3D

@export_group("Movement Settings")
@export var move_speed:float = 5
@export var acceleration:float = 4
@export var decceleration:float = 5
@export var rotation_speed:float = 10

@onready var body: MeshInstance3D = $Body

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := transform.basis * Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, $CamRoot/SpringArm3D.rotation.y).normalized()
	var target_rotation = atan2(direction.x, direction.z) - rotation.y
	
	if direction:
		body.rotation.y = lerp_angle(body.rotation.y, target_rotation, rotation_speed * delta)
		velocity.x = lerp(velocity.x, direction.x * move_speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * move_speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, decceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, decceleration * delta)

	move_and_slide()
