extends Node3D

@export var rotation_speed: float = 12.0
@export var rotation_axis: Vector3 = Vector3(0, 0, 1)
@export var child_node_to_rotate: Node3D


func _physics_process(delta: float) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera:
		look_at(camera.global_position, Vector3.UP, true)
	if child_node_to_rotate:
		child_node_to_rotate.rotate(rotation_axis, rotation_speed * delta)