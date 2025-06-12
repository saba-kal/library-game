extends State

@export var speed: float = 7.0
@export var damage: int = 1
@export var pre_attack_delay: float = 1.0
@export var post_attack_delay: float = 1.0
@export var rotation_speed: float = 10.0
@export var stop_distance: float = 7.0
@export var fade_out_distance: float = 7.0
@export var attack_anim_name: String = "Run"
@export var idle_anim_name: String = "Idle"
@export var fade_anim_name: String = "FadeOut"
@export var state_transition_upon_finish: String = "Idle"
@export var sound_name: String
@export var attached_sound_to_stop: AttachedSound3D
@export var projectile_area: Area3D
@export var fade_anim_player: AnimationPlayer

var player: Player
var end_position: Vector3
var return_position: Vector3
var attack_started: bool = false
var can_damage: bool = false
var fade_out_started: bool = false
var end_position_reached: bool = false
var pre_attack_timer: Timer
var post_attack_timer: Timer


func Init() -> void:
	player = get_tree().get_first_node_in_group("player")
	projectile_area.body_entered.connect(on_nody_entered)

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
	return_position = enemy.global_position
	attack_started = false
	end_position_reached = false
	fade_out_started = false
	can_damage = false
	anim_player.play(attack_anim_name)
	AudioManager.play_3d(sound_name, enemy.global_position)
	if attached_sound_to_stop:
		attached_sound_to_stop.stop()
	nav_agent.is_disabled = true
	pre_attack_timer.start()


func Physics_Update(delta: float) -> void:
	if end_position_reached:
		return

	var direction: Vector3 = (end_position - enemy.global_position).normalized()
	if !attack_started:
		direction = (player.global_position - enemy.global_position).normalized()
		Util.rotate_y_to_face_direction(enemy, direction, rotation_speed * delta)
		return

	Util.rotate_y_to_face_direction(enemy, direction, rotation_speed * delta)

	if !fade_out_started:
		var distance_sqr_to_target: float = enemy.global_position.distance_squared_to(end_position)
		if distance_sqr_to_target <= fade_out_distance * fade_out_distance:
			fade_out()
			can_damage = false

	enemy.global_position = enemy.global_position.move_toward(end_position, delta * speed)
	if enemy.global_position.is_equal_approx(end_position):
		end_position_reached = true
		enemy.global_position = return_position
		fade_in()
		anim_player.play(idle_anim_name)
		post_attack_timer.start()


func Exit() -> void:
	enable_collision()
	reset_fade()
	pre_attack_timer.stop()
	post_attack_timer.stop()
	nav_agent.is_disabled = false
	can_damage = false
	attack_started = false
	end_position_reached = false
	fade_out_started = false
	if attached_sound_to_stop:
		attached_sound_to_stop.play()


func on_pre_attack_timer_finished() -> void:
	calculate_end_position()
	attack_started = true
	can_damage = true


func on_post_attack_timer_finished() -> void:
	enemy.disengage()
	Transitioned.emit(self, state_transition_upon_finish)


func calculate_end_position() -> void:
	end_position = player.global_position
	# Remove height element for ending position so that the enemy does not accidentally go through the ground.
	end_position.y = enemy.global_position.y
	# Add a bit of distance so that the enemy stops a bit further to the other side of the player.
	var direction: Vector3 = (end_position - enemy.global_position).normalized()
	end_position += direction * stop_distance


func disable_collision() -> void:
	if collision_shape:
		collision_shape.disabled = true


func enable_collision() -> void:
	if collision_shape:
		collision_shape.disabled = false


func on_nody_entered(node: Node3D) -> void:
	if can_damage && node is Player:
		node.take_damage(damage)


func fade_in() -> void:
	if fade_anim_player:
		fade_anim_player.play_backwards("FadeOut")


func fade_out() -> void:
	fade_out_started = true
	if fade_anim_player:
		fade_anim_player.play("FadeOut")


func reset_fade() -> void:
	if fade_anim_player:
		fade_anim_player.play("RESET")
