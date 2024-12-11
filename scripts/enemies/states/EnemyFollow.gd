extends State
class_name EnemyFollow

@export var move_speed:float = 2.0
@export var engage_range:float = 2.0
@export var rotation_speed:float = 10.0

func Enter():
	pass

func Exit():
	pass

func Update(_delta: float):
	if nav_agent:
		if player_target:
			nav_agent.target_position = player_target.global_position

func Physics_Update(_delta: float):
	if player_target != null:
		await get_tree().physics_frame
		var destination = nav_agent.get_next_path_position()
		var local_destination = destination - enemy.global_position
		var move_direction = local_destination.normalized()
		var target_rotation = atan2(move_direction.x, move_direction.z) - enemy.rotation.y
		
		mesh.rotation.y = lerp_angle(mesh.rotation.y, target_rotation, rotation_speed * _delta)
		enemy.velocity = move_direction * move_speed
		
		if player_target != null:
			if enemy.global_position.distance_to(player_target.global_position) < engage_range:
				print("ATTACK")
	else:
		Transitioned.emit(self,"idle")
