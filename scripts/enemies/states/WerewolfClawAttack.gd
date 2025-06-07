extends State

@export var wind_up_animation: String
@export var attack_animation: String
@export var attached_sound: AttachedSound3D
@export var damage: int
@export var attack_parts: PackedByteArray
@export var chase_state: String

@export_group("Attacking parts")
@export var left_claw: Area3D
@export var right_claw: Area3D
@export var jaw: Area3D

@export_group("Timing")
@export var wind_up: float
@export var wind_down: float
@export var timings: PackedFloat32Array
@export var jump_timing: float

@onready var attack_timer: Timer = $AttackTimer
@onready var jump_timer = $JumpTimer
@onready var end_timer = $EndTimer

var attack_counter: int

func _ready() -> void:
	attack_timer.timeout.connect(attack)
	jump_timer.timeout.connect(jump)
	end_timer.timeout.connect(end)

func Enter():
	nav_agent.is_disabled = true
	anim_player.play(wind_up_animation)
	left_claw.monitoring = false
	right_claw.monitoring = false
	jaw.monitoring = false
	attack_counter = 0
	attack_timer.start(wind_up)
	jump_timer.start(jump_timing)
	attached_sound.play()

func Exit():
	nav_agent.is_disabled = false
	left_claw.monitoring = true
	right_claw.monitoring = true
	jaw.monitoring = true
	attack_timer.stop()
	jump_timer.stop()
	end_timer.stop()
	if self.attached_sound:
		self.attached_sound.stop()

func Update(_delta: float) -> void:
	if left_claw.monitoring:
		hit_bodies(left_claw)
	if right_claw.monitoring:
		hit_bodies(right_claw)
	if jaw.monitoring:
		hit_bodies(jaw)
	if (enemy.is_on_floor()):
		enemy.velocity = Vector3.ZERO

func hit_bodies(area: Area3D) -> void:
	for body in area.get_overlapping_bodies():
		if body.is_in_group("player"):
			var health: Health = Util.get_child_node_of_type(body, Health)
			if health != null:
				health.take_damage(damage)
				area.monitoring = false

func attack():
	if attack_counter == 0:
		anim_player.play(attack_animation)
	left_claw.monitoring = attack_parts[attack_counter] % 2 == 1
	right_claw.monitoring = attack_parts[attack_counter] % 4 > 1
	jaw.monitoring = attack_parts[attack_counter] > 3

	if attack_counter < timings.size():
		attack_timer.start(timings[attack_counter])
		attack_counter += 1
	else:
		if (end_timer.is_stopped()):
			end_timer.start(wind_down)

func jump():
	enemy.velocity = Vector3(0, 0, 5).rotated(Vector3(0, 1, 0), enemy.rotation.y)
	enemy.velocity += Vector3(0, 2, 0)

func angle_to_player() -> float:
	if player_target == null:
		return 0
	var v3: Vector3 = player_target.global_position - enemy.global_position
	return v3.angle_to(Vector3(1, 0, 0))

func end():
	Transitioned.emit(self, chase_state)
