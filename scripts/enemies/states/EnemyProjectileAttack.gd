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
var pre_attack_timer: Timer
var post_attack_timer: Timer


func Init() -> void:
	player = get_tree().get_first_node_in_group("player")

	pre_attack_timer = Timer.new()
	pre_attack_timer.wait_time = pre_attack_delay
	pre_attack_timer.one_shot = true
	add_child(pre_attack_timer)
	pre_attack_timer.timeout.connect(on_pre_attack_timer_finished)

	post_attack_timer = Timer.new()
	post_attack_timer.wait_time = post_attack_delay
	post_attack_timer.one_shot = true
	add_child(post_attack_timer)
	post_attack_timer.timeout.connect(on_post_attack_timer_finished)


func Enter() -> void:
	self.nav_agent.is_disabled = true
	self.enemy.velocity = Vector3.ZERO
	self.anim_player.play(anime_name)
	pre_attack_timer.start()


func Physics_Update(delta: float) -> void:
	var direction: Vector3 = (self.player.global_position - self.enemy.global_position).normalized()
	Util.rotate_y_to_face_direction(enemy, direction, rotation_speed * delta)


func Exit() -> void:
	self.nav_agent.is_disabled = false
	pre_attack_timer.stop()
	post_attack_timer.stop()


func on_pre_attack_timer_finished() -> void:
	var projectile: Projectile = self.projectile_scene.instantiate()
	projectile.set_meta("parryable", true)
	var direction: Vector3 = (self.player.global_position - self.enemy.global_position).normalized()
	projectile.direction = direction
	projectile.speed = self.projectile_speed
	projectile.damage = self.projectile_damage
	self.get_tree().root.add_child(projectile)
	projectile.global_position = self.projectile_spawn_point.global_position
	post_attack_timer.start()


func on_post_attack_timer_finished() -> void:
	Transitioned.emit(self, self.state_transition_upon_finish)
	self.enemy.disengage()
