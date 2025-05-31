class_name EnemyWanderPath extends Node3D

var wonder_positions: Array[Marker3D] = []
var agent_to_position_index: Dictionary[EnemyBase, int] = {} 


func _ready() -> void:
	initialize_wonder_positions()


func register_agent(agent: EnemyBase) -> void:
	if len(wonder_positions) == 0:
		initialize_wonder_positions()
	var agent_position_index = len(agent_to_position_index)
	agent_to_position_index[agent] = agent_position_index % len(wonder_positions)


func initialize_wonder_positions() -> void:
	for child in get_children():
		if child is Marker3D:
			wonder_positions.append(child)


func get_next_wonder_position(agent: EnemyBase) -> Vector3:
	if len(wonder_positions) == 0:
		printerr("Wander area has no Marker3D's to determine wonder positions.")
		return Vector3.ZERO
	if !agent_to_position_index.has(agent):
		printerr("Agent was not found in dictionary. Did you ensure registration of the EnemyAI to the AIWanderArea?")
		return Vector3.ZERO

	var position_index = agent_to_position_index[agent]
	var next_position = wonder_positions[position_index].global_position
	if positions_are_equal_2d(agent.global_position, next_position):
		agent_to_position_index[agent] = (position_index + 1) % len(wonder_positions)
	return next_position


func positions_are_equal_2d(position1: Vector3, position2: Vector3) -> bool:
	return Vector3(position1.x, 0, position1.z).distance_squared_to(Vector3(position2.x, 0, position2.z)) <= 2
