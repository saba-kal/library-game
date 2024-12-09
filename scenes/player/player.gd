extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var body: MeshInstance3D = $Body


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	print(input_dir)
	var direction := transform.basis * Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, $CamRoot/SpringArm3D.rotation.y).normalized()
	var target_rotation = atan2(direction.x, direction.z) - rotation.y
	if direction:
		body.rotation.y = lerp_angle(body.rotation.y, target_rotation, 20 * delta)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
