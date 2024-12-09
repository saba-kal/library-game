extends Node3D

@export var rotationSpeed:int = 40.0

@onready var springArm: SpringArm3D = $SpringArm3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("cam_left"):
		springArm.rotation_degrees.y += rotationSpeed * delta
	if Input.is_action_pressed("cam_right"):
		springArm.rotation_degrees.y -= rotationSpeed * delta
