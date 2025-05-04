extends BossState

@export var nav_agent: NavigationAgent3D
@export var boss: VampireBoss
@export var move_speed: float = 5.0
@export var rotation_speed: float = 10.0
@export var inner_stop_distance: float = 6.0
@export var outer_stop_distance: float = 7.0
@export var projectile_scene: PackedScene
@export var attack_cooldown: float = 3.0
@export_range(1, 10) var projectile_count: int = 3
@export_range(1, 10) var projectile_damage: int = 1
@export var projectile_speed: float = 10.0
@export var angle_between_projectiles: float = 15.0
@export var projectile_spawn_point: Marker3D

var player: Player
var time_since_last_attack: float = 0.0


func Enter() -> void:
	time_since_last_attack = 0
	if !player:
		player = self.get_tree().get_first_node_in_group("player")


func Update(delta: float):
	var direction_to_player: Vector3 = (player.global_position - boss.global_position).normalized()
	var distance_sqr_to_player = player.global_position.distance_squared_to(boss.global_position)
	if distance_sqr_to_player < inner_stop_distance * inner_stop_distance:
		nav_agent.target_position = boss.global_position - direction_to_player * 5
	elif distance_sqr_to_player > outer_stop_distance * outer_stop_distance:
		nav_agent.target_position = player.global_position

	if time_since_last_attack >= attack_cooldown:
		time_since_last_attack = 0
		fire_projectiles()

	time_since_last_attack += delta


func Physics_Update(delta: float) -> void:

	# Handle movement
	var distance_sqr_to_player = player.global_position.distance_squared_to(boss.global_position)
	if (inner_stop_distance * inner_stop_distance < distance_sqr_to_player &&
		outer_stop_distance * outer_stop_distance > distance_sqr_to_player):
		boss.velocity = Vector3.ZERO
	else:
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


func fire_projectiles() -> void:
	var total_cone_angle: float = (projectile_count - 1) * angle_between_projectiles
	var start_angle: float = -total_cone_angle / 2.0

	for i in range(projectile_count):
		var projectile: Projectile = projectile_scene.instantiate()
		projectile.set_meta("parryable", true)
		var current_angle: float = start_angle + i * angle_between_projectiles
		var direction: Vector3 = (player.global_position - boss.global_position).normalized()
		direction = direction.rotated(Vector3.UP, deg_to_rad(current_angle))
		projectile.direction = direction
		projectile.speed = projectile_speed
		projectile.damage = projectile_damage
		self.get_tree().root.add_child(projectile)
		projectile.global_position = projectile_spawn_point.global_position
