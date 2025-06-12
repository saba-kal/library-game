class_name EnemySpawner extends Node3D

var roll_weight: float = 0.0
var acc_weight: float = 0.0
var total_weight: float = 0.0

@export var choices: Array[EnemySpawnChance]
@export var wander_path: EnemyWanderPath

const GHOST_ENEMY = preload("res://scenes/enemies/enemy_types/ghost_enemy.tscn")
const WITCH_ENEMY = preload("res://scenes/enemies/enemy_types/witch_enemy.tscn")
const WEREWOLF_ENEMY = preload("res://scenes/enemies/enemy_types/werewolf_enemy.tscn")
var enemy_instance: EnemyBase

func _ready() -> void:
	var gizmo: Node3D = get_node_or_null("MeshInstance3D")
	if gizmo:
		gizmo.visible = false

func spawn_random_enemy() -> EnemyBase:
	self.rotation.y = 0
	# Iterate through the objects
	for choice in choices:
		# Take current object weight and accumulate it
		total_weight += choice.weight
		# Take current sum and assign to the object.
		choice.acc_weight = total_weight

	enemy_instance = pick_enemy()
	if wander_path:
		wander_path.add_child(enemy_instance)
	else:
		get_parent().add_child(enemy_instance)
	enemy_instance.rotation.y = 0
	enemy_instance.top_level = true
	enemy_instance.global_position = global_position
	return enemy_instance

func pick_enemy():
	# Roll the number
	var roll: float = randf_range(0.0, total_weight)
	# Now search for the first with acc_weight > roll
	for enemy in choices:
		if (enemy.acc_weight > roll):
			match enemy.name:
				"Witch":
					return WITCH_ENEMY.instantiate()
				"Ghost":
					return GHOST_ENEMY.instantiate()
				"Werewolf":
					return WEREWOLF_ENEMY.instantiate()
				_:
					print("not found: ", enemy.name)
			break
