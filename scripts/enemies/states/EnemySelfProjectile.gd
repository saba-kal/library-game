extends State

@export var speed: float = 7.0
@export var damage: int = 1
@export var time_until_attack_start:float = 1.0
@export var rotation_speed:float = 10.0
@export var stop_distance:float = 7.0
@export var teleport_distance:float = 5.0
@export var attack_anim_name:String = "Run"
@export var fade_anim_name:String = "FadeOut"
@export var state_transition_upon_target_missed: String = "Idle"
@export var projectile_area:Area3D
@export var fade_anim_player:AnimationPlayer

var player: Player
var end_position: Vector3
var attack_started: bool = false
var target_was_hit: bool = false


func Enter() -> void:
	if !self.player:
		self.player = get_tree().get_first_node_in_group("player")
	self.anim_player.play(self.attack_anim_name)
	self.enemy.is_disabled = true
	self.disable_collision()
	self.projectile_area.body_entered.connect(self.on_nody_entered)
	# First attack delay is shorter because there is no fade in anim
	self.start_projectile_attack(self.time_until_attack_start / 2.0)


func Update(_delta:float) -> void:
	pass


func Physics_Update(delta:float) -> void:

	var direction: Vector3 = (self.end_position - self.enemy.global_position).normalized()
	if !self.attack_started:
		Util.rotate_y_to_face_direction(enemy, direction, rotation_speed * delta)
		return

	Util.rotate_y_to_face_direction(enemy, direction, rotation_speed * delta)
	self.enemy.global_position = self.enemy.global_position.move_toward(self.end_position, delta * speed)
	if self.enemy.global_position.is_equal_approx(self.end_position):
		if self.target_was_hit:
			self.teleport_to_random_location()
			self.fade_in()
			self.start_projectile_attack(self.time_until_attack_start)
			self.target_was_hit = false
		else:
			self.enemy.disengage()
			Transitioned.emit(self, self.state_transition_upon_target_missed)


func Exit() -> void:
	self.enemy.is_disabled = false
	self.projectile_area.body_entered.disconnect(self.on_nody_entered)
	self.enable_collision()


func start_projectile_attack(delay: float) -> void:
	self.attack_started = false
	self.calculate_end_position()
	await get_tree().create_timer(delay).timeout
	self.attack_started = true


func calculate_end_position() -> void:
	self.end_position = self.player.global_position
	# Remove height element for ending position so that the enemy does not accidentally go through the ground.
	self.end_position.y = self.enemy.global_position.y
	# Add a bit of distance so that the enemy stops a bit further to the other side of the player.
	var direction: Vector3 = (self.end_position - self.enemy.global_position).normalized()
	self.end_position += direction * self.stop_distance


func teleport_to_random_location() -> void:
	var random_vector_2d = Util.get_random_point_on_circle(self.teleport_distance)
	self.enemy.global_position = Vector3(
		self.player.global_position.x + random_vector_2d.x,
		self.enemy.global_position.y,
		self.player.global_position.z+ random_vector_2d.y
	)

func disable_collision() -> void:
	if self.collision_shape:
		self.collision_shape.disabled = true


func enable_collision() -> void:
	if self.collision_shape:
		self.collision_shape.disabled = false


func on_nody_entered(node: Node3D) -> void:
	if node is Player:
		node.take_damage(self.damage)
		self.fade_out()
		self.target_was_hit = true


func fade_in() -> void:
	if self.fade_anim_player:
		self.fade_anim_player.play_backwards("FadeOut")


func fade_out() -> void:
	if self.fade_anim_player:
		self.fade_anim_player.play("FadeOut")
