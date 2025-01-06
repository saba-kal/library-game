extends State

@export var pre_attack_delay: float = 1.0
@export var post_attack_delay: float = 1.0
@export var rotation_speed: float = 10.0
@export var projectile_speed: float = 10.0
@export var projectile_damage: int = 1
@export var projectile_scene: PackedScene
@export var anime_name: String = "Attack"
@export var state_transition_upon_finish: String = "Wander"
@export var projectile_spawn_point: Marker3D

var player: Player


func Enter() -> void:
	if !self.player:
		self.player = get_tree().get_first_node_in_group("player")

	self.nav_agent.target_position = self.enemy.global_position
	self.enemy.velocity = Vector3.ZERO
	self.anim_player.play(anime_name)

	await get_tree().create_timer(pre_attack_delay).timeout
	var projectile: Projectile = self.projectile_scene.instantiate()
	projectile.set_meta("parryable", true)
	var direction: Vector3 = (self.player.global_position - self.enemy.global_position).normalized()
	projectile.direction = direction
	projectile.speed = self.projectile_speed
	projectile.damage = self.projectile_damage
	self.get_tree().root.add_child(projectile)
	projectile.global_position = self.projectile_spawn_point.global_position

	await get_tree().create_timer(post_attack_delay).timeout
	Transitioned.emit(self, self.state_transition_upon_finish)
	self.enemy.disengage()



func Physics_Update(delta:float) -> void:
	var direction: Vector3 = (self.player.global_position - self.enemy.global_position).normalized()
	Util.rotate_y_to_face_direction(enemy, direction, rotation_speed * delta)
