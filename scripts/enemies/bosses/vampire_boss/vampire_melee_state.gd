extends BossState

@export var attack_damage: int = 1
@export var attack_area: Area3D
@export var boss: VampireBoss
@export var animation_tree: AnimationTree

@onready var pre_attack_timer: Timer = $PreAttackDelayTimer
@onready var post_attack_timer: Timer = $PostAttackDelayTimer

var is_player_in_attack_area: bool = false
var player: Player
var time_since_start_start: float = 0


func _ready() -> void:
	attack_area.body_entered.connect(on_attack_area_body_entered)
	attack_area.body_exited.connect(on_attack_area_body_exited)
	pre_attack_timer.timeout.connect(on_pre_attack_timer_complete)
	post_attack_timer.timeout.connect(on_post_attack_timer_complete)


func Enter() -> void:
	if !player:
		player = self.get_tree().get_first_node_in_group("player")
	animation_tree.set("parameters/melee_attack_shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	pre_attack_timer.start()


func Exit() -> void:
	pre_attack_timer.stop()
	post_attack_timer.stop()


func on_attack_area_body_entered(body: Node3D):
	if body is Player:
		is_player_in_attack_area = true


func on_attack_area_body_exited(body: Node3D):
	if body is Player:
		is_player_in_attack_area = false


func on_pre_attack_timer_complete() -> void:
	if is_player_in_attack_area:
		player.take_damage(attack_damage)
	post_attack_timer.start()


func on_post_attack_timer_complete() -> void:
	boss.change_state("Chase")
