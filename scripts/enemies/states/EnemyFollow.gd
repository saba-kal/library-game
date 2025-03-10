extends State
class_name EnemyFollow

@export var run_anim_name:String = ""
@export var move_speed:float = 2.0
@export var engage_range:float = 2.0
@export var rotation_speed:float = 10.0

func Enter():
	print("Entering: Follow State")
	anim_player.play(run_anim_name, 0.2)
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
		Util.rotate_y_to_face_direction(enemy, move_direction, rotation_speed * _delta)
		enemy.velocity.x = move_direction.x * move_speed
		enemy.velocity.z = move_direction.z * move_speed
		
		if player_target != null:
			if enemy.global_position.distance_to(player_target.global_position) < engage_range:
				Transitioned.emit(self,"meleeattack")
	else:
		nav_agent.target_position = Vector3.ZERO
		Transitioned.emit(self,"idle")
