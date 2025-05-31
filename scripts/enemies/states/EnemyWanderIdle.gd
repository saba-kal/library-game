extends State
class_name EnemyWanderIdle

@export var idle_anim_name:String = ""
@export var move_speed:float = 2.0
@export var rotation_speed:float = 20.0
@export var state_transition_upon_player_detection:String = "Follow"
@export var attached_sound:AttachedSound3D

var starting_position:Vector3 = Vector3.ZERO
var wander_path: EnemyWanderPath

func Init() -> void:
	var parent = enemy.get_parent()
	if parent is EnemyWanderPath:
		wander_path = parent
		wander_path.register_agent(enemy)

func random_new_spot():
	nav_agent.set_movement_target(Vector3(starting_position.x + randf_range(-5,5), 0,starting_position.z + randf_range(-5,5)))

func Enter():
	print("Entering: Idle Wander State")
	nav_agent.movement_speed = move_speed
	anim_player.play(idle_anim_name)
	nav_agent.is_disabled = false

	# Wander following a predetermined path.
	if wander_path:
		var target_pos: Vector3 = wander_path.get_next_wonder_position(enemy)
		nav_agent.set_movement_target(target_pos)

	# Wander towards random direction.
	else: 
		if starting_position == Vector3.ZERO:
			starting_position = enemy.global_position
		else:
			nav_agent.set_movement_target(starting_position)
			nav_agent.navigation_finished.connect(random_new_spot)
		if nav_agent.target_position == Vector3.ZERO:
			random_new_spot()
			nav_agent.navigation_finished.connect(random_new_spot)

	if attached_sound:
		attached_sound.play()

func Exit():
	if nav_agent.navigation_finished.is_connected(random_new_spot):
		nav_agent.navigation_finished.disconnect(random_new_spot)
	if self.attached_sound:
		self.attached_sound.stop()

func Update(_delta:float):
	pass

func Physics_Update(_delta:float):

	if player_target:
		nav_agent.set_movement_target(enemy.global_position)
		if nav_agent.navigation_finished.is_connected(random_new_spot):
			nav_agent.navigation_finished.disconnect(random_new_spot)
		Transitioned.emit(self,self.state_transition_upon_player_detection)
		player_target = null

	elif wander_path:
		var target_pos: Vector3 = wander_path.get_next_wonder_position(enemy)
		nav_agent.set_movement_target(target_pos)

	if enemy:
		var destination = nav_agent.get_next_path_position()
		var local_destination = destination - enemy.global_position
		var move_direction = local_destination.normalized()
		Util.rotate_y_to_face_direction(enemy, move_direction, rotation_speed * _delta)
