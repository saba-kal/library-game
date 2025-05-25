extends State
class_name EnemyMeleeAttack

@export var damage:int = 1
@export var attack_size:PackedScene = null
var attack_instance:Area3D
var time_before_attack_hits:float = 1
var player_in_range:bool = false
var player:Player

func Enter():
	print("Entering: Melee Attack State")
	self.nav_agent.is_disabled = true
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
		player = body

func player_outside_range(body:Node3D):
	if body.is_in_group("player"):
		player_in_range = false
		player = null

func perform_attack():
	if player_in_range:
		player.take_damage(damage)
	else:
		print("Player wasn't in range of attack area.")
	attack_instance.queue_free()
	Transitioned.emit(self,"follow")

func Exit():
	self.nav_agent.is_disabled = false

func Update(_delta: float):
	pass

func Physics_Update(_delta: float):
	enemy.velocity = Vector3.ZERO
