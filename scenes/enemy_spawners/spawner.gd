class_name EnemySpawner extends Node3D

var roll_weight : float = 0.0
var acc_weight : float = 0.0
var total_weight : float = 0.0

@export var choices : Array[EnemySpawnChance]

const GHOST_ENEMY = preload("res://scenes/enemies/enemy_types/ghost_enemy.tscn")
const WITCH_ENEMY = preload("res://scenes/enemies/enemy_types/witch_enemy.tscn")

var enemy_instance : EnemyBase

func initialize_probabilities() -> void:
	# Iterate through the objects
	for choice in choices:
		# Take current object weight and accumulate it
		total_weight += choice.weight
		# Take current sum and assign to the object.
		choice.acc_weight = total_weight
	
	enemy_instance = pick_enemy()
	get_parent().add_child(enemy_instance)
	queue_free()

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
			break
