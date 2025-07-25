extends Node


func get_child_node_of_type(node: Node, type: Variant) -> Node:
	for child in node.get_children():
		if is_instance_of(child, type):
			return child
	return null


func get_child_nodes_of_type(node: Node3D, type: Variant) -> Array:
	var nodes: Array[Variant] = []
	for child in node.get_children():
		if is_instance_of(child, type):
			nodes.append(child)
	return nodes


func remove_elem(array: Array, elem: Variant) -> bool:
	var index: int = array.find(elem)
	if index >= 0:
		array.remove_at(index)
	return index >= 0


func rotate_y_to_face_direction(node: Node3D, direction: Vector3, delta: float) -> void:
	var target_rotation = atan2(direction.x, direction.z)
	node.global_rotation.y = lerp_angle(node.global_rotation.y, target_rotation, delta)


func get_random_point_on_circle(radius: float) -> Vector2:
	var angle: float = randf_range(0, 2 * PI)
	var x: float = radius * cos(angle)
	var y: float = radius * sin(angle)
	return Vector2(x, y)

# Returns a normalized Vector2 representing the XZ direction from `source` to `target`.
func get_2d_direction(source: Node3D, target: Node3D) -> Vector2:
	var source_pos := source.global_position
	var target_pos := target.global_position

	# Compute direction in XZ plane (ignore Y-axis)
	var direction_3d := Vector3(target_pos.x - source_pos.x, 0, target_pos.z - source_pos.z)

	# Convert to Vector2 (X and Z) and normalize
	return Vector2(direction_3d.x, direction_3d.z).normalized()

func print_stack_trace():
	var stack = get_stack()
	print("--- Stack Trace Begin ---")
	for i in range(stack.size()):
		print("%d: %s (%s:%d)" % [
			i,
			stack[i]["function"],
			stack[i]["source"],
			stack[i]["line"]
		])
	print("--- Stack Trace End ---")