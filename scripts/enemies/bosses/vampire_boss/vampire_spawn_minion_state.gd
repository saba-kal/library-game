extends BossState

@export var nav_agent: NavigationAgent3D
@export var boss: VampireBoss
@export var move_speed: float = 5.0
@export var rotation_speed: float = 10.0
@export var pre_spawn_delay: float = 2.0
@export var post_spawn_delay: float = 2.0
@export var minion_scene: PackedScene
@export var animation_tree: AnimationTree

var player: Player
var spawn_in_progress: bool = false


func Enter() -> void:
	spawn_in_progress = false
	if !player:
		player = self.get_tree().get_first_node_in_group("player")


func Update(delta: float):
	nav_agent.target_position = boss.room_center_marker.global_position


func Physics_Update(delta: float) -> void:

	var distance_to_target: float = nav_agent.distance_to_target()
	if distance_to_target < 0.2  && !spawn_in_progress:
		spawn_minions()
	elif distance_to_target < 0.2:
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


func spawn_minions() -> void:
	spawn_in_progress = true
	animation_tree.set("parameters/vampire_state/transition_request", "stand")
	await get_tree().create_timer(pre_spawn_delay).timeout
	for spawn_marker: Marker3D in boss.phase_2_minion_positions:
		var minion: Node3D = minion_scene.instantiate()
		boss.get_parent().add_child(minion)
		minion.global_position = spawn_marker.global_position
	await get_tree().create_timer(post_spawn_delay).timeout
	boss.change_state("Projectile")
