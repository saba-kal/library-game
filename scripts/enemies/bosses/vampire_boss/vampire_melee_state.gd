extends BossState

@export var attack_damage: int = 1
@export var charge_distance: float = 5.0
@export var charge_speed: float = 10.0
@export var rotation_speed: float = 20.0
@export var motion_curve: Curve
@export var attack_area: Area3D
@export var boss: VampireBoss
@export var animation_tree: AnimationTree

@onready var pre_attack_timer: Timer = $PreAttackDelayTimer
@onready var wind_up_timer: Timer = $WindUpDelayTimer
@onready var attack_completed_timer: Timer = $AttackCompletedTimer
@onready var post_attack_timer: Timer = $PostAttackDelayTimer

var can_damage: bool = false
var player: Player
var time_since_start_start: float = 0
var total_attack_time: float
var attack_start_position: Vector3
var attack_end_position: Vector3


func _ready() -> void:
	attack_area.body_entered.connect(on_attack_area_body_entered)
	total_attack_time = pre_attack_timer.wait_time + wind_up_timer.wait_time + attack_completed_timer.wait_time


func Enter() -> void:
	if !player:
		player = self.get_tree().get_first_node_in_group("player")

	var direction: Vector3 = (player.global_position - boss.global_position).normalized()
	attack_start_position = boss.global_position
	attack_end_position = boss.global_position + direction * charge_distance
	time_since_start_start = 0
	boss.show_attack_indicator()

	pre_attack_timer.start()
	await pre_attack_timer.timeout
	on_pre_attack_timer_complete()

	wind_up_timer.start()
	await wind_up_timer.timeout
	on_wind_up_timer_complete()

	attack_completed_timer.start()
	await attack_completed_timer.timeout
	on_attack_completed_timer_complete()

	post_attack_timer.start()
	await post_attack_timer.timeout
	on_post_attack_timer_complete()
	

func Physics_Update(delta: float):
	var attack_progress: float = time_since_start_start / total_attack_time
	if attack_progress > 1.0:
		return # Charge motion is complete.

	var motion_curve_val: float = motion_curve.sample_baked(attack_progress)
	var target_position: Vector3 = lerp(attack_start_position, attack_end_position, motion_curve_val)
	var direction = boss.global_position.direction_to(target_position)
	boss.velocity = direction * charge_speed
	boss.move_and_slide()

	var rotation_direction: Vector3 = - attack_start_position.direction_to(attack_end_position)
	Util.rotate_y_to_face_direction(
		boss,
		rotation_direction,
		rotation_speed * delta)
	time_since_start_start += delta


func Exit() -> void:
	can_damage = false
	pre_attack_timer.stop()
	wind_up_timer.stop()
	post_attack_timer.stop()
	animation_tree.set("parameters/melee_attack_shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	boss.reset_attack_indicator()


func on_pre_attack_timer_complete() -> void:
	animation_tree.set("parameters/melee_attack_shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func on_wind_up_timer_complete() -> void:
	can_damage = true
	initial_attack_area_check()
	AudioManager.play_3d("boss_melee_attack", boss.global_position)


func on_attack_completed_timer_complete() -> void:
	can_damage = false


func on_post_attack_timer_complete() -> void:
	if boss.phase >= 3: # In the third phase, boss alternates between chasing/melee and firing projectiles/
		boss.change_state("Projectile")
	else:
		boss.change_state("Chase")


# This is needed when the attack area first activates.
# There may already be bodies in the area. So we want to make sure they are damaged.
func initial_attack_area_check() -> void:
	var bodies: Array[Node3D] = attack_area.get_overlapping_bodies()
	for body: Node3D in bodies:
		on_attack_area_body_entered(body)


func on_attack_area_body_entered(body: Node3D):
	if body is Player && can_damage:
		player.take_damage(attack_damage)