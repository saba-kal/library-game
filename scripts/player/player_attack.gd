extends CharacterState

signal started

@export var player: Player

@export_group("Target States")
@export var movement_state: CharacterState
@export var next_attack: CharacterState
@export var parry_state: CharacterState

@export_group("Attack Details")
@export var damage: int = 1
@export var distance: float = .4
@export var wind_up_period: float = 0.3
@export var swing_duration: float = .4
@export var wind_down_period: float = .3
@export var sound_effect_name: String
@export var animation_node_name: String
@export var hit_particle_effect: PackedScene

@onready var hit_area: Area3D = $"../../LibrarianPlayer/LibrarianArmature/Skeleton3D/BoneAttachment3D/Umbrella/Area"
@onready var nearby_enemy_tracker: NearbyEnemyTracker = $"../../LibrarianPlayer/NearbyEnemyTracker"
@onready var movement_payback = animation_tree.get("parameters/Attack/playback")

var step_dir: Vector2
var last_dir: Vector2
var swing_timer: Timer
var wind_up_timer: Timer
var wind_down_timer: Timer
var queued_attack: bool
var hit_bodies: Dictionary
var can_damage: bool = false


func _ready() -> void:
	hit_area.body_entered.connect(on_body_entered)
	wind_up_timer = Timer.new()
	wind_up_timer.one_shot = true
	wind_up_timer.name = "wind up"
	wind_up_timer.timeout.connect(swing_start)
	add_child(wind_up_timer)
	swing_timer = Timer.new()
	swing_timer.one_shot = true
	swing_timer.name = "swing_timer"
	swing_timer.timeout.connect(swing_complete)
	add_child(swing_timer)
	wind_down_timer = Timer.new()
	wind_down_timer.one_shot = true
	wind_down_timer.name = "wind_down_timer"
	wind_down_timer.timeout.connect(done)
	add_child(wind_down_timer)


func handle_input(_event: InputEvent) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	last_dir = input_dir

	if _event.is_action_pressed("parry"):
		finished.emit(parry_state.get_path(), {'direction': last_dir})
	elif _event.is_action_pressed("attack"):
		var attack_dir := orient_player_towards_attack()
		last_dir = attack_dir
		if next_attack and wind_up_timer.time_left + swing_timer.time_left == 0 and wind_down_timer.time_left > 0:
			finished.emit(next_attack.get_path(), {'direction': attack_dir})
		else:
			queued_attack = true


func enter(_previous_state_path: String, data := {}) -> void:
	queued_attack = false
	orient_player_towards_attack()
	wind_up_timer.start(wind_up_period)
	animation_tree.set("parameters/Actions/transition_request", "Attack")
	movement_payback.travel(animation_node_name)


func exit() -> void:
	swing_timer.stop()
	wind_down_timer.stop()
	wind_up_timer.stop()


func swing_start() -> void:
	hit_bodies = {}
	can_damage = true
	initial_attack_area_check()
	player.constant_velocity(player.body.transform.basis.z, distance / swing_duration)
	swing_timer.start(swing_duration)
	AudioManager.play_3d(sound_effect_name, character.global_position)


func swing_complete() -> void:
	character.velocity *= 0.2
	wind_down_timer.start(wind_down_period)
	if queued_attack and next_attack:
		finished.emit(next_attack.get_path(), {'direction': last_dir})
	hit_bodies = {}
	can_damage = false


func done() -> void:
	finished.emit(movement_state.get_path())


func orient_player_towards_attack() -> Vector2:
	var attack_dir: Vector2 = Vector2(player.body.transform.basis.z.x, player.body.transform.basis.z.z)
	var closest_enemy: Node3D = null
	var min_distance_sqr: float = 100000
	for enemy: Node3D in nearby_enemy_tracker.get_living_enemies():
		var distance_sqr: float = enemy.global_position.distance_squared_to(player.global_position)
		if distance_sqr < min_distance_sqr:
			min_distance_sqr = distance_sqr
			closest_enemy = enemy

	if !closest_enemy:
		var input_dir := Input.get_vector("left", "right", "up", "down")
		if input_dir != Vector2.ZERO:
			player.set_orientation_from_top_down_vector(input_dir)
		else:
			player.face_global_direction(attack_dir)
		return attack_dir

	attack_dir = Util.get_2d_direction(player, closest_enemy)
	player.face_global_direction(attack_dir)
	return attack_dir


# This is needed when the attack area first activates.
# There may already be bodies in the area. So we want to make sure they are damaged.
func initial_attack_area_check() -> void:
	var bodies: Array[Node3D] = hit_area.get_overlapping_bodies()
	for body: Node3D in bodies:
		on_body_entered(body)


func on_body_entered(body: Node3D) -> void:
	if not (can_damage &&
		is_instance_valid(body) &&
		body.is_in_group("enemy") &&
		body.has_meta("damageable") &&
		!hit_bodies.has(body)):
			return

	var health: Health = Util.get_child_node_of_type(body, Health)
	if is_instance_valid(health) && health.current > 0:
		health.take_damage(damage, player)
		hit_bodies.get_or_add(body)
		AudioManager.play_3d("enemy_hit", character.global_position)
		var particle_effect: Node3D = hit_particle_effect.instantiate()
		get_tree().root.add_child(particle_effect)
		var direction: Vector3 = (body.global_position - player.global_position).normalized()
		particle_effect.global_position = body.global_position
		particle_effect.global_position.y += 1.5
		particle_effect.look_at(particle_effect.global_position + direction * 0.3)
		HitStopManager.frame_freeze(0.1, 0.2)