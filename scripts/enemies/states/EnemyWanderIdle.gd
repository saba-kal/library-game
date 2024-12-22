extends State
class_name EnemyWanderIdle

@export var idle_anim_name:String = ""
@export var move_speed:float = 2.0
@export var rotation_speed:float = 10.0
@export var state_transition_upon_player_detection:String = "Follow"

var starting_position:Vector3 = Vector3.ZERO

func random_new_spot():
	nav_agent.target_position = Vector3(starting_position.x + randf_range(-5,5), 0,starting_position.z + randf_range(-5,5))

func Enter():
	print("Entering: Idle Wander State")
	anim_player.play(idle_anim_name)
	if starting_position == Vector3.ZERO:
		starting_position = enemy.global_position
	else:
		nav_agent.target_position = starting_position
		nav_agent.navigation_finished.connect(random_new_spot)
	if nav_agent.target_position == Vector3.ZERO:
		random_new_spot()
		nav_agent.navigation_finished.connect(random_new_spot)

func Exit():
	pass

func Update(_delta:float):
	pass

func Physics_Update(_delta:float):

	if player_target:
		nav_agent.target_position = Vector3.ZERO
		nav_agent.navigation_finished.disconnect(random_new_spot)
		Transitioned.emit(self,self.state_transition_upon_player_detection)
		player_target = null
	
	if enemy:
		await get_tree().physics_frame
		var destination = nav_agent.get_next_path_position()
		var local_destination = destination - enemy.global_position
		var move_direction = local_destination.normalized()
		Util.rotate_y_to_face_direction(enemy, move_direction, rotation_speed * _delta)
		enemy.velocity.x = move_direction.x * move_speed
		enemy.velocity.z = move_direction.z * move_speed
