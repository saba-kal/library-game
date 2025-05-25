extends BossState

@export var nav_agent: NavigationAgent3D
@export var boss: VampireBoss
@export var move_speed: float = 5.0
@export var rotation_speed: float = 10.0
@export var stop_distance: float = 3.0
@export var animation_tree: AnimationTree

var player: Player


func Enter() -> void:
	if !player:
		player = self.get_tree().get_first_node_in_group("player")
	animation_tree.set("parameters/vampire_state/transition_request", "move")


func Update(delta: float):
	var direction_to_player: Vector3 = (player.global_position - boss.global_position).normalized()
	nav_agent.target_position = player.global_position


func Physics_Update(delta: float) -> void:

	# When the boss gets close to player, change to attack state.
	var distance_sqr_to_player = player.global_position.distance_squared_to(boss.global_position)
	if distance_sqr_to_player < stop_distance:
		boss.velocity = Vector3.ZERO
		boss.change_state("Melee")
		return

	# Handle movement
	var destination = nav_agent.get_next_path_position()
	var local_destination = destination - boss.global_position
	var move_direction = local_destination.normalized()
	boss.velocity.x = move_direction.x * move_speed
	boss.velocity.z = move_direction.z * move_speed
	boss.move_and_slide()

	# Handle rotation
	var direction_to_player: Vector3 = (player.global_position - boss.global_position).normalized()
	Util.rotate_y_to_face_direction(
		boss,
		-direction_to_player,
		rotation_speed * delta)
