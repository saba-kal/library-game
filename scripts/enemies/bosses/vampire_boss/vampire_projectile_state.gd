extends BossState

@export var nav_agent: CharacterNavAgent
@export var boss: VampireBoss
@export var move_speed: float = 5.0
@export var rotation_speed: float = 10.0
@export var inner_stop_distance: float = 6.0
@export var outer_stop_distance: float = 7.0
@export var projectile_scene: PackedScene
@export var attack_delay: float = 1.0
@export var attack_cooldown: float = 3.0
@export_range(1, 10) var projectile_count: int = 3
@export_range(1, 10) var projectile_damage: int = 1
@export var projectile_speed: float = 10.0
@export var angle_between_projectiles: float = 15.0
@export var projectile_spawn_point: Marker3D
@export var animation_tree: AnimationTree

var player: Player
var time_since_last_attack: float = 0.0


func Enter() -> void:
	time_since_last_attack = 0
	if !player:
		player = self.get_tree().get_first_node_in_group("player")
	animation_tree.set("parameters/vampire_state/transition_request", "move")
	nav_agent.movement_speed = move_speed
	nav_agent.is_disabled = false


func Update(delta: float):
	var direction_to_player: Vector3 = (player.global_position - boss.global_position).normalized()
	var distance_sqr_to_player = player.global_position.distance_squared_to(boss.global_position)
	if distance_sqr_to_player < inner_stop_distance * inner_stop_distance:
		nav_agent.set_movement_target(boss.global_position - direction_to_player * 5)
	elif distance_sqr_to_player > outer_stop_distance * outer_stop_distance:
		nav_agent.set_movement_target(player.global_position)

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

	# Handle rotation
	var direction_to_player: Vector3 = (player.global_position - boss.global_position).normalized()
	Util.rotate_y_to_face_direction(
		boss,
		-direction_to_player,
		rotation_speed * delta)


func fire_projectiles() -> void:

	animation_tree.set("parameters/ranged_attack_shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	await get_tree().create_timer(attack_delay).timeout
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
