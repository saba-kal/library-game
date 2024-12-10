extends State
class_name EnemyWanderIdle

@export var enemy:CharacterBody3D = null
@export var mesh:MeshInstance3D = null
@export var nav_agent:NavigationAgent3D = null
@export var move_speed:float = 2.0
@export var rotation_speed:float = 10.0

var starting_position:Vector3

func random_new_spot():
	nav_agent.target_position = Vector3(starting_position.x + randf_range(-5,5), 0,starting_position.z + randf_range(-5,5))
	
func Enter():
	starting_position = enemy.global_position
	nav_agent.navigation_finished.connect(random_new_spot)
	if !nav_agent.target_position:
		random_new_spot()

func Exit():
	pass

func Update(_delta:float):
	pass

func Physics_Update(_delta:float):
	if player_target:
		nav_agent.target_position = Vector3.ZERO
		nav_agent.navigation_finished.disconnect(random_new_spot)
		Transitioned.emit(self,"Follow")
		player_target = null
		Exit()
	if enemy:
		await get_tree().physics_frame
		var destination = nav_agent.get_next_path_position()
		var local_destination = destination - enemy.global_position
		var move_direction = local_destination.normalized()
		var target_rotation = atan2(move_direction.x, move_direction.z) - enemy.rotation.y
		mesh.rotation.y = lerp_angle(mesh.rotation.y, target_rotation, rotation_speed * _delta)
		enemy.velocity = move_direction * move_speed
