extends State

@export var run_anim_name: String = "Run"
@export var rotation_speed: float = 10.0
@export var move_speed: float = 3.0
@export var max_run_time: float = 10.0
@export var stop_distance: float = 6.0
@export var chase_distance: float = 10.0
@export var state_transition_upon_target_lost: String = "Wander"
@export var states_transition_upon_distance_reached: Array[String] = ["ProjectileAttack"]

var time_in_state: float = 0


func Enter() -> void:
	self.time_in_state = 0
	self.anim_player.play(run_anim_name, 0.2)


func Update(delta: float) -> void:
	self.time_in_state += delta
	if self.nav_agent && self.player_target:
		var direction_to_player: Vector3 = (self.player_target.global_position - self.enemy.global_position).normalized()
		var distance_sqr_to_player = self.player_target.global_position.distance_squared_to(self.enemy.global_position)
		if distance_sqr_to_player < chase_distance * chase_distance:
			self.nav_agent.target_position = self.enemy.global_position - direction_to_player * 5
		else:
			self.nav_agent.target_position = self.player_target.global_position


func Physics_Update(_delta: float) -> void:
	if self.player_target != null && self.time_in_state < self.max_run_time:
		var distance_sqr_to_player = self.player_target.global_position.distance_squared_to(self.enemy.global_position)
		if distance_sqr_to_player >= stop_distance * stop_distance:
			var rand_state: String = self.states_transition_upon_distance_reached.pick_random()
			Transitioned.emit(self, rand_state)
		else:
			await get_tree().physics_frame
			var destination = nav_agent.get_next_path_position()
			var local_destination = destination - enemy.global_position
			var move_direction = local_destination.normalized()
			Util.rotate_y_to_face_direction(enemy, move_direction, rotation_speed * _delta)
			enemy.velocity.x = move_direction.x * move_speed
			enemy.velocity.z = move_direction.z * move_speed
	else:
		nav_agent.target_position = Vector3.ZERO
		Transitioned.emit(self, self.state_transition_upon_target_lost)
