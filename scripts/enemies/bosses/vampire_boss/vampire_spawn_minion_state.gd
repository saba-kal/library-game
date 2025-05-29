extends BossState

@export var nav_agent: CharacterNavAgent
@export var boss: VampireBoss
@export var move_speed: float = 5.0
@export var rotation_speed: float = 10.0
@export var minion_scene: PackedScene
@export var animation_tree: AnimationTree

@onready var pre_spawn_timer: Timer = $PreSpawnDelayTimer
@onready var post_spawn_timer: Timer = $PostSpawnDelayTimer

var player: Player
var spawn_in_progress: bool = false
var spawned_minions: Array[EnemyBase] = []


func _ready() -> void:
	boss.death.connect(on_boss_death)


func Enter() -> void:
	spawn_in_progress = false
	if !player:
		player = self.get_tree().get_first_node_in_group("player")
	nav_agent.is_disabled = false
	nav_agent.movement_speed = move_speed


func Update(delta: float):
	nav_agent.set_movement_target(boss.room_center_marker.global_position)


func Physics_Update(delta: float) -> void:

	var distance_to_target: float = nav_agent.distance_to_target()
	if distance_to_target < 1  && !spawn_in_progress:
		spawn_minions()
	elif distance_to_target < 1:
		return

	# Handle rotation
	var direction_to_player: Vector3 = (player.global_position - boss.global_position).normalized()
	Util.rotate_y_to_face_direction(
		boss,
		-direction_to_player,
		rotation_speed * delta)


func Exit() -> void:
	pre_spawn_timer.stop()
	post_spawn_timer.stop()


func spawn_minions() -> void:
	spawn_in_progress = true
	animation_tree.set("parameters/vampire_state/transition_request", "stand")
	pre_spawn_timer.start()
	await pre_spawn_timer.timeout
	for spawn_marker: Marker3D in boss.phase_2_minion_positions:
		var minion: EnemyBase = minion_scene.instantiate()
		boss.get_parent().add_child(minion)
		minion.global_position = spawn_marker.global_position
		spawned_minions.append(minion)
	post_spawn_timer.start()
	await post_spawn_timer.timeout
	if boss.phase <= 2:
		boss.change_state("Chase")
	elif boss.phase == 3:
		boss.change_state("Projectile")


func on_boss_death() -> void:
	for minion in spawned_minions:
		if is_instance_valid(minion):
			minion.kill()
	spawned_minions = []
