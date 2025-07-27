extends Node3D

@export var rotationSpeed:float = 40.0

@onready var springArm: SpringArm3D = $SpringArm3D

func _process(delta: float) -> void:
	# Uncomment if you want camera rotation.
	#if Input.is_action_pressed("cam_left"):
		#springArm.rotation_degrees.y += rotationSpeed * delta
	#if Input.is_action_pressed("cam_right"):
		#springArm.rotation_degrees.y -= rotationSpeed * delta
	pass
