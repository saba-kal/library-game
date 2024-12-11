extends State
class_name EnemyMeleeAttack

@export var attack_size:PackedScene = null
var attack_instance:Area3D
var time_before_attack_hits:float = 1
var player_in_range:bool = false

func Enter():
	print("Entering: Melee Attack State")
	nav_agent.target_position = enemy.global_position
	spawn_area_attack()

func spawn_area_attack():
	attack_instance = attack_size.instantiate()
	mesh.add_child(attack_instance)
	attack_instance.body_entered.connect(player_in_area_range)
	attack_instance.body_exited.connect(player_outside_range)
	attack_instance.update_attack_size(4, 3)
	await get_tree().create_timer(time_before_attack_hits).timeout
	perform_attack()

func player_in_area_range(body:Node3D):
	if body.is_in_group("player"):
		player_in_range = true

func player_outside_range(body:Node3D):
	if body.is_in_group("player"):
		player_in_range = false

func perform_attack():
	if player_in_range:
		print("PLAYER DAMAGED.")
	else:
		print("Player wasn't in range of attack area.")
	attack_instance.queue_free()
	Transitioned.emit(self,"follow")

func Exit():
	pass

func Update(_delta: float):
	pass

func Physics_Update(_delta: float):
	enemy.velocity = Vector3.ZERO
